# Formula: Letsencrypt
This formula installs Letsencrypt's Certbot.

# Usage
Using this formula is done in whatever formula certificates need to be
deployed - such as nginx, apache or similar.

Create an ssl.sls that does something similar to the following:

```
include:
  - letsencrypt

...
deploy http vhosts that rewrite everything except the letsencrypt
validation URL patterns to https. This is required for the --webroot
method of certbot to function properly!
...

nginx_ssl_{{ site_name }}:
  file.managed:
    - source: {{ ssl_vhost_source }}
    - require:
      - pkg: nginx
      - cmd: nginx_ssl_{{ site_name }}_issue
    - watch_in:
      - service: nginx

nginx_ssl_{{ site_name }}_issue:
  cmd.run:
    - name: >
             /opt/letsencrypt/bin/letsencrypt certonly --webroot
             -w {{ site_root }} -d {{ domain }} -d {{ alt_domain }}
    - creates: /etc/letsencrypt/live/{{ domain }}/fullchain.pem
    - require:
      - pip: letsencrypt

nginx_ssl_{{ site_name }}_renew:
  cron.present:
    - name: >
             /opt/letsencrypt/bin/letsencrypt certonly --webroot --renew
             -w {{ site_root }} -d {{ domain }} -d {{ alt_domain }}
    - identifier: renew-cert-for-{{ site_name }}
    - daymonth: 23
    - hour: 11
    - minute: 11
    - require:
      - cmd: nginx_ssl{{ site_name}}_issue

```
