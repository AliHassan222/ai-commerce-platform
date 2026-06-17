alter table public.profiles enable row level security;
alter table public.addresses enable row level security;
alter table public.products enable row level security;
alter table public.carts enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.wishlists enable row level security;
alter table public.wishlist_items enable row level security;
alter table public.product_reviews enable row level security;
alter table public.notifications enable row level security;

comment on table public.profiles is 'RLS enabled in 005_rls_foundation.sql.';
comment on table public.addresses is 'RLS enabled in 005_rls_foundation.sql.';
comment on table public.products is 'RLS enabled in 005_rls_foundation.sql.';
comment on table public.carts is 'RLS enabled in 005_rls_foundation.sql.';
comment on table public.cart_items is 'RLS enabled in 005_rls_foundation.sql.';
comment on table public.orders is 'RLS enabled in 005_rls_foundation.sql.';
comment on table public.order_items is 'RLS enabled in 005_rls_foundation.sql.';
comment on table public.wishlists is 'RLS enabled in 005_rls_foundation.sql.';
comment on table public.wishlist_items is 'RLS enabled in 005_rls_foundation.sql.';
comment on table public.product_reviews is 'RLS enabled in 005_rls_foundation.sql.';
comment on table public.notifications is 'RLS enabled in 005_rls_foundation.sql.';

create policy profiles_select_own
on public.profiles
for select
to authenticated
using (
  public.owns_profile(id)
);

create policy profiles_select_internal
on public.profiles
for select
to authenticated
using (
  public.has_permission('users.read')
);

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
);

create policy profiles_update_super_admin
on public.profiles
for update
to authenticated
using (
  public.has_permission('users.manage_roles')
)
with check (
  public.has_permission('users.manage_roles')
);

create policy addresses_select_own
on public.addresses
for select
to authenticated
using (
  profile_id = public.current_profile_id()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy addresses_insert_own
on public.addresses
for insert
to authenticated
with check (
  profile_id = public.current_profile_id()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy addresses_update_own
on public.addresses
for update
to authenticated
using (
  profile_id = public.current_profile_id()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
)
with check (
  profile_id = public.current_profile_id()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy addresses_delete_own
on public.addresses
for delete
to authenticated
using (
  profile_id = public.current_profile_id()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy products_select_public
on public.products
for select
to public
using (
  status = 'active'
  and deleted_at is null
);

create policy products_select_internal
on public.products
for select
to authenticated
using (
  public.has_permission('products.read')
);

create policy products_insert_internal
on public.products
for insert
to authenticated
with check (
  public.has_permission('products.create')
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy products_update_internal
on public.products
for update
to authenticated
using (
  (
    public.has_permission('products.update')
    or public.has_permission('products.publish')
    or public.has_permission('products.delete')
    or public.has_permission('products.restore')
  )
  and coalesce(public.current_profile_status(), '') = 'active'
)
with check (
  (
    public.has_permission('products.update')
    or public.has_permission('products.publish')
    or public.has_permission('products.delete')
    or public.has_permission('products.restore')
  )
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy carts_select_own
on public.carts
for select
to authenticated
using (
  public.owns_cart(id)
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy carts_insert_own
on public.carts
for insert
to authenticated
with check (
  profile_id = public.current_profile_id()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy carts_update_own
on public.carts
for update
to authenticated
using (
  public.owns_cart(id)
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
)
with check (
  profile_id = public.current_profile_id()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy carts_delete_own
on public.carts
for delete
to authenticated
using (
  public.owns_cart(id)
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy cart_items_select_own
on public.cart_items
for select
to authenticated
using (
  public.owns_cart(cart_id)
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy cart_items_insert_own
on public.cart_items
for insert
to authenticated
with check (
  public.owns_cart(cart_id)
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy cart_items_update_own
on public.cart_items
for update
to authenticated
using (
  public.owns_cart(cart_id)
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
)
with check (
  public.owns_cart(cart_id)
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy cart_items_delete_own
on public.cart_items
for delete
to authenticated
using (
  public.owns_cart(cart_id)
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy orders_select_own
on public.orders
for select
to authenticated
using (
  public.owns_order(id)
  and deleted_at is null
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy orders_select_internal
on public.orders
for select
to authenticated
using (
  public.has_permission('orders.read_all')
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy order_items_select_own
on public.order_items
for select
to authenticated
using (
  public.owns_order(order_id)
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy order_items_select_internal
on public.order_items
for select
to authenticated
using (
  public.has_permission('orders.read_all')
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy wishlists_select_own
on public.wishlists
for select
to authenticated
using (
  profile_id = public.current_profile_id()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy wishlists_insert_own
on public.wishlists
for insert
to authenticated
with check (
  profile_id = public.current_profile_id()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy wishlists_update_own
on public.wishlists
for update
to authenticated
using (
  profile_id = public.current_profile_id()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
)
with check (
  profile_id = public.current_profile_id()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy wishlists_delete_own
on public.wishlists
for delete
to authenticated
using (
  profile_id = public.current_profile_id()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy wishlist_items_select_own
on public.wishlist_items
for select
to authenticated
using (
  exists (
    select 1
    from public.wishlists w
    where w.id = wishlist_id
      and w.profile_id = public.current_profile_id()
  )
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy wishlist_items_insert_own
on public.wishlist_items
for insert
to authenticated
with check (
  exists (
    select 1
    from public.wishlists w
    where w.id = wishlist_id
      and w.profile_id = public.current_profile_id()
  )
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy wishlist_items_delete_own
on public.wishlist_items
for delete
to authenticated
using (
  exists (
    select 1
    from public.wishlists w
    where w.id = wishlist_id
      and w.profile_id = public.current_profile_id()
  )
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy product_reviews_select_published
on public.product_reviews
for select
to public
using (
  status = 'published'
);

create policy product_reviews_select_own
on public.product_reviews
for select
to authenticated
using (
  profile_id = public.current_profile_id()
);

create policy product_reviews_select_internal
on public.product_reviews
for select
to authenticated
using (
  public.has_permission('reviews.read')
);

create policy product_reviews_insert_own_verified
on public.product_reviews
for insert
to authenticated
with check (
  profile_id = public.current_profile_id()
  and public.is_verified_email()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
  and status = 'pending'
);

create policy product_reviews_update_own_pending
on public.product_reviews
for update
to authenticated
using (
  profile_id = public.current_profile_id()
  and status = 'pending'
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
)
with check (
  profile_id = public.current_profile_id()
  and status = 'pending'
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy product_reviews_update_internal
on public.product_reviews
for update
to authenticated
using (
  (
    public.has_permission('reviews.moderate')
    or public.has_permission('reviews.hide')
    or public.has_permission('reviews.delete')
  )
  and coalesce(public.current_profile_status(), '') = 'active'
)
with check (
  (
    public.has_permission('reviews.moderate')
    or public.has_permission('reviews.hide')
    or public.has_permission('reviews.delete')
  )
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy product_reviews_delete_own_pending
on public.product_reviews
for delete
to authenticated
using (
  profile_id = public.current_profile_id()
  and status = 'pending'
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);

create policy product_reviews_delete_internal
on public.product_reviews
for delete
to authenticated
using (
  public.has_permission('reviews.delete')
  and coalesce(public.current_profile_status(), '') = 'active'
);

create policy notifications_select_own
on public.notifications
for select
to authenticated
using (
  profile_id = public.current_profile_id()
  and coalesce(public.current_profile_status(), '') in ('pending', 'active')
);
