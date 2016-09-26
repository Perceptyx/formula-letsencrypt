# Formula: Letsencrypt

This formula:
  - installs Letsencrypt's Certbot as python pip package
  - uses a webservers webroot instead of the temporary webserver (nginx default vhost example included)
  - takes care of initial creation of certificates if they have never been requested before
  - creates a cronjob that renews the certificates every two month
  - adds the ability to execute hook scripts (BASH commands) after renewal


# Usage

First prepare your webserver for letsencrypt. Modify your default vhost like follows:

```
root@example.com ~ # cat /etc/nginx/sites-enabled/default 
server {
    listen 80 default_server;
    server_name _;
 
    root /var/www/letsencrypt;
    index index.html;

    # Redirect everything to our default domain
    location / {
        return 301 https://www.blunix.org$request_uri;
    }

    # Letsencrypts location, refer to:
    location /.well-known {
        auth_basic off;
        allow all;
        index index.html;
        root /var/www/letsencrypt;
    }
}
```

If you feel like nobody should see this, or you dont want to server an error in that location,
you can create `/var/www/letsencrypt/.well-known/index.html` with the following content:

```
<meta http-equiv="refresh" content="0; url=https://www.blunix.org/" />
```

When this is done, just run:

```
salt 'webserver' state.sls letsencrypt
```

It will take care of the magic for you. Dont forget to add hooks in the pillar files if you need any.
