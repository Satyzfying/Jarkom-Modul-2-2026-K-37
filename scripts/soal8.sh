# ============================================================
# KONFIGURASI PRAB - MASTER
# ============================================================
if [ "$(hostname)" = "prab" ]; then

    echo "============================================================"
    echo " KONFIGURASI PRAB SEBAGAI DNS MASTER"
    echo "============================================================"

    # Backup konfigurasi sebelumnya
    if [ -f "$BIND_DIR/named.conf.local" ]; then
        cp "$BIND_DIR/named.conf.local" \
           "$BIND_DIR/named.conf.local.backup_q8_$(date +%Y%m%d%H%M%S)"
        echo "[OK] Backup named.conf.local dibuat."
    fi

    # --------------------------------------------------------
    # 1. Konfigurasi named.conf.local
    # --------------------------------------------------------
    echo "[*] Membuat konfigurasi Master..."

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

    # --------------------------------------------------------
    # 2. Reverse zone 10.82.1.0/24
    # --------------------------------------------------------
    echo "[*] Membuat db.10.82.1..."

    cat > "$CACHE_DIR/db.10.82.1" <<EOF
\$TTL 300
@ IN SOA prab.$DOMAIN. admin.$DOMAIN. (
    2026092904
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

    # --------------------------------------------------------
    # 3. Reverse zone 10.82.4.0/24
    # --------------------------------------------------------
    echo "[*] Membuat db.10.82.4..."

    cat > "$CACHE_DIR/db.10.82.4" <<EOF
\$TTL 300
@ IN SOA prab.$DOMAIN. admin.$DOMAIN. (
    2026092904
    3600
    600
    86400
    300
)
@ IN NS prab.$DOMAIN.
@ IN NS tedd.$DOMAIN.

2 IN PTR abbey.$DOMAIN.
EOF

    # --------------------------------------------------------
    # 4. Reverse zone 10.82.5.0/24
    # --------------------------------------------------------
    echo "[*] Membuat db.10.82.5..."

    cat > "$CACHE_DIR/db.10.82.5" <<EOF
\$TTL 300
@ IN SOA prab.$DOMAIN. admin.$DOMAIN. (
    2026092904
    3600
    600
    86400
    300
)
@ IN NS prab.$DOMAIN.
@ IN NS tedd.$DOMAIN.

2 IN PTR penny.$DOMAIN.
EOF

    # --------------------------------------------------------
    # 5. Validasi konfigurasi
    # --------------------------------------------------------
    echo
    echo "[*] Mengecek named.conf..."
    named-checkconf
    echo "[OK] named.conf valid."

    echo
    echo "[*] Mengecek reverse zone 1..."
    named-checkzone 1.82.10.in-addr.arpa "$CACHE_DIR/db.10.82.1"

    echo
    echo "[*] Mengecek reverse zone 4..."
    named-checkzone 4.82.10.in-addr.arpa "$CACHE_DIR/db.10.82.4"

    echo
    echo "[*] Mengecek reverse zone 5..."
    named-checkzone 5.82.10.in-addr.arpa "$CACHE_DIR/db.10.82.5"

    # --------------------------------------------------------
    # 6. Restart named
    # --------------------------------------------------------
    echo
    stop_named
    start_named

    # --------------------------------------------------------
    # 7. Verifikasi Reverse DNS di Prab
    # --------------------------------------------------------
    echo
    echo "============================================================"
    echo " VERIFIKASI REVERSE DNS DI PRAB"
    echo "============================================================"

    echo "10.82.1.4 ->"
    dig @"$PRAB_IP" -x 10.82.1.4 +short

    echo "10.82.1.5 ->"
    dig @"$PRAB_IP" -x 10.82.1.5 +short

    echo "10.82.1.6 ->"
    dig @"$PRAB_IP" -x 10.82.1.6 +short

    echo "10.82.1.7 ->"
    dig @"$PRAB_IP" -x 10.82.1.7 +short

    echo "10.82.4.2 ->"
    dig @"$PRAB_IP" -x 10.82.4.2 +short

    echo "10.82.5.2 ->"
    dig @"$PRAB_IP" -x 10.82.5.2 +short

    echo
    echo "[SELESAI] Konfigurasi Master Prab selesai."
    echo "[INFO] Lanjutkan menjalankan script yang sama di Tedd."

# ============================================================
# KONFIGURASI TEDD - SLAVE
# ============================================================
elif [ "$(hostname)" = "tedd" ]; then

    echo "============================================================"
    echo " KONFIGURASI TEDD SEBAGAI DNS SLAVE"
    echo "============================================================"

    # Backup konfigurasi sebelumnya
    if [ -f "$BIND_DIR/named.conf.local" ]; then
        cp "$BIND_DIR/named.conf.local" \
           "$BIND_DIR/named.conf.local.backup_q8_$(date +%Y%m%d%H%M%S)"
        echo "[OK] Backup named.conf.local dibuat."
    fi

    # --------------------------------------------------------
    # 1. Konfigurasi named.conf.local
    # --------------------------------------------------------
    echo "[*] Membuat konfigurasi Slave..."

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

    # --------------------------------------------------------
    # 2. Validasi konfigurasi
    # --------------------------------------------------------
    echo
    echo "[*] Mengecek named.conf..."
    named-checkconf
    echo "[OK] named.conf valid."

    # --------------------------------------------------------
    # 3. Restart named agar Slave menarik zone dari Master
    # --------------------------------------------------------
    echo
    stop_named
    start_named

    # Beri waktu untuk zone transfer
    echo "[*] Menunggu zone transfer dari Prab..."
    sleep 5

    # --------------------------------------------------------
    # 4. Cek file hasil zone transfer
    # --------------------------------------------------------
    echo
    echo "============================================================"
    echo " FILE REVERSE ZONE DI TEDD"
    echo "============================================================"

    ls -l "$CACHE_DIR"/db.10.82.1 \
          "$CACHE_DIR"/db.10.82.4 \
          "$CACHE_DIR"/db.10.82.5

    # --------------------------------------------------------
    # 5. Verifikasi Reverse DNS di Tedd
    # --------------------------------------------------------
    echo
    echo "============================================================"
    echo " VERIFIKASI REVERSE DNS DI TEDD"
    echo "============================================================"

    echo "10.82.1.4 ->"
    dig @"$TEDD_IP" -x 10.82.1.4 +short

    echo "10.82.1.5 ->"
    dig @"$TEDD_IP" -x 10.82.1.5 +short

    echo "10.82.1.6 ->"
    dig @"$TEDD_IP" -x 10.82.1.6 +short

    echo "10.82.1.7 ->"
    dig @"$TEDD_IP" -x 10.82.1.7 +short

    echo "10.82.4.2 ->"
    dig @"$TEDD_IP" -x 10.82.4.2 +short

    echo "10.82.5.2 ->"
    dig @"$TEDD_IP" -x 10.82.5.2 +short

    echo
    echo "[SELESAI] Konfigurasi Slave Tedd selesai."
    echo "[OK] Reverse DNS dan zone transfer telah diverifikasi."

else
    echo "[ERROR] Hostname harus 'prab' atau 'tedd'."
    echo "Hostname saat ini: $(hostname)"
    exit 1
fi

echo
echo "============================================================"
echo " SCRIPT SOAL NO. 8 SELESAI"
echo "============================================================"
