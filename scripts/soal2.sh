#!/bin/bash


# ==== ROOTKIT ====
dhclient eth0

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o eth0 -s 10.82.0.0/16 -j MASQUERADE
