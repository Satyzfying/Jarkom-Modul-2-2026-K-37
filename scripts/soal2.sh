#!/bin/bash
# ==============================================================================
# NOMOR 2: Konfigurasi WAN, IP Forwarding, dan NAT Masquerade pada Rootkit
# ==============================================================================

# ==== ROOTKIT ====
# Pastikan antarmuka WAN (eth0) aktif mengambil DHCP dari NAT node
udhcpc -i eth0

# Aktifkan IP forwarding di kernel
sysctl -w net.ipv4.ip_forward=1

# Pasang masquerading untuk seluruh subnet internal 10.82.0.0/16
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o eth0 -s 10.82.0.0/16 -j MASQUERADE
