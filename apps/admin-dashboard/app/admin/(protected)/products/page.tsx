import Link from "next/link";
import { MaterialIcon } from "@/components/material-icon";

const products = [
  { name: "Pro Audio Studio Z1", category: "Electronics", price: "$299.00", stock: 142, status: "Active" },
  { name: "SprintFlow Runner X1", category: "Fashion", price: "$120.00", stock: 0, status: "Draft" },
  { name: "Lumos Quantum G3", category: "Laptops", price: "$1,899.00", stock: 18, status: "Active" }
];

export default function ProductsPage() {
  return (
    <main className="mx-auto w-full max-w-7xl space-y-xl p-xl">
      <div className="flex flex-col justify-between gap-md lg:flex-row lg:items-end">
        <div>
          <p className="text-xs font-black uppercase tracking-[0.18em] text-outline">Catalog</p>
          <h1 className="mt-sm text-4xl font-black tracking-[-0.04em]">Products</h1>
          <p className="mt-sm text-on-surface-variant">Manage products, variants, images, status, and soft-delete workflows.</p>
        </div>
        <div className="flex gap-md">
          <Link href="/admin/categories" className="rounded-lg border border-outline-variant bg-white px-md py-sm text-sm font-black">
            Manage Categories
          </Link>
          <Link href="/admin/products/new" className="rounded-lg bg-primary px-md py-sm text-sm font-black text-on-primary">
            Add Product
          </Link>
        </div>
      </div>

      <div className="overflow-hidden rounded-xl border border-outline-variant bg-surface-container-lowest shadow-panel">
        <table className="w-full text-left">
          <thead className="border-b border-outline-variant bg-surface-container-low">
            <tr>
              <th className="px-lg py-md text-xs font-black uppercase tracking-[0.14em] text-on-surface-variant">Product</th>
              <th className="px-lg py-md text-xs font-black uppercase tracking-[0.14em] text-on-surface-variant">Category</th>
              <th className="px-lg py-md text-right text-xs font-black uppercase tracking-[0.14em] text-on-surface-variant">Price</th>
              <th className="px-lg py-md text-right text-xs font-black uppercase tracking-[0.14em] text-on-surface-variant">Stock</th>
              <th className="px-lg py-md text-xs font-black uppercase tracking-[0.14em] text-on-surface-variant">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-outline-variant">
            {products.map((product) => (
              <tr key={product.name} className="hover:bg-surface-container-low">
                <td className="px-lg py-md">
                  <Link href="/admin/products/demo-product" className="flex items-center gap-md font-black text-on-surface">
                    <span className="grid h-10 w-10 place-items-center rounded-lg bg-surface-container-high text-primary">
                      <MaterialIcon name="inventory_2" />
                    </span>
                    {product.name}
                  </Link>
                </td>
                <td className="px-lg py-md text-sm">{product.category}</td>
                <td className="px-lg py-md text-right font-mono text-sm font-bold">{product.price}</td>
                <td className="px-lg py-md text-right text-sm">{product.stock}</td>
                <td className="px-lg py-md">
                  <span className="rounded-full bg-secondary-container px-sm py-xs text-xs font-black text-primary">{product.status}</span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </main>
  );
}
