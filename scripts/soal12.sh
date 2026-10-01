#!/bin/bash

# ==== PENNY ====
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99insecure 2>/dev/null || true
sed -i '/security/s/^/#/' /etc/apt/sources.list 2>/dev/null || true
apt-get update
apt-get install -y apache2-utils
a2enmod auth_basic authn_file authz_user

mkdir -p /var/www/penny/admin
cat <<'EOF' > /var/www/penny/admin/index.html
<!DOCTYPE html>
<html>
<head><title>Dokumen Rahasia</title></head>
<body>
    <h1>Ruang Khusus Sindikat - Penny</h1>
    <p>Selamat datang, Agen <strong>prabs</strong>!</p>
</body>
</html>
EOF
chown -R www-data:www-data /var/www/penny
chmod -R 755 /var/www/penny

htpasswd -bc /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'
chmod 640 /etc/apache2/.htpasswd
chown root:www-data /etc/apache2/.htpasswd

cat <<EOF > /etc/apache2/sites-available/penny.conf
<VirtualHost *:80>
    ServerName penny.k37.com
    ServerAlias www.k37.com k37.com

    DocumentRoot /var/www/penny

    # Pengecualian path /admin dari reverse proxy
    ProxyPass /admin !
    Alias /admin /var/www/penny/admin

    <Directory /var/www/penny/admin>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require valid-user
        DirectoryIndex index.html
    </Directory>

    <Location /admin>
        AuthType Basic
        AuthName "Dokumen Rahasia Sindikat"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Location>

    <Proxy balancer://vaultcluster>
        BalancerMember http://10.82.1.4:80
        BalancerMember http://10.82.1.5:80
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPreserveHost On
    RequestHeader set X-Real-IP "expr=%{REMOTE_ADDR}"

    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/

    ErrorLog \${APACHE_LOG_DIR}/penny_error.log
    CustomLog \${APACHE_LOG_DIR}/penny_access.log combined
</VirtualHost>
EOF

service apache2 restart

# ==== PENGUJIAN DARI CLIENT (misal: gamma) ====
# 1. Tanpa kredensial (HTTP 401 Unauthorized):
#    curl -i http://penny.k37.com/admin/
#
# 2. Password salah (HTTP 401 Unauthorized):
#    curl -i -u "prabs:passwordsalah" http://penny.k37.com/admin/
#
# 3. Kredensial benar (HTTP 200 OK):
#    curl -i -u "prabs:pakar_pinter_jadi_gob***" http://penny.k37.com/admin/

