export type AdminRole = "Super Admin" | "Admin" | "Viewer";

export type NavigationItem = {
  label: string;
  href: string;
  icon: string;
  roles: AdminRole[];
  group: "primary" | "operations" | "governance" | "system";
};

export const demoCurrentRole: AdminRole = "Super Admin";

export const adminNavigation: NavigationItem[] = [
  { label: "Dashboard", href: "/admin", icon: "dashboard", roles: ["Super Admin", "Admin", "Viewer"], group: "primary" },
  { label: "Products", href: "/admin/products", icon: "inventory_2", roles: ["Super Admin", "Admin", "Viewer"], group: "operations" },
  { label: "Categories", href: "/admin/categories", icon: "category", roles: ["Super Admin", "Admin", "Viewer"], group: "operations" },
  { label: "Inventory", href: "/admin/inventory", icon: "warehouse", roles: ["Super Admin", "Admin", "Viewer"], group: "operations" },
  { label: "Orders", href: "/admin/orders", icon: "shopping_cart", roles: ["Super Admin", "Admin", "Viewer"], group: "operations" },
  { label: "Customers", href: "/admin/customers", icon: "group", roles: ["Super Admin", "Admin", "Viewer"], group: "operations" },
  { label: "Reviews", href: "/admin/reviews", icon: "rate_review", roles: ["Super Admin", "Admin", "Viewer"], group: "operations" },
  { label: "Coupons", href: "/admin/coupons", icon: "sell", roles: ["Super Admin", "Admin", "Viewer"], group: "operations" },
  { label: "Reports", href: "/admin/reports", icon: "bar_chart", roles: ["Super Admin", "Admin", "Viewer"], group: "primary" },
  { label: "Notifications", href: "/admin/notifications", icon: "notifications", roles: ["Super Admin", "Admin"], group: "operations" },
  { label: "Users", href: "/admin/users", icon: "manage_accounts", roles: ["Super Admin", "Admin", "Viewer"], group: "governance" },
  { label: "Roles", href: "/admin/roles", icon: "admin_panel_settings", roles: ["Super Admin"], group: "governance" },
  { label: "Permissions", href: "/admin/permissions", icon: "key", roles: ["Super Admin"], group: "governance" },
  { label: "Audit Logs", href: "/admin/audit-logs", icon: "policy", roles: ["Super Admin"], group: "governance" },
  { label: "Settings", href: "/admin/settings", icon: "settings", roles: ["Super Admin", "Admin"], group: "system" }
];

export function getNavigationForRole(role: AdminRole) {
  return adminNavigation.filter((item) => item.roles.includes(role));
}
