# MELLOW Technical Architecture

**Status:** Proposed. Verify all implementation details against installed Quickshell and Hyprland versions.

## 1. Platform
- Target compositor: Hyprland.
- Protocol: Wayland.
- Shell framework: Quickshell.
- UI: QtQuick/QML and JavaScript for lightweight logic.
- Environments: development in the repository on the developer's host (launched with
  `qs -p`); testing on a separate clean Arch Linux + Hyprland PC via `install.sh`.
- Initial launch: manual, no autostart.

MELLOW is intentionally Hyprland-native. Do not build a compositor abstraction for Sway, Niri or other compositors in the initial project.

## 2. Proposed repository structure

```text
MELLOW/
├── shell.qml
├── CLAUDE.md
├── DESIGN.md
├── ARCHITECTURE.md
├── ROADMAP.md
├── core/
│   ├── Config.qml
│   ├── Theme.qml
│   ├── Palette.qml
│   ├── Typography.qml
│   ├── Motion.qml
│   └── ScreenManager.qml
├── integrations/hyprland/
│   ├── HyprlandService.qml
│   ├── WorkspaceService.qml
│   ├── WindowService.qml
│   └── MonitorService.qml
├── services/
│   ├── AudioService.qml
│   ├── NetworkService.qml
│   ├── BluetoothService.qml
│   ├── BatteryService.qml
│   ├── MediaService.qml
│   ├── NotificationService.qml
│   └── WallpaperService.qml
├── components/
├── modules/
│   ├── TopBar/
│   ├── Dock/
│   ├── Island/
│   ├── ControlCenter/
│   ├── Launcher/
│   ├── Overview/
│   ├── WallpaperStudio/
│   └── Notifications/
├── assets/
└── docs/
```

Adjust after inspecting Quickshell packaging and QML module conventions. Do not create empty placeholder modules that are not yet used.

### As built in M0
```text
mellow-shell/
├── shell.qml                  per-screen Variants: TopBar, WorkspaceFrame, FrameReservation ×3, Dock
├── install.sh / uninstall.sh
├── core/                      Config, Theme, ColorScheme (generated), Typography, Motion
├── integrations/hyprland/     HyprlandService
├── components/                Surface, StateLayer, FocusRing, MText, MaterialIcon, IconButton
                               (M5: IconBadge, tonal icon container)
├── modules/TopBar/            TopBar, WorkspaceStrip, StatusArea
├── services/                  MediaService (MPRIS + PipeWire sink), SystemStatsService (/proc, hwmon)
├── modules/Island/            Island (window), MediaCompact, AmbientCompact, MediaPlayer, Artwork
├── modules/ControlCenter/     ControlCenterPopup
├── modules/Dock/              Dock, DockItem
├── modules/Frame/             WorkspaceFrame, FrameReservation
├── tools/gen-palette.py       seed colour -> core/ColorScheme.qml (matugen, dev only)
└── docs/
```
Modules import each other as `qs.<dir>` (Quickshell resolves these from the shell root).

### Hyprland integration and entry points (M1)
- `HyprlandService` exposes monitors, workspaces, windows and the active window, all
  driven by Quickshell's Hyprland event socket (no polling, no `hyprctl`). Actions
  (`focusWorkspace`, `cycle`, `focusWindow`, `closeWindow`) validate their arguments and
  dispatch in Lua syntax when `Hyprland.usingLua` is set, classic syntax otherwise.
  Outside Hyprland every list is empty and actions are no-ops.
- `core/ShellState` holds cross-surface UI state (which monitor shows the Control Center
  or keyboard-opened Dock). Pointer, shortcut and IPC paths all go through it.
- `modules/Shortcuts.qml` registers Hyprland global shortcuts (`mellow:controlCenter`,
  `mellow:dock`, `mellow:closeAll`) and the IPC target `mellow`
  (`toggleControlCenter`, `toggleDock`, `closeAll`, `focusWorkspace <id>`).
  M2 adds `mellow:island`, `mellow:mediaPlayPause`, `mellow:mediaNext`,
  `mellow:mediaPrevious` and matching IPC functions.

### Services (M2)
- `MediaService`: active MPRIS player (playing wins; otherwise the last one played),
  metadata with fallbacks, capabilities, transport/seek actions, PipeWire default sink
  name. Position is re-read once a second only while playing (MPRIS does not push it).
- `SystemStatsService`: CPU from `/proc/stat` deltas, memory from `/proc/meminfo`,
  temperature from the best hwmon sensor (found once at startup). Samples every 3 s
  only while ambient mode is visible; missing sources yield null and are hidden.

### Control Center and theming (M3)
- `AudioService` (PipeWire default sink/source), `NetworkService` (Quickshell.Networking,
  NetworkManager backend; scans only while the Wi-Fi page is open), `BluetoothService`
  (paired devices), `PowerService` (UPower battery, power-profiles-daemon detected via
  busctl), `BrightnessService` (sysfs read, logind `Session.SetBrightness` write,
  throttled). Every control is hidden when its source is unavailable.
- `ThemeState` persists mode and an optional generated scheme (`theme.json`);
  `Theme.color` is a `ThemeColors` object bound to it, falling back per role to the
  built-in `ColorScheme`.
- `WallpaperService` stores wallpapers per monitor plus one revert snapshot
  (`wallpaper.json`) and runs matugen (`--dry-run --json hex`, empty config, never the
  user's templates) in a queued Process with a session cache. `ColorUtil.check` reports
  WCAG contrast for the text role pairs.

### Control Center panel and notifications (M5)
- Full-height surface inside the chrome on the right; the card slides in on x. `MainPage`
  pins the controls and scrolls `MediaCard` and `NotificationList` below them.
- `NotificationService` wraps Quickshell's `NotificationServer`. Only one program per
  session can own `org.freedesktop.Notifications`; the owner is queried (busctl) at
  startup and when the panel opens, and the list says so when it is another program.
  Text is plain, remote images are never loaded, at most `Config.notifications.maxKept`
  are kept, transient ones are not. There are no popups.

### Launcher, Dock and Overview (M4)
- `AppService`: visible desktop entries, ranked search (name, words, generic name,
  keywords, id, comment, in-order letters), launch (Terminal=true apps run in
  `Config.launcher.terminal`), MELLOW's own launch counts (`apps.json`) as a small
  ranking boost, window → desktop entry mapping (`DesktopEntries.heuristicLookup`).
- Dock = pinned entries + running unpinned apps, both from `HyprlandService.windows`.
- Overview reads window geometry from Hyprland IPC (`lastIpcObject.at/size`), refreshed
  on open and on window events while open; previews are one-shot `ScreencopyView`
  captures (`live: false`) created only while the Overview is open.
- `HyprlandService.moveWindowToWorkspace` (`movetoworkspacesilent` /
  `hl.dsp.window.move({ workspace, follow = false, window })`).
- Overview cards: the monitor's workspaces plus empty slots for default workspaces
  `1..Config.overview.defaultWorkspaces` that do not exist on any monitor yet.
- `modules/TopBar/WorkspacePreview`: a click-through, always-mapped layer surface per
  screen. `WorkspaceStrip` exposes the hovered workspace (via `TopBar`); after
  `Config.panel.workspacePreviewDelay` the preview refreshes window geometry
  (`HyprlandService.refreshWindows()`) and shows still captures of that workspace's
  windows. Not shown for the visible workspace or empty ones.

### Effects (M5)
- Theme changes cross-fade in `ThemeColors`; components that animate `color` disable that
  `Behavior` while `Theme.transitioning`.
- `Theme.effects` derives the blur mode from `Config.effects.blur` and
  `Theme.compositorBlur`; `shell.qml` binds the latter to `HyprlandService.blurEnabled`
  so `core/` never talks to Hyprland. `Theme.glass(color)` applies the card opacity.
- Each floating card sets `BackgroundEffect.blurRegion` (Quickshell.Wayland,
  ext-background-effect) to a `Region` on the card with matching corner radii, only
  while the card is shown; Overview/Studio backdrops use it in Expressive mode only.
- Island, Dock, Control Center and the workspace preview draw a 2 px edge band
  (`Theme.cardEdge(fill)`, the fill halfway to opaque) over the 1 px blur inset, so
  the stepped corners of the blur region do not show.

### Surfaces (M0)
| Surface | Layer | Keyboard | Input region | Exclusive zone |
|---|---|---|---|---|
| `mellow:panel` | Top | None | whole panel | panel height |
| `mellow:island` | Top (after panel) | OnDemand while expanded (HyprlandFocusGrab) | exactly the Island | ignored |
| `mellow:frame` | Top | None | empty (click-through) | ignored |
| `mellow:frame-reserve` ×3 | Top (after panel) | None | empty | frame thickness (left/right/bottom) |
| `mellow:dock-edge` | Top | None | fixed edge strip (never changes) | ignored |
| `mellow:dock` | Top | None (OnDemand when keyboard-opened) | empty while hidden; right of the strip while shown | ignored (auto-hide) / auto (pinned) |
| `mellow:control-center` | Top | OnDemand + HyprlandFocusGrab (with the panel) while open | the card while open, empty otherwise | ignored |
| `mellow:wallpaper` | Background | None | whole screen | ignored (only when a wallpaper is set) |
| `mellow:launcher` | Top | OnDemand + HyprlandFocusGrab while open | the sheet while open, empty otherwise | ignored |
| `mellow:overview` | Top (created last) | OnDemand + HyprlandFocusGrab while open | whole screen while open, empty otherwise | ignored |
| `mellow:studio` | Top | OnDemand + HyprlandFocusGrab while open | whole screen while open, empty otherwise | ignored |

Interactive surfaces stay mapped and switch their input region instead of using
xdg-popups: Hyprland's focus grab treats clicks inside a layer-shell popup as outside
clicks, which dismissed the first Control Center on every press.

## 3. Boundaries

### UI
QML components render state and emit user intents. They must not independently spawn shell commands or implement system polling.

### Core
Owns configuration, semantic theme tokens, palette state, typography, motion settings and screen coordination.

### Hyprland integration
Use supported Quickshell Hyprland integration where possible. Verify exact APIs locally.

Centralize:
- active workspace;
- workspace list;
- clients/windows;
- active window;
- monitor list;
- focused monitor;
- relevant compositor events.

Do not let each widget run its own `hyprctl` polling loop. Prefer event-driven updates. If commands are necessary, centralize them, validate arguments, handle errors and avoid blocking the UI thread.

### System services
Keep non-compositor integrations separate:
- audio: PipeWire/WirePlumber;
- media: MPRIS;
- network: NetworkManager;
- Bluetooth: BlueZ;
- battery: UPower or supported interface;
- notifications: desktop notification protocol or supported Quickshell service;
- wallpaper: selected wallpaper backend.

Check Quickshell's built-in integrations before adding dependencies.

## 4. Wayland surfaces

MELLOW may use separate surfaces for:
- full-width panel;
- edge-triggered Dock;
- expanded Island;
- Control Center;
- Launcher;
- Overview;
- persistent workspace frame.

Define layer, keyboard interactivity, exclusive-zone behavior, anchors and monitor targeting deliberately. Avoid surfaces that intercept clicks or keyboard input accidentally.

The persistent frame must not steal input or overlap application content. Account for panel reservations, scaling, monitor changes and fullscreen windows.

## 5. Configuration

Initial settings:
- panel height;
- Dock edge and auto-hide;
- Island behavior;
- Control Center behavior;
- workspace frame enabled/disabled;
- frame thickness and color role;
- blur mode;
- animation/reduced-motion mode;
- theme mode;
- wallpaper and seed override;
- keybindings.

Do not expose every internal implementation detail as a setting.

## 6. Performance and reliability
- Avoid high-frequency polling where events are available.
- Avoid repeated process spawning.
- Avoid expensive image processing on the UI thread.
- Cache wallpaper-derived palettes.
- Debounce wallpaper changes.
- Handle missing sensors/devices/services gracefully.
- Ensure a service failure does not crash the shell.
- Measure startup and idle resource use.
- Keep logs actionable.

## 7. Testing
M0: launch/stop, QML load, panel geometry, workspace updates, Dashboard visibility, monitor changes if available.

Later: media changes, missing services, wallpaper palette generation, blur modes, multiple monitors, fullscreen behavior, keyboard-only workflows.

## 8. Safety
- Development VM is the default.
- Never modify host Hyprland configuration automatically.
- Never replace existing Waybar, Caelestia or other shell.
- Do not enable autostart until explicitly requested.
- Do not run destructive commands or alter bootloader, partitions or filesystem configuration.
- Keep a documented manual rollback procedure.
