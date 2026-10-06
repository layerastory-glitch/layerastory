# Layera Story Dashboard

Dashboard internal untuk pesanan, keuangan, dan invoice usaha undangan pernikahan.
Situs statis (tanpa langkah build), siap diunggah ke Vercel.

Login bawaan: **username `admin`, password `admin12`** (sementara). Aplikasi memaksa Anda membuat password baru
saat masuk pertama kali.

## Isi folder

```
layera-story-dashboard/
├─ public/
│  ├─ index.html          aplikasi (React, dimuat dari CDN)
│  ├─ config.js           konfigurasi (Supabase, data contoh)
│  └─ robots.txt          meminta mesin pencari tidak mengindeks situs ini
├─ supabase/
│  ├─ schema.sql                      tabel dan aturan akses (Row Level Security)
│  └─ tandai-wajib-ganti-password.sql memaksa ganti password admin saat masuk pertama
├─ vercel.json            pengaturan deploy dan header keamanan
├─ PANDUAN-SUPABASE.md    langkah menghubungkan Supabase
└─ README.md              file ini
```

## Dua mode

| | Mode lokal (bawaan) | Mode Supabase |
|---|---|---|
| Cara aktif | `config.js` dibiarkan kosong | isi `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `ADMIN_EMAIL` |
| Akun | satu akun per browser | akun di server Supabase |
| Data | terenkripsi di browser masing-masing | di database Supabase |
| Akses banyak perangkat | tidak (data terpisah per browser) | ya |
| Password diperiksa di | browser | server |

Untuk pemakaian sungguhan oleh Anda dan tim di beberapa perangkat, gunakan **mode Supabase**
(lihat `PANDUAN-SUPABASE.md`). Mode lokal cocok untuk mencoba atau dipakai di satu komputer.

## Mencoba di komputer sendiri

Aplikasi butuh alamat `localhost` atau HTTPS agar enkripsi browser berfungsi. Dari folder ini:

```bash
npx serve public
# atau
python3 -m http.server --directory public 8080
```

Lalu buka `http://localhost:3000` (serve) atau `http://localhost:8080` (python).
Komputer perlu terhubung ke internet karena pustaka dimuat dari CDN.

## Deploy ke Vercel

Vercel tidak menerima unggahan zip langsung lewat dashboard. Pilih salah satu cara:

### Cara A: lewat GitHub (disarankan, mudah diperbarui)

1. Ekstrak zip. Buat repositori **private** baru di GitHub, lalu unggah seluruh isi folder
   (`public`, `supabase`, `vercel.json`, dan seterusnya).
2. Buka https://vercel.com/new, pilih repositori tadi, klik **Import**.
3. Biarkan semua pengaturan apa adanya. `vercel.json` sudah mengatur
   Framework **Other**, tanpa build, dan Output Directory `public`.
4. Klik **Deploy**. Hasilnya berupa alamat `https://nama-proyek.vercel.app`.

### Cara B: lewat Vercel CLI (tanpa GitHub)

```bash
npm install -g vercel
cd layera-story-dashboard
vercel          # jawab pertanyaan; pertama kali akan diminta login
vercel --prod   # terbitkan ke alamat produksi
```

### Setelah deploy

1. Buka alamat situs, masuk dengan `admin` / `admin12`, lalu buat password baru.
2. Ganti nama usaha, rekening, dan alamat di ikon gerigi (**Pengaturan**).
3. (Opsional) Domain sendiri: Vercel > Settings > Domains.
4. Untuk memakai Supabase, ikuti `PANDUAN-SUPABASE.md`, lalu edit `public/config.js` dan deploy ulang.

## Memperbarui isi

Ubah file, lalu `git push` (Cara A) atau jalankan `vercel --prod` lagi (Cara B).
Kalau hanya mengubah `config.js`, tidak perlu menyentuh file lain.

## Cadangan data

Pengaturan > **Cadangan data** > **Ekspor data** menyimpan semua pesanan dan pengaturan ke satu file JSON.
Impor di tempat yang sama. Lakukan ekspor berkala, terutama di mode lokal, karena data hanya ada di browser.
File ekspor **tidak terenkripsi**, simpan di tempat aman.

## Catatan keamanan

- `vercel.json` memasang header keamanan (CSP, HSTS, anti-iframe, dan lainnya).
  CSP mengizinkan `unsafe-eval` karena aplikasi memakai Tailwind CDN. Untuk produksi jangka panjang,
  sebaiknya CSS dikompilasi menjadi satu file statis sehingga `unsafe-eval` dan CDN Tailwind bisa dihapus.
- Kunci Supabase di `config.js` harus kunci **anon/publishable**. Jangan pernah memasukkan kunci
  **service_role/secret**.
- Mode lokal tidak menggantikan keamanan di sisi server. Lihat bagian "Batasan" di `PANDUAN-SUPABASE.md`.
- Pustaka (React, htm, pdf-lib, qrcode-generator, supabase-js) dimuat dari CDN dengan versi dikunci.
  Menyalinnya ke folder `public` sendiri akan menghilangkan ketergantungan pada CDN.
