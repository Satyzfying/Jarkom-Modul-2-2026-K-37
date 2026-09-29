***Jarkom-Modul-2-2026-K-37***


# Soal No. 4 
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

# soal no.5

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

# soal no. 6

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

# soal no. 7

