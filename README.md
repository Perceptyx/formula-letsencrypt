# Saltstack letsencrypt Formula



## Features

  - Installs Letsencrypt's Certbot as python pip package
  - Optionally detects if a webserver is running and decides between using --weebroot or --standalone
  - Can therefore be used on a machine that has no webserver yet but will have in the future without needing pillar changes
  - Creates a cronjob that renews all certificates every two month
  - Adds the ability to execute hook scripts (BASH commands) after renewal, like service nginx reload
  - Logs everything to /var/log/letsencrypt/letsencrypt.log
  - Is quite well documented



## Usage

This formula has an understanding for your webserver not being able to start with missing ssl certificates. Hence, if you do
everything with saltstack, use this formula as follows:

```
1) Copy pillar.example to /srv/pillar/letsencrypt.sls and edit it to your needs
2) salt 'web.example.com' state.apply letsencrypt
3) salt 'web.example.com' state.apply nginx
```

Some time later you may want to add further Subject Alternative Names in the pillars. After doing that, run:

```
1) salt 'web.example.com' state.apply letsencrypt
```

The formula will detect that you changed the amount of domains and will execute the certbot executuable to get the new domains.
It will also detect that nginx is currently running and the files are already present, so it will use --webroot and then
execute the defined hook script.



## Required preperations for usage with apache / nginx / a webserver

This formula will create the webroot directory for you. However you have to prepare your webserver to use include the letsencrypt
location .well-known/acme-challange by including the configurations shipped with this repository in the contrib directory.

```
root@www.example.com ~ # cat /etc/nginx/sites-enabled/www.example.com.conf
server {
    listen 80 default_server;
    server_name www.example.com _;
    # [...] more of your config here
    include /etc/nginx/conf.d/letsencrypt-renewal.conf
}
```

If you feel like nobody should see this, or you dont want to server an error in that location,
you can create `/var/www/letsencrypt/.well-known/index.html` with the following content:

```
<meta http-equiv="refresh" content="0; url=https://www.blunix.org/" />
```


## Contributions

Contributions, bug reports and pull requests are very welcome! Preferably file an issue with your idea first.



## Supported Operating Systems

This formula was developed and tested on debian 8 and ubuntu 14.04 Systems.



## Enterprise Support

Support for this Formula, letsencrypt and Saltstack is available at:

Blunix GmbH - Professional Linux Service

[www.blunix.org](https://www.blunix.org)

<mailto:service@blunix.org>
