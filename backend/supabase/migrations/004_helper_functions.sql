create or replace function public.current_profile_id()
returns uuid
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
  select p.id
  from public.profiles p
  where p.id = auth.uid()
  limit 1;
$$;

comment on function public.current_profile_id()
is 'Returns the current authenticated profile id. Uses SECURITY DEFINER to avoid future RLS recursion on profiles. Execute is restricted to authenticated users.';

revoke all on function public.current_profile_id() from public;
grant execute on function public.current_profile_id() to authenticated;

create or replace function public.current_user_email()
returns text
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
  select u.email::text
  from auth.users u
  where u.id = auth.uid()
  limit 1;
$$;

comment on function public.current_user_email()
is 'Returns the trusted email for the current authenticated user from auth.users. Uses SECURITY DEFINER because auth.users is not client-readable. Execute is restricted to authenticated users.';

revoke all on function public.current_user_email() from public;
grant execute on function public.current_user_email() to authenticated;

create or replace function public.is_verified_email()
returns boolean
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
  select coalesce(
    (
      select u.email_confirmed_at is not null
      from auth.users u
      where u.id = auth.uid()
      limit 1
    ),
    false
  );
$$;

comment on function public.is_verified_email()
is 'Returns true only when the current authenticated user has a verified email in auth.users. Fails closed to false. Execute is restricted to authenticated users.';

revoke all on function public.is_verified_email() from public;
grant execute on function public.is_verified_email() to authenticated;

create or replace function public.current_role_id()
returns uuid
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
  select p.role_id
  from public.profiles p
  where p.id = public.current_profile_id()
  limit 1;
$$;

comment on function public.current_role_id()
is 'Returns the current profile role_id. Uses SECURITY DEFINER to remain reusable after profiles RLS is enabled. Execute is restricted to authenticated users.';

revoke all on function public.current_role_id() from public;
grant execute on function public.current_role_id() to authenticated;

create or replace function public.current_role_code()
returns text
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
  select lower(replace(r.name, ' ', '_'))::text
  from public.profiles p
  join public.roles r on r.id = p.role_id
  where p.id = public.current_profile_id()
  limit 1;
$$;

comment on function public.current_role_code()
is 'Returns a normalized role code such as super_admin, admin, viewer, or customer for the current authenticated profile. Execute is restricted to authenticated users.';

revoke all on function public.current_role_code() from public;
grant execute on function public.current_role_code() to authenticated;

create or replace function public.current_profile_status()
returns text
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
  select p.status::text
  from public.profiles p
  where p.id = public.current_profile_id()
  limit 1;
$$;

comment on function public.current_profile_status()
is 'Returns the current profile status such as pending, active, suspended, or inactive. Execute is restricted to authenticated users.';

revoke all on function public.current_profile_status() from public;
grant execute on function public.current_profile_status() to authenticated;

create or replace function public.has_permission(permission_code text)
returns boolean
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
  select coalesce(
    exists (
      select 1
      from public.profiles p
      join public.roles r
        on r.id = p.role_id
      join public.role_permissions rp
        on rp.role_id = r.id
      join public.permissions perm
        on perm.id = rp.permission_id
      where p.id = public.current_profile_id()
        and p.status = 'active'
        and r.status = 'active'
        and perm.status = 'active'
        and perm.code = permission_code
    ),
    false
  );
$$;

comment on function public.has_permission(text)
is 'Returns true only when the current authenticated active profile has the requested active permission. Fails closed to false. Execute is restricted to authenticated users.';

revoke all on function public.has_permission(text) from public;
grant execute on function public.has_permission(text) to authenticated;

create or replace function public.owns_profile(target_profile_id uuid)
returns boolean
language sql
stable
set search_path = public, auth, pg_temp
as $$
  select coalesce(target_profile_id = public.current_profile_id(), false);
$$;

comment on function public.owns_profile(uuid)
is 'Returns true only when the target profile id matches the current authenticated profile id. Execute is restricted to authenticated users.';

revoke all on function public.owns_profile(uuid) from public;
grant execute on function public.owns_profile(uuid) to authenticated;

create or replace function public.owns_cart(target_cart_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
  select coalesce(
    exists (
      select 1
      from public.carts c
      where c.id = target_cart_id
        and c.profile_id = public.current_profile_id()
    ),
    false
  );
$$;

comment on function public.owns_cart(uuid)
is 'Returns true only when the target cart belongs to the current authenticated profile. Uses SECURITY DEFINER to remain reusable under future cart RLS. Execute is restricted to authenticated users.';

revoke all on function public.owns_cart(uuid) from public;
grant execute on function public.owns_cart(uuid) to authenticated;

create or replace function public.owns_order(target_order_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
  select coalesce(
    exists (
      select 1
      from public.orders o
      where o.id = target_order_id
        and o.profile_id = public.current_profile_id()
    ),
    false
  );
$$;

comment on function public.owns_order(uuid)
is 'Returns true only when the target order belongs to the current authenticated profile. Uses SECURITY DEFINER to remain reusable under future order RLS. Execute is restricted to authenticated users.';

revoke all on function public.owns_order(uuid) from public;
grant execute on function public.owns_order(uuid) to authenticated;
