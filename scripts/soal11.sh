#!/bin/bash

# PRASYARAT (Jalankan sekali di backend sebelum pengujian):
# Di obladi  : echo "<h1>Area Vault - Server Obladi</h1>" > /var/www/vault/index.html
# Di desmond : echo "<h1>Area Vault - Server Desmond</h1>" > /var/www/vault/index.html
# Di rootkit : sysctl -w net.ipv4.ip_forward=1 && iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# ==== PENNY ====
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99insecure 2>/dev/null || true
sed -i '/security/s/^/#/' /etc/apt/sources.list 2>/dev/null || true
apt-get update
apt-get install -y apache2
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests lbmethod_bytraffic lbmethod_bybusyness slotmem_shm headers

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
    RequestHeader set X-Real-IP "expr=%{REMOTE_ADDR}"

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
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99insecure 2>/dev/null || true
sed -i '/security/s/^/#/' /etc/apt/sources.list 2>/dev/null || true
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
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/abbey /etc/nginx/sites-enabled/abbey
rm -f /etc/nginx/sites-enabled/default
nginx -t && service nginx restart


# ==== PENGUJIAN DARI CLIENT (misal: gamma) ====
# 1. Pastikan domain ter-resolve (atau fallback hosts):
#    echo "10.82.5.2 penny.k37.com www.k37.com" >> /etc/hosts
#    echo "10.82.4.2 abbey.k37.com static.k37.com" >> /etc/hosts
#
# 2. Uji Load Balancing Penny (Vault):
#    for i in {1..4}; do curl -s http://penny.k37.com/ | grep -i "Server"; done
#
# 3. Uji Load Balancing Abbey (Core):
#    for i in {1..4}; do echo "--- Request \$i ---"; curl -s http://abbey.k37.com/profil | grep -E "Node Server|Host Header|Client IP"; done
