import Link from "next/link";
import { MaterialIcon } from "./material-icon";
import type { PlaceholderPage } from "@/lib/placeholders";

export function PlaceholderPageView({ page }: { page: PlaceholderPage }) {
  return (
    <main className="mx-auto w-full max-w-7xl space-y-xl p-xl">
      <section className="flex flex-col justify-between gap-lg rounded-2xl border border-outline-variant bg-surface-container-lowest p-xl shadow-panel lg:flex-row lg:items-end">
        <div className="max-w-3xl">
          <div className="mb-md flex h-12 w-12 items-center justify-center rounded-xl bg-secondary-container text-primary">
            <MaterialIcon name={page.icon} />
          </div>
          <p className="text-xs font-black uppercase tracking-[0.18em] text-outline">Protected admin route</p>
          <h1 className="mt-sm text-4xl font-black tracking-[-0.04em] text-on-surface">{page.title}</h1>
          <p className="mt-md text-base leading-7 text-on-surface-variant">{page.description}</p>
        </div>
        {page.primaryAction ? (
          <button className="rounded-lg bg-primary px-lg py-md text-sm font-black text-on-primary shadow-panel">
            {page.primaryAction}
          </button>
        ) : null}
      </section>

      <section className="grid gap-lg lg:grid-cols-3">
        <div className="rounded-xl border border-outline-variant bg-surface-container-lowest p-lg shadow-panel">
          <p className="text-xs font-black uppercase tracking-[0.16em] text-outline">Required Permission</p>
          <p className="mt-md font-mono text-sm font-bold text-primary">{page.requiredPermission}</p>
          <p className="mt-md text-sm leading-6 text-on-surface-variant">
            This screen is a placeholder for future Supabase-backed access checks. Navigation is currently filtered by static RBAC metadata only.
          </p>
        </div>

        <div className="rounded-xl border border-outline-variant bg-surface-container-lowest p-lg shadow-panel lg:col-span-2">
          <p className="text-xs font-black uppercase tracking-[0.16em] text-outline">Planned Workflow Coverage</p>
          <div className="mt-md grid gap-sm sm:grid-cols-2">
            {page.focusAreas.map((area) => (
              <div key={area} className="flex items-center gap-sm rounded-lg bg-surface-container-low p-sm text-sm font-bold">
                <MaterialIcon name="check_circle" className="text-primary" />
                {area}
              </div>
            ))}
          </div>
        </div>
      </section>

      <Link href="/admin" className="inline-flex items-center gap-sm text-sm font-bold text-primary">
        <MaterialIcon name="arrow_back" />
        Back to dashboard
      </Link>
    </main>
  );
}
