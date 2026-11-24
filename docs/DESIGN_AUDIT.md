# Design audit (2026-11-24)

Method: source search over `modules/` and `components/`, plus screenshots of the Launcher,
Overview, Wallpaper Studio and expanded Island (dark and light, isolated copy). Control
Center and pop-ups were seen in this day's earlier tests. Not audited: real pointer and
keyboard use, fractional scaling, Wi-Fi password form. Counts are text matches.

## What is sound (keep)
- No hardcoded colours in modules or components; all text goes through type roles.
- Every duration uses `Motion`, except the decorative seek wave (1600 ms, off with reduced motion).
- Dynamic colour, light/dark cross-fade, blur modes, frame and bar geometry.
- `QuickTile`, `ExpressiveSlider`, `IconBadge` and the Island already feel like one family.

## Findings

| # | Finding | Evidence | Severity |
|---|---|---|---|
| A1 | Floating cards have no shared shape rule | Launcher xl + organic top-left; Control Center xl + md top-right; Dock lg + organic top-right; Island two organic corners; pop-ups and preview mostly lg; Studio xl + organic top-left | High |
| A2 | Same-level cards use different fills and edges | Control Center, Launcher, preview: `surfaceContainer`; Dock, pop-ups, Island: `surfaceContainerHigh`. Edge: 2 px band everywhere except the Launcher's 1 px outline (chosen by the user) | Medium |
| A3 | Wallpaper Studio looks like a plain dialog | No edge band, small labels in an empty right column, gallery row cut at the bottom | High |
| A4 | Motion has durations but no grammar | 22 `{ duration }` animations in 17 files set no easing (linear); Launcher slides 220 ms with fade, Control Center 320 ms without; Control Center uses the decelerate curve for closing too | High |
| A5 | Colour hierarchy is narrow | `contentSurfaceVariant` 42 uses, `tertiary` 1, `primaryContainer` 2: most surfaces read as grey plus one accent | Medium |
| A6 | Type hierarchy is flat | `labelLarge` 17 uses, `headlineMedium` 1, display roles 0; no emphasised weight | Medium |
| A7 | Icon sizes lack a scale | Sizes 16, 18, 20, 22, 28 and 32 set per use | Low |
| A8 | No tooltips at all | DESIGN §12 asks for status labels/tooltips; bar icons are unlabelled for pointer users | Medium |
| A9 | Interaction states differ | No `StateLayer` in `MSwitch`, `ExpressiveSlider`, Studio swatches, Gallery; no `FocusRing` in the bar (which never takes focus). Some may show state another way; check each | Medium |
| A10 | Light Overview mixes black scrim with solid white cards | Empty workspaces are the brightest thing on screen | Medium |
| A11 | Launcher grid ends in a cut row | Bottom row of labels is clipped with no fade or hint to scroll | Low |
| A12 | Stray numbers | `WindowCard` radius 12, margins/spacings of 2, 3 and -8 | Low |

## Functional risks found on the way (not design; no code changed)
- **Scheme cache ignores the scheme type.** `WallpaperService` caches by image/seed only,
  so changing `wallpaper.schemeType` live returns the old result until restart.
- **`theme.mode` is only the first-run value**; `ThemeState` owns the current mode. As a
  setting it would look like a switch that does nothing.
- **Keybind apps and `launcher.terminal` are unrelated**: keybinds run kitty, Firefox and
  Dolphin directly from `hypr/keybinds.lua`.
- `mellow:settings` (Meta+I) is bound but nothing registers it yet.
