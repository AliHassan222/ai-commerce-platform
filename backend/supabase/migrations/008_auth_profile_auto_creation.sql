create or replace function public.handle_auth_user_profile_creation()
returns trigger
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
  customer_role_id uuid;
begin
  select r.id
  into customer_role_id
  from public.roles r
  where r.name = 'Customer'
    and r.status = 'active'
  limit 1;

  if customer_role_id is null then
    raise exception 'Customer role is not available for auth profile auto-creation';
  end if;

  insert into public.profiles (
    id,
    role_id,
    email,
    status
  )
  values (
    new.id,
    customer_role_id,
    new.email,
    'pending'
  )
  on conflict (id) do update
  set
    role_id = excluded.role_id,
    email = excluded.email,
    status = excluded.status;

  return new;
end;
$$;

comment on function public.handle_auth_user_profile_creation()
is 'Creates or repairs the matching public.profiles row after auth.users insert. Uses SECURITY DEFINER because it writes to application tables from auth schema context.';

revoke all on function public.handle_auth_user_profile_creation() from public;

drop trigger if exists on_auth_user_created_create_profile on auth.users;

create trigger on_auth_user_created_create_profile
after insert on auth.users
for each row
execute function public.handle_auth_user_profile_creation();

drop policy if exists profiles_update_own_limited on public.profiles;

create policy profiles_update_own_limited
on public.profiles
for update
to authenticated
using (
  public.owns_profile(id)
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
)
with check (
  public.owns_profile(id)
  and role_id is not distinct from public.current_role_id()
  and status is not distinct from public.current_profile_status()
  and email is not distinct from (
    select p.email
    from public.profiles p
    where p.id = public.current_profile_id()
    limit 1
  )
);
