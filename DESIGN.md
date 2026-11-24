# MELLOW Design System

**Version:** 1.0  
**Status:** Approved product direction  
**Platform:** Arch Linux / EndeavourOS, Hyprland, Wayland  
**Framework:** Quickshell + QtQuick/QML  
**Direction:** Organic Material

## 1. Product identity

MELLOW is an original desktop shell that should feel as though it belongs to the same broad design family as Google Pixel UI, while remaining recognizably its own product.

The intended impression: a desktop interface that could plausibly have been designed by the same design team as Pixel UI, adapted for keyboard-and-mouse use and given its own personality.

### Inspiration, not templates
- **Material Design 3 / Material You / Material 3 Expressive:** semantic color, tonal surfaces, expressive typography, component states, shape language and motion.
- **Pixel UI:** interaction clarity, Quick Settings, media controls, launcher and overview.
- **end-4 and Caelestia:** desktop composition, modularity and system integration.
- **Ryoku:** inspiration specifically for the wallpaper customization experience.

Do not reproduce another project's code, assets, exact layouts or component designs.

## 2. Design principles
1. Recognizable identity: a coherent visual signature, not unrelated widgets.
2. Material first: shared design tokens and consistent component behavior.
3. Organic, not chaotic: asymmetry is intentional and governed by layout rules.
4. Depth over flatness: tonal layering, restrained shadows, optional blur and dimensional iconography.
5. Functional clarity: every control communicates purpose and state.
6. Core before novelty: essential desktop workflows outrank decorative modules.
7. Keyboard and pointer parity for all core actions.
8. Motion explains state changes and never delays interaction.
9. Adaptive colors are semantic and contrast-checked.
10. Blur, intensive animation and decorative effects are optional.

## 3. Desktop composition

MELLOW has a full-width top panel with three zones:
- **Left:** workspace indicator in the top-left corner; inactive workspaces show their number, the active one shows the icon of its main app (the last focused window there), or its number when empty.
- **Center:** MELLOW Island.
- **Right:** clock/date, system status and Pixel-inspired Quick Settings entry point.

The usable workspace has a persistent frame around its perimeter. This is a defining MELLOW visual element.

### 3.1 Full-width panel
Height: 44 logical pixels (configurable in `Config.panel.height`, scale-aware).

The panel must align all three zones, avoid crowding at narrow resolutions, support multiple monitors, and expose hover/focus/pressed/active/disabled states. It must remain visually subordinate to applications.

### 3.2 Dock (left screen edge)
A compact vertical set of pinned applications on the left edge of the screen, outside
the panel. The panel's left zone holds the workspace indicator.

Required behavior:
- appears when pointer approaches the configured screen edge or activation region;
- can be pinned open or set to auto-hide;
- shows running indicators;
- launches applications;
- supports keyboard navigation;
- does not obstruct normal window interaction when hidden.

Test edge activation and exclusive-zone behavior with Hyprland. Provide a configurable activation fallback; do not create hover traps.

### 3.3 Center zone — MELLOW Island
MELLOW Island is the signature element.

**Media mode**
- prioritized whenever a media session is actively playing;
- compact state displays artwork or media marker, track title and artist where space permits;
- clicking expands it into a full Material-inspired player;
- expanded state includes artwork, metadata, previous/play-pause/next, session/output information where available, and a prominent seek control.

**Ambient mode**
- shown when no media session is actively playing;
- displays a restrained system summary, not a wall of metrics;
- candidate metrics: CPU load, memory use, temperature when available, or a subtle activity visualization;
- use stable priority and graceful fallback if sensors are unavailable.

Media mode lingers for a short grace period after playback pauses (default 2 min) so
it can be resumed; after that a small note glyph in Ambient Mode shows that clicking the
Island still opens the player.

The seek control uses a thick expressive progress line with waveform-like styling.
MELLOW uses a Material 3 Expressive wavy line for the played part; its motion only
signals that playback is running. If real waveform data is unavailable, use a restrained deterministic visual representation and never imply it is actual audio analysis.

The compact Island should morph into the expanded player as one coherent surface.

### 3.4 Right zone — System controls
Contains status indicators and Control Center trigger. Control Center is inspired by Pixel Quick Settings, adapted for desktop.

It is a full-height panel that slides in from the right edge: quick controls at the top,
then media controls and the notification center, which scroll.

Potential controls:
- Wi-Fi/network;
- Bluetooth;
- audio output and volume;
- microphone state where supported;
- brightness where supported;
- battery/power;
- Do Not Disturb/notification state;
- Night Light/color temperature if available;
- access to system settings.

Only expose actions supported by the host. Never show fake toggles. Include a prominent entry to Wallpaper Studio.

## 4. Persistent workspace frame

A thin frame surrounds the entire usable workspace continuously, not only in Overview.

Requirements:
- follows monitor/workspace geometry;
- respects panel reservations and screen scaling;
- does not steal input, obstruct windows or create accidental resize regions;
- no inner outline: the chrome alone defines the edge (outline removed after testing);
- thickness and color are theme tokens;
- user can disable it;
- fullscreen policy must be defined and tested.

Default proposal: hide or reduce the frame for true fullscreen surfaces, configurable by the user.

## 5. Launcher and Overview

### 5.1 Application Launcher
Default activation: Meta. Appears from the bottom.

Core functions:
- application search and launch;
- pinned/favorite applications;
- recent applications only if reliable data is available;
- keyboard-first navigation;
- clear empty/loading/no-results states.

Do not add file search, web search, arbitrary command execution or plugin discovery in the initial launcher.

### 5.2 Workspace / window Overview
Default activation: Meta+Tab.

Shows workspaces as distinct preview regions and windows grouped by workspace. Active window is clearly marked. Provide focus and close actions. Drag-and-drop between workspaces may be added only if reliable.

Use Pixel-inspired expressive window cards, but preserve readable titles and usability. The persistent workspace frame remains part of the desktop identity; Overview may emphasize the selected workspace or monitor.

## 6. Wallpaper Studio

A first-class customization module inspired by polished mobile wallpaper pickers, adapted for desktop and multiple monitors.

Required capabilities:
- wallpaper gallery with large previews;
- import/select local images;
- preview per monitor;
- Fill/Fit/Center/Span placement modes where supported;
- apply through configured wallpaper backend;
- derive seed color and generate tonal palette;
- preview light and dark variants;
- manual seed/accent override;
- save and restore named theme presets;
- live preview of panel, Island, Control Center, cards and buttons.

This is planned after the shell foundation and core controls. Do not block M0 on it.

## 7. Color system

Use semantic roles, never arbitrary per-component colors.

Required roles:
In QML the `onX` roles are named `contentX` (e.g. `contentPrimary`), because QML
reserves `on` + capital letter for signal handlers.

- primary / onPrimary / primaryContainer / onPrimaryContainer
- secondary / onSecondary / secondaryContainer / onSecondaryContainer
- tertiary / onTertiary / tertiaryContainer / onTertiaryContainer
- background / onBackground
- surface / onSurface
- surfaceVariant / onSurfaceVariant
- surfaceContainer / surfaceContainerHigh / surfaceContainerHighest
- outline / outlineVariant
- error / onError / errorContainer

Dark theme is the initial default; light theme is supported. Wallpaper-derived seed colors generate tonal palettes. Contrast and text legibility must be checked. Components consume tokens from one centralized theme provider. Manual seed override is supported. Theme updates should animate without requiring restart where practical.

Do not simply pick five dominant RGB colors and call it Material You. Use a validated tonal-palette approach or a documented compatible implementation.

## 8. Shape, spacing and typography

### Shape tokens
- xs: 6 px
- sm: 10 px
- md: 16 px
- lg: 22 px
- xl: 30 px
- organic: 38 px
- pill: fully rounded

Use varied radii intentionally. Do not apply the same pill shape to everything.

### Spacing
4 px base unit: 4, 8, 12, 16, 20, 24, 32, 40, 48.

### Typography
Preferred primary family: Google Sans Flex, then Roboto Flex, with reliable system fallback. Preferred monospace: Roboto Mono, with fallback.

Define semantic roles: displayLarge/Medium, headlineLarge/Medium, titleLarge/Medium, bodyLarge/Medium/Small, labelLarge/Medium/Small.

## 9. Icons and dimensionality

Preferred icon direction: Material Symbols Rounded or another consistent Material-compatible family. Use filled/rounded forms where appropriate, distinguish active/inactive states, and use restrained tonal/two-tone treatment. Use original application icons for apps.

Avoid mixing unrelated icon packs. Do not use emoji as production UI icons.

Create depth through tonal layering, restrained elevation/shadows, optional blur, subtle highlights and foreground/background separation. Avoid excessive glassmorphism.

## 10. Blur and effects

Blur is optional and configurable:
- Off;
- Subtle;
- Expressive.

Use compositor-supported capabilities where possible. Do not apply expensive per-frame software blur to every surface. Provide fallbacks for unsupported configurations and lower-powered graphics. The shell must remain usable with blur disabled.

## 11. Motion

Initial targets:
- hover: 120 ms;
- press: 100 ms;
- card appearance: 220 ms;
- panel/module transition: 320 ms;
- workspace/overview transition: 360 ms;
- theme transition: 450 ms.

Use consistent easing curves and interruptible transitions. Input must not be blocked by animation. Provide reduced-motion settings.

## 12. Accessibility and usability

- visible keyboard focus;
- readable contrast;
- keyboard navigation for core modules;
- configurable keybindings;
- no essential action available only through hover;
- scalable UI;
- reduced motion;
- blur-off mode;
- clear status labels/tooltips;
- do not rely on color alone to communicate state.

## 13. Anti-feature-bloat policy

MELLOW is not an overloaded widget collection.

Do not add decorative widgets without a concrete purpose, redundant controls, complex plugin systems before core stability, fake system toggles, excessive animation settings, or features merely because they are technically possible.

Before proposing a feature, explain the user problem, why existing modules do not solve it, its maintenance cost, and whether it belongs in the current milestone.

## 14. Design acceptance

A module is not design-complete until it uses semantic tokens, has appropriate interaction states, supports dark/light themes, respects reduced motion, works with blur disabled, documents keyboard and pointer interactions, has been checked at multiple display scales, and remains visually consistent with MELLOW.
