#!/bin/bash

# ==== ALPHA (atau Klien lain) ====
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99insecure 2>/dev/null || true
sed -i '/security/s/^/#/' /etc/apt/sources.list 2>/dev/null || true
apt-get update
apt-get install -y apache2-utils

# 1. Stress test titik akhir www.k37.com (Penny -> Vault Cluster)
ab -n 250 -c 10 http://www.k37.com/

# 2. Stress test titik akhir static.k37.com (Abbey -> Core Cluster)
ab -n 250 -c 10 http://static.k37.com/
