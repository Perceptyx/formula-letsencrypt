# This formula installs letsencrypt as python pip package instead of git cloning the certbot repositoy
{% set letsencrypt = salt['pillar.get']('letsencrypt') %}


# Install required apt packages
letsencrypt_packages:
  pkg.installed:
    - pkgs:
      - libffi-dev
      - python-pip

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

# Create the dir for the config file (before the first ever run of letsencrypt, its not present)
letsencrypt_config_directory:
  file.directory:
    - name: /etc/letsencrypt
    - user: root
    - group: root
    - mode: 750

# Create the config file
letsencrypt_config:
  file.managed:
    - name: /etc/letsencrypt/cli.ini
    - source: salt://letsencrypt/files/cli.ini.jinja2
    - template: jinja
    - context:
        config: {{ letsencrypt['config'] }}
    - user: root
    - group: root
    - mode: 640


# Iterate over the defined domains to obtain certificates for
{% for domain in letsencrypt['domains'] %}

# Check if there are already certs for this domain - if not, start initial creation
# There is no comfortable way in salt to check for multiple files as requirement for a cmd.run statement
# Also we dont want to renew all domains when we add one additional domain (as we can only request a specific
# domain for five times within a week or so
letsencrypt_initial-obtain_{{ domain['name'] }}:
  cmd.run:
    - name: /opt/letsencrypt/bin/letsencrypt certonly --webroot -w {{ letsencrypt['config']['webroot-path'] }} -d {{ domain['name'] }}; {{ domain.get('hook', '') }}
    - creates: /etc/letsencrypt/live/{{ domain['name'] }}/fullchain.pem
    - require:
      - pip: letsencrypt_pip-package

{% endfor %}


# Create a cronjob to renew all present domains every 60 days at the first of the month at 0:25 hours
letsencrypt_cronjob:
  cron.present:
    - name: /opt/letsencrypt/bin/letsencrypt certonly --webroot --renew -w {{ letsencrypt['config']['webroot-path'] }}{% for d in letsencrypt['domains'] %} -d {{ d['name'] }}{% endfor %};{% for d in letsencrypt['domains'] %}{% if d.get('hook', False) %} {{ d['hook'] }};{% endif %}{% endfor %}
    - identifier: Renew all letsencrypt certificates
    - month: '1,3,5,7,9,11'
    - daymonth: 1
    - hour: 0
    - minute: 25
