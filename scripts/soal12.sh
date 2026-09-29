#!/bin/bash

# ==== PENNY ====
apt-get update
apt-get install -y apache2-utils

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

    ProxyPass /admin !
    Alias /admin /var/www/penny/admin

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
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/
</VirtualHost>
EOF

service apache2 restart
