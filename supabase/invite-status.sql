-- Curbside: whether sign-up asks for an invite code, readable by anyone (Brief 25 item 7).
-- The landing page and the sign-up form ask this function, so the "invite code required" line and the code field
-- follow app_settings.invite_only instead of a value written into the page. It returns the yes / no flag only: the
-- code itself stays unreadable (app_settings has no API access at all). Run once in the SQL editor, after schema.sql.
create or replace function public.signup_invite_only() returns boolean
  language sql stable security definer set search_path = public as $$
  select coalesce((select invite_only from public.app_settings where id), true);
$$;
revoke all on function public.signup_invite_only() from public;
grant execute on function public.signup_invite_only() to anon, authenticated;
