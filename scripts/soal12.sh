#!/bin/bash
# ==============================================================================
# NOMOR 12: Basic Authentication untuk Path /admin pada Penny
# Node: penny (10.82.5.2)
# Hostname: penny.k37.com, www.k37.com
# Username: prabs
# Password: pakar_pinter_jadi_gob***
# ==============================================================================

# ==== PENNY ====
if [ -z "$1" ] || [ "$1" = "penny" ] || [ "$(hostname)" = "penny" ]; then
    echo "[*] Mengonfigurasi Basic Authentication /admin pada PENNY..."

    # 1. Pastikan paket apache2 dan apache2-utils terinstal
    apt-get update
    apt-get install -y apache2 apache2-utils

    # 2. Buat direktori dokumen rahasia /admin pada Penny
    mkdir -p /var/www/penny/admin

    cat <<'EOF' > /var/www/penny/admin/index.html
<!DOCTYPE html>
<html>
<head><title>Dokumen Rahasia Sindikat</title></head>
<body>
    <h1>Ruang Khusus Sindikat - Penny</h1>
    <p>Selamat datang, Agen <strong>prabs</strong>!</p>
    <p>Dokumen Rahasia Negara The Mesh berhasil diakses.</p>
</body>
</html>
EOF

    # Atur permission
    chown -R www-data:www-data /var/www/penny
    chmod -R 755 /var/www/penny

    # 3. Buat file .htpasswd berisi kredensial username prabs
    # Password: pakar_pinter_jadi_gob***
    htpasswd -bc /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'
    chmod 640 /etc/apache2/.htpasswd
    chown root:www-data /etc/apache2/.htpasswd

    # 4. Aktifkan modul autentikasi dasar Apache
    a2enmod auth_basic
    a2enmod authn_file
    a2enmod authz_user

    # 5. Konfigurasi VirtualHost Penny dengan proteksi Basic Auth pada /admin
    # dan ProxyPass ke Area Vault untuk path lainnya
    cat <<EOF > /etc/apache2/sites-available/penny.conf
<VirtualHost *:80>
    ServerName penny.k37.com
    ServerAlias www.k37.com k37.com

    DocumentRoot /var/www/penny

    # Pengecualian agar /admin ditangani lokal oleh Penny (tidak dilempar ke proxy)
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

    # Balancer cluster ke Area Vault (Obladi & Desmond)
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

    # 6. Validasi konfigurasi dan restart Apache2
    a2dissite 000-default.conf
    a2ensite penny.conf
    apache2ctl configtest && service apache2 restart

    echo "[OK] Konfigurasi Basic Authentication pada PENNY selesai."
fi

# ==== PENGUJIAN DARI CLIENT (ALPHA / BETA / GAMMA / DELTA / EPSILON) ====
# Perintah pengujian dijalankan dari sisi host klien:
#
# 1. Uji akses tanpa kredensial (Harus ditolak: HTTP 401 Unauthorized):
#    curl -i http://penny.k37.com/admin
#
# 2. Uji akses dengan password salah (Harus ditolak: HTTP 401 Unauthorized):
#    curl -i -u prabs:passwordsalah http://penny.k37.com/admin
#
# 3. Uji akses dengan kredensial yang benar (Harus berhasil: HTTP 200 OK):
#    curl -i -u prabs:pakar_pinter_jadi_gob*** http://penny.k37.com/admin
#    curl -s -u prabs:pakar_pinter_jadi_gob*** http://penny.k37.com/admin
#
# 4. Uji via CNAME www.k37.com:
#    curl -i -u prabs:pakar_pinter_jadi_gob*** http://www.k37.com/admin

