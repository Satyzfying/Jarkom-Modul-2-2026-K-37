#!/bin/bash

# ==== OBLADI ====
a2enmod remoteip

cat <<EOF > /etc/apache2/conf-available/remoteip.conf
RemoteIPHeader X-Real-IP
RemoteIPInternalProxy 10.82.5.2
RemoteIPInternalProxy 10.82.0.0/16
EOF
a2enconf remoteip

sed -i 's/%h %l %u %t/%a %l %u %t/' /etc/apache2/apache2.conf
service apache2 restart


# ==== DESMOND ====
a2enmod remoteip

cat <<EOF > /etc/apache2/conf-available/remoteip.conf
RemoteIPHeader X-Real-IP
RemoteIPInternalProxy 10.82.5.2
RemoteIPInternalProxy 10.82.0.0/16
EOF
a2enconf remoteip

sed -i 's/%h %l %u %t/%a %l %u %t/' /etc/apache2/apache2.conf
service apache2 restart


# ==== OBLADA ====
if ! grep -q "set_real_ip_from" /etc/nginx/sites-available/core; then
    sed -i '/listen 80;/a \    set_real_ip_from 10.82.4.2;\n    set_real_ip_from 10.82.0.0/16;\n    real_ip_header X-Real-IP;\n    real_ip_recursive on;' /etc/nginx/sites-available/core
fi
nginx -t && service nginx restart


# ==== MOLLY ====
if ! grep -q "set_real_ip_from" /etc/nginx/sites-available/core; then
    sed -i '/listen 80;/a \    set_real_ip_from 10.82.4.2;\n    set_real_ip_from 10.82.0.0/16;\n    real_ip_header X-Real-IP;\n    real_ip_recursive on;' /etc/nginx/sites-available/core
fi
nginx -t && service nginx restart
