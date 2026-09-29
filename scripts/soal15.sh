#!/bin/bash

# ==== PENNY ====
apt-get update
apt-get install -y php-fpm
a2enmod proxy_fcgi

service php8.2-fpm start 2>/dev/null || service php-fpm start 2>/dev/null
PHP_SOCK=$(ls -1 /run/php/php*-fpm.sock 2>/dev/null | head -n 1)
[ -z "$PHP_SOCK" ] && PHP_SOCK="/run/php/php8.2-fpm.sock"

mkdir -p /var/www/eternal
cat <<'EOF' > /var/www/eternal/index.php
<!DOCTYPE html>
<html>
<head><title>Jalur Eternal</title></head>
<body>
    <h1>Jalur Khusus /eternal (Penny)</h1>
    <p>Status: Layanan PHP-FPM Berhasil Dirender</p>
    <p>PHP Version: <?php echo phpversion(); ?></p>
</body>
</html>
EOF
chown -R www-data:www-data /var/www/eternal
chmod -R 755 /var/www/eternal

cat <<EOF > /etc/apache2/sites-available/penny.conf
<VirtualHost *:80>
    ServerName penny.k37.com
    ServerAlias 10.82.5.2

    RewriteEngine On
    RewriteRule ^(.*)$ http://www.k37.com\$1 [R=301,L]
</VirtualHost>

<VirtualHost *:80>
    ServerName www.k37.com
    ServerAlias k37.com
    DocumentRoot /var/www/penny

    ProxyPass /admin !
    Alias /admin /var/www/penny/admin

    <Location /admin>
        AuthType Basic
        AuthName "Dokumen Rahasia Sindikat"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Location>

    ProxyPass /eternal !
    Alias /eternal /var/www/eternal
    <Directory /var/www/eternal>
        Options +Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
        DirectoryIndex index.php index.html
        <FilesMatch "\.php$">
            SetHandler "proxy:unix:$PHP_SOCK|fcgi://localhost"
        </FilesMatch>
    </Directory>

    <Proxy balancer://vaultcluster>
        BalancerMember http://10.82.1.4:80
        BalancerMember http://10.82.1.5:80
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPreserveHost On
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"
    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/
</VirtualHost>
EOF

service apache2 restart


# ==== ABBEY ====
mkdir -p /var/www/orion
echo "<h1>Jalur Orion Statis</h1>" > /var/www/orion/index.html
echo '<?php echo "KODE PHP TIDAK DIRENDER - MURNI STATIS"; ?>' > /var/www/orion/test.php
chown -R www-data:www-data /var/www/orion
chmod -R 755 /var/www/orion

cat <<EOF > /etc/nginx/sites-available/abbey
upstream core_backend {
    server 10.82.1.6:80;
    server 10.82.1.7:80;
}

server {
    listen 80 default_server;
    server_name abbey.k37.com 10.82.4.2;
    return 302 http://static.k37.com\$request_uri;
}

server {
    listen 80;
    server_name static.k37.com;

    location /orion/ {
        alias /var/www/orion/;
        index index.html index.htm;
        default_type text/plain;
    }

    location = /orion {
        return 301 /orion/;
    }

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

nginx -t && service nginx restart
