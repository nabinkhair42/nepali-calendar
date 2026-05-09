import type { Metadata } from "next";
import { Geist } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-sans",
  subsets: ["latin"],
});


export const metadata: Metadata = {
  title: "Nepali Calendar — macOS Menu Bar App",
  description:
    "Bikram Sambat in your menu bar. A clean, native macOS calendar that lives one click away. Free forever.",
  metadataBase: new URL("https://calendar.nabinkhair.com.np"),
  icons: {
    icon: [{ url: "/icon.svg", type: "image/svg+xml" }],
    apple: "/icon.svg",
  },
  openGraph: {
    title: "Nepali Calendar — macOS Menu Bar App",
    description:
      "Bikram Sambat in your menu bar. A clean, native macOS calendar that lives one click away.",
    type: "website",
    images: [{ url: "/icon.svg", width: 1024, height: 1024 }],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} h-full antialiased scroll-smooth`}
    >
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
