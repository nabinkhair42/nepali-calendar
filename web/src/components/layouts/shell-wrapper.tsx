import { cn } from "@/lib/utils";

interface ShellWrapperProps {
  className?: string;
  children: React.ReactNode;
}

export function ShellWrapper({ className, children }: ShellWrapperProps) {
  return (
    <section className={cn("relative isolate w-full overflow-visible", className)}>
      <div className="relative mx-auto flex w-full max-w-200 flex-col gap-8">
        {children}
      </div>
    </section>
  );
}
