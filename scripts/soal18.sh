# ==== SOAL 18 ====
# ==== PRAB (MASTER DNS) ====
# 1. Update zone file /var/cache/bind/db.k37.com:
#    - Naikkan serial SOA (misal: 2026092909)
#    - Ubah A record abbey menjadi IP fiktif (10.82.4.50) dengan TTL 15 detik:
#      abbey    15    IN    A    10.82.4.50

# Naikkan serial SOA
SERIAL_OLD=$(grep -oE '[0-9]{10}' /var/cache/bind/db.k37.com | head -1)
[ -n "$SERIAL_OLD" ] && sed -i "s/$SERIAL_OLD/$((SERIAL_OLD + 1))/" /var/cache/bind/db.k37.com
sed -i 's/^abbey.*/abbey    15    IN    A    10.82.4.50/' /var/cache/bind/db.k37.com

# Validasi syntax zone file
named-checkzone k37.com /var/cache/bind/db.k37.com

# Reload BIND pada Prab
service bind9 restart 2>/dev/null || service named restart 2>/dev/null || { pkill named; named -c /etc/bind/named.conf; }

# ==== TEDD (SLAVE DNS) ====
# Verifikasi sinkronisasi zone transfer ke Tedd
dig @10.82.1.3 abbey.k37.com A +noall +answer
dig @10.82.1.3 k37.com SOA +noall +answer

# ==== VERIFIKASI 3 FASE TTL CACHING ====
# Fase 1: Sebelum perubahan terjadi (mengembalikan IP lama: 10.82.4.2)
dig @10.82.1.2 abbey.k37.com A +noall +answer

# Fase 2: Saat perubahan baru saja terjadi dalam jeda 15 detik (masih mengembalikan IP lama karena cache)
dig @10.82.1.2 abbey.k37.com A +noall +answer

# Fase 3: Setelah batas TTL 15 detik kedaluwarsa (mengembalikan IP fiktif baru: 10.82.4.50 dengan TTL 15)
sleep 15
dig @10.82.1.2 abbey.k37.com A +noall +answer
