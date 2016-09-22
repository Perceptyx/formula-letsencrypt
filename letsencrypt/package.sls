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
