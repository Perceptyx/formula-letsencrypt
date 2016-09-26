{% set letsencrypt = salt['pillar.get']('letsencrypt') %}

include:
  - letsencrypt.packages

# Create custom configs in directory just for saltstack
letsencrypt_management_config_saltstack-directory:
  file.directory:
    - name: /etc/letsencrypt/saltstack/changes
    - user: root
    - group: root
    - mode: 750
    - makedirs: True

{% if letsencrypt['webroot'] is defined %}
# Create the webroot for the webserver to use
letsencrypt_management_webroot-directory_{{ letsencrypt['webroot-path'] }}/.well-known:
  file.directory:
    - name: {{ letsencrypt['webroot-path'] }}/.well-known
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
{% endif %}


# Iterate over the "packs" with domains to request certificates for
{% for pack in letsencrypt['certificates'] %}

# Create a custom config file with the list of all domains and SANs plus some default options for certbot
letsencrypt_management_config_/etc/letsencrypt/saltstack/{{ pack['domains'][0] }}.conf:
  file.managed:
    - name: /etc/letsencrypt/saltstack/{{ pack['domains'][0] }}.conf
    - user: root
    - group: root
    - mode: 400
    - contents: |
        # This file is managed by Saltstack, DO NOT EDIT IT!
        domains = {{ pack['domains'] | join(', ') }}
        {%- for conf_key in letsencrypt['config'] %}
        {{ conf_key }} = {{ letsencrypt['config'][conf_key] }}
        {%- endfor -%}

{# Create a list of all domains in a file, so we can watch if the domains were updated compared to the previous run #}
letsencrypt_management_change-file_/etc/letsencrypt/saltstack/changes/{{ pack['domains'][0] }}:
  file.managed:
    - name: /etc/letsencrypt/saltstack/changes/{{ pack['domains'][0] }}
    - user: root
    - group: root
    - mode: 400
    - contents: |
        # This file is managed by Saltstack, DO NOT EDIT IT!
        {%- for domain in pack['domains'] %}
        {{ domain }}
        {%- endfor -%}


{#
# Check if there are already certs for this domain - if not, start initial creation
# There is no comfortable way in salt to check for multiple files as requirement for a cmd.run statement
# Also we dont want to renew all domains when we add one additional domain (as we can only request a specific
# domain for five times within a week or so
#}
letsencrypt_management_initial-request_{{ pack['domains'][0] }}:
  cmd.wait:
    - user: root
    - group: root
    - shell: /bin/bash

    # Solve the chicken - egg problem: if there is nothing running on port 80, using webroot can not work
    # lsof -i :{ letsencrypt['check_port'] } will return exit status 0 if sth is listening and != zero if not
    {% set check_port_status = salt['cmd.run']('lsof -i :' + letsencrypt['check_port'] | string + ' 2>&1 > /dev/null; echo $?') %}

    # Check the exit status of lsof - if its not 0, there is no service listening on { letsencrypt['check_port'] }
    # If the port is not used, we can always just use standalone to initial request / refresh on updates of domains.
    # If the port is in use, the only option is to use --webroot
    # If anything goes wrong, update the list of domains file so this state would run again on the next salt run.
    - name: |
        exec 2>&1
        {% if check_port_status != '0' %}
        /opt/letsencrypt/bin/letsencrypt certonly --standalone -c /etc/letsencrypt/saltstack/{{ pack['domains'][0] }}.conf || {
        {%- else -%}
        /opt/letsencrypt/bin/letsencrypt certonly --webroot -w {{ letsencrypt['webroot-path'] }} -c /etc/letsencrypt/saltstack/{{ pack['domains'][0] }}.conf || {
        {%- endif %}
          echo '# previous request unsuccessful' >> /etc/letsencrypt/saltstack/changes/{{ pack['domains'][0] }} && exit 1
        }; {{ pack.get('hook', '') }}


    # We want this command to run, if:
    #   - The certfificate has never been requested before (/etc/letsencrypt/saltstack/{{ pack['domains'][0] }} would not exist)
    #   - The SANs are updated (/etc/letsencrypt/saltstack/{{ pack['domains'][0] }}.conf would be updated too)
    #   - The previous request failed (echo '# previous request unsuccessful' >> .conf would be executed)
    - watch:
      - file: letsencrypt_management_change-file_/etc/letsencrypt/saltstack/changes/{{ pack['domains'][0] }}

    - require:
      - pip: letsencrypt_packages_pip-package

{% endfor %}
