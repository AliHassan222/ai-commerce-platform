create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table public.roles (
  id uuid primary key default gen_random_uuid(),
  name varchar(100) not null unique,
  description text,
  status varchar(30) not null default 'active',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint roles_status_check check (status in ('active', 'inactive'))
);

create table public.permissions (
  id uuid primary key default gen_random_uuid(),
  code varchar(120) not null unique,
  name varchar(120) not null,
  description text,
  status varchar(30) not null default 'active',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint permissions_status_check check (status in ('active', 'inactive'))
);

create table public.role_permissions (
  role_id uuid not null references public.roles(id) on delete cascade,
  permission_id uuid not null references public.permissions(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (role_id, permission_id)
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role_id uuid references public.roles(id) on delete set null,
  email varchar(255) not null unique,
  first_name varchar(120),
  last_name varchar(120),
  phone varchar(50),
  avatar_url text,
  status varchar(30) not null default 'pending',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint profiles_status_check check (status in ('pending', 'active', 'suspended', 'inactive'))
);

create table public.addresses (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  label varchar(100),
  recipient_name varchar(255) not null,
  phone varchar(50),
  country_code char(2) not null,
  state varchar(120),
  city varchar(120) not null,
  address_line_1 text not null,
  address_line_2 text,
  postal_code varchar(30),
  is_default_shipping boolean not null default false,
  is_default_billing boolean not null default false,
  status varchar(30) not null default 'active',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint addresses_status_check check (status in ('active', 'inactive'))
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid references public.categories(id) on delete set null,
  name varchar(255) not null,
  slug varchar(255) not null unique,
  description text,
  status varchar(30) not null default 'active',
  sort_order integer not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint categories_status_check check (status in ('active', 'inactive', 'archived'))
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.categories(id) on delete set null,
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  sku varchar(100) not null unique,
  name varchar(255) not null,
  slug varchar(255) not null unique,
  short_description text,
  description text,
  price_amount numeric(12,2) not null,
  currency_code char(3) not null default 'USD',
  status varchar(30) not null default 'draft',
  ai_enriched boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint products_price_amount_check check (price_amount >= 0),
  constraint products_status_check check (status in ('draft', 'active', 'inactive', 'archived'))
);

create table public.product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  image_url text not null,
  alt_text varchar(255),
  is_primary boolean not null default false,
  sort_order integer not null default 0,
  status varchar(30) not null default 'active',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint product_images_status_check check (status in ('active', 'inactive'))
);

create table public.carts (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id) on delete set null,
  guest_token varchar(255) unique,
  status varchar(30) not null default 'active',
  currency_code char(3) not null default 'USD',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint carts_status_check check (status in ('active', 'converted', 'abandoned'))
);

create table public.cart_items (
  id uuid primary key default gen_random_uuid(),
  cart_id uuid not null references public.carts(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete restrict,
  quantity integer not null,
  unit_price_amount numeric(12,2) not null,
  total_amount numeric(12,2) not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint cart_items_quantity_check check (quantity > 0),
  constraint cart_items_unit_price_amount_check check (unit_price_amount >= 0),
  constraint cart_items_total_amount_check check (total_amount >= 0),
  constraint cart_items_unique_product_per_cart unique (cart_id, product_id)
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id) on delete set null,
  cart_id uuid references public.carts(id) on delete set null,
  shipping_address_id uuid references public.addresses(id) on delete set null,
  billing_address_id uuid references public.addresses(id) on delete set null,
  order_number varchar(50) not null unique,
  status varchar(30) not null default 'pending',
  payment_status varchar(30) not null default 'pending',
  fulfillment_status varchar(30) not null default 'pending',
  currency_code char(3) not null default 'USD',
  subtotal_amount numeric(12,2) not null default 0,
  discount_amount numeric(12,2) not null default 0,
  tax_amount numeric(12,2) not null default 0,
  shipping_amount numeric(12,2) not null default 0,
  total_amount numeric(12,2) not null default 0,
  notes text,
  placed_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint orders_status_check check (status in ('pending', 'confirmed', 'paid', 'fulfilled', 'cancelled', 'refunded')),
  constraint orders_payment_status_check check (payment_status in ('pending', 'authorized', 'paid', 'failed', 'refunded')),
  constraint orders_fulfillment_status_check check (fulfillment_status in ('pending', 'processing', 'shipped', 'delivered', 'returned', 'cancelled')),
  constraint orders_subtotal_amount_check check (subtotal_amount >= 0),
  constraint orders_discount_amount_check check (discount_amount >= 0),
  constraint orders_tax_amount_check check (tax_amount >= 0),
  constraint orders_shipping_amount_check check (shipping_amount >= 0),
  constraint orders_total_amount_check check (total_amount >= 0)
);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name varchar(255) not null,
  product_sku varchar(100) not null,
  quantity integer not null,
  unit_price_amount numeric(12,2) not null,
  total_amount numeric(12,2) not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint order_items_quantity_check check (quantity > 0),
  constraint order_items_unit_price_amount_check check (unit_price_amount >= 0),
  constraint order_items_total_amount_check check (total_amount >= 0)
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_profile_id uuid references public.profiles(id) on delete set null,
  entity_type varchar(100) not null,
  entity_id uuid,
  action varchar(100) not null,
  metadata jsonb not null default '{}'::jsonb,
  status varchar(30) not null default 'success',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint audit_logs_status_check check (status in ('success', 'failed'))
);

create index idx_role_permissions_permission_id on public.role_permissions(permission_id);

create index idx_profiles_role_id on public.profiles(role_id);
create index idx_profiles_status on public.profiles(status);

create index idx_addresses_profile_id on public.addresses(profile_id);
create index idx_addresses_status on public.addresses(status);

create index idx_categories_parent_id on public.categories(parent_id);
create index idx_categories_status on public.categories(status);
create index idx_categories_sort_order on public.categories(sort_order);

create index idx_products_category_id on public.products(category_id);
create index idx_products_created_by on public.products(created_by);
create index idx_products_status on public.products(status);
create index idx_products_name on public.products(name);

create index idx_product_images_product_id on public.product_images(product_id);
create index idx_product_images_primary on public.product_images(product_id, is_primary);

create index idx_carts_profile_id on public.carts(profile_id);
create index idx_carts_status on public.carts(status);

create index idx_cart_items_cart_id on public.cart_items(cart_id);
create index idx_cart_items_product_id on public.cart_items(product_id);

create index idx_orders_profile_id on public.orders(profile_id);
create index idx_orders_cart_id on public.orders(cart_id);
create index idx_orders_status on public.orders(status);
create index idx_orders_payment_status on public.orders(payment_status);
create index idx_orders_fulfillment_status on public.orders(fulfillment_status);
create index idx_orders_placed_at on public.orders(placed_at);

create index idx_order_items_order_id on public.order_items(order_id);
create index idx_order_items_product_id on public.order_items(product_id);

create index idx_audit_logs_actor_profile_id on public.audit_logs(actor_profile_id);
create index idx_audit_logs_entity on public.audit_logs(entity_type, entity_id);
create index idx_audit_logs_action on public.audit_logs(action);
create index idx_audit_logs_created_at on public.audit_logs(created_at);

create trigger set_updated_at_roles
before update on public.roles
for each row
execute function public.set_updated_at();

create trigger set_updated_at_permissions
before update on public.permissions
for each row
execute function public.set_updated_at();

create trigger set_updated_at_role_permissions
before update on public.role_permissions
for each row
execute function public.set_updated_at();

create trigger set_updated_at_profiles
before update on public.profiles
for each row
execute function public.set_updated_at();

create trigger set_updated_at_addresses
before update on public.addresses
for each row
execute function public.set_updated_at();

create trigger set_updated_at_categories
before update on public.categories
for each row
execute function public.set_updated_at();

create trigger set_updated_at_products
before update on public.products
for each row
execute function public.set_updated_at();

create trigger set_updated_at_product_images
before update on public.product_images
for each row
execute function public.set_updated_at();

create trigger set_updated_at_carts
before update on public.carts
for each row
execute function public.set_updated_at();

create trigger set_updated_at_cart_items
before update on public.cart_items
for each row
execute function public.set_updated_at();

create trigger set_updated_at_orders
before update on public.orders
for each row
execute function public.set_updated_at();

create trigger set_updated_at_order_items
before update on public.order_items
for each row
execute function public.set_updated_at();

create trigger set_updated_at_audit_logs
before update on public.audit_logs
for each row
execute function public.set_updated_at();
