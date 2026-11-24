# MELLOW — Confirmed Decisions

## Product
- Name: MELLOW.
- MELLOW is a desktop shell, not merely a widget pack.
- Target compositor: Hyprland.
- Development: on the developer's host, inside the repository only (never its `~/.config`).
- Testing: a separate PC with clean Arch Linux + Hyprland, installed via `install.sh`.
- Framework: Quickshell + QML.
- Initial launch: manual; no autostart until approved.
- Final installer (M6) configures Hyprland itself so users bind nothing by hand: it
  adds MELLOW's keybindings (and, with consent, autostart) as a separate file sourced
  from the user's Hyprland config (Lua only: Hyprland 0.57 no longer reads hyprland.conf), backs up the original, and
  `uninstall.sh` removes it again. Until then binds are added manually.

## Visual identity
- Direction: Organic Material.
- Must feel related to Pixel UI, but remain original.
- Use Material Design 3 / Material You / Material 3 Expressive principles.
- Shared stylistic inspiration from end-4 and Caelestia without copying.
- Ryoku is a reference for Wallpaper Studio's experience only.

## Panel
- Full-width top panel.
- Left (top-left corner): workspace indicator; the active workspace shows its main app's icon, inactive ones their number. (2026-11-19: the separate active-window icon + title was removed.)
- Bar 44 px (2026-11-19, was 52). Bar pills, Island and Control Center trigger are translucent over the blur.
- Workspace corners: top fillets and bottom inner corners share one radius, outer − frame thickness (18 px).
- Floating cards (Control Center, Launcher, Dock) have a faint hairline (`Theme.cardOutline`, outlineVariant at 35 %); without any outline the edges looked too sharp. Overview keeps borders as selection/active markers.
- Center: MELLOW Island.
- Right: Pixel-inspired Quick Settings / Control Center. (2026-11-24) The Control Center is a full-height panel from the right edge with quick controls, media controls and the notification center; Wallpaper Studio's entry is a tile.

## Dock
- Pinned-app Dock on the left screen edge (vertical), appearing on edge interaction.
  (2026-11-16: moved out of the panel's left zone.)

## Fonts
- Pixel / end-4 family: Google Sans Flex (primary), Roboto Flex, Roboto Mono,
  Material Symbols Rounded. Installed per-user by `install.sh`, never bundled.

## Island
- Media is the priority state (with a short grace period after pausing).
- The clock lives in the panel's right zone; the Island's ambient state shows CPU, memory and temperature.
- When no media session is actively playing, show system statistics.
- Clicking compact Island expands a full player.
- Expanded player uses an expressive thick seek line with waveform-like styling.
- Do not represent fabricated waveform as actual audio analysis.

## Workspace frame
- A frame surrounds the entire usable workspace continuously.
- It is a defining visual element.
- It must not steal input or obstruct windows.
- Fullscreen behavior must be designed and tested.
- A setting to disable it is recommended.

## Launcher and Overview
- Meta opens application launcher from bottom.
- Meta+Tab opens workspace/window Overview.
- Overview is Pixel-inspired with expressive window cards.

## Effects
- Blur is optional: Off, Subtle, Expressive. (M5) Implemented through the
  ext-background-effect protocol (Quickshell `BackgroundEffect.blurRegion`, supported by
  Hyprland 0.56), so no Hyprland layer rules are needed. Default Subtle; it falls back to
  Off while Hyprland's `decoration:blur:enabled` is false, so cards are never translucent
  without blur. Blur strength and xray come from the user's Hyprland blur settings.
  The compact Island stays opaque on the bar in every mode. (2026-11-19) The bar and
  frame chrome are translucent with blur too (0.85 Subtle, 0.70 Expressive), with blur
  regions matching their exact shape (rounded outer corners, concave fillets, frame
  ring). Blur of live windows (not just the wallpaper) needs a Hyprland layer rule
  `xray = false` for `^mellow:` namespaces; the M6 installer adds it with the keybinds.
- Reduced-motion mode is required.
- Shell remains usable without blur.

## Product philosophy
- Core functionality before decoration.
- Avoid feature bloat.
- No feature without a concrete user problem.
- All core actions support keyboard and pointer.

## Installer and app theming (2026-11-24)
- The installer also installs kitty, Firefox (default browser), Dolphin and Gwenview.
- App theming uses matugen with MELLOW's own templates, off unless `theming.apps` is set.
- Window decorations and autostart are asked about, never assumed.

## Bar, Settings and Dashboard (2026-11-24)
- The bar gains useful elements (apps, Overview, metrics, tray, battery percentage); it
  stays 44 px with the Island centred. Elements give way before they reach the Island.
- Settings is a normal window with a Dashboard (user picture, system facts and load).
- `shell.qml` uses `UseQApplication`: tray menus need it.
