letsencrypt:
  pkg.installed:
    - pkgs:
      - libffi-dev
  virtualenv.managed:
    - name: /opt/letsencrypt
  pip.installed:
    - bin_env: /opt/letsencrypt
    - require:
      - virtualenv: letsencrypt
