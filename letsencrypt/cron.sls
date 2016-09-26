##
## Install a cronjob that renews the letsencrypt certificates every two month
##

include:
  - letsencrypt.packages
  - letsencrypt.management

{% set letsencrypt = salt['pillar.get']('letsencrypt') %}


# Iterate over the defined domains to request certificates for
{% for pack in letsencrypt['certificates'] %}

# Create cronjobs to renew all present domains every 60 days at the first of the month at 0 hours { loop.index } minutes
letsencrypt_cron_{{ pack['domains'][0] }}:
  cron.present:

    # Check if this pack has a webroot set to True - if so, use the defined webroot for letsencrypt, otherwise use standalone
    {% if pack.get('webroot', False) %}
    - name: "/opt/letsencrypt/bin/letsencrypt certonly --webroot -w {{ letsencrypt['webroot-path'] }} -c /etc/letsencrypt/saltstack/{{ pack['domains'][0] }}.conf >> /var/log/letsencrypt/letsencrypt.log 2>&1 && {{ pack.get('hook', 'exit $?') }} >> /var/log/letsencrypt/letsencrypt.log 2>&1"

    # If webroot is set to False for this pack, use standalone
    {% else %}
    - name: "/opt/letsencrypt/bin/letsencrypt certonly --standalone -c /etc/letsencrypt/saltstack/{{ pack['domains'][0] }}.conf >> /var/log/letsencrypt/letsencrypt.log 2>&1 && {{ pack.get('hook', 'exit $?') }} >> /var/log/letsencrypt/letsencrypt.log 2>&1"

    {% endif %}

    - identifier: Renew all letsencrypt certificates for {{ pack['domains'][0] }}
    - month: '1,3,5,7,9,11'
    - daymonth: 1
    - hour: 0
    # Dont run all jobs at the same minute, wait one minute in between each
    # If standalone is used, only one process can listen on the used port
    - minute: {{ loop.index }}
    - require:
      - pip: letsencrypt_packages_pip-package
      - cmd: letsencrypt_management_initial-request_{{ pack['domains'][0] }}

{% endfor %}
