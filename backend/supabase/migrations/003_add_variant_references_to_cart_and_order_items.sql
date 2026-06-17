-- Add nullable variant references to preserve backward compatibility with
-- existing product-based cart and order line items.
-- Application and checkout validation should require variant_id whenever the
-- selected product has variants.

alter table public.cart_items
add column variant_id uuid references public.product_variants(id) on delete set null;

alter table public.order_items
add column variant_id uuid references public.product_variants(id) on delete set null;

create index idx_cart_items_variant_id on public.cart_items(variant_id);
create index idx_order_items_variant_id on public.order_items(variant_id);

comment on column public.cart_items.variant_id is
'Nullable for backward compatibility. Require variant_id at application and checkout validation level when the product has variants.';

comment on column public.order_items.variant_id is
'Nullable for backward compatibility. Require variant_id at application and checkout validation level when the product has variants.';
