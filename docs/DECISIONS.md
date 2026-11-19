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
  from the user's Hyprland config (classic or Lua), backs up the original, and
  `uninstall.sh` removes it again. Until then binds are added manually.

## Visual identity
- Direction: Organic Material.
- Must feel related to Pixel UI, but remain original.
- Use Material Design 3 / Material You / Material 3 Expressive principles.
- Shared stylistic inspiration from end-4 and Caelestia without copying.
- Ryoku is a reference for Wallpaper Studio's experience only.

## Panel
- Full-width top panel.
- Left (top-left corner): workspace indicator, then the active window's icon and title. Revisit if it does not look right.
- Center: MELLOW Island.
- Right: Pixel-inspired Quick Settings / Control Center.

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
