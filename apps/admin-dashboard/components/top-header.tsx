import Link from "next/link";
import { MaterialIcon } from "./material-icon";

export function TopHeader() {
  return (
    <header className="sticky top-0 z-40 flex h-16 w-full items-center justify-between border-b border-outline-variant bg-surface-container-lowest px-xl">
      <div className="relative w-full max-w-xl focus-within:ring-2 focus-within:ring-primary">
        <MaterialIcon name="search" className="absolute left-md top-1/2 -translate-y-1/2 text-outline" />
        <input
          className="w-full rounded-lg border border-outline-variant bg-surface-container-lowest py-sm pl-11 pr-md text-sm focus:border-primary focus:outline-none"
          placeholder="Search orders, products, customers, or audit logs..."
          type="search"
        />
      </div>

      <div className="ml-xl flex items-center gap-lg">
        <Link href="/admin/notifications" className="relative rounded-full p-sm hover:bg-surface-container-low">
          <MaterialIcon name="notifications" className="text-on-surface-variant" />
          <span className="absolute right-1.5 top-1.5 h-2 w-2 rounded-full border-2 border-white bg-error" />
        </Link>
        <Link href="/admin/settings" className="rounded-full p-sm hover:bg-surface-container-low">
          <MaterialIcon name="settings_suggest" className="text-on-surface-variant" />
        </Link>
        <div className="h-8 w-px bg-outline-variant" />
        <div className="text-right">
          <p className="text-sm font-black text-on-surface">Platform Admin</p>
          <p className="text-[10px] uppercase tracking-wider text-outline">Protected placeholder</p>
        </div>
        <div className="grid h-10 w-10 place-items-center rounded-full border border-outline-variant bg-secondary-container font-black text-primary">
          AI
        </div>
      </div>
    </header>
  );
}
