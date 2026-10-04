 # KONFIGURASI UMUM
 BIND_DIR="/etc/bind"
CACHE_DIR="/var/cache/bind"
DOMAIN="k37.com"
PRAB_IP="10.82.1.2"
TEDD_IP="10.82.1.3"

stop_named() {
    service bind9 stop 2>/dev/null || service named stop 2>/dev/null || pkill named 2>/dev/null || true
}

start_named() {
    service bind9 start 2>/dev/null || service named start 2>/dev/null || named -c /etc/bind/named.conf
}

# ==== PRAB (MASTER DNS) ====
if [ "$(hostname)" = "prab" ]; then
    cat > "$BIND_DIR/named.conf.local" <<EOF
zone "$DOMAIN" {
    type master;
    file "$CACHE_DIR/db.$DOMAIN";
    notify yes;
    allow-transfer { $TEDD_IP; };
};

zone "1.82.10.in-addr.arpa" {
    type master;
    file "$CACHE_DIR/db.10.82.1";
    notify yes;
    allow-transfer { $TEDD_IP; };
};

zone "4.82.10.in-addr.arpa" {
    type master;
    file "$CACHE_DIR/db.10.82.4";
    notify yes;
    allow-transfer { $TEDD_IP; };
};

zone "5.82.10.in-addr.arpa" {
    type master;
    file "$CACHE_DIR/db.10.82.5";
    notify yes;
    allow-transfer { $TEDD_IP; };
};
EOF

    cat > "$CACHE_DIR/db.10.82.1" <<EOF
\$TTL 300
@ IN SOA prab.$DOMAIN. admin.$DOMAIN. (
    2026092901
    3600
    600
    86400
    300
)
@ IN NS prab.$DOMAIN.
@ IN NS tedd.$DOMAIN.

4 IN PTR obladi.$DOMAIN.
5 IN PTR desmond.$DOMAIN.
6 IN PTR oblada.$DOMAIN.
7 IN PTR molly.$DOMAIN.
EOF

    cat > "$CACHE_DIR/db.10.82.4" <<EOF
\$TTL 300
@ IN SOA prab.$DOMAIN. admin.$DOMAIN. (
    2026092901
    3600
    600
    86400
    300
)
@ IN NS prab.$DOMAIN.
@ IN NS tedd.$DOMAIN.

2 IN PTR abbey.$DOMAIN.
EOF

    cat > "$CACHE_DIR/db.10.82.5" <<EOF
\$TTL 300
@ IN SOA prab.$DOMAIN. admin.$DOMAIN. (
    2026092901
    3600
    600
    86400
    300
)
@ IN NS prab.$DOMAIN.
@ IN NS tedd.$DOMAIN.

2 IN PTR penny.$DOMAIN.
EOF

    named-checkconf
    named-checkzone 1.82.10.in-addr.arpa "$CACHE_DIR/db.10.82.1"
    named-checkzone 4.82.10.in-addr.arpa "$CACHE_DIR/db.10.82.4"
    named-checkzone 5.82.10.in-addr.arpa "$CACHE_DIR/db.10.82.5"

    stop_named
    start_named

    dig @"$PRAB_IP" -x 10.82.1.4 +short
    dig @"$PRAB_IP" -x 10.82.1.5 +short
    dig @"$PRAB_IP" -x 10.82.1.6 +short
    dig @"$PRAB_IP" -x 10.82.1.7 +short
    dig @"$PRAB_IP" -x 10.82.4.2 +short
    dig @"$PRAB_IP" -x 10.82.5.2 +short

# ==== TEDD (SLAVE DNS) ====
elif [ "$(hostname)" = "tedd" ]; then

    cat > "$BIND_DIR/named.conf.local" <<EOF
zone "$DOMAIN" {
    type slave;
    masters { $PRAB_IP; };
    file "$CACHE_DIR/db.$DOMAIN";
};

zone "1.82.10.in-addr.arpa" {
    type slave;
    masters { $PRAB_IP; };
    file "$CACHE_DIR/db.10.82.1";
};

zone "4.82.10.in-addr.arpa" {
    type slave;
    masters { $PRAB_IP; };
    file "$CACHE_DIR/db.10.82.4";
};

zone "5.82.10.in-addr.arpa" {
    type slave;
    masters { $PRAB_IP; };
    file "$CACHE_DIR/db.10.82.5";
};
EOF

    named-checkconf

    stop_named
    start_named

    sleep 5

    ls -l "$CACHE_DIR"/db.10.82.1 \
          "$CACHE_DIR"/db.10.82.4 \
          "$CACHE_DIR"/db.10.82.5

    dig @"$TEDD_IP" -x 10.82.1.4 +short
    dig @"$TEDD_IP" -x 10.82.1.5 +short
    dig @"$TEDD_IP" -x 10.82.1.6 +short
    dig @"$TEDD_IP" -x 10.82.1.7 +short
    dig @"$TEDD_IP" -x 10.82.4.2 +short
    dig @"$TEDD_IP" -x 10.82.5.2 +short
fi
