import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Nepali Calendar — macOS Menu Bar App",
  description:
    "Bikram Sambat in your menu bar. A clean, native macOS calendar that lives one click away. Free forever.",
  metadataBase: new URL("https://nepali-calendar.app"),
  openGraph: {
    title: "Nepali Calendar — macOS Menu Bar App",
    description:
      "Bikram Sambat in your menu bar. A clean, native macOS calendar that lives one click away.",
    type: "website",
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
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased scroll-smooth`}
    >
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
