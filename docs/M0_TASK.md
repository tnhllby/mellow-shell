# M0 Task — Environment Audit and Foundation

## Objective
Create the smallest useful, independently launchable MELLOW prototype in the Arch Linux development VM. Do not implement the full product.

## Phase A — Environment audit (no system changes)

Inspect and report:
1. Distribution and kernel.
2. Hyprland version.
3. Quickshell version and installation source.
4. Qt/QML runtime and relevant module availability.
5. Available Quickshell Hyprland integration APIs.
6. Existing wallpaper backend.
7. Monitor layout and scale.
8. VM Wayland graphics acceleration status.
9. Current shell/panel processes.
10. Relevant existing Hyprland configuration, read-only.

Do not install or modify anything during this phase. Provide exact commands and findings. Distinguish verified facts from assumptions.

## Phase B — Implementation proposal

Propose:
- minimal dependency list;
- QML module imports;
- project structure;
- surface/layer strategy;
- how panel avoids intercepting input;
- how persistent workspace frame avoids stealing input;
- manual launch/stop commands;
- rollback plan.

Wait for approval before system-wide installation or major implementation.

## Phase C — M0 implementation

Implement only:
- project bootstrap;
- centralized theme tokens;
- typography and motion tokens;
- reusable surface/button/icon components;
- full-width panel;
- left Dock placeholder/region;
- center Island compact shell;
- right Control Center trigger;
- clock/date;
- basic Hyprland workspace integration;
- persistent workspace frame prototype.

Dashboard may be a minimal prototype only if core panel is stable.

Do not implement yet:
- full media player;
- wallpaper gallery;
- dynamic wallpaper color extraction;
- full Control Center;
- launcher;
- Overview;
- notification center;
- plugin system.

## Phase D — Verification

Verify:
- shell launches manually;
- shell stops cleanly;
- no critical QML errors;
- all panel zones render;
- workspace state updates;
- keyboard focus is not stolen;
- workspace frame does not intercept clicks;
- fullscreen behavior is documented;
- no host configuration was modified.

If multi-monitor testing is unavailable in the VM, mark it unverified.

## Deliverables
- working M0 code;
- environment audit report;
- dependency list;
- launch/stop instructions;
- rollback instructions;
- screenshots if available;
- known limitations;
- Git commit for the verified milestone.
