#!/bin/bash
# ==============================================================================
# NOMOR 14: Pencatatan IP Asli Klien pada Access Log Backend
# - Area Vault (Obladi 10.82.1.4 & Desmond 10.82.1.5 - Apache):
#   Mengaktifkan mod_remoteip untuk mencatat IP asli dari Penny (10.82.5.2)
# - Area Core (Oblada 10.82.1.6 & Molly 10.82.1.7 - Nginx):
#   Mengaktifkan set_real_ip_from & real_ip_header dari Abbey (10.82.4.2)
# ==============================================================================

# ==== OBLADI ====
if [ -z "$1" ] || [ "$1" = "obladi" ] || [ "$(hostname)" = "obladi" ]; then
    echo "[*] Mengonfigurasi Real IP Logging pada OBLADI (Apache)..."

    # 1. Aktifkan modul remoteip
    a2enmod remoteip

    # 2. Buat konfigurasi remoteip untuk mempercayai proxy Penny (10.82.5.2)
    cat <<EOF > /etc/apache2/conf-available/remoteip.conf
RemoteIPHeader X-Real-IP
RemoteIPInternalProxy 10.82.5.2
RemoteIPInternalProxy 10.82.0.0/16
EOF
    a2enconf remoteip

    # 3. Sesuaikan LogFormat agar menggunakan %a (alamat IP klien asli) bukan %h
    sed -i 's/%h %l %u %t/%a %l %u %t/' /etc/apache2/apache2.conf

    # 4. Update konfigurasi virtualhost vault.conf
    cat <<EOF > /etc/apache2/sites-available/vault.conf
<VirtualHost *:80>
    ServerName vault.k37.com
    ServerAlias obladi.k37.com desmond.k37.com
    DocumentRoot /var/www/vault

    RemoteIPHeader X-Real-IP
    RemoteIPInternalProxy 10.82.5.2
    RemoteIPInternalProxy 10.82.0.0/16

    <Directory /var/www/vault>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    <Directory /var/www/vault/arsip>
        Options +Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/vault_error.log
    CustomLog \${APACHE_LOG_DIR}/vault_access.log combined
</VirtualHost>
EOF

    # 5. Restart Apache2
    apache2ctl configtest && service apache2 restart
    echo "[OK] Konfigurasi Real IP Logging pada OBLADI selesai."
fi

# ==== DESMOND ====
if [ -z "$1" ] || [ "$1" = "desmond" ] || [ "$(hostname)" = "desmond" ]; then
    echo "[*] Mengonfigurasi Real IP Logging pada DESMOND (Apache)..."

    # 1. Aktifkan modul remoteip
    a2enmod remoteip

    # 2. Buat konfigurasi remoteip untuk mempercayai proxy Penny (10.82.5.2)
    cat <<EOF > /etc/apache2/conf-available/remoteip.conf
RemoteIPHeader X-Real-IP
RemoteIPInternalProxy 10.82.5.2
RemoteIPInternalProxy 10.82.0.0/16
EOF
    a2enconf remoteip

    # 3. Sesuaikan LogFormat agar menggunakan %a (alamat IP klien asli) bukan %h
    sed -i 's/%h %l %u %t/%a %l %u %t/' /etc/apache2/apache2.conf

    # 4. Update konfigurasi virtualhost vault.conf
    cat <<EOF > /etc/apache2/sites-available/vault.conf
<VirtualHost *:80>
    ServerName vault.k37.com
    ServerAlias desmond.k37.com obladi.k37.com
    DocumentRoot /var/www/vault

    RemoteIPHeader X-Real-IP
    RemoteIPInternalProxy 10.82.5.2
    RemoteIPInternalProxy 10.82.0.0/16

    <Directory /var/www/vault>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    <Directory /var/www/vault/arsip>
        Options +Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/vault_error.log
    CustomLog \${APACHE_LOG_DIR}/vault_access.log combined
</VirtualHost>
EOF

    # 5. Restart Apache2
    apache2ctl configtest && service apache2 restart
    echo "[OK] Konfigurasi Real IP Logging pada DESMOND selesai."
fi

# ==== OBLADA ====
if [ -z "$1" ] || [ "$1" = "oblada" ] || [ "$(hostname)" = "oblada" ]; then
    echo "[*] Mengonfigurasi Real IP Logging pada OBLADA (Nginx)..."

    PHP_SOCK=$(ls -1 /run/php/php*-fpm.sock 2>/dev/null | head -n 1)
    [ -z "$PHP_SOCK" ] && PHP_SOCK="/run/php/php8.2-fpm.sock"

    cat <<EOF > /etc/nginx/sites-available/core
server {
    listen 80;
    server_name core.k37.com oblada.k37.com molly.k37.com;

    root /var/www/core;
    index index.php index.html index.htm;

    # Konfigurasi Real IP dari Proxy Abbey (10.82.4.2)
    set_real_ip_from 10.82.4.2;
    set_real_ip_from 10.82.0.0/16;
    real_ip_header X-Real-IP;
    real_ip_recursive on;

    # Aturan rewrite /profil -> /profil.php
    rewrite ^/profil/?$ /profil.php last;

    location / {
        try_files \$uri \$uri/ \$uri.php?\$args =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_pass unix:$PHP_SOCK;
        fastcgi_index index.php;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    nginx -t && service nginx restart
    echo "[OK] Konfigurasi Real IP Logging pada OBLADA selesai."
fi

# ==== MOLLY ====
if [ -z "$1" ] || [ "$1" = "molly" ] || [ "$(hostname)" = "molly" ]; then
    echo "[*] Mengonfigurasi Real IP Logging pada MOLLY (Nginx)..."

    PHP_SOCK=$(ls -1 /run/php/php*-fpm.sock 2>/dev/null | head -n 1)
    [ -z "$PHP_SOCK" ] && PHP_SOCK="/run/php/php8.2-fpm.sock"

    cat <<EOF > /etc/nginx/sites-available/core
server {
    listen 80;
    server_name core.k37.com molly.k37.com oblada.k37.com;

    root /var/www/core;
    index index.php index.html index.htm;

    # Konfigurasi Real IP dari Proxy Abbey (10.82.4.2)
    set_real_ip_from 10.82.4.2;
    set_real_ip_from 10.82.0.0/16;
    real_ip_header X-Real-IP;
    real_ip_recursive on;

    # Aturan rewrite /profil -> /profil.php
    rewrite ^/profil/?$ /profil.php last;

    location / {
        try_files \$uri \$uri/ \$uri.php?\$args =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_pass unix:$PHP_SOCK;
        fastcgi_index index.php;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    nginx -t && service nginx restart
    echo "[OK] Konfigurasi Real IP Logging pada MOLLY selesai."
fi

# ==== PENGUJIAN DARI CLIENT (ALPHA / BETA / GAMMA / DELTA / EPSILON) ====
# 1. Dari client (misal Gamma 10.82.2.4), kirim request ke gerbang Penny dan Abbey:
#    curl -s http://www.k37.com/arsip/
#    curl -s http://static.k37.com/profil
#
# 2. Periksa access log di server backend:
#    - Di Obladi / Desmond (Apache):
#      tail -n 5 /var/log/apache2/vault_access.log
#      (Pastikan IP yang tercatat adalah 10.82.2.4, bukan 10.82.5.2)
#
#    - Di Oblada / Molly (Nginx):
#      tail -n 5 /var/log/nginx/access.log
#      (Pastikan IP yang tercatat adalah 10.82.2.4, bukan 10.82.4.2)

