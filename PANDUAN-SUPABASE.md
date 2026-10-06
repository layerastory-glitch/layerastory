# Panduan Supabase untuk Layera Story Dashboard

Panduan ini membawa Anda dari nol sampai dashboard berjalan di Vercel dengan login dan data di Supabase.
Waktu yang dibutuhkan sekitar 20 sampai 30 menit.

> Panduan ini ditulis tanpa bisa mencoba langsung ke proyek Supabase Anda. Nama menu di dashboard Supabase
> sering berubah antarversi, jadi kalau ada nama yang tidak persis sama, cari menu yang fungsinya sama.
> Bagian **7. Pengujian** menunjukkan cara memastikan semuanya benar-benar aman.

## Yang berubah saat memakai Supabase

| | Mode lokal | Mode Supabase |
|---|---|---|
| Pemeriksaan password | di browser | di server Supabase |
| Data pesanan | di browser, terenkripsi | di database, dilindungi aturan akses (RLS) |
| Banyak perangkat | tidak | ya |
| Lupa password | data harus dihapus | tautan reset lewat email |

Aplikasi tetap satu file (`public/index.html`). Yang menentukan modenya hanya `public/config.js`.

## 1. Buat proyek Supabase

1. Daftar atau masuk di https://supabase.com, lalu klik **New project**.
2. Isi nama proyek (misalnya `layera-story`).
3. **Database password**: buat yang panjang dan acak, simpan di pengelola password. Anda hampir tidak akan memakainya,
   tetapi ini kunci utama database.
4. Region: pilih yang terdekat dengan Anda (misalnya Singapore).
5. Tunggu proyek selesai disiapkan.

## 2. Buat tabel dan aturan akses

1. Buka **SQL Editor** > **New query**.
2. Buka file `supabase/schema.sql`, salin seluruh isinya ke editor, klik **Run**.
3. Pastikan tidak ada pesan error. Di **Table Editor** harus muncul tabel `orders` dan `settings`
   dengan label **RLS enabled**.

Yang dilakukan skema ini: hanya pengguna yang sudah login dan pemilik barisnya yang bisa membaca atau
mengubah data. Pengguna anonim ditolak sepenuhnya.

## 3. Atur Authentication

Buka **Authentication** dan periksa pengaturan berikut.

1. **Matikan pendaftaran publik.** Di bagian Sign In / Providers, matikan opsi *Allow new users to sign up*.
   Ini yang paling penting: tanpa ini, siapa pun yang tahu alamat situs Anda bisa membuat akun.
2. Provider **Email** harus aktif.
3. **URL Configuration:** isi *Site URL* dengan alamat situs Anda (misalnya `https://layera-story.vercel.app`)
   dan tambahkan alamat yang sama di *Redirect URLs*. Ini dipakai oleh tautan reset password.
4. **Password policy:** biarkan dulu bawaan (minimal 6 karakter) agar password sementara `admin12` bisa dipakai
   untuk akun pertama. Setelah Anda berhasil ganti password (langkah 6), naikkan menjadi minimal 10 karakter
   dengan huruf besar, huruf kecil, dan angka. Kalau tersedia di paket Anda, aktifkan juga perlindungan
   password yang pernah bocor (leaked password protection).

## 4. Buat akun admin

1. **Authentication** > **Users** > **Add user** > **Create new user**.
2. Isi **email** yang benar-benar Anda kuasai (misalnya `admin@domainanda.com`) dan **password** `admin12`.
   Centang **Auto Confirm User**.
3. Buka **SQL Editor**, salin isi `supabase/tandai-wajib-ganti-password.sql`, ganti emailnya dengan email admin
   Anda, lalu **Run**. Hasil pemeriksaan di akhir harus menampilkan `must_change = true`.
   Penanda ini membuat aplikasi memaksa ganti password saat Anda masuk pertama kali.

Keamanan akun ini bergantung pada email tersebut, karena tautan reset password dikirim ke sana.
Pakai email yang password-nya kuat dan verifikasi dua langkahnya aktif.

## 5. Hubungkan aplikasi

1. Di Supabase buka **Project Settings** > **API** (atau **API Keys**). Salin:
   - **Project URL** (bentuknya `https://xxxxxxxx.supabase.co`)
   - kunci **anon** (juga disebut *public*). Ini kunci yang aman berada di browser.
2. **Jangan pernah** memakai kunci **service_role** atau **secret** di `config.js`. Kunci itu menembus semua aturan akses.
3. Edit `public/config.js`:

```js
window.APP_CONFIG = {
  SUPABASE_URL: "https://xxxxxxxx.supabase.co",
  SUPABASE_ANON_KEY: "eyJ...kunci-anon-anda...",
  ADMIN_EMAIL: "admin@domainanda.com",
  USERNAME_EMAIL: {},
  SEED_DEMO: false
};
```

4. Deploy ulang (`git push`, atau `vercel --prod`).

Catatan versi kunci: aplikasi memuat `supabase-js` versi 2.45.4. Kunci **anon** berformat panjang berawalan `eyJ`
bekerja dengan versi ini. Jika proyek Anda hanya menampilkan kunci jenis baru (*publishable*, berawalan `sb_publishable_`),
naikkan nomor versi `@supabase/supabase-js` di tag `<script>` dalam `public/index.html` ke versi terbaru
(lihat https://www.npmjs.com/package/@supabase/supabase-js), lalu uji ulang login.

## 6. Masuk pertama kali

1. Buka situs. Masuk dengan username `admin` dan password `admin12`.
2. Aplikasi meminta password baru. Isi sesuai syarat yang tampil, lalu simpan.
3. Sekarang kembali ke Supabase dan **naikkan kebijakan password** seperti di langkah 3.4.

Yang terjadi di balik layar: username `admin` dipetakan ke `ADMIN_EMAIL`. Anda juga bisa mengetik email langsung
di kolom username.

Perilaku mode Supabase:
- Sesi tetap aktif walau halaman dimuat ulang, dan terkunci otomatis setelah 15 menit tanpa aktivitas.
- Lima kali salah password menimbulkan jeda di layar login. Supabase juga punya pembatasan sendiri di server.
- Tombol **Ganti password** meminta password saat ini terlebih dahulu.
- **Lupa password?** mengirim tautan reset ke `ADMIN_EMAIL`. Bawaan layanan email Supabase sangat terbatas jumlah
  pengirimannya. Untuk pemakaian rutin, atur SMTP sendiri di Project Settings.

## 7. Pengujian keamanan (jangan dilewatkan)

**a. Pastikan pengguna tanpa login ditolak.** Jalankan di terminal (ganti URL dan kunci):

```bash
curl "https://xxxxxxxx.supabase.co/rest/v1/orders?select=*" \
  -H "apikey: KUNCI_ANON_ANDA"
```

Hasil yang benar adalah pesan `permission denied for table orders` atau daftar kosong `[]`.
Jika data pesanan Anda muncul, **segera hentikan pemakaian** dan periksa kembali langkah 2.

**b. Pastikan pendaftaran dimatikan.** Coba:

```bash
curl -X POST "https://xxxxxxxx.supabase.co/auth/v1/signup" \
  -H "apikey: KUNCI_ANON_ANDA" -H "Content-Type: application/json" \
  -d '{"email":"coba@contoh.com","password":"Percobaan12345"}'
```

Harus ditolak (pesan signups not allowed). Jika berhasil, buka kembali langkah 3.1.

**c. Cek di aplikasi.** Buat satu pesanan, muat ulang halaman, lalu buka Table Editor di Supabase.
Baris pesanan harus muncul di tabel `orders`.

## 8. Memindahkan data dari versi lama

1. Di situs lama (mode lokal atau artifact), buka **Pengaturan** > **Cadangan data** > **Ekspor data**.
   Simpan file JSON-nya.
2. Di situs mode Supabase, masuk, buka **Pengaturan** > **Pilih file impor**, pilih file tadi, lalu **Impor dan ganti**.
3. Hapus file JSON dari komputer setelah selesai, karena isinya tidak terenkripsi.

Impor menggantikan seluruh data di akun tersebut.

## 9. Cadangan

- Lakukan **Ekspor data** dari aplikasi secara berkala (misalnya tiap akhir bulan).
- Cadangan otomatis harian database tersedia di paket berbayar Supabase. Paket gratis tidak menjamin hal itu.
- Proyek gratis dapat dijeda otomatis jika lama tidak dipakai. Buka dashboard Supabase untuk mengaktifkannya lagi.

## 10. Mengatasi masalah

| Gejala | Kemungkinan penyebab |
|---|---|
| "Pustaka Supabase gagal dimuat" | koneksi internet atau CDN terblokir; muat ulang |
| "Tidak dapat terhubung ke Supabase" | `SUPABASE_URL` atau kunci di `config.js` salah |
| Selalu "Username atau password salah" | email di `ADMIN_EMAIL` tidak sama dengan email akun, atau akun belum terkonfirmasi (centang *Auto Confirm User*) |
| "Gagal memuat data dari Supabase" | `schema.sql` belum dijalankan, atau RLS/policy belum terpasang |
| Tidak diminta ganti password saat masuk pertama | `tandai-wajib-ganti-password.sql` belum dijalankan atau emailnya salah |
| Tautan reset password mengarah ke alamat yang salah | *Site URL* dan *Redirect URLs* di Authentication belum sesuai |
| Konsol browser menampilkan error CSP saat memakai domain Supabase sendiri | tambahkan domainnya pada `connect-src` di `vercel.json` |

## 11. Batasan yang jujur

- **Belum ada verifikasi dua langkah (MFA) di dalam aplikasi.** Supabase mendukungnya, tetapi layar untuk
  mendaftarkan dan memasukkan kodenya belum dibuat. Sementara itu, lindungi email admin dengan verifikasi dua langkah.
- **Satu pemilik data.** Semua baris dimiliki satu akun. Kalau nanti ada staf dengan hak berbeda, tabel peran dan
  aturan akses perlu ditambah.
- **Data pesanan disimpan sebagai satu kolom JSON.** Praktis untuk aplikasi ini, tetapi laporan lanjutan langsung di SQL
  akan lebih sulit dibanding tabel yang dipecah per kolom.
- **CSP mengizinkan `unsafe-eval`** karena aplikasi memakai Tailwind lewat CDN. Untuk produksi jangka panjang,
  kompilasi CSS menjadi file statis agar celah itu bisa ditutup.
- **Kunci anon memang publik.** Keamanannya bertumpu pada aturan akses (RLS) di database, bukan pada kerahasiaan kunci.
  Itu sebabnya pengujian 7a penting.
- Mode Supabase belum diuji terhadap proyek Supabase asli. Logikanya hanya diuji dengan server tiruan.
