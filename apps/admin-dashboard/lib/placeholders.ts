export type PlaceholderPage = {
  title: string;
  description: string;
  icon: string;
  requiredPermission: string;
  primaryAction?: string;
  focusAreas: string[];
};

export const placeholderPages: Record<string, PlaceholderPage> = {
  products: {
    title: "Products",
    description: "Manage catalog records, publishing state, soft deletes, and product detail workflows.",
    icon: "inventory_2",
    requiredPermission: "products.read",
    primaryAction: "Add Product",
    focusAreas: ["Product list", "Product detail", "Publish and archive", "Variant and image tabs"]
  },
  categories: {
    title: "Categories",
    description: "Manage category hierarchy, visibility, archive, and restore workflows.",
    icon: "category",
    requiredPermission: "categories.read",
    primaryAction: "Add Category",
    focusAreas: ["Category tree", "Create and edit", "Soft delete", "Restore"]
  },
  inventory: {
    title: "Inventory",
    description: "Track variant-level stock, low-stock alerts, and internal adjustment workflows.",
    icon: "warehouse",
    requiredPermission: "products.read",
    focusAreas: ["Variant stock", "Reserved quantity", "Low stock", "Adjustment audit trail"]
  },
  orders: {
    title: "Orders",
    description: "Review orders, status transitions, fulfillment state, and customer context.",
    icon: "shopping_cart",
    requiredPermission: "orders.read_all",
    focusAreas: ["Order list", "Order detail", "Status updates", "Fulfillment timeline"]
  },
  customers: {
    title: "Customers",
    description: "Support customer profiles, status review, addresses, orders, and activity history.",
    icon: "group",
    requiredPermission: "users.read",
    focusAreas: ["Profile detail", "Address history", "Order history", "Status controls"]
  },
  reviews: {
    title: "Reviews",
    description: "Moderate published, pending, hidden, and deleted product review workflows.",
    icon: "rate_review",
    requiredPermission: "reviews.read",
    focusAreas: ["Moderation queue", "Published reviews", "Hide review", "Delete review"]
  },
  coupons: {
    title: "Coupons",
    description: "Manage promotional rules and coupon lifecycle without exposing raw data to customers.",
    icon: "sell",
    requiredPermission: "coupons.read",
    primaryAction: "Create Coupon",
    focusAreas: ["Coupon list", "Eligibility", "Usage limits", "Disable workflow"]
  },
  reports: {
    title: "Reports",
    description: "Monitor revenue, orders, conversion, catalog health, and operational trends.",
    icon: "bar_chart",
    requiredPermission: "reports.read",
    focusAreas: ["Revenue", "Orders", "Customers", "Catalog performance"]
  },
  notifications: {
    title: "Notifications",
    description: "Inspect notification status, dispatch outcomes, and AI operational alerts.",
    icon: "notifications",
    requiredPermission: "notifications.read",
    focusAreas: ["Notification feed", "Failed dispatch", "Channel filters", "AI alerts"]
  },
  users: {
    title: "Users",
    description: "Manage internal users, customer profiles, status, and support-safe profile access.",
    icon: "manage_accounts",
    requiredPermission: "users.read",
    primaryAction: "Invite User",
    focusAreas: ["Internal users", "Customers", "Status", "Role assignment"]
  },
  roles: {
    title: "Roles",
    description: "Review and manage RBAC role boundaries for Super Admin, Admin, and Viewer.",
    icon: "admin_panel_settings",
    requiredPermission: "users.manage_roles",
    focusAreas: ["Role list", "Assigned permissions", "Promotion workflow", "Governance"]
  },
  permissions: {
    title: "Permissions",
    description: "Inspect permission codes and role-to-permission mappings used by RLS and admin guards.",
    icon: "key",
    requiredPermission: "users.manage_roles",
    focusAreas: ["Permission catalog", "Role mappings", "Read-only review", "Audit alignment"]
  },
  "audit-logs": {
    title: "Audit Logs",
    description: "Investigate privileged platform actions, production interventions, and sensitive updates.",
    icon: "policy",
    requiredPermission: "audit_logs.read",
    focusAreas: ["Actor filters", "Entity filters", "Time range", "Sensitive actions"]
  },
  settings: {
    title: "Settings",
    description: "Configure platform-level administrative settings with permission-aware controls.",
    icon: "settings",
    requiredPermission: "settings.update",
    focusAreas: ["General", "Payments", "Shipping", "AI settings"]
  }
};
