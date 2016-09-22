# This formula installs letsencrypt as python pip package instead of git cloning the certbot repositoy
{% set letsencrypt = salt['pillar.get']('letsencrypt') %}


# Install required apt packages
letsencrypt_packages:
  pkg.installed:
    - pkgs:
      - libffi-dev
      # We need python-pip to be able to use to pip.installed saltstack state module
      - python-pip
      # We need lsof to solve the chicken-egg problem (see below) (todo: or use netstat, which is installed everywhere by default)
      - lsof

# Create a virtualenv for letsencrypt
letsencrypt_virtualenv_/opt/letsencrypt:
  virtualenv.managed:
    - name: /opt/letsencrypt

# Install the python-pip package in the new virtualenv
letsencrypt_pip-package:
  pip.installed:
    - name: letsencrypt
    - bin_env: /opt/letsencrypt
    - require:
      - virtualenv: letsencrypt_virtualenv_/opt/letsencrypt


# Iterate over the defined domains to obtain certificates for
{% for domain in letsencrypt['domains'] %}

# Check if there are already certs for this domain - if not, start initial creation
# There is no comfortable way in salt to check for multiple files as requirement for a cmd.run statement
# Also we dont want to renew all domains when we add one additional domain (as we can only request a specific
# domain for five times within a week or so
letsencrypt_initial-obtain_{{ domain['name'] }}:
  cmd.run:
    # Solve the chicken - egg problem: if there is nothing running on port 80, using webroot can not work
    # lsof -i :80 will return exit status 0 if sth is listening and != zero if not
    {% set port_80_status = salt['cmd.run']('lsof -i :80 2>&1 > /dev/null; echo $?') %}
    {% if port_80_status != '0' %}
    - name: /opt/letsencrypt/bin/letsencrypt certonly {{ letsencrypt['arguments'] | join(' ') }} --standalone -d {{ domain['name'] }}; {{ domain.get('hook', '') }}

    {% else %}
    - name: /opt/letsencrypt/bin/letsencrypt {{ letsencrypt['arguments'] | join(' ') }} --webroot -w {{ domain['webroot'] }} -d {{ domain['name'] }}; {{ domain.get('hook', '') }}

    {% endif %}
    - creates: /etc/letsencrypt/live/{{ domain['name'] }}/fullchain.pem
    - require:
      - pip: letsencrypt_pip-package

{% endfor %}


# Create a cronjob to renew all present domains every 60 days at the first of the month at 0:25 hours
# For the cronjob we assume that we have a webroot
letsencrypt_cronjob:
  cron.present:
    - name: /opt/letsencrypt/bin/letsencrypt {{ letsencrypt['arguments'] | join(' ') }} --webroot --renew {% for d in letsencrypt['domains'] %} -w {{ d['webroot'] }} -d {{ d['name'] }}{% endfor %};{% for d in letsencrypt['domains'] %}{% if d.get('hook', False) %} {{ d['hook'] }};{% endif %}{% endfor %}
    - identifier: Renew all letsencrypt certificates
    - month: '1,3,5,7,9,11'
    - daymonth: 1
    - hour: 0
    - minute: 25
