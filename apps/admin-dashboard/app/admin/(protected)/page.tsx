import Link from "next/link";
import { KpiCard } from "@/components/kpi-card";
import { MaterialIcon } from "@/components/material-icon";

const recentOrders = [
  { id: "#ORD-9921", customer: "Sarah Connor", value: "$1,249.00", status: "Processing" },
  { id: "#ORD-9920", customer: "James Howlett", value: "$49.99", status: "Pending" },
  { id: "#ORD-9919", customer: "Eleanor Thorne", value: "$842.10", status: "Shipped" }
];

export default function AdminDashboardPage() {
  return (
    <main className="mx-auto w-full max-w-7xl space-y-xl p-xl">
      <section className="flex flex-col justify-between gap-lg lg:flex-row lg:items-end">
        <div>
          <p className="text-xs font-black uppercase tracking-[0.18em] text-outline">Phase 2 Admin Baseline</p>
          <h1 className="mt-sm text-4xl font-black tracking-[-0.04em] text-on-surface">Commerce Command Center</h1>
          <p className="mt-md max-w-2xl text-on-surface-variant">
            Stitch visual baseline converted into a protected Next.js route shell. Data is mocked until Supabase integration begins.
          </p>
        </div>
        <Link href="/admin/products/new" className="rounded-lg bg-primary px-lg py-md text-sm font-black text-on-primary shadow-panel">
          Add Product
        </Link>
      </section>

      <section className="grid grid-cols-1 gap-lg md:grid-cols-2 xl:grid-cols-4">
        <KpiCard label="Total Revenue" value="$124,592" icon="payments" trend="+12.5%" />
        <KpiCard label="Total Orders" value="1,842" icon="shopping_bag" trend="+4.2%" />
        <KpiCard label="Active Customers" value="8,291" icon="person_add" trend="-1.5%" trendTone="negative" />
        <KpiCard label="Conversion Rate" value="3.24%" icon="ads_click" trend="+0.8%" />
      </section>

      <section className="grid gap-lg xl:grid-cols-3">
        <div className="rounded-xl border border-outline-variant bg-surface-container-lowest p-xl shadow-panel xl:col-span-2">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-black">Revenue Analytics</h2>
            <span className="rounded-full bg-secondary-container px-sm py-xs text-xs font-bold text-primary">Placeholder</span>
          </div>
          <div className="relative mt-xl h-80 overflow-hidden rounded-xl bg-gradient-to-br from-surface-container-low to-white">
            <svg className="absolute inset-0 h-full w-full" preserveAspectRatio="none" viewBox="0 0 800 260">
              <path d="M0,220 Q120,190 220,170 T430,120 T620,80 T800,58 L800,260 L0,260 Z" fill="rgba(0,82,255,0.08)" />
              <path d="M0,220 Q120,190 220,170 T430,120 T620,80 T800,58" fill="none" stroke="#0052FF" strokeWidth="5" />
            </svg>
            <div className="absolute bottom-lg left-lg rounded-xl bg-white/85 p-md shadow-panel backdrop-blur">
              <p className="text-xs font-bold uppercase tracking-[0.14em] text-outline">AI Insight</p>
              <p className="mt-xs max-w-sm text-sm text-on-surface-variant">Catalog velocity suggests inventory review before next promotion window.</p>
            </div>
          </div>
        </div>

        <div className="rounded-xl border border-outline-variant bg-surface-container-lowest p-xl shadow-panel">
          <h2 className="text-xl font-black">Recent Orders</h2>
          <div className="mt-lg space-y-sm">
            {recentOrders.map((order) => (
              <Link key={order.id} href="/admin/orders" className="flex items-center justify-between rounded-lg border border-outline-variant p-md hover:border-primary">
                <div>
                  <p className="font-mono text-sm font-black text-primary">{order.id}</p>
                  <p className="text-sm text-on-surface-variant">{order.customer}</p>
                </div>
                <div className="text-right">
                  <p className="font-black">{order.value}</p>
                  <p className="text-xs text-outline">{order.status}</p>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>

      <section className="grid gap-lg md:grid-cols-3">
        {[
          ["Products need variants", "Build product detail tabs for variants, images, inventory, and reviews.", "inventory_2"],
          ["RBAC placeholders active", "Sidebar filters routes for Super Admin, Admin, and Viewer metadata.", "admin_panel_settings"],
          ["No Supabase connected", "All screens remain mock-first until Phase 2 integration tasks begin.", "database"]
        ].map(([title, description, icon]) => (
          <div key={title} className="rounded-xl border border-outline-variant bg-surface-container-lowest p-lg shadow-panel">
            <MaterialIcon name={icon} className="text-primary" />
            <h3 className="mt-md font-black">{title}</h3>
            <p className="mt-sm text-sm leading-6 text-on-surface-variant">{description}</p>
          </div>
        ))}
      </section>
    </main>
  );
}
