#!/bin/bash
# ==============================================================================
# NOMOR 9: Web Statis Apache & Autoindex Direktori /arsip/ pada Area Vault
# Node Area Vault: obladi (10.82.1.4) & desmond (10.82.1.5)
# Hostname: vault.k37.com, obladi.k37.com, desmond.k37.com
# ==============================================================================

# ==== OBLADI ====
if [ -z "$1" ] || [ "$1" = "obladi" ] || [ "$(hostname)" = "obladi" ]; then
    echo "[*] Mengonfigurasi Apache pada node OBLADI..."

    # 1. Update dan instalasi Apache2
    apt-get update
    apt-get install -y apache2

    # 2. Siapkan direktori DocumentRoot dan folder /arsip/
    mkdir -p /var/www/vault/arsip

    # Halaman utama root vault
    cat <<EOF > /var/www/vault/index.html
<!DOCTYPE html>
<html>
<head><title>Vault - Obladi</title></head>
<body>
    <h1>Area Vault - Server Obladi</h1>
    <p>Layanan Web Statis K37</p>
    <p><a href="/arsip/">Masuk ke Direktori Arsip</a></p>
</body>
</html>
EOF

    # File-file contoh di dalam folder /arsip/ untuk pembuktian autoindex
    echo "Arsip dokumen rahasia 1 - Area Vault (Obladi)" > /var/www/vault/arsip/dokumen1.txt
    echo "Laporan inventaris data statis K-37" > /var/www/vault/arsip/inventaris.pdf
    echo "Backup data konfigurasi vault" > /var/www/vault/arsip/vault_backup.tar.gz

    # Pastikan hak akses file dan folder
    chown -R www-data:www-data /var/www/vault
    chmod -R 755 /var/www/vault

    # 3. Konfigurasi VirtualHost Apache untuk hostname vault.k37.com & obladi.k37.com
    cat <<EOF > /etc/apache2/sites-available/vault.conf
<VirtualHost *:80>
    ServerName vault.k37.com
    ServerAlias obladi.k37.com desmond.k37.com
    DocumentRoot /var/www/vault

    <Directory /var/www/vault>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    # Direktori /arsip/ dengan fitur autoindex (directory listing) aktif
    <Directory /var/www/vault/arsip>
        Options +Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/vault_error.log
    CustomLog \${APACHE_LOG_DIR}/vault_access.log combined
</VirtualHost>
EOF

    # 4. Aktifkan modul autoindex, aktifkan site, dan restart service apache2
    a2enmod autoindex
    a2enmod dir
    a2dissite 000-default.conf
    a2ensite vault.conf
    service apache2 restart

    echo "[OK] Konfigurasi Apache pada OBLADI selesai."
fi

# ==== DESMOND ====
if [ -z "$1" ] || [ "$1" = "desmond" ] || [ "$(hostname)" = "desmond" ]; then
    echo "[*] Mengonfigurasi Apache pada node DESMOND..."

    # 1. Update dan instalasi Apache2
    apt-get update
    apt-get install -y apache2

    # 2. Siapkan direktori DocumentRoot dan folder /arsip/
    mkdir -p /var/www/vault/arsip

    # Halaman utama root vault
    cat <<EOF > /var/www/vault/index.html
<!DOCTYPE html>
<html>
<head><title>Vault - Desmond</title></head>
<body>
    <h1>Area Vault - Server Desmond</h1>
    <p>Layanan Web Statis K37</p>
    <p><a href="/arsip/">Masuk ke Direktori Arsip</a></p>
</body>
</html>
EOF

    # File-file contoh di dalam folder /arsip/ untuk pembuktian autoindex
    echo "Arsip dokumen rahasia 1 - Area Vault (Desmond)" > /var/www/vault/arsip/dokumen1.txt
    echo "Laporan inventaris data statis K-37" > /var/www/vault/arsip/inventaris.pdf
    echo "Backup data konfigurasi vault" > /var/www/vault/arsip/vault_backup.tar.gz

    # Pastikan hak akses file dan folder
    chown -R www-data:www-data /var/www/vault
    chmod -R 755 /var/www/vault

    # 3. Konfigurasi VirtualHost Apache untuk hostname vault.k37.com & desmond.k37.com
    cat <<EOF > /etc/apache2/sites-available/vault.conf
<VirtualHost *:80>
    ServerName vault.k37.com
    ServerAlias desmond.k37.com obladi.k37.com
    DocumentRoot /var/www/vault

    <Directory /var/www/vault>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    # Direktori /arsip/ dengan fitur autoindex (directory listing) aktif
    <Directory /var/www/vault/arsip>
        Options +Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/vault_error.log
    CustomLog \${APACHE_LOG_DIR}/vault_access.log combined
</VirtualHost>
EOF

    # 4. Aktifkan modul autoindex, aktifkan site, dan restart service apache2
    a2enmod autoindex
    a2enmod dir
    a2dissite 000-default.conf
    a2ensite vault.conf
    service apache2 restart

    echo "[OK] Konfigurasi Apache pada DESMOND selesai."
fi

# ==== PENGUJIAN DARI CLIENT (ALPHA / BETA / GAMMA / DELTA / EPSILON) ====
# Perintah pengujian dijalankan dari sisi host klien menggunakan hostname:
#
# 1. Pastikan DNS resolver mengarah ke prab dan tedd:
#    cat /etc/resolv.conf
#
# 2. Pengujian akses HTTP ke direktori /arsip/ menggunakan hostname vault.k37.com:
#    curl -i http://vault.k37.com/arsip/
#    curl -s http://vault.k37.com/arsip/
#
# 3. Pengujian akses HTTP ke masing-masing node spesifik menggunakan hostname:
#    curl -i http://obladi.k37.com/arsip/
#    curl -i http://desmond.k37.com/arsip/

