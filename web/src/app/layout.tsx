import type { Metadata } from "next";
import { Space_Grotesk, JetBrains_Mono } from "next/font/google";
import "./globals.css";
import { SiteHeader } from "@/components/layouts/site-header";
import { SiteFooter } from "@/components/layouts/site-footer";
import { ThemeProvider } from "@/components/theme-provider";
import { TooltipProvider } from "@/components/ui/tooltip";
import { PageShortcuts } from "@/components/page-shortcuts";

const spaceGrotesk = Space_Grotesk({
  variable: "--font-space-grotesk",
  subsets: ["latin"],
});

const jetBrainsMono = JetBrains_Mono({
  variable: "--font-jetbrains-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Nepali Calendar — macOS Menu Bar App",
  description:
    "Bikram Sambat in your menu bar. A clean, native macOS calendar that lives one click away.",
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
      className={`${spaceGrotesk.variable} ${jetBrainsMono.variable} antialiased scroll-smooth`}
      suppressHydrationWarning
    >
      <body className="min-h-screen">
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          <TooltipProvider delayDuration={150}>
            <PageShortcuts />
            <div className="relative grid min-h-screen w-full grid-cols-[1fr_min(50rem,calc(100%-3rem))_1fr]">
              <div className="col-start-2 flex min-h-screen w-full flex-col">
                <SiteHeader />
                <main id="main-content" className="flex flex-1 flex-col">
                  {children}
                </main>
                <SiteFooter />
              </div>
              <div className="col-start-1 row-span-full border-r border-dashed border-r-(--pattern-fg) pattern-hatch" />
              <div className="col-start-3 row-span-full border-l border-dashed border-l-(--pattern-fg) pattern-hatch" />
            </div>
          </TooltipProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
