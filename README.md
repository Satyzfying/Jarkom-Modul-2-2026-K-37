# Jarkom-Modul-2-2026-K-37

Praktikum Jaringan Komputer 2026 - Modul 2 ("The Mesh")

| Nama | NRP | Peran |
|---|---|---|
| Azfaro Zid Ilmi | 5027251018 | Orang 1 - Spesialis DNS & Resolusi Nama |
| Gede Satya Putra Aryanta | 5027251012 | Orang 2 - Spesialis Web Server & Reverse Proxy |

---

## Pembagian Kerja

Pembagian kerja paling adil dan minim konflik dependensi adalah membagi tugas berdasarkan dua domain keahlian teknis: **Infrastruktur DNS** dan **Web/Reverse Proxy**, setelah fondasi jaringan selesai dibangun bersama.

### Fondasi Awal (Dikerjakan Bersama)
* **Soal 1–3 (Setup Jaringan & NAT)**: Bangun topologi GNS3, tetapkan alokasi IP seluruh entitas, aktifkan routing dan NAT di `rootkit`, serta tambahkan resolver awal `192.168.122.1` pada seluruh host non-router.

### Orang 1: Spesialis DNS & Resolusi Nama (Azfaro Zid Ilmi)
* **Soal 4, 6, 8 (Infrastruktur BIND9)**: Konfigurasikan authoritative master di `prab`, slave di `tedd`, mekanisme zone transfer, sinkronisasi serial SOA, serta deklarasi *reverse zone* (PTR).
* **Soal 5, 7 (Zone Records & Hostname)**: Terapkan penamaan *system-wide* seluruh entitas, buat A record untuk tiap node, petakan A record `vault` dan `core`, serta siapkan CNAME kanonik `www` dan `static`.
* **Soal 17, 19 (Fitur Record Tambahan)**: Tambahkan TXT record untuk seluruh entitas klien (`alpha`–`epsilon`) serta CNAME `outbound` ke domain publik dan uji aksesnya via `curl`.
* **Soal 18 (Eksperimen Cache & TTL)**: Atur TTL 15 detik pada A record `abbey`, ubah ke IP fiktif, lalu uji verifikasi 3 fase cache DNS dari sisi klien.

### Orang 2: Spesialis Web Server & Reverse Proxy (Gede Satya Putra Aryanta)
* **Soal 9, 10 (Backend Web Server)**: Konfigurasikan Apache di area *vault* (`obladi`, `desmond`) dengan fitur autoindex `/arsip/`, serta pasang Nginx + PHP-FPM di area *core* (`oblada`, `molly`) dengan *rewrite rule* `/profil`.
* **Soal 11, 14 (Reverse Proxy & Logging)**: Siapkan reverse proxy Apache di `penny` dan Nginx di `abbey`, teruskan header `Host` dan `X-Real-IP`, serta modifikasi format log backend agar mencatat IP asli pengunjung.
* **Soal 12, 13 (Autentikasi & Redirect)**: Pasang Basic Authentication untuk path `/admin` di `penny`, terapkan *redirect* permanen (301) ke `www`, serta *redirect* sementara (302) ke `static`.
* **Soal 15 (Dedicated Path)**: Buat penanganan rute lokal `/eternal` (eksekusi PHP) pada `penny` dan rute `/orion` (statis murni) pada `abbey`.

### Pengujian Akhir & Otomasi (Kolaborasi)
* **Soal 16 (Stress Testing)**: Eksekusi pengujian ApacheBench (250 request, konkurensi 10) dari `alpha` ke domain kanonik, sementara rekan memantau stabilitas proxy dan log backend.
* **Soal 20 (Persistensi & Scripting)**: Rapikan seluruh script instalasi ke dalam direktori `/root` masing-masing node, uji *reboot* untuk memastikan semua layanan autostart, dan ekspor project GNS3.

---

## Daftar Isi

- [Informasi Topologi & Pembagian IP](#informasi-topologi--pembagian-ip)
- [Nomor 1 - Satya & Azfaro](#nomor-1---satya--azfaro)
- [Nomor 2 - Satya & Azfaro](#nomor-2---satya--azfaro)
- [Nomor 3 - Satya & Azfaro](#nomor-3---satya--azfaro)
- [Nomor 4 - Azfaro](#nomor-4---azfaro)
- [Nomor 5 - Azfaro](#nomor-5---azfaro)
- [Nomor 6 - Azfaro](#nomor-6---azfaro)
- [Nomor 7 - Azfaro](#nomor-7---azfaro)
- [Nomor 8 - Azfaro](#nomor-8---azfaro)
- [Nomor 9 - Satya](#nomor-9---satya)
- [Nomor 10 - Satya](#nomor-10---satya)
- [Nomor 11 - Satya](#nomor-11---satya)
- [Nomor 12 - Satya](#nomor-12---satya)
- [Nomor 13 - Satya](#nomor-13---satya)
- [Nomor 14 - Satya](#nomor-14---satya)
- [Nomor 15 - Satya](#nomor-15---satya)

---

## Informasi Topologi & Pembagian IP

- **Kelompok:** K-37
- **Prefix Subnet:** `10.82.x.x` (Netmask: `/24` atau `255.255.255.0`)
- **Router Utama:** `rootkit` (6 antarmuka: `eth0` ke internet/NAT, `eth1` s/d `eth5` ke masing-masing subnet internal)
- **DNS Resolver Awal Non-Router:** `192.168.122.1`

| Node | Antarmuka | Alamat IP | Netmask | Gateway | Subnet / Keterangan |
|---|---|---|---|---|---|
| **rootkit** | `eth0`<br>`eth1`<br>`eth2`<br>`eth3`<br>`eth4`<br>`eth5` | DHCP (NAT)<br>`10.82.1.1`<br>`10.82.2.1`<br>`10.82.3.1`<br>`10.82.4.1`<br>`10.82.5.1` | -<br>`255.255.255.0`<br>`255.255.255.0`<br>`255.255.255.0`<br>`255.255.255.0`<br>`255.255.255.0` | -<br>-<br>-<br>-<br>-<br>- | Router Utama (Internet Gateway)<br>Subnet eth1 (Server DNS & Web)<br>Subnet eth2 (Klien Sayap Kiri)<br>Subnet eth3 (Klien Sayap Kanan)<br>Subnet eth4 (Reverse Proxy Abbey)<br>Subnet eth5 (Reverse Proxy Penny) |
| **prab** | `eth0` | `10.82.1.2` | `255.255.255.0` | `10.82.1.1` | DNS Master (Subnet eth1) |
| **tedd** | `eth0` | `10.82.1.3` | `255.255.255.0` | `10.82.1.1` | DNS Slave (Subnet eth1) |
| **obladi** | `eth0` | `10.82.1.4` | `255.255.255.0` | `10.82.1.1` | Static Web Server (Area Vault) |
| **desmond** | `eth0` | `10.82.1.5` | `255.255.255.0` | `10.82.1.1` | Static Web Server (Area Vault) |
| **oblada** | `eth0` | `10.82.1.6` | `255.255.255.0` | `10.82.1.1` | Dynamic Web Server (Area Core) |
| **molly** | `eth0` | `10.82.1.7` | `255.255.255.0` | `10.82.1.1` | Dynamic Web Server (Area Core) |
| **alpha** | `eth0` | `10.82.2.2` | `255.255.255.0` | `10.82.2.1` | Klien Sayap Kiri (Subnet eth2) |
| **beta** | `eth0` | `10.82.2.3` | `255.255.255.0` | `10.82.2.1` | Klien Sayap Kiri (Subnet eth2) |
| **gamma** | `eth0` | `10.82.2.4` | `255.255.255.0` | `10.82.2.1` | Klien Sayap Kiri (Subnet eth2) |
| **delta** | `eth0` | `10.82.3.2` | `255.255.255.0` | `10.82.3.1` | Klien Sayap Kanan (Subnet eth3) |
| **epsilon** | `eth0` | `10.82.3.3` | `255.255.255.0` | `10.82.3.1` | Klien Sayap Kanan (Subnet eth3) |
| **abbey** | `eth0` | `10.82.4.2` | `255.255.255.0` | `10.82.4.1` | Reverse Proxy Server Nginx (Subnet eth4) |
| **penny** | `eth0` | `10.82.5.2` | `255.255.255.0` | `10.82.5.1` | Reverse Proxy Server Apache (Subnet eth5) |

---

# Laporan Praktikum Modul 2

## Nomor 1 - Satya & Azfaro

---

### Deskripsi Soal
Intinya di nomor 1 ini kita disuruh bangun topologi sesuai gambar di modul dan ngatur IP statis beserta default gateway untuk semua entitas yang ada di jaringan.

### Langkah Konfigurasi (GNS3)

Semua konfigurasi antarmuka kita simpan di `/etc/network/interfaces` pada masing-masing node.

**1. Di Router Utama (`rootkit`):**  
Buka console `rootkit`, masukkan konfigurasi untuk eth0 (DHCP NAT) dan eth1 s/d eth5 (IP statis 10.82.x.1):

```bash
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
service networking restart
```

**2. Di Seluruh Host Non-Router:**  
Tiap host internal kita pasang IP statis pada `eth0` dan gateway diarahkan ke router `rootkit` (`10.82.x.1`).

Contoh pada node `prab` (`10.82.1.2`):
```bash
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.82.1.2
  netmask 255.255.255.0
  gateway 10.82.1.1
EOF
service networking restart
```
*(Lakukan hal yang sama untuk host lainnya sesuai tabel pembagian IP di atas).*

### Script
Seluruh konfigurasi nomor 1 disimpan di [`scripts/soal1.sh`](scripts/soal1.sh).

### Verifikasi & Pembuktian
Tinggal kita cek apakah IP sudah terpasang dengan perintah:
```bash
ip -br a
```

![Topologi Jaringan Modul 2](Assets/1-topology.png)  
*(Tangkapan layar topologi jaringan Modul 2)*

![Bukti Konfigurasi IP Rootkit](Assets/1-rootkit-ip.png)  
*(Tangkapan layar hasil perintah `ip -br a` pada rootkit)*

---

## Nomor 2 - Satya & Azfaro

---

### Deskripsi Soal
Di nomor ini intinya bikin si `rootkit` bisa nyambung internet via eth0 (DHCP NAT) sekaligus jadi gerbang buat semua subnet internal kelompok kita (`10.82.0.0/16`) lewat NAT Masquerade dan aktifin `ip_forward`.

### Langkah Konfigurasi (GNS3)

Buka console **`rootkit`**, lalu jalankan perintah berikut:

```bash
# 1. Ambil IP dan gateway internet lewat DHCP NAT
udhcpc -i eth0

# 2. Aktifkan IP forwarding di kernel Linux
sysctl -w net.ipv4.ip_forward=1

# 3. Pasang aturan MASQUERADE untuk semua subnet kelompok (10.82.0.0/16)
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o eth0 -s 10.82.0.0/16 -j MASQUERADE
```

### Script
Seluruh konfigurasi nomor 2 disimpan di [`scripts/soal2.sh`](scripts/soal2.sh).

### Verifikasi & Pembuktian
Tinggal cek tabel NAT iptables dan coba ping internet dari router:
```bash
iptables -t nat -L -v -n
ping -c 3 8.8.8.8
```

![Bukti Aturan NAT Masquerade](Assets/2-nat-masquerade.png)  
*(Tangkapan layar daftar aturan iptables NAT POSTROUTING pada rootkit)*

![Bukti Ping Internet Rootkit](Assets/2-rootkit-ping.png)  
*(Tangkapan layar pengujian ping ke 8.8.8.8 dari rootkit)*

---

## Nomor 3 - Satya & Azfaro

---

### Deskripsi Soal
Biar semua host non-router bisa ngeresolve domain sebelum DNS lokal kita bangun, kita pasang resolver awal `nameserver 192.168.122.1` di `/etc/resolv.conf` masing-masing host. Karena routing dan NAT di rootkit udah jalan, semua host otomatis bisa internetan dan saling terhubung antar-subnet.

### Langkah Konfigurasi (GNS3)

Di seluruh host non-router (`prab`, `tedd`, `obladi`, `desmond`, `oblada`, `molly`, `alpha`, `beta`, `gamma`, `delta`, `epsilon`, `abbey`, `penny`), jalankan:

```bash
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

### Script
Seluruh konfigurasi nomor 3 disimpan di [`scripts/soal3.sh`](scripts/soal3.sh).

### Verifikasi & Pembuktian
Kita uji dua hal dari salah satu klien (misalnya `alpha`):
1. **Cek resolusi DNS dan koneksi internet:**
   ```bash
   ping -c 3 google.com
   ```
2. **Cek koneksi lintas subnet (inter-subnet routing via router rootkit):**
   ```bash
   ping -c 3 10.82.1.2  # Ping ke prab di Subnet 1
   ping -c 3 10.82.3.2  # Ping ke delta di Subnet 3
   ping -c 3 10.82.4.2  # Ping ke abbey di Subnet 4
   ```

![Bukti Ping Resolv DNS](Assets/3-dns-ping.png)  
*(Tangkapan layar pengujian ping google.com dari klien)*

![Bukti Ping Antar Subnet](Assets/3-inter-subnet-ping.png)  
*(Tangkapan layar pengujian ping lintas subnet/switch)*

---

## Nomor 4 - Azfaro

---

### Deskripsi Soal
Bangun DNS Server menggunakan BIND9 dengan `prab` sebagai authoritative master zona `k37.com` dan `tedd` sebagai slave. Pasang SOA yang menunjuk ke `prab.k37.com`, NS record untuk `prab` dan `tedd`, A record masing-masing, serta apex `k37.com` mengarah ke `penny` (`10.82.5.2`). Aktifkan notify dan allow-transfer ke `tedd`, set forwarder ke `192.168.122.1`. Terakhir, perbarui resolver di seluruh host non-router: IP prab, IP tedd, lalu 192.168.122.1.

### Langkah Konfigurasi (GNS3)

**1. Di DNS Master (`prab`):**  
Install paket bind9:
```bash
apt update && apt install bind9 bind9-utils bind9-dnsutils -y
```

Konfigurasi forwarder di `/etc/bind/named.conf.options`:
```bash
root@prab:~# cat > /etc/bind/named.conf.options <<'EOF'
options {
  directory "/var/cache/bind";

  forwarders {
    192.168.122.1;
  };

  recursion yes;
};
EOF
```
<img src="Assets/soal4_Konfigurasi prab.png" width="500">

Daftarkan zona `k37.com` di `/etc/bind/named.conf.local`:
```bash
root@prab:~# cat > /etc/bind/named.conf.local <<'EOF'
zone "k37.com" {
  type master;
  file "/var/cache/bind/db.k37.com";
  notify yes;
  allow-transfer {
    10.82.1.3;
  };
};
EOF
```
<img src="Assets/soal4_configurasi local.png" width="500">

Buat zone file `/var/cache/bind/db.k37.com`:
```bash
root@prab:~# cat > /var/cache/bind/db.k37.com <<'EOF'
$TTL 300

@   IN  SOA     prab.k37.com. admin.k37.com. (
        2026092901
        3600
        600
        86400
        300
)

    IN  NS      prab.k37.com.
    IN  NS      tedd.k37.com.

@       IN  A       10.82.5.2
prab    IN  A       10.82.1.2
tedd    IN  A       10.82.1.3
EOF
service bind9 restart
```
<img src="Assets/soal4_konfigurasi k37.png" width="500">

Validasi zone file:
```bash
named-checkzone k37.com /var/cache/bind/db.k37.com
```

**2. Di DNS Slave (`tedd`):**  
Install bind9 dan daftarkan slave zone di `/etc/bind/named.conf.local`:
```bash
apt update && apt install bind9 bind9-utils bind9-dnsutils -y

root@tedd:~# cat > /etc/bind/named.conf.local <<'EOF'
zone "k37.com" {
  type slave;
  masters {
    10.82.1.2;
  };
  file "/var/cache/bind/db.k37.com";
};
EOF
service bind9 restart
```
<img src="Assets/soal4_konfigurasited.png" width="500">

**3. Update Resolver di Seluruh Host Non-Router:**  
Jalankan di seluruh node non-router:
```bash
cat > /etc/resolv.conf <<'EOF'
nameserver 10.82.1.2
nameserver 10.82.1.3
nameserver 192.168.122.1
EOF
```

### Script
Seluruh konfigurasi nomor 4 disimpan di [`scripts/soal4.sh`](scripts/soal4.sh).

### Verifikasi & Pembuktian
Tes query DNS di `prab` dan `tedd`:
```bash
root@prab:~# dig @127.0.0.1 k37.com +short
10.82.5.2
root@tedd:~# dig @127.0.0.1 k37.com +short
10.82.5.2
```
<img src="Assets/soal4_tes dns pada ted.png" width="600">

Validasi dari sisi client (`alpha`):
```bash
dig k37.com
```
<img src="Assets/soal4_validasi dns master.png" width="600">

---

## Nomor 5 - Azfaro

---

### Deskripsi Soal
Namai semua hostname sesuai glosarium topologi dan verifikasi secara system-wide. Buat domain untuk masing-masing node sesuai namanya (misal: `alpha.k37.com`) di DNS Master `prab` lengkap dengan alokasi IP-nya.

### Langkah Konfigurasi (GNS3)

**1. Konfigurasi Hostname di Setiap Node:**  
Di masing-masing node kita set hostname-nya:
```bash
echo alpha > /etc/hostname && hostname alpha
```
*(Lakukan hal serupa untuk beta, gamma, delta, epsilon, abbey, penny, obladi, desmond, oblada, dan molly).*

Daftar IP dan hostname yang didapat:  
<img src="Assets/soal5_Ip hostname.png" width="500">

**2. Tambahkan Record ke Zone File di `prab`:**  
Buka console `prab`, tambahkan seluruh A record node ke `/var/cache/bind/db.k37.com`:
```bash
root@prab:~# cat > /var/cache/bind/db.k37.com <<'EOF'
$TTL 300

@   IN  SOA     prab.k37.com. admin.k37.com. (
        2026092902
        3600
        600
        86400
        300
)

    IN  NS      prab.k37.com.
    IN  NS      tedd.k37.com.

@       IN  A   10.82.5.2
prab    IN  A   10.82.1.2
tedd    IN  A   10.82.1.3

alpha       IN  A   10.82.2.2
beta        IN  A   10.82.2.3
gamma       IN  A   10.82.2.4
delta       IN  A   10.82.3.2
epsilon     IN  A   10.82.3.3
abbey       IN  A   10.82.4.2
penny       IN  A   10.82.5.2
obladi      IN  A   10.82.1.4
desmond     IN  A   10.82.1.5
oblada      IN  A   10.82.1.6
moly        IN  A   10.82.1.7
EOF
service bind9 restart
```
<img src="Assets/soal5_konfigurasi master.png" width="500">

### Script
Seluruh konfigurasi nomor 5 disimpan di [`scripts/soal5.sh`](scripts/soal5.sh).

### Verifikasi & Pembuktian
Coba ping domain hostname dari client `alpha`:
```bash
ping -c 2 beta.k37.com
ping -c 2 gamma.k37.com
ping -c 2 delta.k37.com
```
<img src="Assets/soal5_validasi.png" width="600">

---

## Nomor 6 - Azfaro

---

### Deskripsi Soal
Pastikan zone transfer berjalan lancar dan salinan zona terbaru dari `prab` berhasil diterima oleh `tedd`. Nilai nomor serial SOA di kedua server DNS harus sama persis.

### Langkah Konfigurasi & Verifikasi (GNS3)

Tinggal bandingkan nomor serial SOA langsung dari DNS Master (`prab`) dan DNS Slave (`tedd`):

```bash
dig @10.82.1.2 k37.com SOA +short
dig @10.82.1.3 k37.com SOA +short
```

Output di terminal:
```bash
root@prab:~# dig @10.82.1.2 k37.com SOA +short
prab.k37.com. admin.k37.com. 2026092902 3600 600 86400 300
root@prab:~# dig @10.82.1.3 k37.com SOA +short
prab.k37.com. admin.k37.com. 2026092902 3600 600 86400 300
```
Serial keduanya sama-sama `2026092902`, membuktikan zone transfer berhasil sinkron sempurna.

<img src="Assets/soal6.png" width="600">

### Script
Seluruh konfigurasi nomor 6 disimpan di [`scripts/soal6.sh`](scripts/soal6.sh).

---

## Nomor 7 - Azfaro

---

### Deskripsi Soal
Tambahkan A record untuk `vault.k37.com` (IP obladi & desmond) dan `core.k37.com` (IP oblada & molly). Buat juga alias CNAME `www.k37.com` mengarah ke `penny.k37.com` serta `static.k37.com` mengarah ke `abbey.k37.com`. Naikkan serial number dan uji dari client.

### Langkah Konfigurasi (GNS3)

Di DNS Master (`prab`), kita tambahkan record baru ke file zone dan naikkan serial number SOA:

```bash
cat <<EOF >> /var/cache/bind/db.k37.com

vault       IN  A       10.82.1.4
vault       IN  A       10.82.1.5

core        IN  A       10.82.1.6
core        IN  A       10.82.1.7

www         IN  CNAME   penny.k37.com.
static      IN  CNAME   abbey.k37.com.
EOF

# Naikkan serial SOA dari 2026092902 jadi 2026092903
sed -i 's/2026092902/2026092903/' /var/cache/bind/db.k37.com
rndc reload
```
<img src="Assets/soal7_1.png" width="500">

### Script
Seluruh konfigurasi nomor 7 disimpan di [`scripts/Soal7.sh`](scripts/Soal7.sh).

### Verifikasi & Pembuktian
Jalankan query `dig` dari client (misal `gamma`):
```bash
dig vault.k37.com A +short
dig core.k37.com A +short
dig www.k37.com CNAME +short
dig static.k37.com CNAME +short
```
Hasil yang diharapkan:
```text
10.82.1.4
10.82.1.5
10.82.1.6
10.82.1.7
penny.k37.com.
abbey.k37.com.
```
<img src="Assets/soal7_2.png" width="400"> <img src="Assets/soal7_3.png" width="400">

---

## Nomor 8 - Azfaro

---

### Deskripsi Soal
Di `prab` deklarasikan reverse zone untuk segmen jaringan vault & core (`10.82.1.0/24`), abbey (`10.82.4.0/24`), dan penny (`10.82.5.0/24`). Di `tedd` tarik reverse zone tersebut sebagai slave, isi PTR record untuk hostname terkait, dan pastikan pencarian balik IP mengembalikan hostname yang benar.

### Langkah Konfigurasi (GNS3)

**1. Di Master (`prab`):**  
Deklarasikan reverse zone di `/etc/bind/named.conf.local`:
```bash
cat > /etc/bind/named.conf.local <<'EOF'
zone "k37.com" {
    type master;
    file "/var/cache/bind/db.k37.com";
    notify yes;
    allow-transfer { 10.82.1.3; };
};

zone "1.82.10.in-addr.arpa" {
    type master;
    file "/var/cache/bind/db.10.82.1";
    notify yes;
    allow-transfer { 10.82.1.3; };
};

zone "4.82.10.in-addr.arpa" {
    type master;
    file "/var/cache/bind/db.10.82.4";
    notify yes;
    allow-transfer { 10.82.1.3; };
};

zone "5.82.10.in-addr.arpa" {
    type master;
    file "/var/cache/bind/db.10.82.5";
    notify yes;
    allow-transfer { 10.82.1.3; };
};
EOF
```

Buat reverse zone file untuk Subnet 1 (`db.10.82.1`):
```bash
cat > /var/cache/bind/db.10.82.1 <<'EOF'
$TTL 300
@ IN SOA prab.k37.com. admin.k37.com. (
    2026092901
    3600
    600
    86400
    300
)
@ IN NS prab.k37.com.
@ IN NS tedd.k37.com.

4 IN PTR obladi.k37.com.
5 IN PTR desmond.k37.com.
6 IN PTR oblada.k37.com.
7 IN PTR molly.k37.com.
EOF
```
<img src="Assets/soal8_1.png" width="500">

Buat reverse zone file untuk Subnet 4 (`db.10.82.4`) dan Subnet 5 (`db.10.82.5`):
```bash
cat > /var/cache/bind/db.10.82.4 <<'EOF'
$TTL 300
@ IN SOA prab.k37.com. admin.k37.com. (
    2026092901
    3600
    600
    86400
    300
)
@ IN NS prab.k37.com.
@ IN NS tedd.k37.com.

2 IN PTR abbey.k37.com.
EOF

cat > /var/cache/bind/db.10.82.5 <<'EOF'
$TTL 300
@ IN SOA prab.k37.com. admin.k37.com. (
    2026092901
    3600
    600
    86400
    300
)
@ IN NS prab.k37.com.
@ IN NS tedd.k37.com.

2 IN PTR penny.k37.com.
EOF
service bind9 restart
```

**2. Di Slave (`tedd`):**  
Daftarkan reverse zone tipe slave di `/etc/bind/named.conf.local`:
```bash
cat > /etc/bind/named.conf.local <<'EOF'
zone "k37.com" {
    type slave;
    masters { 10.82.1.2; };
    file "/var/cache/bind/db.k37.com";
};

zone "1.82.10.in-addr.arpa" {
    type slave;
    masters { 10.82.1.2; };
    file "/var/cache/bind/db.10.82.1";
};

zone "4.82.10.in-addr.arpa" {
    type slave;
    masters { 10.82.1.2; };
    file "/var/cache/bind/db.10.82.4";
};

zone "5.82.10.in-addr.arpa" {
    type slave;
    masters { 10.82.1.2; };
    file "/var/cache/bind/db.10.82.5";
};
EOF
service bind9 restart
```
<img src="Assets/soal8_2.png" width="500">

### Script
Seluruh konfigurasi nomor 8 disimpan di [`scripts/soal8.sh`](scripts/soal8.sh).

### Verifikasi & Pembuktian
Uji query reverse DNS (PTR) dari client atau master:
```bash
dig @10.82.1.2 -x 10.82.1.4 +short
dig @10.82.1.2 -x 10.82.1.5 +short
dig @10.82.1.2 -x 10.82.4.2 +short
dig @10.82.1.2 -x 10.82.5.2 +short
```
Hasil yang diharapkan:
```text
obladi.k37.com.
desmond.k37.com.
abbey.k37.com.
penny.k37.com.
```

---

## Nomor 9 - Satya

---

### Deskripsi Soal
Di area vault (`obladi` dan `desmond`), pasang web server statis pakai Apache. Buka folder direktori `/arsip/` dengan fitur autoindex (directory listing) aktif biar seluruh file di dalamnya bisa ditelusuri lewat browser/curl. Akses pengujian wajib lewat hostname (`vault.k37.com/arsip/`), bukan IP address.

### Langkah Konfigurasi (GNS3)

Jalankan perintah ini di console **`obladi`** dan **`desmond`**:

```bash
# 1. Install Apache2
apt-get update && apt-get install -y apache2

# 2. Siapkan folder /arsip/ dan beberapa file dummy (tanpa index.html)
mkdir -p /var/www/vault/arsip
echo "Arsip dokumen rahasia 1" > /var/www/vault/arsip/dokumen1.txt
echo "Laporan inventaris data statis K-37" > /var/www/vault/arsip/inventaris.pdf
chown -R www-data:www-data /var/www/vault
chmod -R 755 /var/www/vault

# 3. Konfigurasi VirtualHost dengan Options +Indexes khusus untuk /arsip
cat <<EOF > /etc/apache2/sites-available/vault.conf
<VirtualHost *:80>
    ServerName vault.k37.com
    ServerAlias obladi.k37.com desmond.k37.com
    DocumentRoot /var/www/vault

    <Directory /var/www/vault>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    <Directory /var/www/vault/arsip>
        Options +Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/vault_error.log
    CustomLog \${APACHE_LOG_DIR}/vault_access.log combined
</VirtualHost>
EOF

# 4. Aktifkan modul autoindex dan site vault
a2enmod autoindex dir
a2dissite 000-default.conf
a2ensite vault.conf
service apache2 restart
```

### Script
Seluruh konfigurasi nomor 9 disimpan di [`scripts/soal9.sh`](scripts/soal9.sh).

### Verifikasi & Pembuktian
Dari salah satu client (misal `gamma`, `alpha`, atau `delta`), uji akses lewat hostname:

```bash
# Cek respons header (HTTP 200 OK)
curl -i http://vault.k37.com/arsip/

# Cek tampilan autoindex daftar file
curl -s http://vault.k37.com/arsip/
```

Output terminal yang diharapkan:
```html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
 <head>
  <title>Index of /arsip</title>
 </head>
 <body>
<h1>Index of /arsip</h1>
<table>
  ...
  <tr><td><a href="dokumen1.txt">dokumen1.txt</a></td>...</tr>
  <tr><td><a href="inventaris.pdf">inventaris.pdf</a></td>...</tr>
</table>
</body></html>
```

---

## Nomor 10 - Satya

---

### Deskripsi Soal
Di area core (`oblada` dan `molly`), pasang layanan web dinamis PHP-FPM pakai Nginx. Buat aplikasi sederhana beranda (`index.php`) dan profil (`profil.php`). Pasang aturan rewrite Nginx biar akses ke `/profil` bisa dibuka dengan URL bersih tanpa ekstensi `.php`. Akses pengujian wajib lewat hostname.

### Langkah Konfigurasi (GNS3)

Jalankan perintah ini di console **`oblada`** dan **`molly`**:

```bash
# 1. Install Nginx dan PHP-FPM
apt-get update && apt-get install -y nginx php-fpm

# 2. Pastikan service PHP-FPM jalan dan ambil socket-nya
service php8.2-fpm start 2>/dev/null || service php-fpm start 2>/dev/null
PHP_SOCK=$(ls -1 /run/php/php*-fpm.sock 2>/dev/null | head -n 1)
[ -z "$PHP_SOCK" ] && PHP_SOCK="/run/php/php8.2-fpm.sock"

# 3. Buat folder dan file beranda & profil
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

# 4. Konfigurasi Nginx Server Block dengan rewrite /profil
cat <<EOF > /etc/nginx/sites-available/core
server {
    listen 80;
    server_name core.k37.com oblada.k37.com molly.k37.com;

    root /var/www/core;
    index index.php index.html index.htm;

    # Rewrite URL bersih /profil ke /profil.php
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
```

### Script
Seluruh konfigurasi nomor 10 disimpan di [`scripts/soal10.sh`](scripts/soal10.sh).

### Verifikasi & Pembuktian
Dari client (`gamma` atau `delta`), uji akses beranda dan profil URL bersih:

```bash
# 1. Akses Beranda
curl -i http://core.k37.com/

# 2. Akses Clean URL /profil (tanpa .php)
curl -i http://core.k37.com/profil
curl -s http://core.k37.com/profil
```

Output terminal yang diharapkan (`curl -i http://core.k37.com/profil`):
```text
HTTP/1.1 200 OK
Server: nginx/...
Content-Type: text/html; charset=UTF-8

<!DOCTYPE html>
<html>
<head><title>Core - Profil</title></head>
<body>
    <h1>Halaman Profil - Core Network K-37</h1>
    <p>Node Server: oblada (10.82.1.6)</p>
    <p>Host Header: core.k37.com</p>
    ...
```

---

## Nomor 11 - Satya

---

### Deskripsi Soal
Konfigurasikan **Penny** (Apache) sebagai reverse proxy & load balancer ke area vault (`obladi` & `desmond`). Sementara itu, konfigurasikan **Abbey** (Nginx) sebagai reverse proxy & load balancer ke area core (`oblada` & `molly`). Keduanya wajib meneruskan header **Host** dan **X-Real-IP** ke backend. Buktikan distribusi lalu lintasnya.

### Langkah Konfigurasi (GNS3)

**1. Di Node `penny` (Apache Reverse Proxy):**
```bash
apt-get update && apt-get install -y apache2
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers

cat <<EOF > /etc/apache2/sites-available/penny.conf
<VirtualHost *:80>
    ServerName penny.k37.com
    ServerAlias www.k37.com k37.com

    <Proxy balancer://vaultcluster>
        BalancerMember http://10.82.1.4:80
        BalancerMember http://10.82.1.5:80
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPreserveHost On
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/

    ErrorLog \${APACHE_LOG_DIR}/penny_error.log
    CustomLog \${APACHE_LOG_DIR}/penny_access.log combined
</VirtualHost>
EOF

a2dissite 000-default.conf
a2ensite penny.conf
service apache2 restart
```

**2. Di Node `abbey` (Nginx Reverse Proxy):**
```bash
apt-get update && apt-get install -y nginx

cat <<EOF > /etc/nginx/sites-available/abbey
upstream core_backend {
    server 10.82.1.6:80;
    server 10.82.1.7:80;
}

server {
    listen 80;
    server_name abbey.k37.com static.k37.com;

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

ln -sf /etc/nginx/sites-available/abbey /etc/nginx/sites-enabled/abbey
rm -f /etc/nginx/sites-enabled/default
nginx -t && service nginx restart
```

### Script
Seluruh konfigurasi nomor 11 disimpan di [`scripts/soal11.sh`](scripts/soal11.sh).

### Verifikasi & Pembuktian
Uji distribusi trafik dari client (`gamma` atau `delta`):

1. **Uji Penny (Apache Balancer ke Vault):**
   ```bash
   for i in {1..4}; do curl -s http://penny.k37.com/ | grep -i "Server"; done
   ```
   Respons bergantian antara `Obladi` dan `Desmond`.

2. **Uji Abbey (Nginx Balancer ke Core + Forwarding Header):**
   ```bash
   for i in {1..4}; do
       echo "--- Request $i ---"
       curl -s http://abbey.k37.com/profil | grep -E "Node Server|Host Header|Client IP"
   done
   ```
   Output terminal yang diharapkan:
   ```text
   --- Request 1 ---
   <p>Node Server: oblada (10.82.1.6)</p>
   <p>Host Header: abbey.k37.com</p>
   <p>Client IP (X-Real-IP): 10.82.2.4</p>
   --- Request 2 ---
   <p>Node Server: molly (10.82.1.7)</p>
   <p>Host Header: abbey.k37.com</p>
   <p>Client IP (X-Real-IP): 10.82.2.4</p>
   ```

---

## Nomor 12 - Satya

---

### Deskripsi Soal
Terdapat ruang khusus di `penny` yang menyimpan dokumen rahasia sindikat pada path `/admin`. Pasang proteksi **HTTP Basic Authentication** untuk path `/admin`. Akses tanpa kredensial atau password salah harus ditolak (401), dan hanya boleh masuk jika menggunakan:
- **Username:** `prabs`
- **Password:** `pakar_pinter_jadi_gob***`

### Langkah Konfigurasi (GNS3)

Buka console node **`penny`**, lalu jalankan:

```bash
# 1. Install apache2-utils untuk perintah htpasswd
apt-get update && apt-get install -y apache2-utils

# 2. Buat folder lokal /admin dan file dokumen rahasianya di Penny
mkdir -p /var/www/penny/admin
cat <<'EOF' > /var/www/penny/admin/index.html
<!DOCTYPE html>
<html>
<head><title>Dokumen Rahasia</title></head>
<body>
    <h1>Ruang Khusus Sindikat - Penny</h1>
    <p>Selamat datang, Agen <strong>prabs</strong>!</p>
</body>
</html>
EOF
chown -R www-data:www-data /var/www/penny
chmod -R 755 /var/www/penny

# 3. Buat file kredensial .htpasswd
htpasswd -bc /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'
chmod 640 /etc/apache2/.htpasswd
chown root:www-data /etc/apache2/.htpasswd

# 4. Tambahkan proteksi di VirtualHost Penny (kecualikan /admin dari reverse proxy)
cat <<EOF > /etc/apache2/sites-available/penny.conf
<VirtualHost *:80>
    ServerName penny.k37.com
    ServerAlias www.k37.com k37.com

    DocumentRoot /var/www/penny

    # Kecualikan /admin agar ditangani lokal oleh Penny
    ProxyPass /admin !
    Alias /admin /var/www/penny/admin

    <Location /admin>
        AuthType Basic
        AuthName "Dokumen Rahasia Sindikat"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Location>

    # Balancer cluster ke Area Vault
    <Proxy balancer://vaultcluster>
        BalancerMember http://10.82.1.4:80
        BalancerMember http://10.82.1.5:80
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPreserveHost On
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/
</VirtualHost>
EOF

service apache2 restart
```

### Script
Seluruh konfigurasi nomor 12 disimpan di [`scripts/soal12.sh`](scripts/soal12.sh).

### Verifikasi & Pembuktian
Dari client (`gamma` atau `alpha`), uji akses dengan 3 skenario:

```bash
# 1. Tanpa kredensial -> Ditolak (HTTP 401 Unauthorized)
curl -i http://penny.k37.com/admin

# 2. Password salah -> Ditolak (HTTP 401 Unauthorized)
curl -i -u prabs:passwordsalah http://penny.k37.com/admin

# 3. Kredensial benar -> Berhasil (HTTP 200 OK)
curl -i -u prabs:pakar_pinter_jadi_gob*** http://penny.k37.com/admin
```

Output terminal saat kredensial benar:
```text
HTTP/1.1 200 OK
Date: ...
Server: Apache/...
Content-Type: text/html; charset=UTF-8

<!DOCTYPE html>
<html>
<head><title>Dokumen Rahasia</title></head>
<body>
    <h1>Ruang Khusus Sindikat - Penny</h1>
    <p>Selamat datang, Agen <strong>prabs</strong>!</p>
</body>
</html>
```

---

## Nomor 13 - Satya

---

### Deskripsi Soal
Setiap entitas dari luar harus memanggil gerbang dengan nama kanoniknya:
- Akses ke **IP penny** (`10.82.5.2`) atau domain **`penny.k37.com`** harus di-redirect permanen (**status code 301**) ke **`www.k37.com`**.
- Akses ke **IP abbey** (`10.82.4.2`) atau domain **`abbey.k37.com`** harus di-redirect sementara (**status code 302**) ke **`static.k37.com`**.

### Langkah Konfigurasi (GNS3)

**1. Di Node `penny` (Apache Redirect 301):**  
Aktifkan modul rewrite, lalu pisahkan VirtualHost untuk redirect 301 dan VirtualHost kanonik `www.k37.com`:
```bash
a2enmod rewrite

cat <<EOF > /etc/apache2/sites-available/penny.conf
# VirtualHost 1: Redirect 301 untuk IP 10.82.5.2 & penny.k37.com
<VirtualHost *:80>
    ServerName penny.k37.com
    ServerAlias 10.82.5.2

    RewriteEngine On
    RewriteRule ^(.*)$ http://www.k37.com\$1 [R=301,L]
</VirtualHost>

# VirtualHost 2: Host Kanonik www.k37.com
<VirtualHost *:80>
    ServerName www.k37.com
    ServerAlias k37.com
    DocumentRoot /var/www/penny

    ProxyPass /admin !
    Alias /admin /var/www/penny/admin

    <Location /admin>
        AuthType Basic
        AuthName "Dokumen Rahasia Sindikat"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Location>

    <Proxy balancer://vaultcluster>
        BalancerMember http://10.82.1.4:80
        BalancerMember http://10.82.1.5:80
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPreserveHost On
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"
    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/
</VirtualHost>
EOF
service apache2 restart
```

**2. Di Node `abbey` (Nginx Redirect 302):**  
Buat server block default untuk menangkap IP `10.82.4.2` dan domain `abbey.k37.com`, lalu `return 302` ke `static.k37.com`:
```bash
cat <<EOF > /etc/nginx/sites-available/abbey
upstream core_backend {
    server 10.82.1.6:80;
    server 10.82.1.7:80;
}

# Redirect 302 Sementara
server {
    listen 80 default_server;
    server_name abbey.k37.com 10.82.4.2;
    return 302 http://static.k37.com\$request_uri;
}

# Host Kanonik
server {
    listen 80;
    server_name static.k37.com;

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
nginx -t && service nginx restart
```

### Script
Seluruh konfigurasi nomor 13 disimpan di [`scripts/soal13.sh`](scripts/soal13.sh).

### Verifikasi & Pembuktian
Dari client, uji status code respons:

```bash
# 1. Cek Redirect 301 Penny (Harus 301 Moved Permanently -> Location: http://www.k37.com/)
curl -i http://penny.k37.com/
curl -i http://10.82.5.2/

# 2. Cek Redirect 302 Abbey (Harus 302 Found / Moved Temporarily -> Location: http://static.k37.com/)
curl -i http://abbey.k37.com/
curl -i http://10.82.4.2/

# 3. Uji Follow Redirect
curl -L http://penny.k37.com/
curl -L http://abbey.k37.com/profil
```

Output terminal saat cek redirect 301 Penny:
```text
HTTP/1.1 301 Moved Permanently
Date: ...
Location: http://www.k37.com/
Content-Type: text/html; charset=iso-8859-1
```

Output terminal saat cek redirect 302 Abbey:
```text
HTTP/1.1 302 Moved Temporarily
Server: nginx/...
Location: http://static.k37.com/
Connection: keep-alive
```

---

## Nomor 14 - Satya

---

### Deskripsi Soal
Pastikan *access log* pada setiap server web di **area vault** (`obladi`, `desmond`) maupun **area core** (`oblada`, `molly`) mencatat alamat **IP asli client**, bukan mencatat IP proxy dari Penny (`10.82.5.2`) atau Abbey (`10.82.4.2`).

### Langkah Konfigurasi (GNS3)

**1. Di Server Area Vault (`obladi` & `desmond` - Apache):**  
Aktifkan modul `mod_remoteip`, set IP Penny sebagai trusted proxy, dan ubah `%h` jadi `%a` pada format log:
```bash
a2enmod remoteip

cat <<EOF > /etc/apache2/conf-available/remoteip.conf
RemoteIPHeader X-Real-IP
RemoteIPInternalProxy 10.82.5.2
RemoteIPInternalProxy 10.82.0.0/16
EOF
a2enconf remoteip

sed -i 's/%h %l %u %t/%a %l %u %t/' /etc/apache2/apache2.conf
service apache2 restart
```

**2. Di Server Area Core (`oblada` & `molly` - Nginx):**  
Tambahkan konfigurasi `set_real_ip_from` dan `real_ip_header` pada blok server `/etc/nginx/sites-available/core`:
```bash
sed -i '/listen 80;/a \    set_real_ip_from 10.82.4.2;\n    set_real_ip_from 10.82.0.0/16;\n    real_ip_header X-Real-IP;\n    real_ip_recursive on;' /etc/nginx/sites-available/core
nginx -t && service nginx restart
```

### Script
Seluruh konfigurasi nomor 14 disimpan di [`scripts/soal14.sh`](scripts/soal14.sh).

### Verifikasi & Pembuktian
1. Dari client (`gamma` IP `10.82.2.4`), kirim request ke kedua gerbang:
   ```bash
   curl -s http://www.k37.com/arsip/
   curl -s http://static.k37.com/profil
   ```
2. Cek log di backend Area Vault (`obladi` / `desmond`):
   ```bash
   tail -n 5 /var/log/apache2/vault_access.log
   ```
   **Hasil:** Kolom IP mencatat `10.82.2.4` (IP asli client, bukan `10.82.5.2` milik Penny).

3. Cek log di backend Area Core (`oblada` / `molly`):
   ```bash
   tail -n 5 /var/log/nginx/access.log
   ```
   **Hasil:** Kolom IP mencatat `10.82.2.4` (IP asli client, bukan `10.82.4.2` milik Abbey).

---

## Nomor 15 - Satya

---

### Deskripsi Soal
Buat jalur proxy khusus yang berdiri sendiri:
- Di **penny** buat rute **/eternal** yang menyajikan direktori `/var/www/eternal` dan dapat mengeksekusi (**rendering**) file **PHP** via PHP-FPM.
- Di **abbey** buat rute **/orion** yang menyajikan direktori `/var/www/orion` secara **murni statis tanpa rendering PHP**.

### Langkah Konfigurasi (GNS3)

**1. Di Node `penny` (Apache + PHP-FPM Jalur `/eternal`):**
```bash
apt-get update && apt-get install -y php-fpm
a2enmod proxy_fcgi

service php8.2-fpm start 2>/dev/null || service php-fpm start 2>/dev/null
PHP_SOCK=$(ls -1 /run/php/php*-fpm.sock 2>/dev/null | head -n 1)
[ -z "$PHP_SOCK" ] && PHP_SOCK="/run/php/php8.2-fpm.sock"

mkdir -p /var/www/eternal
cat <<'EOF' > /var/www/eternal/index.php
<!DOCTYPE html>
<html>
<head><title>Jalur Eternal</title></head>
<body>
    <h1>Jalur Khusus /eternal (Penny)</h1>
    <p>Status: Layanan PHP-FPM Berhasil Dirender</p>
    <p>PHP Version: <?php echo phpversion(); ?></p>
</body>
</html>
EOF
chown -R www-data:www-data /var/www/eternal
chmod -R 755 /var/www/eternal

# Tambahkan direktif /eternal di VirtualHost www.k37.com pada penny.conf:
cat <<EOF > /etc/apache2/sites-available/penny.conf
<VirtualHost *:80>
    ServerName penny.k37.com
    ServerAlias 10.82.5.2

    RewriteEngine On
    RewriteRule ^(.*)$ http://www.k37.com\$1 [R=301,L]
</VirtualHost>

<VirtualHost *:80>
    ServerName www.k37.com
    ServerAlias k37.com
    DocumentRoot /var/www/penny

    ProxyPass /admin !
    Alias /admin /var/www/penny/admin

    <Location /admin>
        AuthType Basic
        AuthName "Dokumen Rahasia Sindikat"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Location>

    # Jalur Khusus /eternal dengan PHP-FPM
    ProxyPass /eternal !
    Alias /eternal /var/www/eternal
    <Directory /var/www/eternal>
        Options +Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
        DirectoryIndex index.php index.html
        <FilesMatch "\.php$">
            SetHandler "proxy:unix:$PHP_SOCK|fcgi://localhost"
        </FilesMatch>
    </Directory>

    <Proxy balancer://vaultcluster>
        BalancerMember http://10.82.1.4:80
        BalancerMember http://10.82.1.5:80
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPreserveHost On
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"
    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/
</VirtualHost>
EOF

service apache2 restart
```

**2. Di Node `abbey` (Nginx Murni Statis Jalur `/orion`):**
```bash
mkdir -p /var/www/orion
echo "<h1>Jalur Orion Statis</h1>" > /var/www/orion/index.html
echo '<?php echo "KODE PHP TIDAK DIRENDER - MURNI STATIS"; ?>' > /var/www/orion/test.php
chown -R www-data:www-data /var/www/orion
chmod -R 755 /var/www/orion

cat <<EOF > /etc/nginx/sites-available/abbey
upstream core_backend {
    server 10.82.1.6:80;
    server 10.82.1.7:80;
}

server {
    listen 80 default_server;
    server_name abbey.k37.com 10.82.4.2;
    return 302 http://static.k37.com\$request_uri;
}

server {
    listen 80;
    server_name static.k37.com;

    # Jalur Khusus /orion (Murni Statis tanpa FastCGI)
    location /orion/ {
        alias /var/www/orion/;
        index index.html index.htm;
        default_type text/plain;
    }

    location = /orion {
        return 301 /orion/;
    }

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

nginx -t && service nginx restart
```

### Script
Seluruh konfigurasi nomor 15 disimpan di [`scripts/soal15.sh`](scripts/soal15.sh).

### Verifikasi & Pembuktian
Dari client, uji kedua jalur:

1. **Uji Jalur `/eternal` di Penny (PHP Berhasil Dirender):**
   ```bash
   curl -s http://www.k37.com/eternal/
   ```
   **Output:** Tampil HTML dengan versi PHP:
   ```html
   <h1>Jalur Khusus /eternal (Penny)</h1>
   <p>Status: Layanan PHP-FPM Berhasil Dirender</p>
   <p>PHP Version: 8.2...</p>
   ```

2. **Uji Jalur `/orion` di Abbey (Murni Statis):**
   ```bash
   curl -s http://static.k37.com/orion/
   curl -s http://static.k37.com/orion/test.php
   ```
   **Output:** Request ke `test.php` mencetak teks mentah:
   ```php
   <?php echo "KODE PHP TIDAK DIRENDER - MURNI STATIS"; ?>
   ```
   Hal ini membuktikan bahwa PHP tidak dieksekusi sama sekali dan disajikan secara murni statis.