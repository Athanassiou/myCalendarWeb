# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**myCalendar** (WAR context: `/myCalendar`) is a Jakarta EE web port of the `myCalendar4` Swing desktop app. It is a retirement-countdown calculator ("Days 2 Go") that computes remaining working days to a target date, accounting for weekends, public holidays, vacation, and training days.

Runs on **Apache Tomcat** at `/Library/Tomcat/`. Built as a WAR with Maven.

## Build & Deploy

```bash
# Build
~/apache-maven-3.8.6/bin/mvn clean package

# Deploy to Tomcat
cp target/myCalendar-1.0-SNAPSHOT.war /Library/Tomcat/webapps/myCalendar.war
```

There are no automated tests. Manual testing via browser at `http://localhost:8080/myCalendar/`.

## Architecture

**Servlet + JSP** (Jakarta EE 9.1, Java 11) — no ORM, no database.

### Core classes

| Class | Role |
|---|---|
| `CalendarEngine` | Pure Java calculation logic — no AWT. Computes Easter algorithmically (Gauss/Spencer) to derive German federal holidays for any year (Bayern/BW set: includes Fronleichnam). Replaces the `myDataPack` + flat-file approach of the Swing original. |
| `UserPreferences` | Bean holding the 8 user settings. Reads/writes a single cookie `d2g_prefs` (`_`-separated integers — RFC 6265 forbids commas in cookie values). |
| `CalcResult` | Immutable result bean — populated by `CalendarEngine.calculate()`. |
| `CalendarServlet` | Maps to `` (context root) and `/index` — **not** `/`, which would make it the default servlet and swallow static resource requests (`.js`, etc.). GET: computes and forwards to `index.jsp`. POST: reads form, saves cookie, redirects (PRG pattern). |
| `SliderServlet` | Maps to `/slider`. GET with `?age=X` param — calculates with target year = birthYear + age, returns JSON for live AJAX updates. |

### JSP

`index.jsp` — single-page dashboard. N3 Dark Theme CSS is referenced from the shared Tomcat ROOT context (`/styles/n3.css`, `/styles/n3-driver.css`) — do **not** bundle these into the WAR. `n3Sidebar.js` is bundled in `src/main/webapp/`.

Dashboard panels: **Uhrzeit & Datum**, **Übersicht**, **Detailwerte**, **Zielalter** (`#panel-clock`, `#panel-overview`, `#panel-details`, `#panel-age`). The Zielalter slider has a fixed range of 61–70 with equidistant ticks (61/64/67/70).

Sidebar nav-section-label reads "Countdown", shrinking to "D2GO" in compact mode (`.label-full` / `.label-compact`).

### Modals (popups)

Two modals, both styled via `.modal-overlay` / `.settings-card`, opened from sidebar links and closed via the × button, click-outside, or (Settings) submitting the form:

- **Einstellungen** (`#settingsOverlay`) — the 8-field preferences form, POSTs to `/` on "Übernehmen".
- **Panels** (`#panelsOverlay`) — 4 on/off switches to show/hide each dashboard panel. State persists client-side in `localStorage` under `d2g_panels` (JSON, e.g. `{"clock":false}`), applied early in `<body>` via `body.hide-*` classes to avoid flicker.

### Client-side localStorage keys

| Key | Values | Purpose |
|---|---|---|
| `n3theme` | `dark` / `grey` | Grey Mode toggle |
| `n3sidebar` | `full` / `compact` | Sidebar compact toggle |
| `d2g_panels` | JSON `{clock,overview,details,age: bool}` | Per-panel visibility (Panels popup) |

### Preferences mapping

| Cookie index | Field | Default |
|---|---|---|
| 0 | targetMonth | 12 |
| 1 | targetYear | 2029 |
| 2 | remainVacation | 20 |
| 3 | annualVacation | 30 |
| 4 | currentTraining | 2 |
| 5 | annualTraining | 4 |
| 6 | birthMonth | 12 |
| 7 | birthYear | 1964 |

### Vacation/training formula

Replicates the Swing original (`myDataPack.Calculate()`):

```
years  = targetYear - currentYear - 1   (full years, excluding current and target)
x      = targetMonth / 12               (fraction of target year)
vacation  = remainVacation  + years * annualVacation  + (int)(x * annualVacation)
training  = currentTraining + years * annualTraining  + (int)(x * annualTraining)
workdays  = businessDays - (holidays + vacation + training)
```

### N3 Dark Theme

See `/Users/eathanassiou/Projects/NextThree/CLAUDE.md` for the full N3 design-system reference. CSS variables, grey mode, compact sidebar, and sidebar JS are shared across Tomcat apps via the ROOT context.

## Key Technologies

- Java 11, Jakarta EE 9.1, Apache Tomcat
- No database — state is held in cookies only
- N3 Dark Theme CSS (served from ROOT webapp at `/styles/`)
