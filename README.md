# MELLOW

An original Hyprland-native desktop shell built with Quickshell and QML, in an
"Organic Material" style related to Pixel UI and Material 3 Expressive.

**Status:** milestone M0 (foundation). See `docs/M0_STATUS.md`.

## Quick start (Arch Linux + Hyprland)
```sh
git clone <repo-url> ~/mellow-shell && cd ~/mellow-shell
./install.sh --dry-run   # preview
./install.sh             # quickshell, fonts (per-user), ~/.config/quickshell/mellow symlink
qs -c mellow             # run; Ctrl+C or `qs kill -c mellow` to stop
```
Try it without installing: `qs -p ~/mellow-shell`. Uninstall: `./uninstall.sh`.
Details, rollback and the test checklist are in `docs/RUNNING.md`.

## Documents
- `DESIGN.md`: canonical design and interaction specification.
- `ARCHITECTURE.md`: technical architecture, surfaces and module layout.
- `ROADMAP.md`: milestones and acceptance criteria.
- `CLAUDE.md`: instructions for Claude Code.
- `docs/DECISIONS.md`: approved product decisions.
- `docs/AUDIT.md`: environment audit.
- `docs/RUNNING.md`: install, launch, stop, rollback, test checklist.
- `docs/M0_TASK.md`, `docs/M0_STATUS.md`: current milestone task and status.
- `.claude/IMPLEMENTATION_WORKFLOW.md`: coding workflow.

## Credits
Inspired by Material Design 3, Pixel UI, end-4 and Caelestia (composition) and Ryoku
(wallpaper experience). No code, assets or exact layouts are copied. Fonts are
downloaded from Google Fonts / Material Design Icons under their own licences.
