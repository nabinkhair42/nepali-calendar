// Visual replica of the macOS menu bar popover. Static — meant for the hero.
// Mirrors the actual app: Devanagari by default, Sun + Sat as weekend (per
// Nepal's Cabinet decision Chaitra 23 2082 BS), no shadows or gradients.
"use client";

const NEPALI_DIGITS = ["०", "१", "२", "३", "४", "५", "६", "७", "८", "९"];
const toNE = (n: number): string =>
  String(n)
    .split("")
    .map((c) => (/[0-9]/.test(c) ? NEPALI_DIGITS[Number(c)] : c))
    .join("");

const WEEKDAYS_EN = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const WEEKDAYS_NE = ["आइत", "सोम", "मंगल", "बुध", "बिहि", "शुक्र", "शनि"];

// Sample BS month grid: Jestha 2082 (May–June 2026). Starts Friday. 32 days.
const SAMPLE_DAYS = (() => {
  const days: { bs: number; ad: number; weekday: number }[] = [];
  let weekday = 5; // 15 May 2026 = Friday
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

export function AppPreview({ devanagari = true }: { devanagari?: boolean }) {
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
  const weekdays = devanagari ? WEEKDAYS_NE : WEEKDAYS_EN;
  const todayPill = devanagari
    ? `मंगल · ${toNE(26)} जे`
    : "Tue · 26 Jes";

  return (
    <div className="relative w-[320px] mx-auto">
      

      {/* popover */}
      <div className="rounded-2xl glass-strong overflow-hidden">
        {/* header */}
        <div className="flex items-baseline px-4 pt-3.5 pb-2.5 gap-2">
          <div className="min-w-0">
            <div className="text-[18px] font-semibold tracking-tight">
              {monthLabel} {yearLabel}
            </div>
            <div className="-mt-0.5 flex items-center gap-1.5 flex-wrap">
              <span className="text-[11px] text-(--muted)">May–Jun 2026</span>
              <span
                className="text-[10px] font-semibold px-1.5 py-0.5 rounded-full"
                style={{
                  color: "var(--accent)",
                  background: "color-mix(in srgb, var(--accent) 14%, transparent)",
                }}
              >
                {todayPill}
              </span>
            </div>
          </div>
          <div className="ml-auto flex gap-0.5 shrink-0">
            <NavBtn>
              <ChevronLeft />
            </NavBtn>
            <NavBtn small>
              <Scope />
            </NavBtn>
            <NavBtn>
              <ChevronRight />
            </NavBtn>
          </div>
        </div>
        <div className="border-t border-(--border)" />
        {/* grid */}
        <div className="px-3.5 py-3">
          <div className="grid grid-cols-7 gap-1 mb-1.5">
            {weekdays.map((w, i) => (
              <div
                key={w + i}
                className={`text-[10px] font-semibold text-center tracking-wider ${
                  i === 0 || i === 6 ? "text-red-500" : "text-(--muted)"
                }`}
              >
                {w}
              </div>
            ))}
          </div>
          <div className="grid grid-cols-7 gap-1">
            {slots.map((s, i) => {
              if (!s) return <div key={i} className="h-10" />;
              const col = i % 7;
              const isToday = s.bs === TODAY_BS;
              const isWeekend = col === 0 || col === 6;
              return (
                <div
                  key={i}
                  className={`relative h-10 rounded-[10px] flex flex-col items-center justify-center transition ${
                    isToday
                      ? "bg-(--accent) text-white"
                      : isWeekend
                        ? "bg-red-500/8"
                        : ""
                  }`}
                >
                  <span
                    className={`text-[14px] leading-none font-medium ${
                      isWeekend && !isToday ? "text-red-500" : ""
                    }`}
                  >
                    {fmt(s.bs)}
                  </span>
                  <span
                    className={`text-[8.5px] leading-none mt-0.5 ${
                      isToday ? "text-white/85" : "text-(--muted)/80"
                    }`}
                  >
                    {s.ad}
                  </span>
                </div>
              );
            })}
          </div>
        </div>
        <div className="border-t border-(--border)" />
        {/* footer */}
        <div className="px-3.5 py-2.5 flex items-center gap-2">
          <div className="flex flex-col gap-0">
            <span
              className="text-[9px] font-semibold tracking-widest"
              style={{ color: "var(--accent)" }}
            >
              TODAY
            </span>
            <span className="text-[11px] text-(--muted) leading-tight">
              Tue, May 26, 2026
            </span>
          </div>
          <span className="ml-auto inline-flex items-center justify-center w-[26px] h-[22px] rounded-md bg-black/6 dark:bg-white/8">
            <BookCharacter />
          </span>
          <span className="inline-flex items-center justify-center w-[24px] h-[22px] rounded-md bg-black/6 dark:bg-white/8">
            <Power />
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
      className={`inline-flex items-center justify-center w-6 h-6 rounded-md text-(--muted) hover:bg-black/6 dark:hover:bg-white/8 ${
        small ? "" : ""
      }`}
    >
      {children}
    </span>
  );
}

/* SF Symbol-style line icons (chevron.left, chevron.right, scope, character.book.closed, power) */

function ChevronLeft() {
  return (
    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden>
      <path
        d="M15 6l-6 6 6 6"
        stroke="currentColor"
        strokeWidth="2.4"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ChevronRight() {
  return (
    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden>
      <path
        d="M9 6l6 6-6 6"
        stroke="currentColor"
        strokeWidth="2.4"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function Scope() {
  return (
    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden>
      <circle cx="12" cy="12" r="8.5" stroke="currentColor" strokeWidth="1.8" />
      <circle cx="12" cy="12" r="2" fill="currentColor" />
      <path d="M12 1.5v3M12 19.5v3M1.5 12h3M19.5 12h3" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
    </svg>
  );
}

function BookCharacter() {
  return (
    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden>
      <path
        d="M5 4h11a3 3 0 0 1 3 3v13H7a2 2 0 0 1-2-2V4Z"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinejoin="round"
      />
      <path d="M5 18h14" stroke="currentColor" strokeWidth="1.8" />
      <text
        x="12"
        y="14"
        fontSize="7"
        fontWeight="700"
        textAnchor="middle"
        fill="currentColor"
      >
        अ
      </text>
    </svg>
  );
}

function Power() {
  return (
    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden>
      <path
        d="M12 3v9"
        stroke="currentColor"
        strokeWidth="2.2"
        strokeLinecap="round"
      />
      <path
        d="M6.5 7.5a8 8 0 1 0 11 0"
        stroke="currentColor"
        strokeWidth="2.2"
        strokeLinecap="round"
      />
    </svg>
  );
}
