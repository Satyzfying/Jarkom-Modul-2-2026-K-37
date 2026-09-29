#!/bin/bash

# ==== OBLADI ====
apt-get update
apt-get install -y apache2

mkdir -p /var/www/vault/arsip
echo "Arsip dokumen rahasia 1 - Obladi" > /var/www/vault/arsip/dokumen1.txt
echo "Laporan inventaris data statis K-37" > /var/www/vault/arsip/inventaris.pdf
chown -R www-data:www-data /var/www/vault
chmod -R 755 /var/www/vault

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
apt-get update
apt-get install -y apache2

mkdir -p /var/www/vault/arsip
echo "Arsip dokumen rahasia 2 - Desmond" > /var/www/vault/arsip/dokumen2.txt
echo "Laporan inventaris data statis K-37" > /var/www/vault/arsip/inventaris.pdf
chown -R www-data:www-data /var/www/vault
chmod -R 755 /var/www/vault

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
