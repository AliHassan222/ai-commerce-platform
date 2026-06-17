begin;

create or replace function pg_temp.assert_true(condition boolean, message text)
returns void
language plpgsql
as $$
begin
  if not coalesce(condition, false) then
    raise exception '%', message;
  end if;
end;
$$;

delete from auth.users
where id in (
  '12000000-0000-0000-0000-000000000001'::uuid,
  '12000000-0000-0000-0000-000000000002'::uuid
);

insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
)
values
  (
    '00000000-0000-0000-0000-000000000000'::uuid,
    '12000000-0000-0000-0000-000000000001'::uuid,
    'authenticated',
    'authenticated',
    'ownership.customer.one@example.test',
    '$2a$10$7EqJtq98hPqEX7fNZaFWoO.HXh6n6PvxI6Bfq5lHppZArYrusS4CS',
    timezone('utc', now()),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    timezone('utc', now()),
    timezone('utc', now()),
    '',
    '',
    '',
    ''
  ),
  (
    '00000000-0000-0000-0000-000000000000'::uuid,
    '12000000-0000-0000-0000-000000000002'::uuid,
    'authenticated',
    'authenticated',
    'ownership.customer.two@example.test',
    '$2a$10$7EqJtq98hPqEX7fNZaFWoO.HXh6n6PvxI6Bfq5lHppZArYrusS4CS',
    timezone('utc', now()),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    timezone('utc', now()),
    timezone('utc', now()),
    '',
    '',
    '',
    ''
  );

insert into public.addresses (
  id,
  profile_id,
  recipient_name,
  country_code,
  city,
  address_line_1,
  status
)
values
  (
    '52000000-0000-0000-0000-000000000001'::uuid,
    '12000000-0000-0000-0000-000000000001'::uuid,
    'Customer One',
    'US',
    'Austin',
    '101 Ownership Lane',
    'active'
  ),
  (
    '52000000-0000-0000-0000-000000000002'::uuid,
    '12000000-0000-0000-0000-000000000002'::uuid,
    'Customer Two',
    'US',
    'Dallas',
    '202 Ownership Lane',
    'active'
  );

insert into public.carts (
  id,
  profile_id,
  status,
  currency_code
)
values
  (
    '53000000-0000-0000-0000-000000000001'::uuid,
    '12000000-0000-0000-0000-000000000001'::uuid,
    'active',
    'USD'
  ),
  (
    '53000000-0000-0000-0000-000000000002'::uuid,
    '12000000-0000-0000-0000-000000000002'::uuid,
    'active',
    'USD'
  );

insert into public.cart_items (
  id,
  cart_id,
  product_id,
  quantity,
  unit_price_amount,
  total_amount
)
values
  (
    '53100000-0000-0000-0000-000000000001'::uuid,
    '53000000-0000-0000-0000-000000000001'::uuid,
    (select id from public.products where slug = 'nova-x-smartphone'),
    1,
    799.00,
    799.00
  ),
  (
    '53100000-0000-0000-0000-000000000002'::uuid,
    '53000000-0000-0000-0000-000000000002'::uuid,
    (select id from public.products where slug = 'aerobook-14'),
    1,
    1099.00,
    1099.00
  );

insert into public.orders (
  id,
  profile_id,
  cart_id,
  shipping_address_id,
  billing_address_id,
  order_number,
  status,
  payment_status,
  fulfillment_status,
 currency_code,
  subtotal_amount,
  discount_amount,
  tax_amount,
  shipping_amount,
  total_amount
)
values
  (
    '54000000-0000-0000-0000-000000000001'::uuid,
    '12000000-0000-0000-0000-000000000001'::uuid,
    '53000000-0000-0000-0000-000000000001'::uuid,
    '52000000-0000-0000-0000-000000000001'::uuid,
    '52000000-0000-0000-0000-000000000001'::uuid,
    'OWN-ORDER-001',
    'pending',
    'pending',
    'pending',
    'USD',
    799.00,
    0.00,
    0.00,
    0.00,
    799.00
  ),
  (
    '54000000-0000-0000-0000-000000000002'::uuid,
    '12000000-0000-0000-0000-000000000002'::uuid,
    '53000000-0000-0000-0000-000000000002'::uuid,
    '52000000-0000-0000-0000-000000000002'::uuid,
    '52000000-0000-0000-0000-000000000002'::uuid,
    'OWN-ORDER-002',
    'pending',
    'pending',
    'pending',
    'USD',
    1099.00,
    0.00,
    0.00,
    0.00,
    1099.00
  );

insert into public.order_items (
  id,
  order_id,
  product_id,
  product_name,
  product_sku,
  quantity,
  unit_price_amount,
  total_amount
)
values
  (
    '54100000-0000-0000-0000-000000000001'::uuid,
    '54000000-0000-0000-0000-000000000001'::uuid,
    (select id from public.products where slug = 'nova-x-smartphone'),
    'Nova X Smartphone',
    'PHONE-001',
    1,
    799.00,
    799.00
  ),
  (
    '54100000-0000-0000-0000-000000000002'::uuid,
    '54000000-0000-0000-0000-000000000002'::uuid,
    (select id from public.products where slug = 'aerobook-14'),
    'AeroBook 14',
    'LAPTOP-001',
    1,
    1099.00,
    1099.00
  );

insert into public.wishlists (
  id,
  profile_id,
  name,
  is_default,
  status
)
values
  (
    '55000000-0000-0000-0000-000000000001'::uuid,
    '12000000-0000-0000-0000-000000000001'::uuid,
    'Customer One Wishlist',
    true,
    'active'
  ),
  (
    '55000000-0000-0000-0000-000000000002'::uuid,
    '12000000-0000-0000-0000-000000000002'::uuid,
    'Customer Two Wishlist',
    true,
    'active'
  );

insert into public.wishlist_items (
  id,
  wishlist_id,
  product_id
)
values
  (
    '55100000-0000-0000-0000-000000000001'::uuid,
    '55000000-0000-0000-0000-000000000001'::uuid,
    (select id from public.products where slug = 'nova-x-smartphone')
  ),
  (
    '55100000-0000-0000-0000-000000000002'::uuid,
    '55000000-0000-0000-0000-000000000002'::uuid,
    (select id from public.products where slug = 'aerobook-14')
  );

insert into public.notifications (
  id,
  profile_id,
  channel,
  type,
  title,
  message,
  status
)
values
  (
    '56000000-0000-0000-0000-000000000001'::uuid,
    '12000000-0000-0000-0000-000000000001'::uuid,
    'in_app',
    'order_update',
    'Order Update',
    'Your order was received.',
    'sent'
  ),
  (
    '56000000-0000-0000-0000-000000000002'::uuid,
    '12000000-0000-0000-0000-000000000002'::uuid,
    'in_app',
    'order_update',
    'Order Update',
    'Your order was received.',
    'sent'
  );

insert into public.product_reviews (
  id,
  product_id,
  profile_id,
  rating,
  title,
  review_text,
  status,
  is_verified_purchase
)
values
  (
    '57000000-0000-0000-0000-000000000001'::uuid,
    (select id from public.products where slug = 'nova-x-smartphone'),
    '12000000-0000-0000-0000-000000000001'::uuid,
    5,
    'Pending own review',
    'Owned pending review.',
    'pending',
    false
  ),
  (
    '57000000-0000-0000-0000-000000000002'::uuid,
    (select id from public.products where slug = 'nova-x-smartphone'),
    '12000000-0000-0000-0000-000000000002'::uuid,
    4,
    'Pending other review',
    'Other pending review.',
    'pending',
    false
  ),
  (
    '57000000-0000-0000-0000-000000000003'::uuid,
    (select id from public.products where slug = 'nova-x-smartphone'),
    '12000000-0000-0000-0000-000000000002'::uuid,
    5,
    'Published other review',
    'Other published review.',
    'published',
    true
  );

set local role authenticated;
select set_config('request.jwt.claim.role', 'authenticated', true);
select set_config('request.jwt.claim.sub', '12000000-0000-0000-0000-000000000001', true);

select pg_temp.assert_true(
  (select count(*) from public.profiles where id = '12000000-0000-0000-0000-000000000001'::uuid) = 1,
  'Customer should be able to read own profile'
);

select pg_temp.assert_true(
  (select count(*) from public.profiles where id = '12000000-0000-0000-0000-000000000002'::uuid) = 0,
  'Customer should not be able to read another profile'
);

select pg_temp.assert_true(
  (select count(*) from public.addresses where id = '52000000-0000-0000-0000-000000000001'::uuid) = 1,
  'Customer should be able to read own address'
);

select pg_temp.assert_true(
  (select count(*) from public.addresses where id = '52000000-0000-0000-0000-000000000002'::uuid) = 0,
  'Customer should not be able to read another address'
);

select pg_temp.assert_true(
  (select count(*) from public.carts where id = '53000000-0000-0000-0000-000000000001'::uuid) = 1,
  'Customer should be able to read own cart'
);

select pg_temp.assert_true(
  (select count(*) from public.carts where id = '53000000-0000-0000-0000-000000000002'::uuid) = 0,
  'Customer should not be able to read another cart'
);

select pg_temp.assert_true(
  (select count(*) from public.cart_items where id = '53100000-0000-0000-0000-000000000001'::uuid) = 1,
  'Customer should be able to read own cart items'
);

select pg_temp.assert_true(
  (select count(*) from public.cart_items where id = '53100000-0000-0000-0000-000000000002'::uuid) = 0,
  'Customer should not be able to read another cart items'
);

select pg_temp.assert_true(
  (select count(*) from public.orders where id = '54000000-0000-0000-0000-000000000001'::uuid) = 1,
  'Customer should be able to read own order'
);

select pg_temp.assert_true(
  (select count(*) from public.orders where id = '54000000-0000-0000-0000-000000000002'::uuid) = 0,
  'Customer should not be able to read another order'
);

select pg_temp.assert_true(
  (select count(*) from public.order_items where id = '54100000-0000-0000-0000-000000000001'::uuid) = 1,
  'Customer should be able to read own order items'
);

select pg_temp.assert_true(
  (select count(*) from public.order_items where id = '54100000-0000-0000-0000-000000000002'::uuid) = 0,
  'Customer should not be able to read another order items'
);

select pg_temp.assert_true(
  (select count(*) from public.wishlists where id = '55000000-0000-0000-0000-000000000001'::uuid) = 1,
  'Customer should be able to read own wishlist'
);

select pg_temp.assert_true(
  (select count(*) from public.wishlists where id = '55000000-0000-0000-0000-000000000002'::uuid) = 0,
  'Customer should not be able to read another wishlist'
);

select pg_temp.assert_true(
  (select count(*) from public.wishlist_items where id = '55100000-0000-0000-0000-000000000001'::uuid) = 1,
  'Customer should be able to read own wishlist items'
);

select pg_temp.assert_true(
  (select count(*) from public.wishlist_items where id = '55100000-0000-0000-0000-000000000002'::uuid) = 0,
  'Customer should not be able to read another wishlist items'
);

select pg_temp.assert_true(
  (select count(*) from public.notifications where id = '56000000-0000-0000-0000-000000000001'::uuid) = 1,
  'Customer should be able to read own notifications'
);

select pg_temp.assert_true(
  (select count(*) from public.notifications where id = '56000000-0000-0000-0000-000000000002'::uuid) = 0,
  'Customer should not be able to read another notifications'
);

select pg_temp.assert_true(
  (select count(*) from public.product_reviews where id = '57000000-0000-0000-0000-000000000001'::uuid) = 1,
  'Customer should be able to read own pending review'
);

select pg_temp.assert_true(
  (select count(*) from public.product_reviews where id = '57000000-0000-0000-0000-000000000002'::uuid) = 0,
  'Customer should not be able to read another user pending review'
);

select pg_temp.assert_true(
  (select count(*) from public.product_reviews where id = '57000000-0000-0000-0000-000000000003'::uuid) = 1,
  'Customer should be able to read published reviews'
);

do $$
begin
  begin
    insert into public.orders (
      id,
      profile_id,
      order_number,
      status,
      payment_status,
      fulfillment_status,
      currency_code,
      subtotal_amount,
      discount_amount,
      tax_amount,
      shipping_amount,
      total_amount
    )
    values (
      '54000000-0000-0000-0000-000000000099'::uuid,
      '12000000-0000-0000-0000-000000000001'::uuid,
      'OWN-ORDER-099',
      'pending',
      'pending',
      'pending',
      'USD',
      10.00,
      0.00,
      0.00,
      0.00,
      10.00
    );

    raise exception 'Customer direct order insert should have been denied by RLS';
  exception
    when insufficient_privilege or sqlstate '42501' then
      null;
  end;
end;
$$;

rollback;
