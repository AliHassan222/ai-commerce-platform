import Link from "next/link";

export default function NewProductPage() {
  return (
    <main className="mx-auto w-full max-w-6xl space-y-xl p-xl pb-32">
      <div>
        <div className="flex items-center gap-sm text-sm font-bold text-on-surface-variant">
          <Link href="/admin/products" className="hover:text-primary">Products</Link>
          <span>/</span>
          <span className="text-on-surface">New Product</span>
        </div>
        <h1 className="mt-sm text-4xl font-black tracking-[-0.04em]">Add New Product</h1>
        <p className="mt-sm text-on-surface-variant">Placeholder form preserving the Stitch product creation baseline.</p>
      </div>

      <div className="grid gap-xl lg:grid-cols-3">
        <div className="space-y-lg lg:col-span-2">
          <section className="rounded-xl border border-outline-variant bg-white p-lg shadow-panel">
            <h2 className="text-lg font-black">Product Details</h2>
            <div className="mt-lg space-y-md">
              <input className="w-full rounded-lg border border-outline-variant p-md" placeholder="Product title" />
              <textarea className="min-h-40 w-full rounded-lg border border-outline-variant p-md" placeholder="Detailed description" />
            </div>
          </section>
          <section className="rounded-xl border border-outline-variant bg-white p-lg shadow-panel">
            <h2 className="text-lg font-black">Pricing & Inventory Placeholder</h2>
            <div className="mt-lg grid gap-md md:grid-cols-2">
              <input className="rounded-lg border border-outline-variant p-md" placeholder="Base price" type="number" />
              <input className="rounded-lg border border-outline-variant p-md" placeholder="Base SKU" />
            </div>
          </section>
        </div>

        <aside className="space-y-lg">
          <section className="rounded-xl border border-outline-variant bg-white p-lg shadow-panel">
            <h2 className="text-xs font-black uppercase tracking-[0.16em] text-outline">Product Status</h2>
            <select className="mt-md w-full rounded-lg border border-outline-variant p-md">
              <option>Draft</option>
              <option>Active</option>
            </select>
          </section>
          <section className="rounded-xl border border-outline-variant bg-primary p-lg text-white shadow-panel">
            <h2 className="font-black">Next build steps</h2>
            <p className="mt-sm text-sm leading-6 text-white/80">Connect categories, variants, product images, inventory, publish controls, and audit activity.</p>
          </section>
        </aside>
      </div>
    </main>
  );
}
