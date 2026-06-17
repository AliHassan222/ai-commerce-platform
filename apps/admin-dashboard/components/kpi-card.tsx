import { MaterialIcon } from "./material-icon";

type KpiCardProps = {
  label: string;
  value: string;
  icon: string;
  trend: string;
  trendTone?: "positive" | "negative";
};

export function KpiCard({ label, value, icon, trend, trendTone = "positive" }: KpiCardProps) {
  return (
    <div className="group rounded-xl border border-outline-variant bg-surface-container-lowest p-lg transition-colors hover:border-primary">
      <div className="mb-md flex items-start justify-between">
        <div className="rounded-lg bg-primary-container/10 p-sm transition-colors group-hover:bg-primary">
          <MaterialIcon name={icon} className="text-primary group-hover:text-white" />
        </div>
        <span
          className={`rounded-full px-sm py-1 text-xs font-bold ${
            trendTone === "positive" ? "bg-emerald-50 text-emerald-600" : "bg-rose-50 text-rose-600"
          }`}
        >
          {trend}
        </span>
      </div>
      <p className="text-xs font-bold uppercase tracking-[0.14em] text-on-surface-variant">{label}</p>
      <h2 className="mt-xs text-2xl font-black tracking-tight text-on-surface">{value}</h2>
    </div>
  );
}
