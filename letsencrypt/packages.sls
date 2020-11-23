{%- from "letsencrypt/map.jinja" import letsencrypt with context %}

# Install required apt packages
{% if salt['grains.get']('os_family') == 'FreeBSD' %}
letsencrypt_packages:
  pkg.installed:
    - pkgs:
{% if salt['pillar.get']('letsencrypt:use_native_packages', False) == True %}
      - {{ letsencrypt.pkg }}
{% else %}
      - py37-pip
      - py37-virtualenv
{% endif %}

{% elif salt['grains.get']('os_family') == 'Debian' %}
letsencrypt_packages:
  pkg.installed:
    - pkgs:
{% if salt['pillar.get']('letsencrypt:use_native_packages', False) == True %}
      - {{ letsencrypt.pkg }}
{% else %}
      - libffi-dev
      - python3-dev
      # We need python3-pip to be able to use to pip.installed saltstack state module
      - python3-pip
      # We need this package to install the pip package "certbot"
      - libssl-dev
      # Use virtualenv package
      - python3-virtualenv
      - virtualenv
{% endif %}

{% endif %}

{% if salt['pillar.get']('letsencrypt:use_native_packages', False) == False %}
# Create a virtualenv for letsencrypt
letsencrypt_packages_virtualenv_/opt/letsencrypt:
  virtualenv.managed:
    - name: /opt/letsencrypt
    - python: python3

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

{% endif %}
