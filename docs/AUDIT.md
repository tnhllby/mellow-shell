# M0 Environment Audit (Phase A)

Date: 2026-11-16. Read-only audit of the **development host**; nothing was installed or modified.

## Environment model (decided after the audit)
- **Development host:** HP Laptop 15-dw3xxx, bare metal, daily driver running end-4's
  illogical-impulse ("ii") Quickshell shell. MELLOW is developed in
  `~/Projects/Shell/mellow-shell` only and launched with `qs -p <repo>`; the host's
  `~/.config` is never modified and nothing is installed there.
- **Test machine:** separate PC with a clean Arch Linux + Hyprland. MELLOW is cloned from
  Git and installed with `install.sh`.

## Development host findings

| Item | Finding | Command |
|---|---|---|
| Distro / kernel | EndeavourOS (rolling), Linux 7.2.11-arch1-1 | `/etc/os-release`, `uname -a` |
| Virtualisation | none (bare metal) | `systemd-detect-virt` |
| Hyprland | 0.56.2, **Lua config** (`hyprland.lua`) | `hyprctl version` |
| Quickshell | 0.3.2 (rev 4f508be), via `illogical-impulse-quickshell-git` | `qs --version`, `pacman -Qi` |
| Quickshell in repos | `quickshell 0.3.2-1` is in **extra** | `pacman -Si quickshell` |
| Qt | 6.12.0 (base, declarative, wayland, svg, 5compat, shadertools, multimedia) | `pacman -Q` |
| Monitors | HDMI-A-1 1920×1080@60 at 0,0 scale 1; eDP-1 1366×768@60 at 1920,0 scale 1 | `hyprctl monitors -j` |
| GPU | Intel Iris Xe (i915) + NVIDIA MX450 (nvidia 615.78); GL renderer NVIDIA, GL 4.6 | `lspci -k`, `eglinfo -B` |
| Running shell | ii (`qs -c ii`): bar, dock, background, screen corners on both monitors | `hyprctl layers`, `qs list --all` |
| Wallpaper | no standalone backend; ii draws it on a `quickshell:background` layer | `hyprctl layers`, `execs.lua` |
| Fonts | Google Sans Flex and Material Symbols Rounded present; Roboto Flex / Roboto Mono absent | `fc-list`, `fc-match` |

## Quickshell APIs verified against installed qmltypes
- `Quickshell.Hyprland`: `Hyprland` singleton (`focusedMonitor`, `focusedWorkspace`,
  `activeToplevel`, `monitors`, `workspaces`, `toplevels`, `rawEvent`, `dispatch()`,
  `monitorFor()`, `refresh*()`, `usingLua`); `HyprlandWorkspace` (`id`, `name`, `active`,
  `focused`, `urgent`, `hasFullscreen`, `monitor`, `toplevels`, `activate()`);
  `HyprlandMonitor` (`name`, `x`, `y`, `width`, `height`, `scale`, `activeWorkspace`,
  `focused`); `HyprlandFocusGrab` (`active`, `windows`, `cleared`); `GlobalShortcut`;
  `HyprlandWindow`.
- Core: `PanelWindow` (`anchors`, `margins`, `exclusiveZone`, `exclusionMode`
  {Normal, Ignore, Auto}, `aboveWindows`, `focusable`), `QsWindow.mask`, `Region`
  (`item`, nested regions), `PopupWindow` + `PopupAnchor`, `Variants`, `Scope`,
  `SystemClock`, `DesktopEntries` (`applications`, `byId`), `Quickshell.iconPath()`.
- `Quickshell.Wayland`: `WlrLayershell` (`layer` {Background, Bottom, Top, Overlay},
  `keyboardFocus` {None, Exclusive, OnDemand}, `namespace`), `BackgroundEffect.blurRegion`
  (present; compositor support unverified).
- Available for later milestones: Services.Mpris, Pipewire, UPower, Notifications,
  SystemTray, Bluetooth, Networking; Widgets (`IconImage`, `ClippingRectangle`, …).

## Compatibility notes
1. Hyprland 0.56 can use a Lua config. `hyprctl dispatch` then takes Lua
   (`hl.dsp.…`), so MELLOW uses `HyprlandWorkspace.activate()` rather than dispatcher strings.
2. QML reserves property names `on` + capital letter for signal handlers, so Material
   `onX` colour roles are exposed as `contentX` (see `core/ColorScheme.qml`).
3. `Palette` collides with QtQuick's built-in type; the generated scheme is `ColorScheme`.
4. `qmllint` cannot resolve Quickshell's runtime `qs.*` imports; the runtime load and
   its log are the authoritative check.
5. Running MELLOW next to another shell stacks exclusive zones (observed on the host:
   reserved top = ii 45 px + MELLOW 56 px).
