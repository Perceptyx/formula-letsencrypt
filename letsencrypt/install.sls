letsencrypt:
  pkg.installed:
    - pkgs:
      - python-cffi
  virtualenv.managed:
    - name: /opt/letsencrypt
  pip.installed:
    - bin_env: /opt/letsencrypt
    - require:
      - virtualenv: letsencrypt
