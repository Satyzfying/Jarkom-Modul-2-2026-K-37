# ==== PRAB & TEDD ====
apt update
apt install bind9 bind9-utils bind9-dnsutils -y

cat <<EOF > /etc/bind/named.conf.options
options {
  directory "/var/cache/bind";

  forwarders {
    192.168.122.1;
  };

  recursion yes;
};

EOF


# ==== PRAB (MASTER DNS) ====
cat <<EOF > /etc/bind/named.conf.local
zone "k37.com" {
  type master;
  file "/var/cache/bind/db.k37.com";

  notify yes;

  allow-transfer {
    10.82.1.3;
  };
};

EOF

cat <<EOF > /var/cache/bind/db.k37.com
\$TTL 300

@   IN  SOA     prab.k37.com. admin.k37.com. (
        2026092901
        3600
        600
        86400
        300
)

    IN  NS      prab.k37.com.
    IN  NS      tedd.k37.com.

@       IN  A       10.82.5.2
prab    IN  A       10.82.1.2
tedd    IN  A       10.82.1.3

EOF

named-checkconf
named-checkzone k37.com /var/cache/bind/db.k37.com

named -c /etc/bind/named.conf


# ==== TEDD (SLAVE DNS) ====
cat <<EOF > /etc/bind/named.conf.local
zone "k37.com" {
  type slave;

  masters {
    10.82.1.2;
  };

  file "/var/cache/bind/db.k37.com";
};

EOF

named-checkconf

named -c /etc/bind/named.conf


# ==== SEMUA HOST ====
echo "nameserver 10.82.1.2" > /etc/resolv.conf
echo "nameserver 10.82.1.3" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf