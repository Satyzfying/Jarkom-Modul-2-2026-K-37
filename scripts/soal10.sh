#!/bin/bash
# ==============================================================================
# NOMOR 10: Web Dinamis (PHP-FPM & Nginx) pada Area Core
# Node Area Core: oblada (10.82.1.6) & molly (10.82.1.7)
# Hostname: core.k37.com, oblada.k37.com, molly.k37.com
# Fitur: Halaman Beranda, Halaman Profil, dan URL Rewrite Bersih (/profil)
# ==============================================================================

# ==== OBLADA ====
if [ -z "$1" ] || [ "$1" = "oblada" ] || [ "$(hostname)" = "oblada" ]; then
    echo "[*] Mengonfigurasi Web Dinamis Nginx + PHP-FPM pada OBLADA..."

    # 1. Update dan instalasi Nginx serta PHP-FPM
    apt-get update
    apt-get install -y nginx php-fpm

    # 2. Pastikan service PHP-FPM aktif dan deteksi socket PHP-FPM
    PHP_SERVICE=$(ls /etc/init.d/php*-fpm 2>/dev/null | head -n 1 | xargs -r basename)
    if [ -n "$PHP_SERVICE" ]; then
        service "$PHP_SERVICE" start
    else
        service php-fpm start 2>/dev/null || true
    fi

    PHP_SOCK=$(ls -1 /run/php/php*-fpm.sock 2>/dev/null | head -n 1)
    if [ -z "$PHP_SOCK" ]; then
        PHP_SOCK="/run/php/php8.2-fpm.sock"
    fi
    echo "[*] PHP-FPM socket terdeteksi: $PHP_SOCK"

    # 3. Buat direktori DocumentRoot /var/www/core
    mkdir -p /var/www/core

    # Halaman Beranda (index.php)
    cat <<'EOF' > /var/www/core/index.php
<!DOCTYPE html>
<html>
<head><title>Core - Beranda (Oblada)</title></head>
<body>
    <h1>Selamat Datang di Beranda Core Area</h1>
    <p>Node Server: <strong>Oblada</strong> (10.82.1.6)</p>
    <p>Layanan Web Dinamis PHP-FPM & Nginx - Kelompok K-37</p>
    <p><a href="/profil">Menuju Halaman Profil</a></p>
</body>
</html>
EOF

    # Halaman Profil (profil.php)
    cat <<'EOF' > /var/www/core/profil.php
<!DOCTYPE html>
<html>
<head><title>Core - Profil</title></head>
<body>
    <h1>Halaman Profil - Core Network K-37</h1>
    <p>Node Server: <strong>Oblada</strong> (10.82.1.6)</p>
    <p>Host Header: <?php echo htmlspecialchars($_SERVER['HTTP_HOST'] ?? '-'); ?></p>
    <p>Client IP (X-Real-IP): <?php echo htmlspecialchars($_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR']); ?></p>
    <p>Status: Layanan Web Dinamis PHP-FPM Aktif</p>
    <p>PHP Version: <?php echo phpversion(); ?></p>
    <p>Request URI: <?php echo htmlspecialchars($_SERVER['REQUEST_URI']); ?></p>
    <p><a href="/">Kembali ke Beranda</a></p>
</body>
</html>
EOF

    # Atur permission
    chown -R www-data:www-data /var/www/core
    chmod -R 755 /var/www/core

    # 4. Konfigurasi Server Block Nginx dengan Aturan Rewrite /profil
    cat <<EOF > /etc/nginx/sites-available/core
server {
    listen 80;
    server_name core.k37.com oblada.k37.com molly.k37.com;

    root /var/www/core;
    index index.php index.html index.htm;

    # Aturan rewrite URL bersih tanpa ekstensi .php: /profil -> /profil.php
    rewrite ^/profil/?$ /profil.php last;

    location / {
        try_files \$uri \$uri/ \$uri.php?\$args =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_pass unix:$PHP_SOCK;
        fastcgi_index index.php;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    # 5. Aktifkan site dan restart Nginx
    ln -sf /etc/nginx/sites-available/core /etc/nginx/sites-enabled/core
    rm -f /etc/nginx/sites-enabled/default
    nginx -t && service nginx restart

    echo "[OK] Konfigurasi OBLADA selesai."
fi

# ==== MOLLY ====
if [ -z "$1" ] || [ "$1" = "molly" ] || [ "$(hostname)" = "molly" ]; then
    echo "[*] Mengonfigurasi Web Dinamis Nginx + PHP-FPM pada MOLLY..."

    # 1. Update dan instalasi Nginx serta PHP-FPM
    apt-get update
    apt-get install -y nginx php-fpm

    # 2. Pastikan service PHP-FPM aktif dan deteksi socket PHP-FPM
    PHP_SERVICE=$(ls /etc/init.d/php*-fpm 2>/dev/null | head -n 1 | xargs -r basename)
    if [ -n "$PHP_SERVICE" ]; then
        service "$PHP_SERVICE" start
    else
        service php-fpm start 2>/dev/null || true
    fi

    PHP_SOCK=$(ls -1 /run/php/php*-fpm.sock 2>/dev/null | head -n 1)
    if [ -z "$PHP_SOCK" ]; then
        PHP_SOCK="/run/php/php8.2-fpm.sock"
    fi
    echo "[*] PHP-FPM socket terdeteksi: $PHP_SOCK"

    # 3. Buat direktori DocumentRoot /var/www/core
    mkdir -p /var/www/core

    # Halaman Beranda (index.php)
    cat <<'EOF' > /var/www/core/index.php
<!DOCTYPE html>
<html>
<head><title>Core - Beranda (Molly)</title></head>
<body>
    <h1>Selamat Datang di Beranda Core Area</h1>
    <p>Node Server: <strong>Molly</strong> (10.82.1.7)</p>
    <p>Layanan Web Dinamis PHP-FPM & Nginx - Kelompok K-37</p>
    <p><a href="/profil">Menuju Halaman Profil</a></p>
</body>
</html>
EOF

    # Halaman Profil (profil.php)
    cat <<'EOF' > /var/www/core/profil.php
<!DOCTYPE html>
<html>
<head><title>Core - Profil</title></head>
<body>
    <h1>Halaman Profil - Core Network K-37</h1>
    <p>Node Server: <strong>Molly</strong> (10.82.1.7)</p>
    <p>Host Header: <?php echo htmlspecialchars($_SERVER['HTTP_HOST'] ?? '-'); ?></p>
    <p>Client IP (X-Real-IP): <?php echo htmlspecialchars($_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR']); ?></p>
    <p>Status: Layanan Web Dinamis PHP-FPM Aktif</p>
    <p>PHP Version: <?php echo phpversion(); ?></p>
    <p>Request URI: <?php echo htmlspecialchars($_SERVER['REQUEST_URI']); ?></p>
    <p><a href="/">Kembali ke Beranda</a></p>
</body>
</html>
EOF

    # Atur permission
    chown -R www-data:www-data /var/www/core
    chmod -R 755 /var/www/core

    # 4. Konfigurasi Server Block Nginx dengan Aturan Rewrite /profil
    cat <<EOF > /etc/nginx/sites-available/core
server {
    listen 80;
    server_name core.k37.com molly.k37.com oblada.k37.com;

    root /var/www/core;
    index index.php index.html index.htm;

    # Aturan rewrite URL bersih tanpa ekstensi .php: /profil -> /profil.php
    rewrite ^/profil/?$ /profil.php last;

    location / {
        try_files \$uri \$uri/ \$uri.php?\$args =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_pass unix:$PHP_SOCK;
        fastcgi_index index.php;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    # 5. Aktifkan site dan restart Nginx
    ln -sf /etc/nginx/sites-available/core /etc/nginx/sites-enabled/core
    rm -f /etc/nginx/sites-enabled/default
    nginx -t && service nginx restart

    echo "[OK] Konfigurasi MOLLY selesai."
fi

# ==== PENGUJIAN DARI CLIENT (ALPHA / BETA / GAMMA / DELTA / EPSILON) ====
# Perintah pengujian dijalankan dari sisi host klien menggunakan hostname:
#
# 1. Pengujian akses Beranda melalui hostname core.k37.com:
#    curl -i http://core.k37.com/
#
# 2. Pengujian akses URL Bersih /profil (tanpa .php) melalui hostname:
#    curl -i http://core.k37.com/profil
#    curl -s http://core.k37.com/profil
#
# 3. Pengujian hostname spesifik per node:
#    curl -i http://oblada.k37.com/profil
#    curl -i http://molly.k37.com/profil

