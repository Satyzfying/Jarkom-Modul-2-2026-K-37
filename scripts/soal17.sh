 cat >> /var/cache/bind/db.k37.com <<'EOF'

; TXT record - Soal No. 17
alpha       IN TXT "alpha"
beta        IN TXT "beta"
gamma       IN TXT "gamma"
delta       IN TXT "delta"
epsilon     IN TXT "epsilon"
EOF



sed -i 's/2026092903/2026092904/' /var/cache/bind/db.k37.com

tail -10 /var/cache/bind/db.k37.com

named-checkzone k37.com /var/cache/bind/db.k37.com

pkill named

named -c /etc/bind/named.conf

ps aux | grep '[n]amed'

named -c /etc/bind/named.conf