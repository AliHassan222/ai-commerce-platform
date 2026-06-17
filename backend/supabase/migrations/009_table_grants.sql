grant usage on schema public to anon, authenticated;

grant select on public.categories to anon, authenticated;
grant select on public.products to anon, authenticated;
grant select on public.product_variants to anon, authenticated;
grant select on public.product_images to anon, authenticated;
grant select on public.product_reviews to anon, authenticated;

grant select, update on public.profiles to authenticated;
grant select, insert, update, delete on public.addresses to authenticated;
grant select, insert, update, delete on public.carts to authenticated;
grant select, insert, update, delete on public.cart_items to authenticated;
grant select on public.orders to authenticated;
grant select on public.order_items to authenticated;
grant select, insert, update, delete on public.wishlists to authenticated;
grant select, insert, delete on public.wishlist_items to authenticated;
grant select on public.notifications to authenticated;
grant select, insert, update, delete on public.product_reviews to authenticated;

grant insert, update on public.categories to authenticated;
grant insert, update on public.products to authenticated;
grant insert, update on public.product_variants to authenticated;
grant insert, update, delete on public.product_images to authenticated;
