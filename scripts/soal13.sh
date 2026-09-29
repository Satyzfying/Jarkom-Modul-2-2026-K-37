#!/bin/bash
# ==============================================================================
# NOMOR 13: Redirection Kanonik pada Penny (301) dan Abbey (302)
# - PENNY (Apache): Akses IP 10.82.5.2 & domain penny.k37.com -> Redirect 301 ke www.k37.com
# - ABBEY (Nginx): Akses IP 10.82.4.2 & domain abbey.k37.com -> Redirect 302 ke static.k37.com
# ==============================================================================

# ==== PENNY ====
if [ -z "$1" ] || [ "$1" = "penny" ] || [ "$(hostname)" = "penny" ]; then
    echo "[*] Mengonfigurasi Redirection 301 pada PENNY..."

    # 1. Pastikan modul rewrite dan proxy aktif
    a2enmod rewrite proxy proxy_http proxy_balancer lbmethod_byrequests headers auth_basic authn_file authz_user

    # 2. Konfigurasi VirtualHost Penny
    cat <<EOF > /etc/apache2/sites-available/penny.conf
# VirtualHost 1: Menangani IP 10.82.5.2 dan domain penny.k37.com -> Redirect 301 Permanen
<VirtualHost *:80>
    ServerName penny.k37.com
    ServerAlias 10.82.5.2

    RewriteEngine On
    RewriteRule ^(.*)$ http://www.k37.com\$1 [R=301,L]

    ErrorLog \${APACHE_LOG_DIR}/penny_redirect_error.log
    CustomLog \${APACHE_LOG_DIR}/penny_redirect_access.log combined
</VirtualHost>

# VirtualHost 2: Host Kanonik www.k37.com (Reverse Proxy & Basic Auth)
<VirtualHost *:80>
    ServerName www.k37.com
    ServerAlias k37.com

    DocumentRoot /var/www/penny

    # Proteksi Basic Auth untuk /admin (Soal 12)
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

    # Balancer cluster ke Area Vault (Soal 11)
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

    # 3. Validasi konfigurasi dan restart Apache
    a2dissite 000-default.conf
    a2ensite penny.conf
    apache2ctl configtest && service apache2 restart

    echo "[OK] Konfigurasi Redirection 301 pada PENNY selesai."
fi

# ==== ABBEY ====
if [ -z "$1" ] || [ "$1" = "abbey" ] || [ "$(hostname)" = "abbey" ]; then
    echo "[*] Mengonfigurasi Redirection 302 pada ABBEY..."

    # 1. Konfigurasi Server Block Nginx pada Abbey
    cat <<EOF > /etc/nginx/sites-available/abbey
upstream core_backend {
    server 10.82.1.6:80;
    server 10.82.1.7:80;
}

# Server Block 1: Menangani IP 10.82.4.2 dan domain abbey.k37.com -> Redirect 302 Sementara
server {
    listen 80 default_server;
    server_name abbey.k37.com 10.82.4.2;

    return 302 http://static.k37.com\$request_uri;
}

# Server Block 2: Host Kanonik static.k37.com (Reverse Proxy ke Area Core)
server {
    listen 80;
    server_name static.k37.com;

    location / {
        proxy_pass http://core_backend;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

    # 2. Validasi dan reload Nginx
    ln -sf /etc/nginx/sites-available/abbey /etc/nginx/sites-enabled/abbey
    rm -f /etc/nginx/sites-enabled/default
    nginx -t && service nginx restart

    echo "[OK] Konfigurasi Redirection 302 pada ABBEY selesai."
fi

# ==== PENGUJIAN DARI CLIENT (ALPHA / BETA / GAMMA / DELTA / EPSILON) ====
# Perintah pengujian redirection dijalankan dari sisi host klien:
#
# 1. Pengujian Redirection 301 pada Penny:
#    a. Akses melalui domain penny.k37.com (harus 301 ke www.k37.com):
#       curl -i http://penny.k37.com/
#
#    b. Akses melalui IP Penny 10.82.5.2 (harus 301 ke www.k37.com):
#       curl -i http://10.82.5.2/
#
# 2. Pengujian Redirection 302 pada Abbey:
#    a. Akses melalui domain abbey.k37.com (harus 302 ke static.k37.com):
#       curl -i http://abbey.k37.com/
#
#    b. Akses melalui IP Abbey 10.82.4.2 (harus 302 ke static.k37.com):
#       curl -i http://10.82.4.2/
#
# 3. Pengujian Follow Redirect (-L) memastikan halaman kanonik terakses sempurna:
#    curl -L http://penny.k37.com/
#    curl -L http://abbey.k37.com/profil

