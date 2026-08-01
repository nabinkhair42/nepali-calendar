import Link from "next/link";

const linkClass =
  "underline decoration-from-font underline-offset-4 transition-colors hover:text-foreground";

export function SiteFooter() {
  return (
    <footer className="flex h-24 flex-wrap items-center justify-between gap-3 px-2 text-sm leading-normal text-muted-foreground">
      <span>Made by Nabin Khair</span>
      <nav className="flex items-center gap-4">
        <Link href="/privacy" className={linkClass}>
          Privacy
        </Link>
        <Link href="/terms" className={linkClass}>
          Terms
        </Link>
      </nav>
    </footer>
  );
}
