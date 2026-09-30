#!/bin/bash

# ==== ALPHA (atau Klien lain) ====
apt-get update
apt-get install -y apache2-utils

# 1. Stress test titik akhir www.k37.com (Penny -> Vault Cluster)
ab -n 250 -c 10 http://www.k37.com/

# 2. Stress test titik akhir static.k37.com (Abbey -> Core Cluster)
ab -n 250 -c 10 http://static.k37.com/
