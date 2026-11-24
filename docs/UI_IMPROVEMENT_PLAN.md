# UI improvement plan (proposal, awaiting approval)

Nothing here is implemented. Bar 44 px, left auto-hide Dock, centred Island, frame
geometry, blur modes, shortcuts and IPC stay as they are.

## 1. Design language: "Organic Material" made explicit

**Shape (A1, A3).** One rule: a floating card has radius xl, with one *anchor corner*
pointing at what opened it, and one *organic corner* diagonally opposite.
| Card | Anchor (md) | Organic (38 px) |
|---|---|---|
| Control Center | top-right (status pill) | bottom-left |
| Launcher | none (screen-centred) | top-left, as now |
| Dock | none (edge-centred) | top-right, as now |
| Pop-ups | top-right | none (too small; radius lg) |
| Workspace preview | top-left | none (radius lg) |
| Studio, Settings | none | top-left |
The Island keeps its two organic corners: they are its signature.

**Surface (A2, A10).** Three levels: chrome `surfaceContainer`; floating card
`surfaceContainer`; content inside a card `surfaceContainerHighest`. Small standalone
cards (pop-ups, Dock, Island) stay `surfaceContainerHigh`. Edges stay as the user chose.
Overview empty slots become tonal outlines instead of filled cards.

**Motion (A4).** Named pairs in `Motion` instead of raw durations: `enter`, `exit`
(shorter, accelerating), `move` (spatial, slight overshoot for small controls only) and
`state` (colour/opacity). Same total times as DESIGN §11; reduced motion stays instant.

**Colour (A5).** Give roles jobs: primary = active/main action; secondary = selection;
tertiary = media and time-based things (seek line, Island progress); error = urgent.

**Type and icons (A6, A7).** Page titles `headlineMedium`, section titles `titleMedium`,
one emphasised weight for active items. Icon tokens: 18 (inline), 22 (control), 28 (hero).

**Interaction (A8, A9, A12).** One `Tooltip` component (pointer delay and keyboard focus),
state layers on every pressable control, stray numbers replaced by tokens.

## 2. Steps (each one commit, tested in the isolated copy)
| Step | Content | Size | Risk |
|---|---|---|---|
| 1 | Motion, icon and surface tokens; easing fixes (A2, A4, A7, A12) | M | low |
| 2 | Card shape rule (A1), Control Center, pop-ups, preview | S | low; blur regions follow radii |
| 3 | State layers and tooltips (A8, A9) | M | medium: a tooltip needs its own click-through surface |
| 4 | Studio layout, Launcher scroll edge, Overview light (A3, A10, A11) | M | low |
| 5 | Colour and type roles (A5, A6) | S | medium: taste; show before/after first |
| 6 | Settings UI (section 3) | L | medium |
Steps 1-2 first, since Settings should be built from them.

## 3. Settings UI
A normal window (`FloatingWindow`, present in the installed Quickshell), opened by
Meta+I, IPC and a Control Center entry. Left navigation, one page at a time, search later.
Changes apply at once and are written to `config.json`; each changed row has a reset
button. Keeps unknown keys in the file; a broken file is shown, never overwritten silently.

| Page | Settings (existing keys) |
|---|---|
| Appearance | Dark theme (live, `ThemeState`), `effects.blur`, `motion.reduced`, `theming.apps`, link to Wallpaper Studio |
| Wallpaper & colours | `wallpaper.draw`, `.folders`, `.schemeType`, `.presetSeeds` |
| Bar & clock | `panel.height`, `.workspacePreview` + delay + width, `clock.timeFormat`, `.dateFormat` |
| Frame | `frame.enabled`, `.thickness`, `.fullscreenPolicy` |
| Island | `island.compactMaxWidth`, `.expandedWidth`, `.pausedGrace`, `.statsInterval` |
| Dock & Launcher | `dock.autoHide`, `.hideDelay`, `.triggerWidth`, `.pinned`, `launcher.terminal`, `.maxResults` |
| Control Center & notifications | `controlCenter.width`, `notifications.popups`, `.popupTimeout`, `.maxKept` |
| Overview | `overview.defaultWorkspaces` |
| About | version, `Config.problems`, which services are available |

- Widget comes from the type: bool = switch, int = slider with value, enum = segmented
  button (list when long), string = text field, strings = editable list.
- `theme.mode` is not shown (see audit). Delays, widths and intervals go under "Advanced".
- `ConfigSchema` gains `title`, `page`, `advanced` and `unit`; pages are built from it, so
  a key cannot be forgotten. Needs `Config.set`/`reset` and the scheme-cache fix.
- The user's own list of extra settings is still to come.

## 4. Ideas from end-4 / end4-pC
Based on the local `ii` module names and the end4-pC README, not on their code. end4-pC
requires illogical-impulse; only ideas are taken.

| Idea | Seen in | Problem it solves | Cost | Advice |
|---|---|---|---|---|
| On-screen display for volume/brightness | ii `onScreenDisplay` | Media keys give no feedback | S | Yes, after step 3 |
| Keybinding sheet | ii `cheatsheet`; end4-pC lists keys in its launcher | New shortcuts are undiscoverable | S | Yes, as a Settings page first |
| Session menu (lock, log out, power off) | ii `sessionScreen` | MELLOW has no way to leave the session | M | Yes; confirm before power actions |
| Settings found from the launcher | end4-pC | Finding a setting quickly | S | Yes, after Settings |
| Notification grouping by app | ii `NotificationGroup` | Long lists | M | Later |
| Do Not Disturb | DESIGN §3.4 | Silencing pop-ups | S | Yes, with Settings |
| Local theme presets | end4-pC presets; ROADMAP M6 | Saving a look | M | Yes; no online gallery |
| Desktop widgets, lyrics, online wallpapers, AI/translator, on-screen keyboard | ii / end4-pC | None stated for MELLOW | L | No (DESIGN §13) |

## 5. Decisions needed
1. Approve steps 1-5, or choose some.
2. Is the Control Center's extra organic corner welcome?
3. Settings as a normal window?
4. Which section 4 ideas enter M6?
5. The extra settings list.
