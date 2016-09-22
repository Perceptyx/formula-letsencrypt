{% set letsencrypt = salt['pillar.get']('letsencrypt') %}

include:
  - letsencrypt.package
  - letsencrypt.management


# Iterate over the defined domains to request certificates for
{% for domain in letsencrypt['domains'] %}

# Create cronjobs to renew all present domains every 60 days at the first of the month
letsencrypt_cronjob_{{ domain['names'][0] }}:
  cron.present:
    # If webroot is not defined for this domain, we can use standalone
    {% if domain['webroot'] is defined %}
    - name: exec 2>&1; /opt/letsencrypt/bin/letsencrypt {{ letsencrypt['webroot_arguments'] | join(' ') }} --webroot -w {{ domain['webroot'] }} -d '{{ domain['names'] | join(',') }}' && {{ domain.get('hook', '') }}

    {% else %}
    - name: exec 2>&1; /opt/letsencrypt/bin/letsencrypt {{ letsencrypt['standalone_arguments'] | join(' ') }} -d '{{ domain['names'] | join(',')}}' && {{ domain.get('hook', '') }}

    {% endif %}
    - identifier: Renew all letsencrypt certificates for {{ domain['names'][0] }}
    - month: '1,3,5,7,9,11'
    - daymonth: 1
    - hour: 0
    # Dont run all jobs at the same minute, wait one minute in between each
    # If standalone is used, only one process can listen on the used port
    - minute: {{ loop.index }}
    - require:
      - pip: letsencrypt_pip-package
      - cmd: letsencrypt_initial-request_{{ domain['names'][0] }}

{% endfor %}
