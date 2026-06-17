type MaterialIconProps = {
  name: string;
  className?: string;
  filled?: boolean;
};

const iconLabels: Record<string, string> = {
  admin_panel_settings: "RO",
  ads_click: "CV",
  arrow_back: "<-",
  bar_chart: "RP",
  category: "CA",
  check_circle: "OK",
  dashboard: "DB",
  database: "DB",
  group: "CU",
  hub: "AI",
  inventory_2: "PR",
  key: "KY",
  logout: "LO",
  manage_accounts: "US",
  notifications: "NT",
  payments: "$",
  person_add: "CU",
  policy: "AU",
  rate_review: "RV",
  search: "SR",
  sell: "CP",
  settings: "ST",
  settings_suggest: "ST",
  shield_person: "SA",
  shopping_bag: "OD",
  shopping_cart: "OR",
  warehouse: "IN"
};

export function MaterialIcon({ name, className }: MaterialIconProps) {
  return (
    <span
      className={`inline-grid h-6 min-w-6 place-items-center rounded-md border border-current/10 px-1 text-[10px] font-black leading-none ${className ?? ""}`}
      aria-hidden="true"
    >
      {iconLabels[name] ?? name.slice(0, 2).toUpperCase()}
    </span>
  );
}
