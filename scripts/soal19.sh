# ==== SOAL 19 ====
# ==== PRAB  ====
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

cat >> /var/cache/bind/db.k37.com <<'EOF'
outbound    IN    CNAME    http.badssl.com.
EOF

SERIAL_OLD=$(grep -oE '[0-9]{10}' /var/cache/bind/db.k37.com | head -1)
[ -n "$SERIAL_OLD" ] && sed -i "s/$SERIAL_OLD/$((SERIAL_OLD + 1))/" /var/cache/bind/db.k37.com

named-checkconf /etc/bind/named.conf
named-checkzone k37.com /var/cache/bind/db.k37.com

service bind9 restart 2>/dev/null || service named restart 2>/dev/null || { pkill named; named -c /etc/bind/named.conf; }

dig @10.82.1.2 outbound.k37.com CNAME +noall +answer

which curl >/dev/null 2>&1 || apt-get install -y curl 2>/dev/null || true
curl http://outbound.k37.com
