-- COUTELYA V1.0 — schéma Supabase/PostgreSQL
-- L'application reste offline-first via SQLite.

create extension if not exists pgcrypto;

create table if not exists public.workshops (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  phone text,
  whatsapp text,
  address text,
  plan text not null default 'free' check (plan in ('free', 'pro', 'atelier')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.clients (
  id uuid primary key,
  workshop_id uuid not null references public.workshops(id) on delete cascade,
  first_name text not null,
  last_name text not null,
  phone text,
  whatsapp text,
  email text,
  gender text,
  address text,
  notes text,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz
);

create table if not exists public.measurements (
  id uuid primary key,
  workshop_id uuid not null references public.workshops(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  category text not null,
  values_json jsonb not null default '{}'::jsonb,
  taken_at timestamptz not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz
);

create table if not exists public.orders (
  id uuid primary key,
  workshop_id uuid not null references public.workshops(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete restrict,
  reference text not null,
  garment_type text not null,
  description text,
  fabric text,
  color text,
  total_amount numeric(12,2) not null default 0 check (total_amount >= 0),
  order_date timestamptz,
  fitting_date timestamptz,
  delivery_date timestamptz,
  status text not null default 'registered' check (status in ('registered','measured','cutting','sewing','fitting','alteration','finishing','ready','delivered','cancelled')),
  notes text,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  unique (workshop_id, reference)
);

create table if not exists public.payments (
  id uuid primary key,
  workshop_id uuid not null references public.workshops(id) on delete cascade,
  order_id uuid not null references public.orders(id) on delete cascade,
  amount numeric(12,2) not null check (amount > 0),
  payment_method text not null check (payment_method in ('cash','mobile_money','bank_transfer','other')),
  paid_at timestamptz not null,
  note text,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz
);

create table if not exists public.expenses (
  id uuid primary key,
  workshop_id uuid not null references public.workshops(id) on delete cascade,
  category text not null,
  amount numeric(12,2) not null check (amount > 0),
  expense_date timestamptz not null,
  note text,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz
);

create index if not exists idx_clients_workshop on public.clients(workshop_id);
create index if not exists idx_clients_name on public.clients(workshop_id, last_name, first_name);
create index if not exists idx_orders_workshop_status on public.orders(workshop_id, status);
create index if not exists idx_orders_delivery on public.orders(workshop_id, delivery_date);
create index if not exists idx_payments_order on public.payments(order_id);
create index if not exists idx_expenses_workshop_date on public.expenses(workshop_id, expense_date);

alter table public.workshops enable row level security;
alter table public.clients enable row level security;
alter table public.measurements enable row level security;
alter table public.orders enable row level security;
alter table public.payments enable row level security;
alter table public.expenses enable row level security;

create policy "workshops_owner_all" on public.workshops for all to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "clients_owner_all" on public.clients for all to authenticated using (exists (select 1 from public.workshops w where w.id = clients.workshop_id and w.owner_id = (select auth.uid()))) with check (exists (select 1 from public.workshops w where w.id = clients.workshop_id and w.owner_id = (select auth.uid())));
create policy "measurements_owner_all" on public.measurements for all to authenticated using (exists (select 1 from public.workshops w where w.id = measurements.workshop_id and w.owner_id = (select auth.uid()))) with check (exists (select 1 from public.workshops w where w.id = measurements.workshop_id and w.owner_id = (select auth.uid())));
create policy "orders_owner_all" on public.orders for all to authenticated using (exists (select 1 from public.workshops w where w.id = orders.workshop_id and w.owner_id = (select auth.uid()))) with check (exists (select 1 from public.workshops w where w.id = orders.workshop_id and w.owner_id = (select auth.uid())));
create policy "payments_owner_all" on public.payments for all to authenticated using (exists (select 1 from public.workshops w where w.id = payments.workshop_id and w.owner_id = (select auth.uid()))) with check (exists (select 1 from public.workshops w where w.id = payments.workshop_id and w.owner_id = (select auth.uid())));
create policy "expenses_owner_all" on public.expenses for all to authenticated using (exists (select 1 from public.workshops w where w.id = expenses.workshop_id and w.owner_id = (select auth.uid()))) with check (exists (select 1 from public.workshops w where w.id = expenses.workshop_id and w.owner_id = (select auth.uid())));

grant select, insert, update, delete on public.workshops to authenticated;
grant select, insert, update, delete on public.clients to authenticated;
grant select, insert, update, delete on public.measurements to authenticated;
grant select, insert, update, delete on public.orders to authenticated;
grant select, insert, update, delete on public.payments to authenticated;
grant select, insert, update, delete on public.expenses to authenticated;
