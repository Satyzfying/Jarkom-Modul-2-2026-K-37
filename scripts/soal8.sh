#!/bin/bash

# ==== PRAB (MASTER DNS) ====
if [ "$(hostname)" = "prab" ]; then
    cat > /etc/bind/named.conf.local <<EOF
zone "k37.com" {
    type master;
    file "/var/cache/bind/db.k37.com";
    notify yes;
    allow-transfer { 10.82.1.3; };
};

zone "1.82.10.in-addr.arpa" {
    type master;
    file "/var/cache/bind/db.10.82.1";
    notify yes;
    allow-transfer { 10.82.1.3; };
};

zone "4.82.10.in-addr.arpa" {
    type master;
    file "/var/cache/bind/db.10.82.4";
    notify yes;
    allow-transfer { 10.82.1.3; };
};

zone "5.82.10.in-addr.arpa" {
    type master;
    file "/var/cache/bind/db.10.82.5";
    notify yes;
    allow-transfer { 10.82.1.3; };
};
EOF

    cat > /var/cache/bind/db.10.82.1 <<EOF
\$TTL 300
@ IN SOA prab.k37.com. admin.k37.com. (
    2026092901
    3600
    600
    86400
    300
)
@ IN NS prab.k37.com.
@ IN NS tedd.k37.com.

4 IN PTR obladi.k37.com.
5 IN PTR desmond.k37.com.
6 IN PTR oblada.k37.com.
7 IN PTR molly.k37.com.
EOF

    cat > /var/cache/bind/db.10.82.4 <<EOF
\$TTL 300
@ IN SOA prab.k37.com. admin.k37.com. (
    2026092901
    3600
    600
    86400
    300
)
@ IN NS prab.k37.com.
@ IN NS tedd.k37.com.

2 IN PTR abbey.k37.com.
EOF

    cat > /var/cache/bind/db.10.82.5 <<EOF
\$TTL 300
@ IN SOA prab.k37.com. admin.k37.com. (
    2026092901
    3600
    600
    86400
    300
)
@ IN NS prab.k37.com.
@ IN NS tedd.k37.com.

2 IN PTR penny.k37.com.
EOF

    named-checkconf
    named-checkzone 1.82.10.in-addr.arpa /var/cache/bind/db.10.82.1
    named-checkzone 4.82.10.in-addr.arpa /var/cache/bind/db.10.82.4
    named-checkzone 5.82.10.in-addr.arpa /var/cache/bind/db.10.82.5

    service bind9 restart 2>/dev/null || service named restart 2>/dev/null || { pkill named; named -c /etc/bind/named.conf; }

    dig @10.82.1.2 -x 10.82.1.4 +short
    dig @10.82.1.2 -x 10.82.1.5 +short
    dig @10.82.1.2 -x 10.82.1.6 +short
    dig @10.82.1.2 -x 10.82.1.7 +short
    dig @10.82.1.2 -x 10.82.4.2 +short
    dig @10.82.1.2 -x 10.82.5.2 +short

# ==== TEDD (SLAVE DNS) ====
elif [ "$(hostname)" = "tedd" ]; then
    cat > /etc/bind/named.conf.local <<EOF
zone "k37.com" {
    type slave;
    masters { 10.82.1.2; };
    file "/var/cache/bind/db.k37.com";
};

zone "1.82.10.in-addr.arpa" {
    type slave;
    masters { 10.82.1.2; };
    file "/var/cache/bind/db.10.82.1";
};

zone "4.82.10.in-addr.arpa" {
    type slave;
    masters { 10.82.1.2; };
    file "/var/cache/bind/db.10.82.4";
};

zone "5.82.10.in-addr.arpa" {
    type slave;
    masters { 10.82.1.2; };
    file "/var/cache/bind/db.10.82.5";
};
EOF

    named-checkconf

    service bind9 restart 2>/dev/null || service named restart 2>/dev/null || { pkill named; named -c /etc/bind/named.conf; }

    sleep 3

    dig @10.82.1.3 -x 10.82.1.4 +short
    dig @10.82.1.3 -x 10.82.1.5 +short
    dig @10.82.1.3 -x 10.82.1.6 +short
    dig @10.82.1.3 -x 10.82.1.7 +short
    dig @10.82.1.3 -x 10.82.4.2 +short
    dig @10.82.1.3 -x 10.82.5.2 +short
fi
