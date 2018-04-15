# Install required apt packages
{% if salt['grains.get']('os_family') == 'FreeBSD' %}
letsencrypt_packages:
  pkg.installed:
    - pkgs:
      - py27-pip
{% elif salt['grains.get']('os_family') == 'Debian' %}
letsencrypt_packages:
  pkg.installed:
    - pkgs:
      - libffi-dev
      - python-dev
      # We need python-pip to be able to use to pip.installed saltstack state module
      - python-pip
      # We need lsof to solve the chicken-egg problem when requesting the first certificate when there is no webserver yet
      - lsof
      # We need this package to install the pip package "certbot"
      - libssl-dev
{% endif %}

# Install virtualenv
letsencrypt_packages_pip_virtualenv:
  pip.installed:
    - name: virtualenv

# Install latest version of setuptools, pip install letsencrypt might fail otherwise
letsencrypt_packages_pip-setuptools:
  pip.installed:
    - name: setuptools
    - upgrade: True
    - ignore_installed: True
    - bin_env: /opt/letsencrypt
    - no_cache_dir: True
    - use_vt: True
    - require:
      - virtualenv: letsencrypt_packages_virtualenv_/opt/letsencrypt

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
      - pip: letsencrypt_packages_pip-setuptools
