#!/bin/bash
# ==============================================================================
# NOMOR 11: Reverse Proxy & Load Balancer pada Penny & Abbey
# - PENNY (Apache): Reverse Proxy ke Area Vault (Obladi 10.82.1.4 & Desmond 10.82.1.5)
# - ABBEY (Nginx): Reverse Proxy ke Area Core (Oblada 10.82.1.6 & Molly 10.82.1.7)
# - Forwarding Header: Host dan X-Real-IP ke backend server
# ==============================================================================

# ==== PENNY ====
if [ -z "$1" ] || [ "$1" = "penny" ] || [ "$(hostname)" = "penny" ]; then
    echo "[*] Mengonfigurasi Apache Reverse Proxy pada PENNY (Area Vault)..."

    # 1. Update dan instalasi Apache2
    apt-get update
    apt-get install -y apache2

    # 2. Aktifkan modul-modul proxy, load balancing, dan headers pada Apache
    a2enmod proxy
    a2enmod proxy_http
    a2enmod proxy_balancer
    a2enmod lbmethod_byrequests
    a2enmod headers

    # 3. Konfigurasi VirtualHost Reverse Proxy & Balancer
    cat <<EOF > /etc/apache2/sites-available/penny.conf
<VirtualHost *:80>
    ServerName penny.k37.com
    ServerAlias www.k37.com k37.com

    <Proxy balancer://vaultcluster>
        BalancerMember http://10.82.1.4:80
        BalancerMember http://10.82.1.5:80
        ProxySet lbmethod=byrequests
    </Proxy>

    # Meneruskan Host asli ke backend
    ProxyPreserveHost On

    # Meneruskan IP asli client (X-Real-IP) ke backend
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

    # Reverse proxy ke cluster vault
    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/

    ErrorLog \${APACHE_LOG_DIR}/penny_error.log
    CustomLog \${APACHE_LOG_DIR}/penny_access.log combined
</VirtualHost>
EOF

    # 4. Aktifkan konfigurasi dan restart Apache2
    a2dissite 000-default.conf
    a2ensite penny.conf
    apache2ctl configtest && service apache2 restart

    echo "[OK] Konfigurasi Apache Reverse Proxy pada PENNY selesai."
fi

# ==== ABBEY ====
if [ -z "$1" ] || [ "$1" = "abbey" ] || [ "$(hostname)" = "abbey" ]; then
    echo "[*] Mengonfigurasi Nginx Reverse Proxy pada ABBEY (Area Core)..."

    # 1. Update dan instalasi Nginx
    apt-get update
    apt-get install -y nginx

    # 2. Konfigurasi Server Block Nginx Reverse Proxy & Load Balancer
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

        # Forwarding header Host dan X-Real-IP
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

    # 3. Aktifkan site dan restart Nginx
    ln -sf /etc/nginx/sites-available/abbey /etc/nginx/sites-enabled/abbey
    rm -f /etc/nginx/sites-enabled/default
    nginx -t && service nginx restart

    echo "[OK] Konfigurasi Nginx Reverse Proxy pada ABBEY selesai."
fi

# ==== PENGUJIAN DARI CLIENT (ALPHA / BETA / GAMMA / DELTA / EPSILON) ====
# Perintah pengujian distribusi trafik dan forwarding header dari host klien:
#
# 1. Uji Distribusi Trafik Penny ke Area Vault (Obladi & Desmond):
#    for i in {1..4}; do curl -s http://penny.k37.com/ | grep -i "Server"; done
#    for i in {1..4}; do curl -s http://www.k37.com/ | grep -i "Server"; done
#
# 2. Uji Akses Autoindex melalui Penny:
#    curl -i http://penny.k37.com/arsip/
#
# 3. Uji Distribusi Trafik Abbey ke Area Core (Oblada & Molly) serta Validasi Header Host & X-Real-IP:
#    for i in {1..4}; do
#        echo "--- Request \$i ---"
#        curl -s http://abbey.k37.com/profil | grep -E "Node Server|Host Header|Client IP"
#    done

