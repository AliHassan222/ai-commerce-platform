import Link from "next/link";
import { MaterialIcon } from "@/components/material-icon";

export default function AdminLoginPage() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-background p-md text-on-surface">
      <div className="w-full max-w-[430px]">
        <div className="mb-xl flex flex-col items-center text-center">
          <div className="mb-md flex h-14 w-14 items-center justify-center rounded-xl bg-primary text-on-primary shadow-panel">
            <MaterialIcon name="hub" />
          </div>
          <h1 className="text-2xl font-black tracking-tight">AI Commerce</h1>
          <p className="mt-xs text-sm text-on-surface-variant">Enterprise Admin Portal</p>
        </div>

        <div className="rounded-xl border border-outline-variant bg-white p-xl shadow-panel">
          <h2 className="text-xl font-black">Welcome back</h2>
          <p className="mt-sm text-sm leading-6 text-outline">Supabase Auth is not connected yet. This screen preserves the approved admin login baseline.</p>

          <form className="mt-xl space-y-lg">
            <label className="block space-y-xs">
              <span className="text-xs font-black uppercase tracking-[0.14em] text-outline">Email Address</span>
              <input className="w-full rounded-lg border border-outline-variant p-md" placeholder="admin@example.com" type="email" />
            </label>
            <label className="block space-y-xs">
              <span className="text-xs font-black uppercase tracking-[0.14em] text-outline">Password</span>
              <input className="w-full rounded-lg border border-outline-variant p-md" placeholder="Not connected yet" type="password" />
            </label>
            <Link href="/admin" className="block w-full rounded-lg bg-primary py-md text-center font-black text-white shadow-panel">
              Enter Dashboard
            </Link>
          </form>
        </div>
      </div>
    </main>
  );
}
