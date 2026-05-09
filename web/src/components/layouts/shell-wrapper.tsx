import { cn } from "@/lib/utils";

interface ShellWrapperProps {
  className?: string;
  children: React.ReactNode;
}

/**
 * Section container with hairline rules at top and bottom and a constrained
 * inner column. Mirrors the portfolio's content rhythm — each section sits
 * inside its own ShellWrapper so the dividers stack visually as you scroll.
 */
export function ShellWrapper({ className, children }: ShellWrapperProps) {
  return (
    <section className={cn("relative isolate w-full overflow-visible", className)}>
      <div className="pointer-events-none absolute inset-x-0 top-0 h-px bg-(--pattern-fg)" />
      <div className="pointer-events-none absolute inset-x-0 bottom-0 h-px bg-(--pattern-fg)" />
      <div className="relative mx-auto flex w-full max-w-200 flex-col gap-8">
        {children}
      </div>
    </section>
  );
}
