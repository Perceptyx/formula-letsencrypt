# minimal pillar example to run tests
letsencrypt:
  certificates:
    - domains:
        - something.test.com
      webroot: False
  webroot_path: /var/www/letsencrypt
  check_port: 443
  config:
    email: monitoring@example.com
    server: https://acme-staging.api.letsencrypt.org/directory
    renew-by-default: 'True'
    agree-tos: 'True'
    no-self-upgrade: 'True'
    non-interactive: 'True'
  crontab:
    minute: '*'
    hour: '0'
    daymonth: '1'
    month: '*/2'
    dayweek: '*'
