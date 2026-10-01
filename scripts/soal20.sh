# ==== SOAL 20 ====

# ==== PRAB (MASTER DNS) ====
# 1. Kembalikan A record abbey ke IP asli (10.82.4.2)
sed -i 's/^abbey.*/abbey       IN  A   10.82.4.2/' /var/cache/bind/db.k37.com

# 2. Naikkan serial SOA
SERIAL_OLD=$(grep -oE '[0-9]{10}' /var/cache/bind/db.k37.com | head -1)
[ -n "$SERIAL_OLD" ] && sed -i "s/$SERIAL_OLD/$((SERIAL_OLD + 1))/" /var/cache/bind/db.k37.com

# 3. Validasi & reload BIND
named-checkzone k37.com /var/cache/bind/db.k37.com
service bind9 restart 2>/dev/null || service named restart 2>/dev/null || { pkill named; named -c /etc/bind/named.conf; }

# 4. Autostart BIND pada Prab
echo "service bind9 start 2>/dev/null || service named start 2>/dev/null || named -c /etc/bind/named.conf" >> /root/.bashrc


# ==== TEDD (SLAVE DNS) ====
echo "service bind9 start 2>/dev/null || service named start 2>/dev/null || named -c /etc/bind/named.conf" >> /root/.bashrc


# ==== ROOTKIT ====
echo "sysctl -w net.ipv4.ip_forward=1" >> /root/.bashrc
echo "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >> /root/.bashrc


# ==== PENNY ====
echo "service php8.4-fpm start 2>/dev/null || service php-fpm start 2>/dev/null" >> /root/.bashrc
echo "service apache2 start" >> /root/.bashrc


# ==== ABBEY ====
echo "service nginx start" >> /root/.bashrc


# ==== OBLADI & DESMOND ====
echo "service apache2 start" >> /root/.bashrc


# ==== OBLADA & MOLLY ====
echo "service php8.4-fpm start 2>/dev/null || service php-fpm start 2>/dev/null" >> /root/.bashrc
echo "service nginx start" >> /root/.bashrc


# ==== CLIENT (ALPHA / GAMMA) ====
cat <<'EOF' >> /root/.bashrc
cat > /etc/resolv.conf <<'CONF'
nameserver 10.82.1.2
nameserver 10.82.1.3
nameserver 192.168.122.1
CONF
EOF


# ==== PENGUJIAN SETELAH RESTART ====
# 1. Cek A record abbey kembali normal ke 10.82.4.2
dig @10.82.1.2 abbey.k37.com +short

# 2. Cek Reverse Proxy Penny (HTTP 200 OK)
curl -I http://www.k37.com/

# 3. Cek Reverse Proxy Abbey (HTTP 200 OK)
curl -I http://static.k37.com/profil
