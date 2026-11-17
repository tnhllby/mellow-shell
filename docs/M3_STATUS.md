# M3 Status — Control Center and Wallpaper Studio

## Implemented
- Control Center (panel trigger → popup) with real controls only:
  brightness and volume sliders, Internet / Bluetooth / Microphone / Power mode /
  Dark theme tiles, Wi-Fi and Bluetooth detail pages, battery header and a
  "Wallpaper & style" entry. Controls whose service is missing are hidden; Bluetooth
  pairing and enterprise Wi-Fi are explicitly marked as out of scope in the UI.
- Panel trigger shows live status icons (network, Bluetooth, mute, battery).
- Persistent theme state (`~/.local/state/mellow/theme.json`): dark/light mode and an
  optional generated scheme; the whole shell recolours live.
- Wallpaper Studio: gallery (configurable folders), per-display or all-display target,
  Fill/Fit/Center, colours from the wallpaper (matugen) or seed chips (wallpaper
  swatches via ColorQuantizer + presets), dark/light preview on a miniature MELLOW
  desktop, WCAG contrast line, Apply and one-step Revert.
- MELLOW wallpaper surface on the background layer (only drawn once a wallpaper is set).
- New entry points: `mellow:studio` shortcut; IPC `openStudio`, `toggleTheme`.
- `install.sh --deps` also offers matugen.

## Verified on the development host
- Loads with no QML warnings (besides Qt's benign `textinput` message; the
  `QT_LOGGING_RULES` pragma was removed because it did not take effect reliably,
  `--log-rules` is documented instead).
- Live service values: battery 100 % full, power profiles present, Wi-Fi connected
  ("Megaline"), Bluetooth adapter with paired devices, default sink + volume.
- Brightness write path: logind `SetBrightness` succeeded (no-op value).
- Control Center main page and Wi-Fi page rendered in a non-interactive copy (screenshots).
- Wallpaper Studio rendered in a click-through copy: gallery of `~/Pictures/Wallpapers`,
  wallpaper preview, matugen scheme (dark/light), contrast line (6.5:1 lowest).
- Headless apply → persist → revert in an isolated state directory: wallpaper entry,
  scheme and `canRevert` set, then restored to the built-in scheme.

## Unverified (test machine; docs/RUNNING.md M3 checklist)
- All pointer/keyboard interaction (nothing was clicked or typed on the host).
- Actually changing volume, brightness, Wi-Fi, Bluetooth, power profile, connecting
  to networks, password entry.
- The wallpaper surface on screen (disabled on the host to avoid covering its wallpaper).

## Fixes after the first test-machine run
- Control Center vanished on any click: it was an xdg-popup, and Hyprland's focus grab
  counts clicks inside a layer-shell popup as outside clicks. It is now a layer surface
  (`mellow:control-center`) like the Island, input region = the card.
- Wallpaper Studio could not be opened from the Control Center (same cause); its surface
  now also stays mapped so the focus grab never races surface creation.
- Frame disappeared with maximized windows: Hyprland's `hasfullscreen` includes
  maximize. The frame now hides only for real fullscreen (per-window mode bit 2).

## Known limitations
- Revert keeps one step of history.
- "Span across displays" placement is not offered.
- External-monitor brightness (DDC/CI) is not supported.
- Do-not-disturb and night light are not shown (no backing service yet).
