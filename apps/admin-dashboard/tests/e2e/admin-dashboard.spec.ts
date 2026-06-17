import { expect, test, type Page } from "@playwright/test";

const routes = [
  "/",
  "/admin",
  "/admin/login",
  "/admin/products",
  "/admin/products/new",
  "/admin/products/sample-product",
  "/admin/orders",
  "/admin/customers",
  "/admin/inventory",
  "/admin/categories",
  "/admin/coupons",
  "/admin/users",
  "/admin/roles",
  "/admin/permissions",
  "/admin/reports",
  "/admin/reviews",
  "/admin/settings",
  "/admin/notifications",
  "/admin/audit-logs"
];

const placeholderRoutes = [
  ["/admin/orders", "Orders"],
  ["/admin/customers", "Customers"],
  ["/admin/inventory", "Inventory"],
  ["/admin/categories", "Categories"],
  ["/admin/coupons", "Coupons"],
  ["/admin/users", "Users"],
  ["/admin/roles", "Roles"],
  ["/admin/permissions", "Permissions"],
  ["/admin/reports", "Reports"],
  ["/admin/reviews", "Reviews"],
  ["/admin/settings", "Settings"],
  ["/admin/notifications", "Notifications"],
  ["/admin/audit-logs", "Audit Logs"]
] as const;

async function expectNoConsoleErrors(page: Page) {
  const consoleErrors: string[] = [];
  const pageErrors: string[] = [];

  page.on("console", (message) => {
    if (message.type() === "error") {
      consoleErrors.push(message.text());
    }
  });

  page.on("pageerror", (error) => {
    pageErrors.push(error.message);
  });

  return {
    assert: () => {
      expect(pageErrors, "page errors").toEqual([]);
      expect(consoleErrors, "console errors").toEqual([]);
    }
  };
}

async function gotoRoute(page: Page, route: string) {
  const response = await page.goto(route, { waitUntil: "commit", timeout: 15_000 });
  expect(response?.ok(), `${route} response should be successful`).toBe(true);
}

test.describe("admin dashboard routing", () => {
  for (const route of routes) {
    test(`${route} loads without crashing`, async ({ page }) => {
      const errors = await expectNoConsoleErrors(page);

      await gotoRoute(page, route);

      await expect(page.locator("body")).toBeVisible();
      await expect(page.locator("text=Application error")).toHaveCount(0);
      errors.assert();
    });
  }

  test("homepage redirects to admin dashboard", async ({ page }) => {
    await gotoRoute(page, "/");
    await expect(page).toHaveURL(/\/admin$/);
    await expect(page.getByRole("heading", { name: "Commerce Command Center" })).toBeVisible();
  });

  test("admin dashboard loads dashboard cards and shell", async ({ page }) => {
    await gotoRoute(page, "/admin");

    await expect(page.getByRole("heading", { name: "Commerce Command Center" })).toBeVisible();
    await expect(page.getByText("Total Revenue")).toBeVisible();
    await expect(page.getByText("Total Orders")).toBeVisible();
    await expect(page.getByText("Active Customers")).toBeVisible();
    await expect(page.getByText("Conversion Rate")).toBeVisible();
    await expect(page.getByPlaceholder("Search orders, products, customers, or audit logs...")).toBeVisible();
    await expect(page.locator("aside").getByText("Super Admin")).toBeVisible();
  });

  test("login page renders the approved placeholder login", async ({ page }) => {
    await gotoRoute(page, "/admin/login");

    await expect(page.getByRole("heading", { name: "Welcome back" })).toBeVisible();
    await expect(page.getByPlaceholder("admin@example.com")).toBeVisible();
    await expect(page.getByPlaceholder("Not connected yet")).toBeVisible();
    await expect(page.getByRole("link", { name: "Enter Dashboard" })).toHaveAttribute("href", "/admin");
  });

  test("sidebar navigation reaches key admin sections", async ({ page }) => {
    await gotoRoute(page, "/admin");

    await page.getByRole("link", { name: /Products/ }).click();
    await expect(page).toHaveURL(/\/admin\/products$/);
    await expect(page.getByRole("heading", { name: "Products" })).toBeVisible();

    await page.getByRole("link", { name: /Orders/ }).click();
    await expect(page).toHaveURL(/\/admin\/orders$/);
    await expect(page.getByRole("heading", { name: "Orders" })).toBeVisible();

    await page.getByRole("link", { name: /Audit Logs/ }).click();
    await expect(page).toHaveURL(/\/admin\/audit-logs$/);
    await expect(page.getByRole("heading", { name: "Audit Logs" })).toBeVisible();
  });

  for (const [route, heading] of placeholderRoutes) {
    test(`${heading} placeholder page renders planned workflow coverage`, async ({ page }) => {
      await gotoRoute(page, route);

      await expect(page.getByRole("heading", { name: heading })).toBeVisible();
      await expect(page.getByText("Protected admin route")).toBeVisible();
      await expect(page.getByText("Required Permission")).toBeVisible();
      await expect(page.getByText("Planned Workflow Coverage")).toBeVisible();
    });
  }

  test("product detail route loads with sample productId", async ({ page }) => {
    await gotoRoute(page, "/admin/products/stitch-product-123");

    await expect(page.getByRole("heading", { name: "Product Detail: stitch-product-123" })).toBeVisible();
    await expect(page.getByText("products.read")).toBeVisible();
  });
});

test.describe("admin dashboard responsive layout", () => {
  test("mobile viewport renders without horizontal layout break", async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await gotoRoute(page, "/admin");

    await expect(page.getByRole("heading", { name: "Commerce Command Center" })).toBeVisible();
    await expect(page.getByPlaceholder("Search orders, products, customers, or audit logs...")).toBeVisible();

    const horizontalOverflow = await page.evaluate(() => document.documentElement.scrollWidth > document.documentElement.clientWidth + 2);
    expect(horizontalOverflow).toBe(false);
  });

  test("tablet viewport keeps shell and content usable", async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await gotoRoute(page, "/admin/products");

    await expect(page.getByRole("heading", { name: "Products" })).toBeVisible();
    await expect(page.getByRole("link", { name: "Add Product" })).toBeVisible();
  });

  test("desktop viewport renders full dashboard layout", async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 900 });
    await gotoRoute(page, "/admin");

    await expect(page.getByText("Revenue Analytics")).toBeVisible();
    await expect(page.getByText("Recent Orders")).toBeVisible();
  });
});
