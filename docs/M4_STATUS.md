# M4 Status — Launcher, Dock and Overview

## Implemented
- Launcher (`mellow:launcher`, Meta on release): bottom sheet with search field,
  ranked results grid, pinned apps first when empty, keyboard-first (typing always
  goes to the field; arrows/Tab select; Return launches; Escape clears/closes),
  loading and no-results states. Terminal apps open in `Config.launcher.terminal`.
- Dock: running indicators (dot; longer pill for the focused app), running apps that
  are not pinned after a divider, click focuses/cycles windows, middle click or
  Shift+Return opens a new instance.
- Overview (`mellow:overview`, Meta+Tab): the focused monitor's workspaces as cards
  with window captures at their real positions, active workspace/window marked,
  keyboard selection, focus, close (Delete, middle click, ×), 1–9 workspace,
  Shift+1–9 / drag-and-drop to move windows (including to a new workspace).
- Launcher/Overview/Studio/Control Center are mutually exclusive (`ShellState`).

## Verified on the development host
- Loads with no QML warnings.
- Launcher, Overview and Dock rendered in a non-interactive copy (screenshots): search
  results for "te", Overview of workspace 1 with two window captures and the
  "New workspace" slot, Dock with pinned + running unpinned apps and indicators.
- Overview backdrop dims (pixel measured).
- Lua `hl.dsp.window.move({ workspace, follow, window })` parses (dispatched against a
  non-existent window, so nothing moved).

## Unverified (test machine; docs/RUNNING.md M4 checklist)
- All interaction: typing, launching, focusing, closing, moving windows, drag-and-drop.
- Whether `follow = false` keeps focus in place under the Lua config.
- Release binding for Meta alone.

## Fixes after the first test run
- Launcher never opened from `bindr = SUPER, SUPER_L`: a release bind only sends the
  global shortcut's "released" event, and the launcher listened for "pressed". It now
  toggles on release (Hyprland already drops the release when another key was pressed
  with Meta, so Meta+Tab etc. do not open it).
- Overview felt like it froze: its content was rebuilt on every open and popped in
  without animation while the backdrop faded. It is now built once, fades/scales in
  and out (360 ms), and re-captures previews on open at card size. Measured on the
  host: content ready 11 ms after opening, captures within 50 ms, ~1–2 % CPU while
  open, no frames over 34 ms (3 windows).
- Frame bottom corners looked thinner: the inner corners now share the outer corners'
  centre (radius = outer − thickness), so the line keeps its width round the curve.

## Known limitations
- Previews are still captures taken when the Overview opens (not live).
- Overview shows one monitor (the focused one).
- Launch history is MELLOW's own; apps launched elsewhere are not counted.
