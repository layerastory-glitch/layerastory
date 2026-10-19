-- ============================================================
-- Layera Story Dashboard: skema Supabase
-- Jalankan sekali di Supabase > SQL Editor > New query > Run
-- Aman dijalankan ulang (memakai IF NOT EXISTS / DROP IF EXISTS).
-- ============================================================

-- 1) Tabel -----------------------------------------------------
create table if not exists public.orders (
  id         text primary key,                                   -- nomor invoice, mis. INV-202610-001
  owner      uuid not null default auth.uid()
             references auth.users (id) on delete cascade,
  tanggal    date not null,                                      -- tanggal order (untuk pengurutan)
  data       jsonb not null check (jsonb_typeof(data) = 'object'), -- seluruh isi pesanan
  updated_at timestamptz not null default now()
);

create index if not exists orders_owner_tanggal_idx on public.orders (owner, tanggal desc);

create table if not exists public.settings (
  owner      uuid primary key default auth.uid()
             references auth.users (id) on delete cascade,
  data       jsonb not null check (jsonb_typeof(data) = 'object'),
  updated_at timestamptz not null default now()
);

-- 2) Penanda waktu ubah otomatis --------------------------------
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists orders_touch on public.orders;
create trigger orders_touch before update on public.orders
  for each row execute function public.touch_updated_at();

drop trigger if exists settings_touch on public.settings;
create trigger settings_touch before update on public.settings
  for each row execute function public.touch_updated_at();

-- 3) Row Level Security: hanya pemilik baris yang bisa mengakses -
alter table public.orders   enable row level security;
alter table public.settings enable row level security;

-- Pengguna anonim (tanpa login) tidak boleh menyentuh tabel sama sekali
revoke all on public.orders   from anon;
revoke all on public.settings from anon;
grant select, insert, update, delete on public.orders   to authenticated;
grant select, insert, update, delete on public.settings to authenticated;

drop policy if exists "orders: hanya pemilik" on public.orders;
create policy "orders: hanya pemilik" on public.orders
  for all to authenticated
  using      (owner = (select auth.uid()))
  with check (owner = (select auth.uid()));

drop policy if exists "settings: hanya pemilik" on public.settings;
create policy "settings: hanya pemilik" on public.settings
  for all to authenticated
  using      (owner = (select auth.uid()))
  with check (owner = (select auth.uid()));
