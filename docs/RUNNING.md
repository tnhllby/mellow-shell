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

## Keybindings (optional, added by you)
Until the M6 installer sets these up automatically, MELLOW registers Hyprland global shortcuts; bind keys to them in your config:
```
# hyprland.conf
bind = SUPER, C, global, mellow:controlCenter
bind = SUPER, D, global, mellow:dock
bind = SUPER, M, global, mellow:island
bind = , XF86AudioPlay, global, mellow:mediaPlayPause
bind = , XF86AudioNext, global, mellow:mediaNext
bind = , XF86AudioPrev, global, mellow:mediaPrevious
bind = , Escape, global, mellow:closeAll     # optional; Escape already closes focused popups
-- hyprland.lua
hl.bind("SUPER + C", hl.dsp.global("mellow:controlCenter"))
hl.bind("SUPER + D", hl.dsp.global("mellow:dock"))
```
`hyprctl globalshortcuts | grep mellow` lists them. The same actions are available over IPC:
`qs -c mellow ipc call mellow toggleControlCenter` (`qs -c mellow ipc show` lists all).

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
- [ ] Frame visible on left/right/bottom, rounded inner fillets and rounded outer screen corners, continuous with the panel's rounded top corners.
- [ ] Tiled windows sit inside the frame, never under it.
- [ ] Clicking/dragging on the frame does nothing (no focus change, no resize handles).
- [ ] Fullscreen a window (`fullscreen` bind): frame hides; leaving fullscreen brings it back.
- [ ] Moving the pointer to the very left screen edge slides the Dock in, and it stays while the pointer rests on the edge or the Dock; moving right past the Dock hides it after ~0.5 s.
- [ ] Clicking a Dock icon launches the app.
- [ ] Control Center button opens the popup; Escape, clicking outside, or the button again closes it.
- [ ] Typing in a window is never interrupted while the popup is closed.
- [ ] Plug/unplug a monitor: surfaces appear/disappear without errors.
- [ ] `qs kill -c mellow` stops cleanly and reserved space returns to zero (`hyprctl monitors`).

## M1 test checklist (test machine)
- [ ] With the binds above: SUPER+C toggles the Control Center on the focused monitor; Escape closes it.
- [ ] SUPER+D opens the Dock with the first app focused; Up/Down/Tab move the focus ring, Enter launches and closes the Dock, Escape or a click elsewhere closes it.
- [ ] `qs -c mellow ipc call mellow focusWorkspace 7` switches to (and creates) workspace 7.
- [ ] Clicking a workspace pill and scrolling over the strip switch workspaces (classic `hyprland.conf` dispatch path).
- [ ] The active window's icon and title follow focus, appear only on that window's monitor, and elide on narrow screens.
- [ ] Opening/closing/moving windows and workspaces updates the strip immediately (no delay, no polling).
- [ ] `hyprctl reload` and monitor hot-plug leave MELLOW working with no errors in the log.

## M2 test checklist (test machine)
- [ ] Start music (browser, mpv, Spotify…): the Island switches to artwork + title + artist with a progress hairline.
- [ ] Pause: media mode remains ~2 min, then ambient (CPU / RAM / temperature) with a note glyph; clicking it still opens the player.
- [ ] No player at all: ambient mode, Island not clickable.
- [ ] Clicking the Island morphs it into the player in one motion; Escape or clicking outside collapses it.
- [ ] Player: previous/play-pause/next work and grey out when the player cannot do them; the play button's shape morphs.
- [ ] Wavy seek line moves while playing and is still while paused; clicking/dragging seeks (when the player supports it).
- [ ] Keyboard (SUPER+M): play button focused with ring; Space/K, Left/Right (±5 s), N/P, Tab, Escape.
- [ ] Track without artwork/artist/album: placeholder art, no empty lines.
- [ ] Media keys bound to `mellow:media*` control the active player.
- [ ] Narrow monitor: compact Island never overlaps the side zones; the expanded player fits the screen.
