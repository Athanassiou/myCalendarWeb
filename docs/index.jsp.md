# index.jsp

Single-page dashboard for the "Days 2 Go" retirement countdown. Server-rendered by `CalendarServlet` (GET → forward) with request attributes `result` (`CalcResult`) and `prefs` (`UserPreferences`).

## JSP scriptlet (top of file)

- `result`, `prefs` — pulled from request attributes.
- `minAge` / `maxAge` — fixed slider bounds `61` / `70`.
- `tickAge1..4` — equidistant tick labels across `[minAge, maxAge]` (currently `61, 64, 67, 70`).
- `ctx` — context path, used to build absolute links/form actions (`<%= ctx %>/`, `<%= ctx %>/slider`).

## Layout

- **Sidebar** (`#sidebar`) — logo, nav section label, nav links, footer with theme/compact toggles.
  - Nav section label shows two spans: `.label-full` ("Countdown") and `.label-compact` ("D2GO"). CSS swaps which is visible based on `body.compact`.
  - `#settingsLink` and `#panelsLink` are `href="#"` links that open modals via JS (see below) — they do not navigate.
- **Main dashboard** (`.dashboard`, 4-column responsive grid, collapses to 2/1 columns at 1100px/600px):
  - `#panel-clock` — live digital clock (day name, date, HH:MM:SS), updated every second via `tick()`.
  - `#panel-overview` — target date, countdown (years/months/days), total workdays remaining.
  - `#panel-details` — breakdown: total days, business days, weekend days, holidays, vacation, training.
  - `#panel-age` — target age (`result.age`), the **Zielalter slider** (range `61–70`, ticks `61/64/67/70`), and workdays at the selected age.

## Modals

Both modals share `.modal-overlay` (fixed, full-screen backdrop, hidden unless `.open`) and `.settings-card` (centered card, max-width 640px, scrollable, with a `.modal-close` × button).

- **`#settingsOverlay` / `#settings`** — the 8-field preferences form (`targetMonth`, `targetYear`, `remainVacation`, `annualVacation`, `currentTraining`, `annualTraining`, `birthMonth`, `birthYear`). POSTs to `<%= ctx %>/`; `CalendarServlet` saves the cookie and redirects (PRG), which naturally leaves the modal closed on reload.
  - Opened by `#settingsLink`.
  - Closed by `#settingsClose`, clicking the backdrop, or submitting the form.
- **`#panelsOverlay` / `#panels`** — 4 toggle switches (`#panel-toggle-clock/overview/details/age`) to show/hide the corresponding dashboard panel.
  - Opened by `#panelsLink`.
  - Closed by `#panelsClose` or clicking the backdrop.
  - Each switch toggles a `body.hide-*` class (`hide-clock`, `hide-overview`, `hide-details`, `hide-age`) which sets `display: none` on the matching panel, and persists the full state as JSON to `localStorage['d2g_panels']`.

## Inline scripts

1. **Early `<body>` script** — reads `localStorage` (`n3theme`, `n3sidebar`, `d2g_panels`) and sets `document.body.className` *before* the rest of the page renders, so grey mode, compact sidebar, and hidden panels apply without a flash of unstyled/default content.
2. **`<script src="n3Sidebar.js">`** — shared sidebar behavior: hamburger/mobile overlay, Grey Mode toggle (`#themeToggle`), compact sidebar toggle (`#compactToggle`). See project root for details.
3. **Bottom inline `<script>`** (single IIFE):
   - Digital clock `tick()`, run every second.
   - Zielalter slider `updateSlider()` — on `input`, fetches `<%= ctx %>/slider?age=N` and patches all the dashboard numbers/date from the JSON response (`SliderServlet`).
   - Settings modal open/close wiring.
   - Panels modal open/close wiring + per-panel visibility toggle + `localStorage` persistence.

## localStorage keys

| Key | Values | Set by |
|---|---|---|
| `n3theme` | `"dark"` \| `"grey"` | `n3Sidebar.js` (Grey Mode toggle) |
| `n3sidebar` | `"full"` \| `"compact"` | `n3Sidebar.js` (compact toggle) |
| `d2g_panels` | JSON, e.g. `{"clock":false,"overview":true,...}` | Panels modal switches |

Note: server-side preferences (the 8 settings fields) are stored separately in the `d2g_prefs` cookie via `UserPreferences` — see root `CLAUDE.md`.
