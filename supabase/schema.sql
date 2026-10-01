-- Curbside: the database for your own copy (Brief 21 §7).
-- Run once in a new Supabase project: Dashboard > SQL Editor > New query > paste this file > Run.
-- Then paste the project's URL and anon (publishable) key into the CONFIG block at the top of
-- parklet-checker.html. See README.md, "Your own backend".
--
-- Security posture:
--   * Row Level Security is ON for every table. A signed-in user reads, writes and deletes only their
--     own rows; a signed-out request (the public anon key alone) reads nothing.
--   * Only the public anon key ever goes in the page. Never put the service-role key, or any database
--     password, in the HTML or the repository.
--   * Sign-up is invite-only by default: one code, kept in app_settings (no API access at all) and
--     checked here, in the database, when an account is created. The page never sees the code.

create extension if not exists pgcrypto;

-- ── profiles: one row per user ───────────────────────────────────────────────────────────────────
create table if not exists public.profiles (
  id            uuid primary key references auth.users (id) on delete cascade,
  display_name  text,
  organization  text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
alter table public.profiles enable row level security;
drop policy if exists "profiles: read own"   on public.profiles;
drop policy if exists "profiles: insert own" on public.profiles;
drop policy if exists "profiles: update own" on public.profiles;
drop policy if exists "profiles: delete own" on public.profiles;
create policy "profiles: read own"   on public.profiles for select to authenticated using (id = auth.uid());
create policy "profiles: insert own" on public.profiles for insert to authenticated with check (id = auth.uid());
create policy "profiles: update own" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "profiles: delete own" on public.profiles for delete to authenticated using (id = auth.uid());

-- ── designs: every design is owned by the user who made it ───────────────────────────────────────
create table if not exists public.designs (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name            text not null default 'Untitled parklet',
  description     text default '',
  state           jsonb not null default '{}'::jsonb,
  version         integer not null default 1,
  thumbnail_data  text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index if not exists designs_user_updated on public.designs (user_id, updated_at desc);
alter table public.designs enable row level security;
drop policy if exists "designs: read own"   on public.designs;
drop policy if exists "designs: insert own" on public.designs;
drop policy if exists "designs: update own" on public.designs;
drop policy if exists "designs: delete own" on public.designs;
create policy "designs: read own"   on public.designs for select to authenticated using (user_id = auth.uid());
create policy "designs: insert own" on public.designs for insert to authenticated with check (user_id = auth.uid());
create policy "designs: update own" on public.designs for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "designs: delete own" on public.designs for delete to authenticated using (user_id = auth.uid());

-- ── invite-only sign-up ──────────────────────────────────────────────────────────────────────────
-- One row. RLS on and no policies: neither the anon key nor a signed-in user can read it through the API.
create table if not exists public.app_settings (
  id           boolean primary key default true check (id),
  invite_only  boolean not null default true,
  invite_code  text not null
);
alter table public.app_settings enable row level security;
revoke all on public.app_settings from anon, authenticated;
insert into public.app_settings (id, invite_only, invite_code) values (true, true, 'CHANGE-ME')
  on conflict (id) do nothing;
-- Set your code (run this line with your own value):
--   update public.app_settings set invite_code = 'your-code-here';
-- The one-line toggle to open sign-up to anyone (and back):
--   update public.app_settings set invite_only = false;
-- (Also set CONFIG.INVITE_ONLY = false in parklet-checker.html so the form stops asking for a code.)

-- Checked when an account is created: the code arrives in the sign-up metadata and is removed from it
-- before the account is stored. Existing accounts are untouched (it runs on insert only).
create or replace function public.check_invite_code() returns trigger
  language plpgsql security definer set search_path = public as $$
declare s public.app_settings;
begin
  select * into s from public.app_settings where id;
  if coalesce(s.invite_only, true) and coalesce(new.raw_user_meta_data ->> 'invite_code', '') <> coalesce(s.invite_code, '') then
    raise exception 'invite code required';
  end if;
  new.raw_user_meta_data := coalesce(new.raw_user_meta_data, '{}'::jsonb) - 'invite_code';
  return new;
end $$;
revoke all on function public.check_invite_code() from public, anon, authenticated;
drop trigger if exists check_invite_code on auth.users;
create trigger check_invite_code before insert on auth.users for each row execute function public.check_invite_code();

-- ── My furniture: a private storage bucket, one folder per user (<user id>/<piece id>.json) ─────────
insert into storage.buckets (id, name, public) values ('user-furniture', 'user-furniture', false)
  on conflict (id) do nothing;
drop policy if exists "user-furniture: read own"   on storage.objects;
drop policy if exists "user-furniture: insert own" on storage.objects;
drop policy if exists "user-furniture: update own" on storage.objects;
drop policy if exists "user-furniture: delete own" on storage.objects;
create policy "user-furniture: read own"   on storage.objects for select to authenticated
  using (bucket_id = 'user-furniture' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "user-furniture: insert own" on storage.objects for insert to authenticated
  with check (bucket_id = 'user-furniture' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "user-furniture: update own" on storage.objects for update to authenticated
  using (bucket_id = 'user-furniture' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "user-furniture: delete own" on storage.objects for delete to authenticated
  using (bucket_id = 'user-furniture' and (storage.foldername(name))[1] = auth.uid()::text);

-- ── check: RLS is on for every table in public (all rows should read true) ─────────────────────────
-- select relname, relrowsecurity from pg_class where relnamespace = 'public'::regnamespace and relkind = 'r';

-- Whether sign-up asks for a code, readable by anyone (the flag only, never the code): the landing page and the
-- sign-up form follow it (Brief 25 item 7; also in invite-status.sql for databases set up before it).
create or replace function public.signup_invite_only() returns boolean
  language sql stable security definer set search_path = public as $$
  select coalesce((select invite_only from public.app_settings where id), true);
$$;
revoke all on function public.signup_invite_only() from public;
grant execute on function public.signup_invite_only() to anon, authenticated;
