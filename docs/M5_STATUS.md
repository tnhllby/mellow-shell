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

- Control Center blur missed its left ~16 px: the region took the card position from
  `mapToItem`, which includes the closed card's 0.96 scale, and was never re-measured.
  It now uses plain x/y (+ an explicit parent offset for the nested Dock card).
- Outline back on Control Center, Launcher and Dock, faint (`Theme.cardOutline`,
  outlineVariant at 35 %): without it the edges looked too sharp.

## Remaining M5 items
- None to build; the unverified items in this file and the RUNNING.md checklists remain.

## Workspace slots, hover preview, softer edges (2026-11-22)
- Overview: workspaces 1–6 always have a card (`Config.overview.defaultWorkspaces`);
  missing ones are empty cards you can click or drop a window on. "New workspace"
  takes the next id after them.
- Bar: resting the pointer 300 ms on an inactive workspace number shows a preview card
  under it with still captures of that workspace's windows, its number and the main
  window's title. Click-through; moving along the strip switches it.
- Island and Dock (and Control Center): 2 px edge band in the card's own colour,
  halfway between the card's opacity and opaque, over the 1 px blur inset. Measured
  on the live Island: the jagged dark hairline at the organic corners is now a soft
  band; a tinted 96 % band read as a visible ring and was dropped. Dock edge: the
  blurred-wallpaper pixels along the edge are gone.
- Verified in the non-interactive copy (dark and light): Overview slots, preview card
  with a faked hover on workspace 3 (capture, number, icon, title), Dock edge; no
  warnings. Not verified: hover with a real pointer, preview timing and switching.

## Dimensional iconography (2026-11-23)
- `MaterialIcon`: fill and weight ease over `Motion.hover` (instant with reduced
  motion), so a toggled icon inks in; filled icons are weight 500 (state not by fill and
  colour alone); grade −25 in dark mode to even out light-on-dark glyphs.
- `components/IconBadge`: tonal square behind a state icon with a faint highlight from
  above (`Theme.iconHighlight`, near-white at 8 % dark / 20 % light, fading by mid
  height). Used by Quick Settings tiles and the Wi-Fi/Bluetooth list rows (36 px,
  `secondary` when highlighted). App icons are unchanged.
- Verified in the non-interactive copy (dark and light): Control Center main page and
  Bluetooth page, no warnings; fractional FILL/wght render as in-between glyphs with
  the installed font (standalone test). Not verified on screen: the fill animation
  itself while toggling a tile.
- Seen once: after adding a component file, a live reload failed ("X is not a type");
  the next reload worked. Cause unverified.

## Control Center panel (2026-11-24; pop-ups followed, see M6_STATUS.md)
- Full-height panel (420 px, `Config.controlCenter.width`) sliding in from the right;
  all previous controls (Wallpaper & style is now a tile), media card, notification
  center (actions, dismiss, clear all, urgent marking, scrolling).
- Verified in the non-interactive copy, 1366x768 and 1920x1080, dark and light: slide
  in/out, blur only at rest, real notifications on a private D-Bus (icons, actions shown,
  plain text, transient skipped, clear all), fake MPRIS player with seek line and the
  host's real player, Wi-Fi and Bluetooth pages, and the "another program" state with
  `ii` as owner. No new QML warnings.
- Not verified: pointer/keyboard use (scrolling, dismissing, actions, focus), taking over
  when the other program exits, config reload with kept notifications.
- Seen once: the copy's isolated `theme.json` went from light to dark; not reproduced.

## Theme transition, frame and multi-monitor (2026-11-24)
- `ThemeColors` cross-fades all roles (`animate`, 450 ms); `Theme.transitioning` switches
  off per-component colour animations meanwhile (they kept restarting and froze tiles
  in the old theme). No fade at startup or in the Studio preview; instant with reduced
  motion. Text briefly loses contrast mid-fade, as any light/dark cross-fade does.
- Measured with both monitors and the Control Center open: 27-28 frames per 450 ms
  fade, worst frame 34 ms; about 0.37 s CPU per change.
- Frame: hiding for fullscreen and coming back restores the blur (pixel-identical,
  simulated fullscreen flag); no change needed.
- `ShellState` clears surfaces open on an unplugged monitor, so they do not reopen when
  it returns. Not verified (needs a hot-plug). Fractional scales also not verified.
