alter table public.categories
add column deleted_at timestamptz;

alter table public.products
add column vendor_id uuid,
add column deleted_at timestamptz;

alter table public.orders
add column deleted_at timestamptz;

create table public.vendors (
  id uuid primary key default gen_random_uuid(),
  owner_profile_id uuid references public.profiles(id) on delete set null,
  name varchar(255) not null,
  slug varchar(255) not null unique,
  legal_name varchar(255),
  contact_email varchar(255) not null,
  contact_phone varchar(50),
  description text,
  status varchar(30) not null default 'draft',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint vendors_status_check check (status in ('draft', 'active', 'suspended', 'inactive'))
);

alter table public.products
add constraint products_vendor_id_fkey
foreign key (vendor_id) references public.vendors(id) on delete set null;

create table public.product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  sku varchar(100) not null unique,
  name varchar(255),
  option_values jsonb not null default '{}'::jsonb,
  price_amount numeric(12,2) not null,
  compare_at_price numeric(12,2),
  currency_code char(3) not null default 'USD',
  weight_grams integer,
  status varchar(30) not null default 'active',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint product_variants_price_amount_check check (price_amount >= 0),
  constraint product_variants_compare_at_price_check check (compare_at_price is null or compare_at_price >= 0),
  constraint product_variants_weight_grams_check check (weight_grams is null or weight_grams >= 0),
  constraint product_variants_status_check check (status in ('active', 'inactive'))
);

create table public.inventory (
  id uuid primary key default gen_random_uuid(),
  variant_id uuid not null references public.product_variants(id) on delete cascade,
  vendor_id uuid references public.vendors(id) on delete set null,
  location_code varchar(100) not null,
  quantity_on_hand integer not null default 0,
  quantity_reserved integer not null default 0,
  reorder_threshold integer,
  status varchar(30) not null default 'active',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint inventory_quantity_on_hand_check check (quantity_on_hand >= 0),
  constraint inventory_quantity_reserved_check check (quantity_reserved >= 0),
  constraint inventory_reserved_not_exceed_on_hand_check check (quantity_reserved <= quantity_on_hand),
  constraint inventory_reorder_threshold_check check (reorder_threshold is null or reorder_threshold >= 0),
  constraint inventory_status_check check (status in ('active', 'inactive')),
  constraint inventory_unique_variant_vendor_location unique (variant_id, vendor_id, location_code)
);

create table public.coupons (
  id uuid primary key default gen_random_uuid(),
  code varchar(80) not null unique,
  description text,
  discount_type varchar(30) not null,
  discount_value numeric(12,2) not null,
  minimum_order_amount numeric(12,2),
  usage_limit integer,
  usage_count integer not null default 0,
  starts_at timestamptz,
  ends_at timestamptz,
  status varchar(30) not null default 'draft',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint coupons_discount_type_check check (discount_type in ('percentage', 'fixed_amount', 'free_shipping')),
  constraint coupons_discount_value_check check (discount_value >= 0),
  constraint coupons_minimum_order_amount_check check (minimum_order_amount is null or minimum_order_amount >= 0),
  constraint coupons_usage_limit_check check (usage_limit is null or usage_limit >= 0),
  constraint coupons_usage_count_check check (usage_count >= 0),
  constraint coupons_date_range_check check (ends_at is null or starts_at is null or ends_at >= starts_at),
  constraint coupons_status_check check (status in ('draft', 'active', 'expired', 'disabled'))
);

create table public.order_coupons (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  coupon_id uuid references public.coupons(id) on delete set null,
  coupon_code varchar(80) not null,
  discount_amount numeric(12,2) not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint order_coupons_discount_amount_check check (discount_amount >= 0)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  channel varchar(30) not null,
  type varchar(80) not null,
  title varchar(255) not null,
  message text not null,
  payload jsonb not null default '{}'::jsonb,
  status varchar(30) not null default 'pending',
  sent_at timestamptz,
  read_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint notifications_channel_check check (channel in ('push', 'email', 'sms', 'in_app')),
  constraint notifications_status_check check (status in ('pending', 'queued', 'sent', 'failed', 'read'))
);

create table public.wishlists (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  name varchar(120) not null,
  is_default boolean not null default false,
  status varchar(30) not null default 'active',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint wishlists_status_check check (status in ('active', 'archived'))
);

create table public.wishlist_items (
  id uuid primary key default gen_random_uuid(),
  wishlist_id uuid not null references public.wishlists(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  variant_id uuid references public.product_variants(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint wishlist_items_unique_item unique (wishlist_id, product_id, variant_id)
);

create table public.product_reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  variant_id uuid references public.product_variants(id) on delete set null,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  rating integer not null,
  title varchar(255),
  review_text text,
  status varchar(30) not null default 'pending',
  is_verified_purchase boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint product_reviews_rating_check check (rating between 1 and 5),
  constraint product_reviews_status_check check (status in ('pending', 'published', 'rejected', 'hidden'))
);

create index idx_categories_deleted_at on public.categories(deleted_at);

create index idx_products_vendor_id on public.products(vendor_id);
create index idx_products_deleted_at on public.products(deleted_at);

create index idx_orders_deleted_at on public.orders(deleted_at);

create index idx_vendors_owner_profile_id on public.vendors(owner_profile_id);
create index idx_vendors_status on public.vendors(status);
create index idx_vendors_name on public.vendors(name);

create index idx_product_variants_product_id on public.product_variants(product_id);
create index idx_product_variants_status on public.product_variants(status);
create index idx_product_variants_price_amount on public.product_variants(price_amount);

create index idx_inventory_variant_id on public.inventory(variant_id);
create index idx_inventory_vendor_id on public.inventory(vendor_id);
create index idx_inventory_status on public.inventory(status);
create index idx_inventory_location_code on public.inventory(location_code);

create index idx_coupons_status on public.coupons(status);
create index idx_coupons_code on public.coupons(code);
create index idx_coupons_starts_at on public.coupons(starts_at);
create index idx_coupons_ends_at on public.coupons(ends_at);

create index idx_order_coupons_order_id on public.order_coupons(order_id);
create index idx_order_coupons_coupon_id on public.order_coupons(coupon_id);
create index idx_order_coupons_coupon_code on public.order_coupons(coupon_code);

create index idx_notifications_profile_id on public.notifications(profile_id);
create index idx_notifications_status on public.notifications(status);
create index idx_notifications_channel on public.notifications(channel);
create index idx_notifications_type on public.notifications(type);

create index idx_wishlists_profile_id on public.wishlists(profile_id);
create index idx_wishlists_status on public.wishlists(status);
create index idx_wishlists_default on public.wishlists(profile_id, is_default);

create index idx_wishlist_items_wishlist_id on public.wishlist_items(wishlist_id);
create index idx_wishlist_items_product_id on public.wishlist_items(product_id);
create index idx_wishlist_items_variant_id on public.wishlist_items(variant_id);

create index idx_product_reviews_product_id on public.product_reviews(product_id);
create index idx_product_reviews_variant_id on public.product_reviews(variant_id);
create index idx_product_reviews_profile_id on public.product_reviews(profile_id);
create index idx_product_reviews_status on public.product_reviews(status);
create index idx_product_reviews_rating on public.product_reviews(rating);

create trigger set_updated_at_vendors
before update on public.vendors
for each row
execute function public.set_updated_at();

create trigger set_updated_at_product_variants
before update on public.product_variants
for each row
execute function public.set_updated_at();

create trigger set_updated_at_inventory
before update on public.inventory
for each row
execute function public.set_updated_at();

create trigger set_updated_at_coupons
before update on public.coupons
for each row
execute function public.set_updated_at();

create trigger set_updated_at_order_coupons
before update on public.order_coupons
for each row
execute function public.set_updated_at();

create trigger set_updated_at_notifications
before update on public.notifications
for each row
execute function public.set_updated_at();

create trigger set_updated_at_wishlists
before update on public.wishlists
for each row
execute function public.set_updated_at();

create trigger set_updated_at_wishlist_items
before update on public.wishlist_items
for each row
execute function public.set_updated_at();

create trigger set_updated_at_product_reviews
before update on public.product_reviews
for each row
execute function public.set_updated_at();
