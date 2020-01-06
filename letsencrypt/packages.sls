# Install required apt packages
{% if salt['grains.get']('os_family') == 'FreeBSD' %}
letsencrypt_packages:
  pkg.installed:
    - pkgs:
      - py27-pip
      - py37-pip

# Install virtualenv
letsencrypt_packages_pip_virtualenv:
  pip.installed:
    - name: virtualenv
    - bin_env: '/usr/local/bin/pip-3.7'
    - require:
      - pkg: letsencrypt_packages
{% elif salt['grains.get']('os_family') == 'Debian' %}
letsencrypt_packages:
  pkg.installed:
    - pkgs:
      - libffi-dev
      - python3-dev
      # We need python3-pip to be able to use to pip.installed saltstack state module
      - python3-pip
      # We need lsof to solve the chicken-egg problem when requesting the first certificate when there is no webserver yet
      - lsof
      # We need this package to install the pip package "certbot"
      - libssl-dev

# Install virtualenv
letsencrypt_packages_pip_virtualenv:
  pip.installed:
    - name: virtualenv
{% endif %}

# Create a virtualenv for letsencrypt
letsencrypt_packages_virtualenv_/opt/letsencrypt:
  virtualenv.managed:
    - name: /opt/letsencrypt

# # Install latest version of setuptools, pip install letsencrypt might fail otherwise
letsencrypt_packages_pip-setuptools:
  pip.installed:
    - name: setuptools
    - upgrade: True
    - ignore_installed: True
    - bin_env: /opt/letsencrypt
    - no_cache_dir: True
    - require:
      - virtualenv: letsencrypt_packages_virtualenv_/opt/letsencrypt

# Install the python-pip package in the new virtualenv
letsencrypt_packages_pip-package:
  pip.installed:
    - name: letsencrypt
    - upgrade: True
    - ignore_installed: True
    - bin_env: /opt/letsencrypt
    - require:
      - virtualenv: letsencrypt_packages_virtualenv_/opt/letsencrypt
      - pip: letsencrypt_packages_pip-setuptools
