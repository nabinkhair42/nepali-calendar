import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { SiteHeader } from "@/components/layouts/site-header";
import { SiteFooter } from "@/components/layouts/site-footer";
import { ThemeProvider } from "@/components/theme-provider";
import { TooltipProvider } from "@/components/ui/tooltip";
import { PageShortcuts } from "@/components/page-shortcuts";
import { DISPLAY_NAME } from "@/lib/app-constants";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: `${DISPLAY_NAME} — macOS Menu Bar App`,
  description:
    "Bikram Sambat in your menu bar. Festivals, public holidays, and a quiet popover.",
  metadataBase: new URL("https://calendar.nabinkhair.com.np"),
  icons: {
    icon: [{ url: "/icon.svg", type: "image/svg+xml" }],
    apple: "/icon.svg",
  },
  openGraph: {
    title: `${DISPLAY_NAME} — macOS Menu Bar App`,
    description:
      "Bikram Sambat in your menu bar. Festivals, public holidays, and a quiet popover.",
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
      className={`${inter.variable} antialiased`}
      suppressHydrationWarning
    >
      <body className="min-h-screen font-sans">
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          <TooltipProvider delayDuration={150}>
            <PageShortcuts />
            <div className="relative grid min-h-screen w-full grid-cols-1 justify-items-center overflow-x-clip px-6">
              <div className="flex min-h-screen w-full max-w-[50rem] min-w-0 flex-col">
                <SiteHeader />
                <main id="main-content" className="flex flex-1 flex-col">
                  {children}
                </main>
                <SiteFooter />
              </div>
            </div>
          </TooltipProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
