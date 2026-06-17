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
    <aside className="z-50 flex w-full shrink-0 flex-col border-b border-outline-variant bg-surface p-md lg:sticky lg:left-0 lg:top-0 lg:h-screen lg:w-sidebar-width lg:border-b-0 lg:border-r">
      <div className="mb-md px-sm lg:mb-xl">
        <p className="text-2xl font-black tracking-tight text-primary">AI Commerce</p>
        <p className="text-xs font-semibold uppercase tracking-[0.18em] text-on-surface-variant">Enterprise Admin</p>
      </div>

      <nav className="flex gap-md overflow-x-auto pb-xs lg:flex-1 lg:flex-col lg:gap-0 lg:space-y-lg lg:overflow-y-auto lg:pr-xs">
        {groups.map(([group, label]) => {
          const groupItems = items.filter((item) => item.group === group);
          if (groupItems.length === 0) {
            return null;
          }

          return (
            <div key={group} className="flex shrink-0 gap-xs lg:block lg:space-y-xs">
              <p className="hidden px-sm text-[10px] font-black uppercase tracking-[0.16em] text-outline lg:block">{label}</p>
              {groupItems.map((item) => {
                const isActive = pathname === item.href || (item.href !== "/admin" && pathname.startsWith(`${item.href}/`));

                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={`flex whitespace-nowrap items-center gap-md rounded-lg p-sm transition-all ${
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

      <div className="mt-md space-y-sm border-t border-outline-variant pt-md lg:mt-auto">
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
