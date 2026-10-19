-- ============================================================
-- Setelah membuat akun admin dengan password sementara (admin12),
-- jalankan ini agar aplikasi MEMAKSA ganti password saat masuk pertama.
-- Ganti email di bawah dengan email akun admin Anda.
-- ============================================================
update auth.users
   set raw_user_meta_data = coalesce(raw_user_meta_data, '{}'::jsonb) || '{"must_change": true}'::jsonb
 where email = 'admin@domainanda.com';

-- Pemeriksaan: harus menampilkan 1 baris dengan must_change = true
select email, raw_user_meta_data ->> 'must_change' as must_change
  from auth.users
 where email = 'admin@domainanda.com';
