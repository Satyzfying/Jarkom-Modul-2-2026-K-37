# Jarkom-Modul-2-2026-K-37

| Nama | NRP |
|---|---|
| Azfaro Zid Ilmi | 5027251018 |
| Gede Satya Putra Aryanta | 5027251012 |

---

## Daftar Isi

- [Tabel Pembagian Interface & Alamat IP](#tabel-pembagian-interface--alamat-ip)
- [Nomor 1](#nomor-1)
- [Nomor 2](#nomor-2)
- [Nomor 3](#nomor-3)
- [Soal No. 4](#soal-no-4)
- [soal no.5](#soal-no5)
- [soal no. 6](#soal-no-6)
- [soal no. 7](#soal-no-7)
- [soal no.8](#soal-no8)
- [Nomor 9](#nomor-9)
- [Nomor 10](#nomor-10)
- [Nomor 11](#nomor-11)
- [Nomor 12](#nomor-12)
- [Nomor 13](#nomor-13)
- [Nomor 14](#nomor-14)
- [Nomor 15](#nomor-15)

---

### Tabel Pembagian Interface & Alamat IP

Prefix ip : 10.82.x.x

| Node | Antarmuka | Alamat IP | Netmask | Gateway | Subnet / Keterangan |
|---|---|---|---|---|---|
| rootkit | `eth0`<br>`eth1`<br>`eth2`<br>`eth3`<br>`eth4`<br>`eth5` | DHCP (NAT)<br>`10.82.1.1`<br>`10.82.2.1`<br>`10.82.3.1`<br>`10.82.4.1`<br>`10.82.5.1` | -<br>`255.255.255.0`<br>`255.255.255.0`<br>`255.255.255.0`<br>`255.255.255.0`<br>`255.255.255.0` | -<br>-<br>-<br>-<br>-<br>- | Router Utama (Internet Gateway)<br>Subnet eth1 (Server)<br>Subnet eth2 (Klien Sayap Kiri)<br>Subnet eth3 (Klien Sayap Kanan)<br>Subnet eth4 (Reverse Proxy Abbey)<br>Subnet eth5 (Reverse Proxy Penny) |
| prab | `eth0` | `10.82.1.2` | `255.255.255.0` | `10.82.1.1` | DNS Server (eth1) |
| tedd | `eth0` | `10.82.1.3` | `255.255.255.0` | `10.82.1.1` | DNS Server (eth1) |
| obladi | `eth0` | `10.82.1.4` | `255.255.255.0` | `10.82.1.1` | Static Web Server (eth1) |
| desmond | `eth0` | `10.82.1.5` | `255.255.255.0` | `10.82.1.1` | Static Web Server (eth1) |
| oblada | `eth0` | `10.82.1.6` | `255.255.255.0` | `10.82.1.1` | Dynamic Web Server (eth1) |
| molly | `eth0` | `10.82.1.7` | `255.255.255.0` | `10.82.1.1` | Dynamic Web Server (eth1) |
| alpha | `eth0` | `10.82.2.2` | `255.255.255.0` | `10.82.2.1` | Klien Sayap Kiri (eth2) |
| beta | `eth0` | `10.82.2.3` | `255.255.255.0` | `10.82.2.1` | Klien Sayap Kiri (eth2) |
| gamma | `eth0` | `10.82.2.4` | `255.255.255.0` | `10.82.2.1` | Klien Sayap Kiri (eth2) |
| delta | `eth0` | `10.82.3.2` | `255.255.255.0` | `10.82.3.1` | Klien Sayap Kanan (eth3) |
| epsilon | `eth0` | `10.82.3.3` | `255.255.255.0` | `10.82.3.1` | Klien Sayap Kanan (eth3) |
| abbey | `eth0` | `10.82.4.2` | `255.255.255.0` | `10.82.4.1` | Reverse Proxy Server (eth4) |
| penny | `eth0` | `10.82.5.2` | `255.255.255.0` | `10.82.5.1` | Reverse Proxy Server (eth5) |

---

# Laporan Praktikum Modul 2

## Nomor 1

---

![Topologi Jaringan Modul 2](Assets/1-topology.png)

Pada nomor 1 ini kita diminta membangun topologi sesuai gambar rancangan di modul dan mengonfigurasi IP statis beserta default gateway untuk seluruh node yang ada di jaringan.

Konfigurasi antarmuka disimpan di `/etc/network/interfaces` pada masing-masing node. 

Seluruh konfigurasi nomor 1 ini sudah kami kumpulkan di [`scripts/soal1.sh`](scripts/soal1.sh).

**Cara pakai script:**
1. Buka console **rootkit** di GNS3, lalu copy-paste blok kode di bawah `# ROOTKIT (Router Utama)` yang ada di `scripts/soal1.sh` (isinya config interface `eth0` s/d `eth5`), kemudian jalankan `service networking restart`.
2. Buka console masing-masing node internal (`prab`, `tedd`, `obladi`, `desmond`, `oblada`, `molly`, `alpha`, `beta`, `gamma`, `delta`, `epsilon`, `abbey`, `penny`), lalu copy-paste blok kode yang sesuai dengan nama nodenya di `scripts/soal1.sh` dan jalankan `service networking restart`.

Contoh config di `rootkit`:
```bash
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
```

Contoh config di node host internal (misal `prab`):
```bash
auto eth0
iface eth0 inet static
  address 10.82.1.2
  netmask 255.255.255.0
  gateway 10.82.1.1
```

Bukti hasil pengecekan IP dengan `ip -br a` pada `rootkit`:
![Bukti Konfigurasi IP Rootkit](Assets/1-rootkit-ip.png)

---

## Nomor 2

---

Di nomor ini kita mengonfigurasi koneksi internet pada router utama `rootkit` melalui antarmuka `eth0` (DHCP NAT), mengaktifkan IP forwarding pada kernel Linux, dan menerapkan aturan NAT Masquerade agar seluruh node internal di subnet `10.82.0.0/16` dapat mengakses internet.

Script konfigurasinya disimpan di [`scripts/soal2.sh`](scripts/soal2.sh).

**Cara pakai script:**
Buka console **rootkit** di GNS3, lalu copy-paste seluruh isi skrip `scripts/soal2.sh` berikut:
```bash
# Ambil IP dan gateway internet lewat DHCP NAT
udhcpc -i eth0

# Aktifkan IP forwarding di kernel Linux
sysctl -w net.ipv4.ip_forward=1

# Pasang aturan MASQUERADE untuk semua subnet kelompok (10.82.0.0/16)
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o eth0 -s 10.82.0.0/16 -j MASQUERADE
```

Bukti pengecekan aturan iptables NAT dan pengujian koneksi internet dari `rootkit` (`ping 8.8.8.8`):
![Bukti Aturan NAT Masquerade](Assets/2-nat-masquerade.png)
![Bukti Ping Internet Rootkit](Assets/2-rootkit-ping.png)

---

## Nomor 3

---

Di nomor ini kita memasang DNS resolver awal `nameserver 192.168.122.1` pada seluruh host non-router agar node internal bisa melakukan resolusi domain sebelum DNS server lokal di-deploy, serta memastikan routing antar-subnet sudah berjalan.

Script konfigurasinya disimpan di [`scripts/soal3.sh`](scripts/soal3.sh).

**Cara pakai script:**
Buka console seluruh host non-router (`prab`, `tedd`, `obladi`, `desmond`, `oblada`, `molly`, `alpha`, `beta`, `gamma`, `delta`, `epsilon`, `abbey`, `penny`), lalu copy-paste perintah yang ada di `scripts/soal3.sh`:
```bash
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

**Pengujian:**
Dari salah satu client (misalnya `alpha`), kita lakukan dua pengujian:
1. Uji resolusi DNS dan koneksi internet:
```bash
ping -c 3 google.com
```
![Bukti Ping Resolv DNS](Assets/3-dns-ping.png)

2. Uji routing antar-subnet (inter-subnet routing) melewati router `rootkit`:
- Ping ke `prab` di Subnet 1 (`10.82.1.2`)
- Ping ke `delta` di Subnet 3 (`10.82.3.2`)
- Ping ke `abbey` di Subnet 4 (`10.82.4.2`)

```bash
ping -c 3 10.82.1.2
ping -c 3 10.82.3.2
ping -c 3 10.82.4.2
```
![Bukti Ping Antar Subnet](Assets/3-inter-subnet-ping.png)

---

## Soal No. 4 
Penjaga Direktori mulai menuliskan hukum The Mesh. Pada node prab, bangun zona <xxxx>.com sebagai authoritative dengan SOA yang menunjuk ke prab.<xxxx>.com, serta tambahkan catatan NS untuk prab.<xxxx>.com dan tedd.<xxxx>.com. Buat A record untuk prab.<xxxx>.com dan tedd.<xxxx>.com yang mengarah ke alamat IP mereka masing-masing, serta A record apex <xxxx>.com yang mengarah ke gerbang aplikasi dinamis (penny). Aktifkan fitur notify dan allow-transfer ke tedd, lalu set forwarders ke 192.168.122.1. Di node tedd, tarik zona <xxxx>.com dari master dan pastikan server menjawab secara authoritative. Setelah fondasi nama ini berdiri kokoh, perbarui urutan resolver pada seluruh Entitas non-router menjadi: IP prab, IP tedd, lalu 192.168.122.1. Verifikasi bahwa query ke domain apex maupun hostname di dalam zona dijawab dengan benar oleh prab atau tedd. 



### 1. Tujuan
Melakukan konfigurasi DNS menggunakan BIND9 dengan `prab` sebagai DNS
Master dan `tedd` sebagai DNS Slave pada domain `k37.com`.
Konfigurasi yang dilakukan meliputi:
- Konfigurasi DNS Master pada `prab`
- Konfigurasi DNS Slave pada `tedd`
- Pembuatan zone `k37.com`
- Konfigurasi DNS forwarder
- Konfigurasi zone transfer dari `prab` ke `tedd`
- Konfigurasi resolver pada host
---

### konfigurasi dns master pada prab
Instalasi pada prab
```bash
apt update
apt install bind9 bind9-utils bind9-dnsutils -y
```
1. Konfigurasi `named.conf.options`

Pada konfigurasi ini, DNS diarahkan untuk menggunakan 192.168.122.1 sebagai DNS forwarder dan mengaktifkan recursive query, sehingga server dapat meneruskan permintaan DNS yang tidak dapat diselesaikan oleh DNS internal ke DNS forwarde
```bash
root@prab:~# cat > /etc/bind/named.conf.options <<'EOF'

> cat > /etc/bind/named.conf.options <<'EOF'

cat > /etc/bind/named.conf.options <<'EOF'
options {
  directory "/var/cache/bind";

  forwarders {
    192.168.122.1;
  };

  recursion yes;
};
EOF
```
<img src="Assets/soal4_Konfigurasi prab.png" width="500" height="300">


setelah itu kita validasi konfigurasinya memakai `named-checkconf`

2. konfigurasi `named.conf.local`

Tujuan konfigurasi named.conf.local adalah untuk mendaftarkan dan mengatur zone DNS k37.com pada server prab sebagai DNS Master.
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
<img src="Assets/soal4_configurasi local.png" width="500" height="300">

### Membuat Zone File `k37.com`

pembuatan zone file k37.com adalah untuk mendefinisikan informasi DNS untuk domain k37.com, seperti SOA, NS, dan A record Zone file ini menentukan `prab` sebagai DNS Master, `tedd` sebagai DNS Slave, serta mengarahkan domain `k37.com` ke IP `10.82.5.2` milik `penny

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
```
<img src="Assets/soal4_konfigurasi k37.png" width="500" height="300">

selanjutnya kita validasi dengan `named-checkzone k37.com /var/cache/bind/db.k37.com`

1. test DNS master
masi diterminal prab jalankan perintah ini
`dig @127.0.0.1 k37.com` `dig @127.0.0.1 prab.k37.com` dan `dig @127.0.0.1 tedd.k37.com`

```bash
root@prab:~# dig @127.0.0.1 k37.com

; <<>> DiG 9.20.29-1~deb13u1-Debian <<>> @127.0.0.1 k37.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 62678
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: d05a46d26150177e010000006abb6334a3afce407f0c56ff (good)
;; QUESTION SECTION:
;k37.com.                       IN      A

;; ANSWER SECTION:
k37.com.                300     IN      A       10.82.5.2

;; Query time: 1 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Tue Sep 29 07:05:24 UTC 2026
;; MSG SIZE  rcvd: 80

root@prab:~# dig @127.0.0.1 prab.k37.com

; <<>> DiG 9.20.29-1~deb13u1-Debian <<>> @127.0.0.1 prab.k37.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 5990
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: c3e917c838601e78010000006abb634695cbefc2c5973032 (good)
;; QUESTION SECTION:
;prab.k37.com.                  IN      A

;; ANSWER SECTION:
prab.k37.com.           300     IN      A       10.82.1.2

;; Query time: 1 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Tue Sep 29 07:05:42 UTC 2026
;; MSG SIZE  rcvd: 85

root@prab:~# dig @127.0.0.1 tedd.k37.com

; <<>> DiG 9.20.29-1~deb13u1-Debian <<>> @127.0.0.1 tedd.k37.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 61119
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 8a04fc45b5093b64010000006abb63512075f805bb27e894 (good)
;; QUESTION SECTION:
;tedd.k37.com.                  IN      A

;; ANSWER SECTION:
tedd.k37.com.           300     IN      A       10.82.1.3

;; Query time: 1 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Tue Sep 29 07:05:53 UTC 2026
;; MSG SIZE  rcvd: 85

```

dari hasil diatas kita menemukan bahwa DNS Master prab sudah bekerja

```bash
k37.com.        A    10.82.5.2
prab.k37.com.   A    10.82.1.2
tedd.k37.com.   A    10.82.1.3
```

### Konfigurasi DNS Slave — tedd

kami menjadikan `tedd`
sebagai server DNS Slave untuk zone `k37.com`. Server `tedd` mengambil
data zone dari DNS Master `prab` melalui proses zone transfer dengan
Master pada IP `10.82.1.2`.

1. buat konfigurasi
```bash
root@tedd:~# cat > /etc/bind/named.conf.local <<'EOF'
zone "k37.com" {
  type slave;

  masters {
    10.82.1.2;
  };

  file "/var/cache/bind/db.k37.com";
};
EOF
```
<img src="Assets/soal4_konfigurasited.png" width="500" height="300">

2. selanjtnya kita menjalankan tes dns pada ted
```bash
named -c /etc/bind/named.conf
ls -l /var/cache/bind/db.k37.com
// tes zone ted
dig @127.0.0.1 k37.com dan dig @127.0.0.1 prab.k37.com
```
```bash
root@tedd:~# dig @127.0.0.1 k37.com

; <<>> DiG 9.20.29-1~deb13u1-Debian <<>> @127.0.0.1 k37.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 62170
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: bfdc114dfca70cb1010000006abb670047604882e5d65496 (good)
;; QUESTION SECTION:
;k37.com.                       IN      A

;; ANSWER SECTION:
k37.com.                300     IN      A       10.82.5.2

;; Query time: 2 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Tue Sep 29 07:21:36 UTC 2026
;; MSG SIZE  rcvd: 80

root@tedd:~# dig @127.0.0.1 prab.k37.com

; <<>> DiG 9.20.29-1~deb13u1-Debian <<>> @127.0.0.1 prab.k37.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 24614
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: fe422b7c6846c719010000006abb670a5a9f84cf40e6d285 (good)
;; QUESTION SECTION:
;prab.k37.com.                  IN      A

;; ANSWER SECTION:
prab.k37.com.           300     IN      A       10.82.1.2

;; Query time: 1 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Tue Sep 29 07:21:46 UTC 2026
;; MSG SIZE  rcvd: 85

root@tedd:~#
```
<img src="Assets/soal4_tes dns pada ted.png" width="700" height="1000">

#### Konfigurasi `/etc/resolv.conf`

Konfigurasi `/etc/resolv.conf` bertujuan untuk menentukan urutan DNS
server yang digunakan oleh setiap host dalam melakukan resolusi domain.
DNS internal dikonfigurasi dengan urutan `prab` sebagai DNS utama,
` tedd` sebagai DNS berikutnya, dan `192.168.122.1` sebagai DNS
forwarder terakhir.

Konfigurasi yang digunakan:

```bash
cat > /etc/resolv.conf <<'EOF'
nameserver 10.82.1.2
nameserver 10.82.1.3
nameserver 192.168.122.1
EOF
```
### Validasi

Untuk membuktikan bahwa sistem DNS *master-slave* berfungsi dengan benar,
kami melakukan validasi dari salah satu klien, yaitu **alpha**.

Cara Validasi  
Kami menggunakan perintah `dig` untuk melakukan query DNS ke apex domain
(`k37.com`). Perintah `dig` digunakan untuk melihat respons DNS secara
detail, termasuk alamat IP yang diberikan dan server DNS yang memberikan
jawaban.

```bash
dig k37.com
```

hasilnya seperti ini'

<img src="Assets/soal4_validasi dns master.png" width="800" height="900">

## soal no.5

Entitas tanpa identitas adalah anomali," pesan Rootkit. Namai semua Entitas (hostname) sesuai glosarium: rootkit, alpha, beta, gamma, delta, epsilon, prab, tedd, abbey, penny, obladi, desmond, oblada, molly, dan verifikasi bahwa setiap host mengenali hostname tersebut secara system-wide. Buat setiap domain untuk masing-masing node sesuai dengan namanya (contoh: alpha.<xxxx>.com) dan assign IP masing-masing juga. Lakukan pengecualian untuk node yang bertanggung jawab atas prab dan tedd

### Konfigurasi Hostname

Langkah pertama adalah memberikan hostname kepada setiap host sesuai dengan nama yang telah ditentukan. Konfigurasi dilakukan secara langsung pada masing-masing node dengan menyimpan hostname pada `/etc/hostname` dan menerapkannya menggunakan perintah `hostname`.
contoh di `Alpha`
```bash
echo alpha > /etc/hostname && hostname alpha
```
Node yang dikonfigurasi meliputi:


- alpha
- beta
- gamma
- delta
- epsilon
- abbey
- penny
- obladi
- desmond
- oblada
- molly

Sedangkan `prab` dan `tedd` tidak dikonfigurasi ulang karena keduanya merupakan node yang bertanggung jawab sebagai NS1 dan NS2.

Identifikasi IP Address Setiap Host

```bash
hostname -I
```
sehingga diperoleh IP dari masing masing host

<img src="Assets/soal5_Ip hostname.png" >


| No. | Host    | IP Address  |
| --: | ------- | ----------- |
|   1 | rootkit | `10.82.1.1` |
|   2 | prab    | `10.82.1.2` |
|   3 | tedd    | `10.82.1.3` |
|   4 | obladi  | `10.82.1.4` |
|   5 | desmond | `10.82.1.5` |
|   6 | oblada  | `10.82.1.6` |
|   7 | molly   | `10.82.1.7` |
|   8 | alpha   | `10.82.2.2` |
|   9 | beta    | `10.82.2.3` |
|  10 | gamma   | `10.82.2.4` |
|  11 | delta   | `10.82.3.2` |
|  12 | epsilon | `10.82.3.3` |
|  13 | abbey   | `10.82.4.2` |
|  14 | penny   | `10.82.5.2` |

### Konfigurasi Domain pada DNS Master

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
```
<img src="Assets/soal5_konfigurasi master.png" >

### Validasi

Setelah konfigurasi hostname dan domain selesai dilakukan, tahap selanjutnya adalah melakukan validasi untuk memastikan bahwa domain yang telah dibuat dapat dikenali oleh client. Validasi dilakukan dari client alpha dengan menggunakan perintah ping terhadap beberapa domain yang telah dikonfigurasi pada DNS Master.

Perintah yang digunakan:
```bash
ping beta.k37.com
ping gamma.k37.com
ping delta.k37.com
```
Pengujian dilakukan untuk memastikan bahwa nama domain dapat diterjemahkan menjadi alamat IP yang sesuai dan host tujuan dapat dijangkau oleh client.

Contoh hasil yang diperoleh:
```bash
PING beta.k37.com (10.82.2.3) ...
64 bytes from 10.82.2.3: ...
```
![Assets/soal5_validasi.png](Assets/soal5_validasi.png)

## soal no. 6

Pastikan zone transfer berjalan, pastikan tedd telah menerima salinan zona terbaru dari prab. Nilai serial SOA di keduanya harus sama karena keduanya tidak bisa dipisahkan dan saling melengkapi.

Tujuannya adalah memastikan bahwa zone k37.com yang terdapat pada DNS Master dapat ditransfer ke DNS Slave dan memiliki data zone yang sama. Salah satu indikator yang digunakan adalah nilai serial pada SOA, karena serial digunakan untuk menunjukkan versi dari zone yang sedang digunakan. Ketentuan praktikum juga meminta agar zone pada prab dan tedd memiliki serial yang sama setelah proses transfer.

### Mengecek Serial Zone pada prab
Untuk membuktikan bahwa tedd (DNS Slave) telah menerima salinan zone terbaru dari prab (DNS Master), kami membandingkan nomor seri SOA dari kedua server secara langsung.


Prab (DNS Master) dan Tedd (DNS Slave)
```bash
dig @10.82.1.2 k37.com SOA +short
dig @10.82.1.3 k37.com SOA +short
```
Kedua perintah tersebut dapat dijalankan dari client yang sama, misalnya prab, sehingga pengujian dilakukan dengan kondisi client yang sama dan hanya server DNS tujuan yang berbeda.

```bash
root@prab:~# dig @127.0.0.1 k37.com SOA +short
prab.k37.com. admin.k37.com. 2026092902 3600 600 86400 300
root@prab:~# dig @10.82.1.2 k37.com SOA +short
prab.k37.com. admin.k37.com. 2026092902 3600 600 86400 300
root@prab:~# dig @10.82.1.3 k37.com SOA +short
prab.k37.com. admin.k37.com. 2026092902 3600 600 86400 300
```
![alt text](Assets/soal6.png)

## soal no. 7
abbey dan penny sebagai gerbang utama, obladi dan desmond sebagai web statis, oblada dan molly sebagai web dinamis. Tambahkan pada zona <xxxx>.com A record untuk vault.<xxxx>.com (IP obladi & desmond), dan core.<xxxx>.com (IP oblada & molly). Tetapkan CNAME:


www.<xxxx>.com → penny.<xxxx>.com

static.<xxxx>.com → abbey.<xxxx>.com

Verifikasi dari dua klien berbeda bahwa seluruh hostname tersebut ter-resolve ke tujuan yang benar dan konsisten.



Pada soal ini, kami membuat beberapa record DNS tambahan untuk menyediakan nama yang lebih mudah digunakan dalam mengakses layanan yang tersedia pada jaringan. Konfigurasi yang dibuat terdiri dari A Record untuk vault dan core, serta CNAME Record untuk menyediakan alias www dan static. Sesuai ketentuan soal, vault diarahkan ke server obladi dan desmond, sedangkan core diarahkan ke oblada dan molly. Selain itu, www dibuat sebagai alias dari penny, dan static dibuat sebagai alias dari abbey.

### Konfigurasi di Prab (Master)

Semua perubahan konfigurasi DNS dilakukan pada server master, yaitu prab. Kami menambahkan record berikut ke dalam file zone:

```bash
cat <<EOF >> /var/cache/bind/db.k37.com

vault       IN  A       10.82.1.4
vault       IN  A       10.82.1.5

core        IN  A       10.82.1.6
core        IN  A       10.82.1.7

www         IN  CNAME   penny.k37.com.
static      IN  CNAME   abbey.k37.com.

EOF
```
Konfigurasi tersebut membuat vault.k37.com memiliki dua alamat IP, yaitu 10.82.1.4 dan 10.82.1.5, yang masing-masing merupakan alamat IP dari obladi dan desmond. Sementara itu, core.k37.com memiliki dua alamat IP, yaitu 10.82.1.6 dan 10.82.1.7, yang merupakan alamat IP dari oblada dan molly.

Setelah melakukan perubahan pada zone file, nomor serial SOA dinaikkan dari:

`2026092902` menjadi: `2026092903`

Perubahan serial dilakukan menggunakan perintah:
```bash
sed -i 's/2026092902/2026092903/' /var/cache/bind/db.k37.com
```
Penaikan serial dilakukan untuk menandai bahwa terdapat perubahan pada zone k37.com, sehingga versi zone terbaru dapat dikenali oleh DNS Slave pada proses sinkronisasi.
 ![alt text](Assets/soal7_1.png)

 selanjutnya
## Verifikasi dari Client

Setelah konfigurasi DNS aktif, dilakukan pengujian dari dua client berbeda. yaitu gama dan, pengujian dilakukan dengan:
```bash
dig vault.k37.com A +short
dig core.k37.com A +short
dig www.k37.com CNAME +short
dig static.k37.com CNAME +short
```
Hasil yang diperoleh:
```
10.82.1.5
10.82.1.4
10.82.1.6
10.82.1.7
penny.k37.com.
abbey.k37.com.
```
![alt text](Assets/soal7_2.png)dan ![alt text](Assets/soal7_3.png)

Hasil tersebut menunjukkan bahwa vault.k37.com berhasil di-resolve ke dua alamat IP repository statis, yaitu 10.82.1.4 dan 10.82.1.5. core.k37.com berhasil di-resolve ke 10.82.1.6 dan 10.82.1.7. Selain itu, www.k37.com berhasil mengarah ke penny.k37.com, sedangkan static.k37.com mengarah ke abbey.k37.com

## soal no.8
 
 Di prab (ns1) deklarasikan reverse zone untuk segmen jaringan  tempat abbey, penny, area vault, dan area core berada. Di tedd (ns2) tarik reverse zone tersebut sebagai slave, isi PTR untuk keempat hostname itu agar pencarian balik IP address mengembalikan hostname yang benar, lalu pastikan query reverse untuk alamat abbey, penny, area vault, dan area core dijawab authoritative.

### Konfigurasi di Prab (Master)

Pertama, kami mendeklarasikan reverse zone pada file /etc/bind/named.conf.local di Prab sebagai DNS Master.
``` bash
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
Pada konfigurasi tersebut, Prab dengan alamat IP 10.82.1.2 bertindak sebagai Master, sedangkan 10.82.1.3 merupakan alamat IP Tedd yang diberikan izin untuk melakukan zone transfer.

Selanjutnya, kami membuat file reverse zone untuk jaringan 10.82.1.0/24 dan mengisinya dengan record PTR untuk hostname yang berada pada jaringan tersebut.
``` bash
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
![alt text](Assets/soal8_1.png)

Record PTR tersebut digunakan untuk menghubungkan alamat IP dengan hostname:
```bash
10.82.1.4 → obladi.k37.com
10.82.1.5 → desmond.k37.com
10.82.1.6 → oblada.k37.com
10.82.1.7 → molly.k37.com
```
Kemudian dibuat reverse zone untuk jaringan 10.82.4.0/24 yang digunakan oleh abbey.
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
```


Selanjutnya dibuat reverse zone untuk jaringan 10.82.5.0/24 yang digunakan oleh penny.

```bash
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
```
```bash
Setelah konfigurasi Master selesai, kami melakukan pengujian menggunakan dig dengan DNS server Prab pada alamat 10.82.1.2.

dig @10.82.1.2 -x 10.82.1.4 +short
dig @10.82.1.2 -x 10.82.1.5 +short
dig @10.82.1.2 -x 10.82.1.6 +short
dig @10.82.1.2 -x 10.82.1.7 +short
dig @10.82.1.2 -x 10.82.4.2 +short
dig @10.82.1.2 -x 10.82.5.2 +short
```
Hasil yang diperoleh:
```bash
obladi.k37.com.
desmond.k37.com.
oblada.k37.com.
molly.k37.com.
abbey.k37.com.
penny.k37.com.
```
Hasil tersebut menunjukkan bahwa Prab berhasil mengembalikan hostname berdasarkan alamat IP yang diberikan.

### Konfigurasi di Tedd (Slave)

Selanjutnya, kami mengonfigurasi Tedd sebagai DNS Slave. Tedd mengambil reverse zone dari Prab sebagai Master melalui alamat 10.82.1.2.

Konfigurasi pada /etc/bind/named.conf.local di Tedd adalah:
``` bash
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
```
![Assets/soal8_2.png](Assets/soal8_2.png)

Kemudian dilakukan pengujian reverse DNS melalui DNS Slave pada alamat 10.82.1.3.
```bash
dig @10.82.1.3 -x 10.82.1.4 +short
dig @10.82.1.3 -x 10.82.1.5 +short
dig @10.82.1.3 -x 10.82.1.6 +short
dig @10.82.1.3 -x 10.82.1.7 +short
dig @10.82.1.3 -x 10.82.4.2 +short
dig @10.82.1.3 -x 10.82.5.2 +short
```
Hasil yang diperoleh:
```
obladi.k37.com.
desmond.k37.com.
oblada.k37.com.
molly.k37.com.
abbey.k37.com.
penny.k37.com.
```
---

## Nomor 9 - Satya

---

Diminta untuk menjalankan layanan web statis menggunakan Apache di area vault (`obladi` dan `desmond`). Direktori `/arsip/` harus dibuka dengan fitur autoindex (directory listing) aktif agar seluruh file di dalamnya bisa dilihat langsung dari browser/curl melalui hostname `vault.k37.com/arsip/`.

Script konfigurasi disimpan di [`scripts/soal9.sh`](scripts/soal9.sh).

**Cara pakai script:**
1. Buka console **obladi**, copy-paste blok kode di bawah `# ==== OBLADI ====` yang ada di `scripts/soal9.sh`.
2. Buka console **desmond**, copy-paste blok kode di bawah `# ==== DESMOND ====` yang ada di `scripts/soal9.sh`.

Di dalam script tersebut dilakukan:
- Instalasi `apache2`.
- Pembuatan direktori `/var/www/vault/arsip` beserta file dummy (`dokumen1.txt`, `inventaris.pdf`, dll) tanpa membuat `index.html` agar autoindex berjalan.
- Pembuatan VirtualHost di `/etc/apache2/sites-available/vault.conf` dengan direktif `Options +Indexes` khusus untuk direktori `/var/www/vault/arsip`:
```apache
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

    ErrorLog ${APACHE_LOG_DIR}/vault_error.log
    CustomLog ${APACHE_LOG_DIR}/vault_access.log combined
</VirtualHost>
```
- Pengaktifan modul `autoindex`, `dir`, enable site `vault.conf`, lalu restart service apache2.

**Pengujian:**
Jalankan pengujian dari client (misal `gamma` atau `delta`) menggunakan hostname:
```bash
# 1. Cek status HTTP 200 OK dan autoindex direktori /arsip/
curl -i http://vault.k37.com/arsip/

# 2. Cek pembacaan isi file dokumen di dalam arsip
curl http://vault.k37.com/arsip/dokumen1.txt

# 3. Cek direktori root (harus 403 Forbidden karena autoindex hanya di /arsip/)
curl -i http://vault.k37.com/
```


![Bukti Autoindex Apache](Assets/9-autoindex.png)


---

## Nomor 10

---

Diminta untuk menjalankan layanan web dinamis PHP-FPM menggunakan Nginx di area core (`oblada` dan `molly`). Buat halaman beranda (`index.php`) dan halaman profil (`profil.php`), serta pasang aturan rewrite agar akses ke `/profil` dapat dibuka dengan clean URL (tanpa ekstensi `.php`) melalui hostname `core.k37.com/profil`.

Script konfigurasi disimpan di [`scripts/soal10.sh`](scripts/soal10.sh).

**Cara pakai script:**
1. Buka console **oblada**, copy-paste blok kode di bawah `# ==== OBLADA ====` yang ada di `scripts/soal10.sh`.
2. Buka console **molly**, copy-paste blok kode di bawah `# ==== MOLLY ====` yang ada di `scripts/soal10.sh`.

Di dalam script tersebut dilakukan:
- Instalasi `nginx` dan `php-fpm`.
- Pembuatan direktori DocumentRoot `/var/www/core` beserta file `index.php` dan `profil.php` yang menampilkan informasi dinamis server (hostname, alamat IP, versi PHP).
- Konfigurasi server block Nginx di `/etc/nginx/sites-available/core` dengan aturan rewrite:
```nginx
server {
    listen 80;
    server_name core.k37.com oblada.k37.com molly.k37.com;

    root /var/www/core;
    index index.php index.html index.htm;

    # Rewrite URL bersih /profil ke /profil.php
    rewrite ^/profil/?$ /profil.php last;

    location / {
        try_files $uri $uri/ $uri.php?$args =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
    }
}
```
- Menghubungkan konfigurasi ke `sites-enabled`, menghapus konfigurasi `default`, dan restart nginx.

**Pengujian:**
Jalankan pengujian dari client (misal `gamma` atau `delta`) menggunakan hostname:
```bash
# 1. Akses halaman beranda
curl -i http://core.k37.com/

# 2. Akses halaman profil dengan clean URL (tanpa .php)
curl -i http://core.k37.com/profil
```



![Bukti Web Dinamis dan Rewrite Profil](Assets/10-core-profil.png)
*(Screenshot hasil pengujian akses clean URL /profil dari client yang berhasil menampilkan konten dinamis PHP)*

---

## Nomor 11

---

Diminta untuk mengonfigurasi **Penny** (Apache) sebagai reverse proxy & load balancer menuju node di area vault (`obladi` & `desmond`), dan mengonfigurasi **Abbey** (Nginx) sebagai reverse proxy & load balancer menuju node di area core (`oblada` & `molly`). Kedua reverse proxy ini wajib meneruskan header `Host` dan `X-Real-IP` ke backend.

Script konfigurasi disimpan di [`scripts/soal11.sh`](scripts/soal11.sh).

**Prasyarat Sebelum Menjalankan:**
1. **Routing Router (`rootkit`)**: Pastikan packet forwarding aktif:
   ```bash
   sysctl -w net.ipv4.ip_forward=1
   iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
   ```
2. **Identitas Backend Vault (`obladi` & `desmond`)**: Pastikan file `index.html` sudah dibuat agar pengujian tidak menghasilkan `403 Forbidden`:
   * Di **obladi**: `echo "<h1>Area Vault - Server Obladi</h1>" > /var/www/vault/index.html`
   * Di **desmond**: `echo "<h1>Area Vault - Server Desmond</h1>" > /var/www/vault/index.html`

**Langkah Eksekusi Script:**
1. Buka console **penny**, copy-paste blok kode di bawah `# ==== PENNY ====` pada `scripts/soal11.sh`.
   Skrip ini mengaktifkan modul `proxy`, `proxy_http`, `proxy_balancer`, `lbmethod_byrequests`, `lbmethod_bytraffic`, `lbmethod_bybusyness`, `slotmem_shm`, dan `headers` di Apache, lalu memasang cluster balancer `balancer://vaultcluster` ke IP `10.82.1.4:80` dan `10.82.1.5:80` dengan `ProxyPreserveHost On` dan `RequestHeader set X-Real-IP "expr=%{REMOTE_ADDR}"`.
2. Buka console **abbey**, copy-paste blok kode di bawah `# ==== ABBEY ====` pada `scripts/soal11.sh`.
   Skrip ini memasang upstream `core_backend` di Nginx ke IP `10.82.1.6:80` dan `10.82.1.7:80` serta meneruskan header `proxy_set_header Host $host;`, `proxy_set_header X-Real-IP $remote_addr;`, `proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;`, dan `proxy_set_header X-Forwarded-Proto $scheme;`.

**Pengujian:**
Dari client (misal node **gamma**):
Pastikan resolusi nama domain diarahkan ke DNS Master (`echo "nameserver 10.82.1.2" > /etc/resolv.conf`) atau pasang mapping statis di `/etc/hosts` client:
```bash
echo "10.82.5.2 penny.k37.com www.k37.com" >> /etc/hosts
echo "10.82.4.2 abbey.k37.com static.k37.com" >> /etc/hosts
```

1. Uji load balancing Penny ke area vault (jalankan request berulang):
```bash
for i in {1..4}; do curl -s http://penny.k37.com/ | grep -i "Server"; done
```
Respons bergantian dijawab oleh `Area Vault - Server Obladi` dan `Area Vault - Server Desmond`.

2. Uji load balancing Abbey ke area core dan cek forwarding header:
```bash
for i in {1..4}; do
    echo "--- Request $i ---"
    curl -s http://abbey.k37.com/profil | grep -E "Node Server|Host Header|Client IP"
done
```
Respons bergantian dijawab oleh `oblada` dan `molly`, serta header `Host` tercatat `abbey.k37.com` dan `Client IP` mencatat IP asli client (`10.82.2.4`).

> **Catatan Troubleshooting Saat Demo:**
> - Jika muncul error `Could not resolve host: penny.k37.com` atau `Temporary failure in name resolution`:
>   1. Jalankan `named -c /etc/bind/named.conf` di **prab** untuk memastikan daemon DNS BIND9 aktif.
>   2. Jalankan `sysctl -w net.ipv4.ip_forward=1` di **rootkit** untuk memastikan router meneruskan paket antar-subnet.
>   3. Atau tambahkan mapping IP ke `/etc/hosts` di client seperti pada langkah persiapan di atas.
> - Jika pengujian `curl` ke Penny menghasilkan `403 Forbidden`, pastikan file `/var/www/vault/index.html` sudah ada di `obladi` dan `desmond`.
> - Jika pengujian `curl` ke Abbey kosong atau menghasilkan `502 Bad Gateway`, pastikan service Nginx dan PHP-FPM aktif di **oblada** dan **molly** (`service nginx restart && service php8.4-fpm restart 2>/dev/null || service php-fpm restart`).

![Bukti Reverse Proxy Penny dan Abbey](Assets/11-reverse-proxy.png)
*(Tangkapan layar hasil pengujian distribusi lalu lintas dan header forwarding dari client)*

---

## Nomor 12

---

Terdapat dokumen rahasia pada direktori `/admin` di node **Penny**. Kita diminta memasang perlindungan **Basic Authentication** pada path `/admin` tersebut. Akses tanpa kredensial atau password salah harus ditolak (401), dan hanya boleh diakses menggunakan:
- **Username:** `prabs`
- **Password:** `pakar_pinter_jadi_gob***`

Script konfigurasi disimpan di [`scripts/soal12.sh`](scripts/soal12.sh).

**Cara pakai script:**
Buka console **penny**, lalu copy-paste seluruh isi `scripts/soal12.sh`.

Di dalam script tersebut dilakukan:
- Instalasi `apache2-utils`.
- Pembuatan direktori rahasia `/var/www/penny/admin` dan file `index.html`.
- Pembuatan file kredensial password terenkripsi via `htpasswd -bc /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'`.
- Konfigurasi VirtualHost Penny dengan menambahkan `ProxyPass /admin !` agar path `/admin` dikecualikan dari reverse proxy (diproses lokal oleh Penny) dan diproteksi dengan `AuthType Basic`:
```apache
ProxyPass /admin !
Alias /admin /var/www/penny/admin

<Directory /var/www/penny/admin>
    Options -Indexes +FollowSymLinks
    AllowOverride None
    Require valid-user
    DirectoryIndex index.html
</Directory>

<Location /admin>
    AuthType Basic
    AuthName "Dokumen Rahasia Sindikat"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Location>
```

**Pengujian:**
Dari client (misal `gamma` atau `alpha`), lakukan pengujian dengan 3 kondisi:
```bash
# 1. Tanpa kredensial -> Ditolak (HTTP 401 Unauthorized)
curl -i http://penny.k37.com/admin/

# 2. Password salah -> Ditolak (HTTP 401 Unauthorized)
curl -i -u "prabs:passwordsalah" http://penny.k37.com/admin/

# 3. Kredensial benar -> Berhasil (HTTP 200 OK)
curl -i -u "prabs:pakar_pinter_jadi_gob***" http://penny.k37.com/admin/
```

![Bukti Basic Authentication Penny](Assets/12-basic-auth.png)
*(Tangkapan layar pengujian HTTP Basic Auth pada path /admin dari client)*

---

## Nomor 13

---

Diminta agar setiap entitas memanggil gerbang menggunakan nama kanoniknya:
- Akses ke IP Penny (`10.82.5.2`) atau domain `penny.k37.com` harus di-redirect permanen (**HTTP 301**) ke `www.k37.com`.
- Akses ke IP Abbey (`10.82.4.2`) atau domain `abbey.k37.com` harus di-redirect sementara (**HTTP 302**) ke `static.k37.com`.

Script konfigurasi disimpan di [`scripts/soal13.sh`](scripts/soal13.sh).

**Cara pakai script:**
1. Buka console **penny**, copy-paste blok `# ==== PENNY ====` pada `scripts/soal13.sh`.
   Skrip ini mengaktifkan `mod_rewrite` di Apache, lalu menambahkan VirtualHost khusus port 80 untuk IP `10.82.5.2` dan domain `penny.k37.com` yang me-rewrite seluruh request ke `http://www.k37.com$1` dengan flag `[R=301,L]`.
2. Buka console **abbey**, copy-paste blok `# ==== ABBEY ====` pada `scripts/soal13.sh`.
   Skrip ini menambahkan server block default di Nginx untuk menangkap IP `10.82.4.2` dan domain `abbey.k37.com`, lalu me-redirect-nya menggunakan `return 302 http://static.k37.com$request_uri;`.

**Pengujian:**
Dari client (misal `gamma`):
```bash
# 1. Uji redirect 301 Penny (hasil: HTTP/1.1 301 Moved Permanently -> Location: http://www.k37.com/)
curl -i http://penny.k37.com/
curl -i http://10.82.5.2/

# 2. Uji redirect 302 Abbey (hasil: HTTP/1.1 302 Moved Temporarily -> Location: http://static.k37.com/)
curl -i http://abbey.k37.com/
curl -i http://10.82.4.2/

# 3. Uji follow redirect sampai 200 OK
curl -L http://penny.k37.com/
curl -L http://abbey.k37.com/profil
```

![Bukti Redirection Kanonik](Assets/13-canonical-redirect.png)
*(Tangkapan layar hasil pengujian status code redirect 301 Penny dan redirect 302 Abbey)*

![Bukti Follow Redirect](Assets/13-follow-redirect.png)
*(Tangkapan layar pengujian follow redirect (-L) menuju konten kanonik HTTP 200 OK)*

---

## Nomor 14

---

Diminta untuk memastikan bahwa file *access log* pada setiap server web di area vault (`obladi`, `desmond`) dan area core (`oblada`, `molly`) mencatat alamat IP asli client pengunjung yang diteruskan oleh proxy, bukan mencatat IP dari Penny (`10.82.5.2`) atau Abbey (`10.82.4.2`).

Script konfigurasi disimpan di [`scripts/soal14.sh`](scripts/soal14.sh).

**Cara pakai script:**
1. Buka console **obladi**, copy-paste blok `# ==== OBLADI ====` dari `scripts/soal14.sh`. Lakukan hal yang sama pada **desmond**.
   Skrip ini mengaktifkan modul `remoteip` di Apache (`a2enmod remoteip`), mengatur `RemoteIPHeader X-Real-IP`, menetapkan IP Penny sebagai `RemoteIPInternalProxy`, dan mengubah format log `%h` menjadi `%a` pada `/etc/apache2/apache2.conf`.
2. Buka console **oblada**, copy-paste blok `# ==== OBLADA ====` dari `scripts/soal14.sh`. Lakukan hal yang sama pada **molly**.
   Skrip ini menambahkan parameter `set_real_ip_from 10.82.4.2;` dan `real_ip_header X-Real-IP;` pada server block Nginx di `/etc/nginx/sites-available/core`.

**Pengujian:**
1. Dari client `gamma` (IP `10.82.2.4`), kirim request ke kedua domain:
```bash
curl -s http://www.k37.com/arsip/
curl -s http://static.k37.com/profil
```
2. Cek access log di server backend:
- Di `obladi` atau `desmond` (Apache):
  ```bash
  tail -n 5 /var/log/apache2/vault_access.log
  ```
  Kolom pertama mencatat IP `10.82.2.4` (IP asli client `gamma`).
- Di `oblada` atau `molly` (Nginx):
  ```bash
  tail -n 5 /var/log/nginx/access.log
  ```
  Kolom `$remote_addr` mencatat IP `10.82.2.4` (IP asli client `gamma`).

![Bukti Real IP Access Log Apache Vault](Assets/14-vault-log.png)
*(Tangkapan layar bukti access log Apache pada server Obladi mencatat IP asli client 10.82.2.4)*

![Bukti Real IP Access Log Nginx Core](Assets/14-core-log.png)
*(Tangkapan layar bukti access log Nginx pada server Molly mencatat IP asli client 10.82.2.4)*

---

## Nomor 15

---

Diminta untuk membuat jalur khusus yang berdiri sendiri:
- Pada **Penny**: buat rute `/eternal` yang menyajikan direktori `/var/www/eternal` dan dapat mengeksekusi (**rendering**) file PHP menggunakan PHP-FPM.
- Pada **Abbey**: buat rute `/orion` yang menyajikan direktori `/var/www/orion` secara **murni statis tanpa rendering PHP** (file PHP disajikan sebagai teks mentah).

Script konfigurasi disimpan di [`scripts/soal15.sh`](scripts/soal15.sh).

**Cara pakai script:**
1. Buka console **penny**, copy-paste blok `# ==== PENNY ====` pada `scripts/soal15.sh`.
   Skrip ini menginstal `php-fpm`, membuat folder `/var/www/eternal/index.php`, mengecualikan `/eternal` dari reverse proxy (`ProxyPass /eternal !`), dan mengarahkan handler file `.php` ke unix socket `php-fpm`.
2. Buka console **abbey**, copy-paste blok `# ==== ABBEY ====` pada `scripts/soal15.sh`.
   Skrip ini membuat folder `/var/www/orion/` berisi file `index.html` dan `test.php`, serta menambahkan blok `location /orion/` di Nginx dengan direktif `alias /var/www/orion/;` dan `default_type text/plain;` tanpa menyertakan `fastcgi_pass`.

**Pengujian:**
Dari client (misal `gamma`):
1. Uji jalur `/eternal` pada Penny (PHP dirender):
```bash
curl -s http://www.k37.com/eternal/
```
Respons menampilkan halaman HTML yang mencantumkan versi PHP server.

2. Uji jalur `/orion` pada Abbey (murni statis):
```bash
# Akses file index.html
curl -s http://static.k37.com/orion/

# Akses file test.php (harus menampilkan kode mentah tanpa dieksekusi)
curl -s http://static.k37.com/orion/test.php
```
Hasil curl ke `test.php` menampilkan string mentah `<?php echo "KODE PHP TIDAK DIRENDER - MURNI STATIS"; ?>`, membuktikan bahwa interpreter PHP tidak dijalankan pada jalur tersebut.

> **Screenshot yang harus diambil:**
> Ambil tangkapan layar terminal client yang menampilkan output `curl -s http://www.k37.com/eternal/` (menampilkan versi PHP aktif) dan `curl -s http://static.k37.com/orion/test.php` (menampilkan kode sumber PHP mentah tanpa dieksekusi). Simpan gambar sebagai `Assets/15-eternal-orion.png`.

![Bukti Jalur Khusus Eternal dan Orion](Assets/15-eternal-orion.png)
*(Tangkapan layar hasil pengujian jalur dinamis /eternal dan jalur murni statis /orion)*

---

## Nomor 16

## NO 17

# Soal no 17

Tambahkan TXT record pada DNS untuk semua klien sayap kiri dan sayap kanan (Alpha, Beta, Gamma, Delta, Epsilon). Jika DNS di-query TXT terhadap nama domain mereka (contoh: alpha.<xxxx>.com), sistem harus mengembalikan teks berupa nama hostname mereka masing-masing (contoh: "alpha").


1. Konfigurasi pada Prab (Master)

Penambahan TXT record dilakukan pada file zone DNS:

/var/cache/bind/db.k37.com

Record TXT yang ditambahkan adalah:
```bash
alpha       IN TXT "alpha"
beta        IN TXT "beta"
gamma       IN TXT "gamma"
delta       IN TXT "delta"
epsilon     IN TXT "epsilon"
```
Sehingga setiap hostname memiliki TXT record sesuai dengan nama hostnya.

Selanjutnya, nilai serial SOA pada Prab dinaikkan dari:

`2026092903` menjadi: `2026092904`

Kenaikan serial dilakukan agar perubahan pada zone dapat dikenali sebagai versi terbaru oleh DNS Slave.

2. Validasi Zone

Setelah TXT record ditambahkan dan serial SOA diperbarui, dilakukan pengecekan menggunakan named-checkzone:

`named-checkzone k37.com /var/cache/bind/db.k37.com`

Hasil yang diperoleh:
```bash
zone k37.com/IN: loaded serial 2026092904
OK
```
![alt text](Assets/17-.png)
Hasil tersebut menunjukkan bahwa konfigurasi zone k37.com berhasil dimuat dengan serial 2026092904 dan tidak terdapat kesalahan sintaks pada zone file.

3. Verifikasi TXT Record

Setelah konfigurasi DNS diaktifkan kembali, dilakukan pengujian menggunakan perintah dig terhadap DNS Master Prab:
```bash
dig @10.82.1.2 alpha.k37.com TXT +short
dig @10.82.1.2 beta.k37.com TXT +short
dig @10.82.1.2 gamma.k37.com TXT +short
dig @10.82.1.2 delta.k37.com TXT +short
dig @10.82.1.2 epsilon.k37.com TXT +short
```
Hasil yang diharapkan:
```bash
"alpha"
"beta"
"gamma"
"delta"
"epsilon"
```
Dengan demikian, setiap hostname klien memiliki TXT record yang mengembalikan teks sesuai dengan nama hostname masing-masing.
```bash
Hostname	TXT Record
alpha.k37.com	"alpha"
beta.k37.com	"beta"
gamma.k37.com	"gamma"
delta.k37.com	"delta"
epsilon.k37.com	"epsilon"
```
![alt text](Assets/17-txt-record.png)
