alter table public.product_variants enable row level security;
alter table public.product_images enable row level security;

comment on table public.product_variants is 'RLS enabled in 007_catalog_detail_rls.sql.';
comment on table public.product_images is 'RLS enabled in 007_catalog_detail_rls.sql.';

create policy product_variants_select_public
on public.product_variants
for select
to public
using (
  status = 'active'
  and exists (
    select 1
    from public.products p
    where p.id = product_id
      and p.status = 'active'
      and p.deleted_at is null
  )
);

create policy product_variants_select_internal
on public.product_variants
for select
to authenticated
using (
  public.has_permission('products.read')
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy product_variants_insert_internal
on public.product_variants
for insert
to authenticated
with check (
  public.has_permission('products.create')
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy product_variants_update_internal
on public.product_variants
for update
to authenticated
using (
  (
    public.has_permission('products.update')
    or public.has_permission('products.delete')
  )
  and coalesce(public.current_profile_status(), '') = 'active'
)
with check (
  (
    public.has_permission('products.update')
    or public.has_permission('products.delete')
  )
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy product_images_select_public
on public.product_images
for select
to public
using (
  status = 'active'
  and exists (
    select 1
    from public.products p
    where p.id = product_id
      and p.status = 'active'
      and p.deleted_at is null
  )
);

create policy product_images_select_internal
on public.product_images
for select
to authenticated
using (
  public.has_permission('products.read')
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy product_images_insert_internal
on public.product_images
for insert
to authenticated
with check (
  (
    public.has_permission('products.create')
    or public.has_permission('products.update')
  )
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy product_images_update_internal
on public.product_images
for update
to authenticated
using (
  public.has_permission('products.update')
  and coalesce(public.current_profile_status(), '') = 'active'
)
with check (
  public.has_permission('products.update')
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy product_images_delete_internal
on public.product_images
for delete
to authenticated
using (
  public.has_permission('products.delete')
  and coalesce(public.current_profile_status(), '') = 'active'
);
