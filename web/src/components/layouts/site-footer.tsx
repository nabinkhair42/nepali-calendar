import Link from "next/link";

export function SiteFooter() {
  return (
    <footer className="flex h-14 flex-wrap items-center justify-between gap-3 px-2 text-xs text-muted-foreground">
      <span>Made by Nabin Khair</span>
      <nav className="flex items-center gap-4">
        <Link
          href="/privacy"
          className="transition-colors hover:text-primary"
        >
          Privacy
        </Link>
        <Link
          href="/terms"
          className="transition-colors hover:text-primary"
        >
          Terms
        </Link>
        <span>© {new Date().getFullYear()}</span>
      </nav>
    </footer>
  );
}
