#!/bin/bash

# ==== PENNY ====
apt-get update
apt-get install -y apache2
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers

cat <<EOF > /etc/apache2/sites-available/penny.conf
<VirtualHost *:80>
    ServerName penny.k37.com
    ServerAlias www.k37.com k37.com

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

a2dissite 000-default.conf
a2ensite penny.conf
service apache2 restart


# ==== ABBEY ====
apt-get update
apt-get install -y nginx

cat <<EOF > /etc/nginx/sites-available/abbey
upstream core_backend {
    server 10.82.1.6:80;
    server 10.82.1.7:80;
}

server {
    listen 80;
    server_name abbey.k37.com static.k37.com;

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

ln -sf /etc/nginx/sites-available/abbey /etc/nginx/sites-enabled/abbey
rm -f /etc/nginx/sites-enabled/default
nginx -t && service nginx restart
