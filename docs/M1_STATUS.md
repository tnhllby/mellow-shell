# M1 Status — Hyprland Integration

## Implemented
- `HyprlandService` (single integration point): monitors (left to right), focused monitor,
  workspaces (+ per monitor), focused workspace, windows (+ per workspace), active window,
  `appIdOf()`. Actions: `activate`, `focusWorkspace(id)` (creates missing workspaces),
  `cycle`, `focusWindow`, `closeWindow` — validated, Lua/classic dispatch aware.
- `ShellState`: shared Control Center / keyboard-Dock state per monitor.
- Entry points (`modules/Shortcuts.qml`): global shortcuts `mellow:controlCenter`,
  `mellow:dock`, `mellow:closeAll`; IPC target `mellow`.
- Dock keyboard mode: opened by shortcut/IPC, takes focus through `HyprlandFocusGrab`;
  Up/Down/Tab, Enter/Space, Escape.
- Panel: active window icon + title after the workspace strip (`Config.panel.showActiveWindow`).

## Test-machine feedback (2026-11-16, round 2)
- Dock stayed open on the frame but hid with the pointer pressed against the screen
  edge: changing a surface's input region drops hover until the pointer moves, which it
  cannot do at the edge. The edge trigger is now its own surface with a fixed input
  region; the dock surface only gains input right of it. (Needs re-test.)
- Frame's focused-monitor outline removed.
- Keybindings: the M6 installer will configure them (docs/DECISIONS.md).

## Verified on the development host
- Loads with no QML warnings; all surfaces on both monitors.
- `qs ipc show` lists the `mellow` target and its four functions.
- `hyprctl globalshortcuts` lists the three `mellow:*` shortcuts.
- Active window title/icon renders on the focused monitor only (screenshot).
- Without `HYPRLAND_INSTANCE_SIGNATURE`: shell still starts and draws every surface; the
  only log line is Quickshell's "Cannot connect to hyprland" warning.

## Unverified (test machine; see docs/RUNNING.md M1 checklist)
- Pressing the shortcuts, Dock keyboard navigation, IPC `focusWorkspace`.
- Classic (`hyprland.conf`) dispatch path; the host uses a Lua config.
- `hyprctl reload` / monitor hot-plug behaviour.

## Known limitations
- No per-workspace window list in the UI yet; the service provides it for Overview (M4).
- Keybindings must be added to Hyprland by the user; MELLOW does not edit Hyprland config.
