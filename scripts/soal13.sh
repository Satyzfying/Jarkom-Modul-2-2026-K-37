#!/bin/bash

# ==== PENNY ====
a2enmod rewrite

cat <<EOF > /etc/apache2/sites-available/penny.conf
<VirtualHost *:80>
    ServerName penny.k37.com
    ServerAlias 10.82.5.2

    RewriteEngine On
    RewriteRule ^(.*)$ http://www.k37.com\$1 [R=301,L]
</VirtualHost>

<VirtualHost *:80>
    ServerName www.k37.com
    ServerAlias k37.com
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
    RequestHeader set X-Real-IP "expr=%{REMOTE_ADDR}"
    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/
</VirtualHost>
EOF

service apache2 restart


# ==== ABBEY ====
cat <<EOF > /etc/nginx/sites-available/abbey
upstream core_backend {
    server 10.82.1.6:80;
    server 10.82.1.7:80;
}

server {
    listen 80 default_server;
    server_name abbey.k37.com 10.82.4.2;
    return 302 http://static.k37.com\$request_uri;
}

server {
    listen 80;
    server_name static.k37.com;

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

nginx -t && service nginx restart
