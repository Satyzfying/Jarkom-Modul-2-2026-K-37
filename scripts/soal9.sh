#!/bin/bash

# ==== OBLADI ====
# Bypass valid-until untuk Debian Security repo jika simulasi tahun 2026
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99insecure 2>/dev/null || true

apt-get update
apt-get install -y apache2

mkdir -p /var/www/vault/arsip
echo "<h1>Area Vault - Server Obladi</h1>" > /var/www/vault/index.html
echo "Arsip dokumen rahasia 1 - Obladi" > /var/www/vault/arsip/dokumen1.txt
echo "Laporan inventaris data statis K-37" > /var/www/vault/arsip/inventaris.pdf
chown -R www-data:www-data /var/www/vault
chmod -R 755 /var/www/vault

cat <<EOF > /etc/apache2/sites-available/vault.conf
<VirtualHost *:80>
    ServerName vault.k37.com
    ServerAlias obladi.k37.com desmond.k37.com penny.k37.com www.k37.com
    DocumentRoot /var/www/vault

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

a2enmod autoindex dir
a2dissite 000-default.conf
a2ensite vault.conf
service apache2 restart


# ==== DESMOND ====
# Bypass valid-until untuk Debian Security repo jika simulasi tahun 2026
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99insecure 2>/dev/null || true

apt-get update
apt-get install -y apache2

mkdir -p /var/www/vault/arsip
echo "<h1>Area Vault - Server Desmond</h1>" > /var/www/vault/index.html
echo "Arsip dokumen rahasia 2 - Desmond" > /var/www/vault/arsip/dokumen2.txt
echo "Laporan inventaris data statis K-37" > /var/www/vault/arsip/inventaris.pdf
chown -R www-data:www-data /var/www/vault
chmod -R 755 /var/www/vault

cat <<EOF > /etc/apache2/sites-available/vault.conf
<VirtualHost *:80>
    ServerName vault.k37.com
    ServerAlias obladi.k37.com desmond.k37.com penny.k37.com www.k37.com
    DocumentRoot /var/www/vault

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

a2enmod autoindex dir
a2dissite 000-default.conf
a2ensite vault.conf
service apache2 restart
