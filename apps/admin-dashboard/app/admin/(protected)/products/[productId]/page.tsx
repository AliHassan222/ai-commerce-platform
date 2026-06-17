import { PlaceholderPageView } from "@/components/placeholder-page";

export default async function ProductDetailPage({ params }: { params: Promise<{ productId: string }> }) {
  const { productId } = await params;

  return (
    <PlaceholderPageView
      page={{
        title: `Product Detail: ${productId}`,
        description: "Future product detail screen with overview, variants, images, inventory, reviews, and activity tabs.",
        icon: "inventory_2",
        requiredPermission: "products.read",
        primaryAction: "Edit Product",
        focusAreas: ["Overview", "Variants", "Images", "Inventory", "Reviews", "Activity"]
      }}
    />
  );
}
