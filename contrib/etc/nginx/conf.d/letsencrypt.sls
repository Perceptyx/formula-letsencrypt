location /.well-known {
    auth_basic off;
    allow all;
    index wedontneednoindex.html;
    root /var/www/letsencrypt;
}
