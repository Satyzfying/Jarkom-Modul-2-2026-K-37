#!/bin/bash
# ==============================================================================
# NOMOR 15: Jalur Proxy Khusus /eternal (PHP) pada Penny & /orion (Statis) pada Abbey
# - PENNY (Apache): Jalur /eternal menyajikan /var/www/eternal dengan rendering PHP via PHP-FPM
# - ABBEY (Nginx): Jalur /orion menyajikan /var/www/orion secara murni statis tanpa PHP
# ==============================================================================

# ==== PENNY ====
if [ -z "$1" ] || [ "$1" = "penny" ] || [ "$(hostname)" = "penny" ]; then
    echo "[*] Mengonfigurasi Jalur Proxy Khusus /eternal pada PENNY..."

    # 1. Pastikan apache2, php-fpm, dan modul proxy_fcgi terinstal & aktif
    apt-get update
    apt-get install -y apache2 php-fpm

    a2enmod rewrite proxy proxy_http proxy_balancer lbmethod_byrequests headers auth_basic authn_file authz_user proxy_fcgi

    # Pastikan service PHP-FPM aktif dan deteksi socket
    PHP_SERVICE=$(ls /etc/init.d/php*-fpm 2>/dev/null | head -n 1 | xargs -r basename)
    [ -n "$PHP_SERVICE" ] && service "$PHP_SERVICE" start
    PHP_SOCK=$(ls -1 /run/php/php*-fpm.sock 2>/dev/null | head -n 1)
    [ -z "$PHP_SOCK" ] && PHP_SOCK="/run/php/php8.2-fpm.sock"
    echo "[*] Socket PHP-FPM pada Penny: $PHP_SOCK"

    # 2. Buat direktori /var/www/eternal beserta file PHP
    mkdir -p /var/www/eternal

    cat <<'EOF' > /var/www/eternal/index.php
<!DOCTYPE html>
<html>
<head><title>Jalur Khusus Eternal - Penny</title></head>
<body>
    <h1>Jalur Khusus /eternal (Penny)</h1>
    <p>Status: <strong>Layanan Web Dinamis PHP-FPM Berhasil Dirender</strong></p>
    <p>PHP Version: <?php echo phpversion(); ?></p>
    <p>Waktu Server: <?php echo date('Y-m-d H:i:s'); ?></p>
    <p>File Path: <?php echo __FILE__; ?></p>
</body>
</html>
EOF

    chown -R www-data:www-data /var/www/eternal
    chmod -R 755 /var/www/eternal

    # 3. Konfigurasi VirtualHost Penny
    cat <<EOF > /etc/apache2/sites-available/penny.conf
# VirtualHost 1: Redirect 301 untuk IP 10.82.5.2 dan domain penny.k37.com
<VirtualHost *:80>
    ServerName penny.k37.com
    ServerAlias 10.82.5.2

    RewriteEngine On
    RewriteRule ^(.*)$ http://www.k37.com\$1 [R=301,L]

    ErrorLog \${APACHE_LOG_DIR}/penny_redirect_error.log
    CustomLog \${APACHE_LOG_DIR}/penny_redirect_access.log combined
</VirtualHost>

# VirtualHost 2: Host Kanonik www.k37.com
<VirtualHost *:80>
    ServerName www.k37.com
    ServerAlias k37.com

    DocumentRoot /var/www/penny

    # Proteksi Basic Auth /admin (Soal 12)
    ProxyPass /admin !
    Alias /admin /var/www/penny/admin

    <Directory /var/www/penny/admin>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        AuthType Basic
        AuthName "Dokumen Rahasia Sindikat"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Directory>

    <Location /admin>
        AuthType Basic
        AuthName "Dokumen Rahasia Sindikat"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Location>

    # Jalur Khusus /eternal: Menyajikan /var/www/eternal dengan PHP-FPM (Soal 15)
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

    # Balancer Cluster ke Area Vault (Soal 11)
    <Proxy balancer://vaultcluster>
        BalancerMember http://10.82.1.4:80
        BalancerMember http://10.82.1.5:80
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPreserveHost On
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/

    ErrorLog \${APACHE_LOG_DIR}/penny_error.log
    CustomLog \${APACHE_LOG_DIR}/penny_access.log combined
</VirtualHost>
EOF

    # 4. Validasi dan reload Apache2
    a2dissite 000-default.conf
    a2ensite penny.conf
    apache2ctl configtest && service apache2 restart

    echo "[OK] Konfigurasi Jalur /eternal pada PENNY selesai."
fi

# ==== ABBEY ====
if [ -z "$1" ] || [ "$1" = "abbey" ] || [ "$(hostname)" = "abbey" ]; then
    echo "[*] Mengonfigurasi Jalur Statis /orion pada ABBEY..."

    # 1. Buat direktori /var/www/orion dan file pengujian statis
    mkdir -p /var/www/orion

    cat <<'EOF' > /var/www/orion/index.html
<!DOCTYPE html>
<html>
<head><title>Jalur Khusus Orion - Abbey</title></head>
<body>
    <h1>Jalur Khusus /orion (Abbey)</h1>
    <p>Status: <strong>Layanan Murni Statis (Tanpa Rendering PHP)</strong></p>
</body>
</html>
EOF

    # File uji coba pembuktian PHP TIDAK dieksekusi (disajikan sebagai teks/mentah)
    echo '<?php echo "KODE PHP TIDAK DIRENDER - MURNI STATIS"; ?>' > /var/www/orion/test.php

    chown -R www-data:www-data /var/www/orion
    chmod -R 755 /var/www/orion

    # 2. Konfigurasi Server Block Nginx pada Abbey
    cat <<EOF > /etc/nginx/sites-available/abbey
upstream core_backend {
    server 10.82.1.6:80;
    server 10.82.1.7:80;
}

# Server Block 1: Redirect 302 Sementara (Soal 13)
server {
    listen 80 default_server;
    server_name abbey.k37.com 10.82.4.2;

    return 302 http://static.k37.com\$request_uri;
}

# Server Block 2: Host Kanonik static.k37.com
server {
    listen 80;
    server_name static.k37.com;

    # Jalur Khusus /orion: Murni Statis menyajikan /var/www/orion tanpa PHP (Soal 15)
    location /orion/ {
        alias /var/www/orion/;
        index index.html index.htm;
        default_type text/plain;
    }

    location = /orion {
        return 301 /orion/;
    }

    # Reverse proxy ke Area Core (Soal 11)
    location / {
        proxy_pass http://core_backend;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

    # 3. Validasi dan reload Nginx
    ln -sf /etc/nginx/sites-available/abbey /etc/nginx/sites-enabled/abbey
    rm -f /etc/nginx/sites-enabled/default
    nginx -t && service nginx restart

    echo "[OK] Konfigurasi Jalur /orion pada ABBEY selesai."
fi

# ==== PENGUJIAN DARI CLIENT (ALPHA / BETA / GAMMA / DELTA / EPSILON) ====
# 1. Pengujian Jalur /eternal pada Penny (Membuktikan PHP Berhasil Dirender):
#    curl -i http://www.k37.com/eternal/
#    curl -s http://www.k37.com/eternal/
#    (Output: Menampilkan versi PHP dan waktu server yang dirender oleh PHP-FPM)
#
# 2. Pengujian Jalur /orion pada Abbey (Membuktikan Konten Murni Statis):
#    curl -i http://static.k37.com/orion/
#    curl -s http://static.k37.com/orion/test.php
#    (Output: test.php menampilkan kode mentah <?php ... ?> membuktikan PHP TIDAK dirender)

