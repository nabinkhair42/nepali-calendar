# NepaliCalendar.app

SwiftUI menu bar app for the Bikram Sambat calendar.

## Build

```bash
swift build -c release        # compile
./build.sh                    # produce NepaliCalendar.app in build/
open build/NepaliCalendar.app # launch
```

## Verify

```bash
swift run NepaliCalendarVerify
# OK  1709 checks passed.
```

`NepaliCalendarVerify` is a CLI that exercises BS↔AD round-trips for every BS
month start (1975–2099), AD round-trips on a sampled grid, year-total
consistency, weekday calculation, and Devanagari numeral formatting. It avoids
XCTest so it runs on systems with only Command Line Tools installed.

## Layout

```
app/
├── Package.swift
├── Info.plist                 # LSUIElement = YES (status-bar only)
├── build.sh                   # wraps swift build into a .app bundle
└── Sources/
    ├── BSCore/                # pure logic — no UI deps
    │   ├── BSData.swift       # year lookup table (auto-generated)
    │   ├── BSDate.swift       # value type + arithmetic
    │   ├── BSConverter.swift  # BS ↔ AD conversion + weekday
    │   └── NepaliFormatter.swift
    ├── NepaliCalendar/        # SwiftUI app
    │   ├── NepaliCalendarApp.swift
    │   ├── State/AppState.swift
    │   ├── Services/LaunchAtLogin.swift
    │   └── Views/
    │       ├── MenuBarLabelView.swift
    │       ├── PopoverRootView.swift
    │       ├── MonthGridView.swift
    │       └── DayCellView.swift
    └── NepaliCalendarVerify/
        └── main.swift
```

## Design notes

- `MenuBarExtra(style: .window)` for a custom popover instead of the dropdown menu style.
- Background uses `.ultraThinMaterial` — on macOS 26 this picks up Liquid Glass automatically.
- `@MainActor` `AppState` re-fetches today at the next local midnight so the highlighted cell stays correct without polling.
- Locale toggle (`EN`/`ने`) persists via `UserDefaults`.
- Launch-at-login uses `SMAppService.mainApp` (macOS 13+).
