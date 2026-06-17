"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { demoCurrentRole, getNavigationForRole } from "@/lib/rbac";
import { MaterialIcon } from "./material-icon";

const groupLabels = {
  primary: "Overview",
  operations: "Operations",
  governance: "Governance",
  system: "System"
} as const;

export function Sidebar() {
  const pathname = usePathname();
  const items = getNavigationForRole(demoCurrentRole);
  const groups = Object.entries(groupLabels);

  return (
    <aside className="sticky left-0 top-0 z-50 flex h-screen w-sidebar-width flex-col border-r border-outline-variant bg-surface p-md">
      <div className="mb-xl px-sm">
        <p className="text-2xl font-black tracking-tight text-primary">AI Commerce</p>
        <p className="text-xs font-semibold uppercase tracking-[0.18em] text-on-surface-variant">Enterprise Admin</p>
      </div>

      <nav className="flex-1 space-y-lg overflow-y-auto pr-xs">
        {groups.map(([group, label]) => {
          const groupItems = items.filter((item) => item.group === group);
          if (groupItems.length === 0) {
            return null;
          }

          return (
            <div key={group} className="space-y-xs">
              <p className="px-sm text-[10px] font-black uppercase tracking-[0.16em] text-outline">{label}</p>
              {groupItems.map((item) => {
                const isActive = pathname === item.href || (item.href !== "/admin" && pathname.startsWith(`${item.href}/`));

                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={`flex items-center gap-md rounded-lg p-sm transition-all ${
                      isActive
                        ? "scale-[0.98] bg-secondary-container font-bold text-on-secondary-container"
                        : "text-secondary hover:bg-surface-container-high"
                    }`}
                  >
                    <MaterialIcon name={item.icon} filled={isActive} />
                    <span className="text-sm font-semibold">{item.label}</span>
                  </Link>
                );
              })}
            </div>
          );
        })}
      </nav>

      <div className="mt-auto space-y-sm border-t border-outline-variant pt-md">
        <div className="rounded-lg bg-primary px-md py-sm text-on-primary shadow-panel">
          <div className="flex items-center gap-sm text-sm font-bold">
            <MaterialIcon name="shield_person" />
            {demoCurrentRole}
          </div>
          <p className="mt-xs text-xs text-white/80">RBAC placeholder until Supabase Auth is connected.</p>
        </div>
        <Link href="/admin/login" className="flex items-center gap-md rounded-lg p-sm text-secondary hover:bg-surface-container-high">
          <MaterialIcon name="logout" className="text-error" />
          <span className="text-sm font-semibold">Log Out</span>
        </Link>
      </div>
    </aside>
  );
}
