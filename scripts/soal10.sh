#!/bin/bash

# ==== OBLADA ====
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99insecure 2>/dev/null || true
sed -i '/security/s/^/#/' /etc/apt/sources.list 2>/dev/null || true

apt-get update
apt-get install -y nginx php-fpm

PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null || echo "8.4")
service "php${PHP_VER}-fpm" start 2>/dev/null || service php8.4-fpm start 2>/dev/null || service php8.2-fpm start 2>/dev/null || service php-fpm start 2>/dev/null
PHP_SOCK=$(ls -1 /run/php/php*-fpm.sock 2>/dev/null | head -n 1)
[ -z "$PHP_SOCK" ] && PHP_SOCK="/run/php/php${PHP_VER}-fpm.sock"

mkdir -p /var/www/core

cat <<'EOF' > /var/www/core/index.php
<!DOCTYPE html>
<html>
<head><title>Core - Beranda</title></head>
<body>
    <h1>Selamat Datang di Beranda Core Area</h1>
    <p>Node: <?php echo gethostname(); ?></p>
    <p><a href="/profil">Menuju Halaman Profil</a></p>
</body>
</html>
EOF

cat <<'EOF' > /var/www/core/profil.php
<!DOCTYPE html>
<html>
<head><title>Core - Profil</title></head>
<body>
    <h1>Halaman Profil - Core Network K-37</h1>
    <p>Node Server: <?php echo gethostname(); ?> (<?php echo $_SERVER['SERVER_ADDR']; ?>)</p>
    <p>Host Header: <?php echo htmlspecialchars($_SERVER['HTTP_HOST'] ?? '-'); ?></p>
    <p>Client IP (X-Real-IP): <?php echo htmlspecialchars($_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR']); ?></p>
    <p>PHP Version: <?php echo phpversion(); ?></p>
    <p><a href="/">Kembali ke Beranda</a></p>
</body>
</html>
EOF

chown -R www-data:www-data /var/www/core
chmod -R 755 /var/www/core

cat <<EOF > /etc/nginx/sites-available/core
server {
    listen 80;
    server_name core.k37.com oblada.k37.com molly.k37.com;

    root /var/www/core;
    index index.php index.html index.htm;

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

ln -sf /etc/nginx/sites-available/core /etc/nginx/sites-enabled/core
rm -f /etc/nginx/sites-enabled/default
nginx -t && service nginx restart


# ==== MOLLY ====
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99insecure 2>/dev/null || true
sed -i '/security/s/^/#/' /etc/apt/sources.list 2>/dev/null || true

apt-get update
apt-get install -y nginx php-fpm

PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null || echo "8.4")
service "php${PHP_VER}-fpm" start 2>/dev/null || service php8.4-fpm start 2>/dev/null || service php8.2-fpm start 2>/dev/null || service php-fpm start 2>/dev/null
PHP_SOCK=$(ls -1 /run/php/php*-fpm.sock 2>/dev/null | head -n 1)
[ -z "$PHP_SOCK" ] && PHP_SOCK="/run/php/php${PHP_VER}-fpm.sock"

mkdir -p /var/www/core

cat <<'EOF' > /var/www/core/index.php
<!DOCTYPE html>
<html>
<head><title>Core - Beranda</title></head>
<body>
    <h1>Selamat Datang di Beranda Core Area</h1>
    <p>Node: <?php echo gethostname(); ?></p>
    <p><a href="/profil">Menuju Halaman Profil</a></p>
</body>
</html>
EOF

cat <<'EOF' > /var/www/core/profil.php
<!DOCTYPE html>
<html>
<head><title>Core - Profil</title></head>
<body>
    <h1>Halaman Profil - Core Network K-37</h1>
    <p>Node Server: <?php echo gethostname(); ?> (<?php echo $_SERVER['SERVER_ADDR']; ?>)</p>
    <p>Host Header: <?php echo htmlspecialchars($_SERVER['HTTP_HOST'] ?? '-'); ?></p>
    <p>Client IP (X-Real-IP): <?php echo htmlspecialchars($_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR']); ?></p>
    <p>PHP Version: <?php echo phpversion(); ?></p>
    <p><a href="/">Kembali ke Beranda</a></p>
</body>
</html>
EOF

chown -R www-data:www-data /var/www/core
chmod -R 755 /var/www/core

cat <<EOF > /etc/nginx/sites-available/core
server {
    listen 80;
    server_name core.k37.com oblada.k37.com molly.k37.com;

    root /var/www/core;
    index index.php index.html index.htm;

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

ln -sf /etc/nginx/sites-available/core /etc/nginx/sites-enabled/core
rm -f /etc/nginx/sites-enabled/default
nginx -t && service nginx restart
