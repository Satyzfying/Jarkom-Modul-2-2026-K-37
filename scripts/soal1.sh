#!/bin/bash
# ==============================================================================
# NOMOR 1: Konfigurasi Interface & Alamat IP (Kelompok K-37, Prefix 10.82.x.x)
# ==============================================================================

# ==== ROOTKIT (Router Utama) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
  address 10.82.1.1
  netmask 255.255.255.0

auto eth2
iface eth2 inet static
  address 10.82.2.1
  netmask 255.255.255.0

auto eth3
iface eth3 inet static
  address 10.82.3.1
  netmask 255.255.255.0

auto eth4
iface eth4 inet static
  address 10.82.4.1
  netmask 255.255.255.0

auto eth5
iface eth5 inet static
  address 10.82.5.1
  netmask 255.255.255.0
EOF

# ==== PRAB (eth1 - DNS) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.1.2
  netmask 255.255.255.0
  gateway 10.82.1.1
EOF

# ==== TEDD (eth1 - DNS) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.1.3
  netmask 255.255.255.0
  gateway 10.82.1.1
EOF

# ==== OBLADI (eth1 - Static) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.1.4
  netmask 255.255.255.0
  gateway 10.82.1.1
EOF

# ==== DESMOND (eth1 - Static) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.1.5
  netmask 255.255.255.0
  gateway 10.82.1.1
EOF

# ==== OBLADA (eth1 - Dynamic) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.1.6
  netmask 255.255.255.0
  gateway 10.82.1.1
EOF

# ==== MOLLY (eth1 - Dynamic) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.1.7
  netmask 255.255.255.0
  gateway 10.82.1.1
EOF

# ==== ALPHA (eth2 - Klien Sayap Kiri) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.2.2
  netmask 255.255.255.0
  gateway 10.82.2.1
EOF

# ==== BETA (eth2 - Klien Sayap Kiri) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.2.3
  netmask 255.255.255.0
  gateway 10.82.2.1
EOF

# ==== GAMMA (eth2 - Klien Sayap Kiri) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.2.4
  netmask 255.255.255.0
  gateway 10.82.2.1
EOF

# ==== DELTA (eth3 - Klien Sayap Kanan) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.3.2
  netmask 255.255.255.0
  gateway 10.82.3.1
EOF

# ==== EPSILON (eth3 - Klien Sayap Kanan) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.3.3
  netmask 255.255.255.0
  gateway 10.82.3.1
EOF

# ==== ABBEY (eth4 - Reverse Proxy) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.4.2
  netmask 255.255.255.0
  gateway 10.82.4.1
EOF

# ==== PENNY (eth5 - Reverse Proxy) ====
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.5.2
  netmask 255.255.255.0
  gateway 10.82.5.1
EOF
