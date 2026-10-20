/*
  Konfigurasi aplikasi. File ini PUBLIK (ikut terkirim ke browser), jadi jangan menaruh rahasia di sini.

  MODE LOKAL (bawaan)  : biarkan SUPABASE_URL dan SUPABASE_ANON_KEY kosong.
                         Akun dan data tersimpan terenkripsi di browser masing-masing.
  MODE SUPABASE        : isi tiga nilai di bawah. Password diperiksa di server dan data disimpan di database.
                         Langkah lengkap ada di PANDUAN-SUPABASE.md.
*/
window.APP_CONFIG = {
  SUPABASE_URL: "https://ceswpywwrvxicsyfrebx.supabase.co",        // contoh: "https://abcdefgh.supabase.co"
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNlc3dweXd3cnZ4aWNzeWZyZWJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEzMDQ3ODUsImV4cCI6MjEwNjg4MDc4NX0.m46O7vjKb9uTasDdPVngKti_XQ4VDJVpb6Cy-SoDkVU",   // kunci "anon" / "publishable" (BUKAN service_role)
  ADMIN_EMAIL: "admin@layerastory.com",         // email akun admin di Supabase; username "admin" dipetakan ke email ini
  USERNAME_EMAIL: {},      // opsional, pengguna lain: { "siti": "siti@domainanda.com" }

  SEED_DEMO: false         // false = mulai kosong; true = isi data contoh saat pertama kali
};
