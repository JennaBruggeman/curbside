-- Curbside: one invite code per person (2026-10-01). Run AFTER schema.sql, once, in the Supabase SQL Editor.
-- Replaces the single shared code in app_settings with a table of codes: each has a label (who it is for), a number
-- of uses (1 by default: one account per code) and an optional expiry. The page never sees a code: the database
-- checks it when an account is created, exactly as before, and removes it from the account's metadata.
--
-- Security posture (unchanged): RLS on, no policies, and no grants: neither the anon key nor a signed-in user can
-- read or change a code through the API. Only you, in the SQL Editor (as the postgres role), can.
-- After this runs, the old shared code in app_settings.invite_code is no longer accepted; app_settings.invite_only
-- still switches the whole check on and off.

create table if not exists public.invite_codes (
  code          text primary key check (length(code) >= 8),
  label         text not null default '',
  max_uses      integer not null default 1 check (max_uses >= 0),
  uses          integer not null default 0 check (uses >= 0),
  expires_at    timestamptz,
  created_at    timestamptz not null default now(),
  last_used_at  timestamptz
);
alter table public.invite_codes enable row level security;
revoke all on public.invite_codes from anon, authenticated;

-- The check, on every new account: the code must exist, have a use left and not have expired; a use is counted.
-- It runs inside the sign-up's transaction, so a sign-up that fails later does not use up the code.
create or replace function public.check_invite_code() returns trigger
  language plpgsql security definer set search_path = public as $$
declare
  s public.app_settings;
  c text := upper(trim(coalesce(new.raw_user_meta_data ->> 'invite_code', '')));
  n integer;
begin
  select * into s from public.app_settings where id;
  if coalesce(s.invite_only, true) then
    update public.invite_codes set uses = uses + 1, last_used_at = now()
      where code = c and uses < max_uses and (expires_at is null or expires_at > now());
    get diagnostics n = row_count;
    if n = 0 then raise exception 'invite code required'; end if;
  end if;
  new.raw_user_meta_data := coalesce(new.raw_user_meta_data, '{}'::jsonb) - 'invite_code';
  return new;
end $$;
revoke all on function public.check_invite_code() from public, anon, authenticated;
-- (the trigger from schema.sql already calls this function; it is re-created here only if it is missing)
drop trigger if exists check_invite_code on auth.users;
create trigger check_invite_code before insert on auth.users for each row execute function public.check_invite_code();

-- ── Make codes (run as often as you like; each row printed is a new code) ─────────────────────────────────────────
-- Three reviewers, one account each, valid for 30 days:
--
--   insert into public.invite_codes (code, label, expires_at)
--   select upper(encode(gen_random_bytes(5), 'hex')), 'Reviewer ' || g, now() + interval '30 days'
--   from generate_series(1, 3) g
--   returning code, label, expires_at;
--
-- See them, and whether each has been used:
--   select code, label, uses, max_uses, expires_at, last_used_at from public.invite_codes order by created_at;
-- Withdraw one (accounts already made with it are untouched):
--   update public.invite_codes set max_uses = uses where label = 'Reviewer 2';
-- Delete all unused ones:
--   delete from public.invite_codes where uses = 0;
