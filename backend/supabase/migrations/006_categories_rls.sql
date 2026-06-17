alter table public.categories enable row level security;

comment on table public.categories is 'RLS enabled in 006_categories_rls.sql.';

create policy categories_select_public
on public.categories
for select
to public
using (
  status = 'active'
  and deleted_at is null
);

create policy categories_select_internal
on public.categories
for select
to authenticated
using (
  public.has_permission('categories.read')
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy categories_insert_internal
on public.categories
for insert
to authenticated
with check (
  public.has_permission('categories.create')
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy categories_update_internal
on public.categories
for update
to authenticated
using (
  (
    public.has_permission('categories.update')
    or public.has_permission('categories.delete')
    or public.has_permission('categories.restore')
  )
  and coalesce(public.current_profile_status(), '') = 'active'
)
with check (
  (
    public.has_permission('categories.update')
    or public.has_permission('categories.delete')
    or public.has_permission('categories.restore')
  )
  and coalesce(public.current_profile_status(), '') = 'active'
);
