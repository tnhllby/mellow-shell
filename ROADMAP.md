# MELLOW Roadmap

Prioritize a useful desktop shell over feature quantity.

## M0 — Foundation
Deliver:
- project bootstrap;
- verified Quickshell environment;
- centralized theme tokens;
- typography and motion tokens;
- reusable Material-inspired components;
- full-width top panel;
- left Dock region;
- center Island shell;
- right Control Center trigger;
- clock/date;
- basic Hyprland workspace integration;
- persistent workspace frame prototype;
- manual launch and rollback instructions.

Acceptance:
- no critical QML errors;
- shell starts/stops manually;
- no existing host configuration is overwritten;
- all three panel zones render;
- workspace state updates;
- frame does not steal input;
- fullscreen behavior is documented;
- multi-monitor behavior is tested or explicitly marked unverified.

## M1 — Hyprland Integration
Deliver centralized Hyprland state, workspace events/switching, active window, monitor detection, window list and reliable keybinding entry points.

Acceptance: no per-widget `hyprctl` polling; event-driven updates where supported; graceful failure.

## M2 — MELLOW Island
Deliver compact media state, MPRIS, expanded player, transport controls, seek control, waveform-style visualization and Ambient Mode fallback.

Acceptance: media changes update Island; no active session shows Ambient Mode; missing metadata is handled; fabricated waveform is not represented as real analysis; keyboard and pointer work.

## M3 — Control Center and Wallpaper Studio
Deliver Pixel-inspired Quick Settings, supported system controls, wallpaper gallery/preview/apply, initial seed-color generation and theme preview.

Acceptance: no fake toggles; unsupported controls are hidden or marked unavailable; wallpaper can be reverted; contrast is checked.

## M4 — Launcher, Dock and Overview
Deliver Meta launcher, application search/launch, pinned apps, Dock auto-hide/activation, Meta+Tab Overview, workspace/window cards, focus/close actions and reliable window movement if feasible.

Acceptance: keyboard-first use works; no hover-only essential controls; launcher does not interfere with typing; Overview reflects actual Hyprland state.

## M5 — Visual polish
Deliver light/dark refinement, wallpaper palette improvements, blur modes, dimensional iconography, animation refinement, reduced-motion support, frame refinement and multi-monitor polish.

Acceptance: usable with blur off and reduced motion; consistent states; animation never blocks input.

## M6 — Settings and release
Deliver settings UI, validated configuration, theme presets, docs, install/uninstall instructions, diagnostics and performance review. The installer sets up MELLOW's Hyprland keybindings (sourced snippet, backed up, removable by `uninstall.sh`) so users do not bind anything manually.

Acceptance: fresh-install procedure verified in clean VM snapshot; rollback verified; limitations documented; no host-specific required paths.
