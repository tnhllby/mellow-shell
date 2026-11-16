# Running, testing and rolling back MELLOW

## Requirements
- Arch Linux with Hyprland (tested with 0.56.2).
- Quickshell ≥ 0.3.2 (`quickshell` in the extra repository).
- Optional fonts: Google Sans Flex, Roboto Flex, Roboto Mono, Material Symbols Rounded.
  Without them text falls back to Noto Sans; without Material Symbols icons are blank.

No other dependencies. `tools/gen-palette.py` needs `matugen`, but only to regenerate the
colour scheme during development.

## Install on the test machine
```sh
git clone <repo-url> ~/mellow-shell
cd ~/mellow-shell
./install.sh --dry-run     # shows every step, changes nothing
./install.sh               # quickshell (sudo pacman), fonts (~/.local/share/fonts/mellow), config symlink
```
Individual steps: `./install.sh --deps`, `--fonts`, `--link`; `-y` skips prompts.

The installer never edits Hyprland configuration and does not enable autostart.

## Launch / stop
| Action | Installed | Straight from the repo |
|---|---|---|
| Start (foreground) | `qs -c mellow` | `qs -p ~/mellow-shell` |
| Start (detached) | `qs -c mellow -d` | `qs -p ~/mellow-shell -d` |
| Stop | `qs kill -c mellow` or Ctrl+C | `qs kill -p ~/mellow-shell` |
| Logs | `qs log -c mellow` | `qs log -p ~/mellow-shell` |

Quickshell reloads QML automatically when files change, so `git pull` on the test machine
updates a running shell.

Stop other bars first (`pkill waybar`, `qs kill -c <other>`), otherwise their exclusive
zones stack with MELLOW's.

Optional autostart, added by you:
```
# hyprland.conf
exec-once = qs -c mellow
-- hyprland.lua
hl.on("hyprland.start", function() hl.exec_cmd("qs -c mellow") end)
```

## Rollback
1. `qs kill -c mellow`. All MELLOW surfaces and reserved space disappear immediately.
2. `./uninstall.sh` removes the config symlink and (after asking) the fonts.
3. Remove the autostart line if you added one. Optionally `sudo pacman -Rns quickshell`.

MELLOW writes nothing else to the system.

## M0 test checklist (test machine)
Run `qs -p ~/mellow-shell` in a terminal and watch for `WARN`/`ERROR` lines.

- [ ] Panel spans the top of every monitor; workspaces left, Island centre, Control Center button right.
- [ ] Switching workspaces (keyboard or clicking a pill) moves the highlighted pill; scrolling over the strip cycles workspaces.
- [ ] Focused monitor's active pill is primary-coloured; the other monitor's is tonal.
- [ ] Frame visible on left/right/bottom, rounded inner corners, continuous with the panel.
- [ ] Tiled windows sit inside the frame, never under it.
- [ ] Clicking/dragging on the frame does nothing (no focus change, no resize handles).
- [ ] Fullscreen a window (`fullscreen` bind): frame hides; leaving fullscreen brings it back.
- [ ] Moving the pointer to the very left screen edge slides the Dock in; leaving it hides the Dock after ~0.5 s.
- [ ] Clicking a Dock icon launches the app.
- [ ] Control Center button opens the popup; Escape, clicking outside, or the button again closes it.
- [ ] Typing in a window is never interrupted while the popup is closed.
- [ ] Plug/unplug a monitor: surfaces appear/disappear without errors.
- [ ] `qs kill -c mellow` stops cleanly and reserved space returns to zero (`hyprctl monitors`).
