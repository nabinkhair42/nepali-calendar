// Visual replica of the macOS menu bar popover. Static — meant for the hero.
"use client";

const NEPALI_DIGITS = ["०", "१", "२", "३", "४", "५", "६", "७", "८", "९"];
const toNE = (n: number): string =>
  String(n)
    .split("")
    .map((c) => (/[0-9]/.test(c) ? NEPALI_DIGITS[Number(c)] : c))
    .join("");

const WEEKDAYS_EN = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

// Sample BS month grid: Jestha 2082 (May–June 2026). Starts on Friday.
// 32 days. AD start = 15 May 2026.
const SAMPLE_DAYS = (() => {
  const days: { bs: number; ad: number; weekday: number }[] = [];
  // 15 May 2026 = Friday (weekday 5 if Sunday=0)
  let weekday = 5;
  let adDay = 15;
  let adMonth = 5;
  for (let bs = 1; bs <= 32; bs++) {
    days.push({ bs, ad: adDay, weekday });
    weekday = (weekday + 1) % 7;
    adDay++;
    if ((adMonth === 5 && adDay > 31) || (adMonth === 6 && adDay > 30)) {
      adMonth++;
      adDay = 1;
    }
  }
  return days;
})();

const TODAY_BS = 26;

export function AppPreview({ devanagari = false }: { devanagari?: boolean }) {
  const startWeekday = SAMPLE_DAYS[0].weekday;
  const slots: ((typeof SAMPLE_DAYS)[number] | null)[] = Array.from(
    { length: startWeekday },
    () => null,
  );
  for (const d of SAMPLE_DAYS) slots.push(d);
  while (slots.length % 7 !== 0) slots.push(null);

  const fmt = (n: number) => (devanagari ? toNE(n) : String(n));
  const monthLabel = devanagari ? "जेठ" : "Jestha";
  const yearLabel = devanagari ? toNE(2082) : "2082";

  return (
    <div className="relative w-[320px] mx-auto">
      {/* faux menu bar with the app's compact label */}
      <div className="relative z-10 mb-3 mx-auto w-fit rounded-md px-2.5 py-1 text-[12px] font-medium tracking-tight glass-strong shadow-[0_2px_10px_rgba(0,0,0,0.08)]">
        <span className="opacity-80">{devanagari ? `जेठ ${toNE(26)}` : "Jes 26"}</span>
      </div>

      {/* popover */}
      <div className="rounded-2xl glass-strong shadow-[0_30px_80px_-20px_rgba(0,0,0,0.35)] overflow-hidden">
        {/* header */}
        <div className="flex items-baseline px-4 pt-3.5 pb-2.5">
          <div>
            <div className="text-[18px] font-semibold tracking-tight">
              {monthLabel} {yearLabel}
            </div>
            <div className="text-[11px] text-[var(--muted)] -mt-0.5">May–Jun 2026</div>
          </div>
          <div className="ml-auto flex gap-0.5">
            <NavBtn>‹</NavBtn>
            <NavBtn small>•</NavBtn>
            <NavBtn>›</NavBtn>
          </div>
        </div>
        <div className="border-t border-[var(--border)]" />
        {/* grid */}
        <div className="px-3.5 py-3">
          <div className="grid grid-cols-7 gap-1 mb-1.5">
            {WEEKDAYS_EN.map((w, i) => (
              <div
                key={w}
                className={`text-[10px] font-medium text-center ${
                  i === 6 ? "text-[var(--accent)]" : "text-[var(--muted)]"
                }`}
              >
                {w}
              </div>
            ))}
          </div>
          <div className="grid grid-cols-7 gap-1">
            {slots.map((s, i) => {
              if (!s) return <div key={i} className="h-9" />;
              const isToday = s.bs === TODAY_BS;
              const isWeekend = i % 7 === 6;
              return (
                <div
                  key={i}
                  className={`relative h-9 rounded-[9px] flex flex-col items-center justify-center transition ${
                    isToday
                      ? "bg-[var(--accent)] text-white shadow-[0_4px_14px_-2px_rgba(210,53,72,0.5)]"
                      : isWeekend
                        ? "bg-[var(--accent-soft)]"
                        : ""
                  }`}
                >
                  <span
                    className={`text-[13px] leading-none font-medium ${
                      isWeekend && !isToday ? "text-[var(--accent)]" : ""
                    }`}
                  >
                    {fmt(s.bs)}
                  </span>
                  <span
                    className={`text-[8.5px] leading-none mt-0.5 ${
                      isToday ? "text-white/85" : "text-[var(--muted)]/80"
                    }`}
                  >
                    {s.ad}
                  </span>
                </div>
              );
            })}
          </div>
        </div>
        <div className="border-t border-[var(--border)]" />
        {/* footer */}
        <div className="px-3.5 py-2.5 flex items-center gap-2">
          <span className="text-[11px] text-[var(--muted)]">
            Tuesday, Jun 9, 2026
          </span>
          <span className="ml-auto inline-flex items-center justify-center min-w-[26px] h-[20px] px-1.5 rounded-md text-[10px] font-semibold bg-black/[0.06] dark:bg-white/[0.08]">
            {devanagari ? "ने" : "EN"}
          </span>
          <span className="inline-flex items-center justify-center w-[24px] h-[22px] rounded-md text-[10px] bg-black/[0.06] dark:bg-white/[0.08]">
            ⏻
          </span>
        </div>
      </div>
    </div>
  );
}

function NavBtn({
  children,
  small,
}: {
  children: React.ReactNode;
  small?: boolean;
}) {
  return (
    <span
      className={`inline-flex items-center justify-center w-6 h-6 rounded-md text-[var(--muted)] hover:bg-black/[0.06] dark:hover:bg-white/[0.08] ${
        small ? "text-[8px]" : "text-[11px]"
      }`}
    >
      {children}
    </span>
  );
}
