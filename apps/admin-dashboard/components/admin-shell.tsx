import { Sidebar } from "./sidebar";
import { TopHeader } from "./top-header";

export function AdminShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen bg-[#f8fafc]">
      <Sidebar />
      <div className="flex min-w-0 flex-1 flex-col">
        <TopHeader />
        {children}
      </div>
    </div>
  );
}
