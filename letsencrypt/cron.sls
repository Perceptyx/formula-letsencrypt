{% set letsencrypt = salt['pillar.get']('letsencrypt') %}

include:
  - letsencrypt.package


# Create a cronjob to renew all present domains every 60 days at the first of the month at 0:25 hours
# For the cronjob we assume that we have a webroot
letsencrypt_cronjob:
  cron.present:
    - name: /opt/letsencrypt/bin/letsencrypt {{ letsencrypt['arguments'] | join(' ') }} --webroot --renew {% for d in letsencrypt['domains'] %} -w {{ d['webroot'] }} -d '{{ d['names'] | join(',') }}'{% endfor %};{% for d in letsencrypt['domains'] %}{% if d.get('hook', False) %} {{ d['hook'] }};{% endif %}{% endfor %}
    - identifier: Renew all letsencrypt certificates
    - month: '1,3,5,7,9,11'
    - daymonth: 1
    - hour: 0
    - minute: 25
    - require:
      - pip: letsencrypt_pip-package
      - cmd: letsencrypt_initial-request_*
