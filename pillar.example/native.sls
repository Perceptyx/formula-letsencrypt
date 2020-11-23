# minimal pillar example to run tests
letsencrypt:
  use_native_packages: True
  certificates:
    - domains:
        - something.test.com
      webroot: False
  webroot_path: /var/www/letsencrypt
  check_port: 443
  config:
    email: monitoring@example.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    renew-by-default: 'True'
    agree-tos: 'True'
    no-self-upgrade: 'True'
    non-interactive: 'True'
