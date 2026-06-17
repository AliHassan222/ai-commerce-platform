import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "AI Commerce Admin",
  description: "Admin dashboard for the AI Commerce Platform"
};

export default function RootLayout({
  children
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="font-sans antialiased">{children}</body>
    </html>
  );
}
