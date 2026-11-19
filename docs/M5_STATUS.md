# M5 Status — Visual polish (in progress)

## Implemented
- Light/dark pass: every surface rendered in both modes. Overview text (selected window
  title, key hint) now sits on surface chips instead of the scrim, and the "New
  workspace" slot has a near-opaque fill; both were unreadable in light mode.
- Contrast check (`ColorUtil.textPairs`) now covers the pairs MELLOW actually draws
  (content on surfaceContainer/Low/Highest, error). All six preset seeds pass in both
  modes with tonal-spot schemes (lowest 6.4:1).
- Blur modes Off / Subtle / Expressive (`Config.effects.blur`, default "subtle") via
  `BackgroundEffect.blurRegion` with rounded regions matching each card.
  `Theme.effects` + `Theme.glass()` give translucency; `HyprlandService.blurEnabled`
  (read on startup and `configreloaded`) forces Off when the compositor does not blur.
- Reduced motion: all animations use `Motion` tokens (audited); input regions follow
  the open state immediately, so no animation blocks input.

## Verified on the development host (non-interactive copy, screenshots)
- Light and dark renders of Control Center, Launcher, Island, Studio, Overview, Dock.
- Hyprland 0.56.2 blurs a layer surface through the protocol, with rounded regions
  (standalone test), and MELLOW's cards in Subtle and Expressive (dark and light).
- Reduced motion: launcher fully shown 60 ms after opening; normal motion not yet.
- No QML warnings in any run.

## Unverified
- Toggling Hyprland blur at runtime (configreloaded path).
- Blur region following the cards during animations (only static states captured).
- All interaction on the test machine (docs/RUNNING.md M5 checklist).

## Fixes after the first test run
- A blurred strip covered the left ~84 px of the screen (bar and windows) whenever the
  Dock was hidden: its blur region followed the card off the surface, and Hyprland
  then blurred the whole Dock surface. The region now exists only while the Dock is
  shown and has slid fully in.
- The shown Dock was never blurred: its window was hidden/re-shown whenever the app
  list reloaded (`visible: apps.length > 0`), and the re-created surface lost its blur
  region. The Dock window now stays mapped (an empty Dock simply never slides in).
- Control Center showed a blurred block before the card: the blur region ignores the
  card's scale/opacity animation. Control Center, Launcher and Overview now blur only
  once fully open, and drop the blur as soon as closing starts.
- Verified in a non-interactive copy with screenshot bursts during opening: no blur
  ahead of the Control Center/Launcher card; Dock card blurred once in place.
- Lesson: a blur region must only describe a settled, on-surface item, and blurred
  surfaces must stay mapped (no `visible` toggling).

## Translucent chrome (2026-11-19)
- Bar and frame are translucent over a blur (`Theme.effects.chromeOpacity`), with blur
  regions built from Region subtraction so the blur follows the rounded outer corners,
  the concave fillets and the frame ring exactly.
- Verified in a non-interactive copy (Expressive, dark): corners and fillets clean, no
  blur outside the chrome, no warnings. Your live session reloaded it in Subtle.
- Live-window blur needs the Hyprland `xray = false` layer rule (docs/RUNNING.md); not
  tested, because it means changing the host's Hyprland config.

## Bar refresh (2026-11-19)
- Bar 44 px; pill sizes derive from it (`Theme.barPill`). Workspace buttons show the
  icon of the workspace's main app (`HyprlandService.mainWindowOn`, last focused window
  tracked from focus changes); the active-window title is gone.
- Workspace strip, status pill and compact Island are translucent; the Island blurs
  in compact and expanded state.
- Top fillets now 18 px like the bottom inner corners (`Theme.chromeShape.innerRadius`).
- Outlines removed from Control Center, Launcher and Dock cards.
- Verified in a non-interactive copy (dark and light): icons per workspace, no
  outlines, no warnings. Not verified: icon updates while switching/moving windows.

## Follow-up (2026-11-19, evening)
- Light rim around blurred cards after the outlines were removed: the card's
  antialiased edge is partly transparent, and the blurred backdrop under it (the
  wallpaper while Hyprland's xray is on) showed through. `components/CardBlurRegion`
  insets each card's blur region by 1 px (Control Center, Launcher, Dock, Island).
  Measured across the Control Center's bottom edge: the edge row now shows the real
  background instead of the blur.
- Workspace strip: inactive workspaces show their number; the active one shows its
  main app's icon (number when empty). Active/urgent pills are translucent too.

## Remaining M5 items
- Frame and multi-monitor polish; dimensional iconography; theme-change animation.
