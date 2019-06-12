{%- from "letsencrypt/map.jinja" import letsencrypt with context %}

##
## Install a cronjob that renews the letsencrypt certificates every two month
##

include:
  - letsencrypt.packages
  - letsencrypt.management

letsencrypt_cron_cronjob-directory:
  file.directory:
    - name: /etc/letsencrypt/saltstack/cronjobs/
    - user: root
    - group: {{ letsencrypt.group }}
    - mode: 700


# Iterate over the defined domains to request certificates for
{% for pack in letsencrypt['certificates'] %}

# Create a script for the cronjob
letsencrypt_cron_script_{{ pack['domains'][0] }}:
  file.managed:
    - name: /etc/letsencrypt/saltstack/cronjobs/{{ pack['domains'][0] }}.sh
    - source: salt://letsencrypt/files/cronjob.sh.jinja2
    - template: jinja
    - context:
        pack: {{ pack|tojson }}
        'webroot_path': {{ letsencrypt['webroot_path'] }}
    - mode: 500
    - user: root
    - root: root

# Create cronjobs to renew all present domains every 60 days at the first of the month at 0 hours { loop.index } minutes
letsencrypt_cron_job_{{ pack['domains'][0] }}:
  cron.present:
    - name: /etc/letsencrypt/saltstack/cronjobs/{{ pack['domains'][0] }}.sh > /dev/null 2>&1
    - identifier: Renew all letsencrypt certificates for {{ pack['domains'][0] }}
    - minute: '{{ letsencrypt.crontab.minute }}'
    - hour: '{{ letsencrypt.crontab.hour }}'
    - daymonth: '{{ letsencrypt.crontab.daymonth }}'
    - month: '{{ letsencrypt.crontab.month }}'
    - dayweek: '{{ letsencrypt.crontab.dayweek }}'
    - require:
      - pip: letsencrypt_packages_pip-package
      - cmd: letsencrypt_management_request-or-renew_{{ pack['domains'][0] }}

{% endfor %}
