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

## Remaining M5 items
- Frame and multi-monitor polish; dimensional iconography; theme-change animation.
