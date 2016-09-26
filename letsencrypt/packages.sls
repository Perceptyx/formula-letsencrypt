# Install required apt packages
letsencrypt_packages_apt:
  pkg.installed:
    - pkgs:
      - libffi-dev
      # We need python-pip to be able to use to pip.installed saltstack state module
      - python-pip
      # We need lsof to solve the chicken-egg problem when requesting the first certificate when there is no webserver yet
      - lsof
      # We need this package to install the pip package "certbot"
      - libssl-dev

# Create a virtualenv for letsencrypt
letsencrypt_packages_virtualenv_/opt/letsencrypt:
  virtualenv.managed:
    - name: /opt/letsencrypt

# Install the python-pip package in the new virtualenv
letsencrypt_packages_pip-package:
  pip.installed:
    - name: letsencrypt
    - bin_env: /opt/letsencrypt
    - require:
      - virtualenv: letsencrypt_packages_virtualenv_/opt/letsencrypt
