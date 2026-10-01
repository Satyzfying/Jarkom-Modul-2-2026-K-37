# ==== SOAL 19 ====
# ==== PRAB (MASTER DNS) ====
# 1. Pastikan forwarders dan recursion aktif di /etc/bind/named.conf.options agar dapat me-resolve domain eksternal
cat <<EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";

    forwarders {
        192.168.122.1;
    };

    allow-query { any; };
    allow-recursion { any; };
    recursion yes;
};
EOF

# 2. Tambahkan CNAME record outbound.k37.com ke http.badssl.com di /var/cache/bind/db.k37.com
cat >> /var/cache/bind/db.k37.com <<'EOF'
outbound    IN    CNAME    http.badssl.com.
EOF

# Naikkan serial SOA
SERIAL_OLD=$(grep -oE '[0-9]{10}' /var/cache/bind/db.k37.com | head -1)
[ -n "$SERIAL_OLD" ] && sed -i "s/$SERIAL_OLD/$((SERIAL_OLD + 1))/" /var/cache/bind/db.k37.com

# Validasi konfigurasi zone
named-checkconf /etc/bind/named.conf
named-checkzone k37.com /var/cache/bind/db.k37.com

# Reload service BIND
service bind9 restart 2>/dev/null || service named restart 2>/dev/null || { pkill named; named -c /etc/bind/named.conf; }

# ==== PENGUJIAN ====
# 1. Verifikasi CNAME record menggunakan dig
dig @10.82.1.2 outbound.k37.com CNAME +noall +answer

# 2. Lakukan curl ke http://outbound.k37.com dan verifikasi respons halaman http.badssl.com
curl http://outbound.k37.com
