export function SiteFooter() {
  return (
    <footer className="flex h-14 items-center justify-between px-2 text-xs text-muted-foreground">
      <span>Made by Nabin Khair</span>
      <span>© {new Date().getFullYear()} · All rights reserved</span>
    </footer>
  );
}
