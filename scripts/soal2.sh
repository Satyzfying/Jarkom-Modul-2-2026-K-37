#!/bin/bash


# Ambil IP via DHCP jika ada, atau fallback IP statis NAT
dhclient eth0 2>/dev/null || udhcpc -i eth0 2>/dev/null || {
    ip link set eth0 up
    ip addr add 192.168.122.50/24 dev eth0 2>/dev/null || true
    ip route replace default via 192.168.122.1 dev eth0
}

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o eth0 -s 10.82.0.0/16 -j MASQUERADE
