# Running, testing and rolling back MELLOW

## Requirements
- Arch Linux with Hyprland (tested with 0.56.2).
- Quickshell ≥ 0.3.2 (`quickshell` in the extra repository).
- Optional fonts: Google Sans Flex, Roboto Flex, Roboto Mono, Material Symbols Rounded.
  Without them text falls back to Noto Sans; without Material Symbols icons are blank.

- Optional: `matugen` (extra) for wallpaper-derived colours in Wallpaper Studio. Without
  it wallpapers still apply; the colour scheme stays unchanged and the Studio says so.
- Control Center sources, each optional (controls without a source are hidden):
  PipeWire (volume, microphone), NetworkManager (Internet), BlueZ (Bluetooth),
  UPower (battery), power-profiles-daemon (power mode), systemd-logind + a
  `/sys/class/backlight` device (laptop brightness), `ddcutil` with i2c access
  (external monitor brightness over DDC/CI; the slider controls the monitor the
  Control Center opened on).

`install.sh --deps` installs Quickshell, matugen and ddcutil (and prints the i2c steps). State is kept in
`~/.local/state/mellow/` (`theme.json`, `wallpaper.json`); delete it to reset.

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

Quickshell reloads QML automatically when files change. A `git pull` that adds new
files or folders can trigger a reload before they exist (e.g. `module "qs.modules.X" is
not installed`), and the running shell keeps the old version. After pulling, restart:
`qs kill -c mellow; qs -c mellow`.

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
bind = SUPER, W, global, mellow:studio
bindr = SUPER, SUPER_L, global, mellow:launcher   # Meta alone; the launcher acts on key release
bind = SUPER, TAB, global, mellow:overview
bind = , XF86AudioPlay, global, mellow:mediaPlayPause
bind = , XF86AudioNext, global, mellow:mediaNext
bind = , XF86AudioPrev, global, mellow:mediaPrevious
bind = , Escape, global, mellow:closeAll     # optional; Escape already closes focused popups
-- hyprland.lua
hl.bind("SUPER + C", hl.dsp.global("mellow:controlCenter"))
hl.bind("SUPER + D", hl.dsp.global("mellow:dock"))
hl.bind("SUPER + SUPER_L", hl.dsp.global("mellow:launcher"), { release = true })
hl.bind("SUPER + TAB", hl.dsp.global("mellow:overview"))
```
`hyprctl globalshortcuts | grep mellow` lists them. The same actions are available over IPC:
`qs -c mellow ipc call mellow toggleControlCenter` (`qs -c mellow ipc show` lists all;
`openStudio` and `toggleTheme` are IPC-only extras).

Qt logs a harmless `qt.qpa.wayland.textinput … Trying to disable … but 0x0 is focused`
warning when a focused popup closes. Hide it with
`qs -c mellow --log-rules "qt.qpa.wayland.textinput=false"`.

## Live blur behind MELLOW (optional, added by you)
MELLOW asks Hyprland to blur behind its bar, frame and panels. If Hyprland's
`decoration:blur:xray` is on, that blur shows only the wallpaper, not the windows behind
a panel. To blur the live windows behind MELLOW while keeping xray for everything else:
```
-- hyprland.lua
hl.layer_rule({ name = "mellow-live-blur", match = { namespace = "^mellow:" }, xray = false })
```
(The classic `hyprland.conf` layerrule syntax for this is not verified yet.) Live blur
re-blurs what is behind a panel whenever it changes (e.g. video), which costs some
GPU time; `Config.effects.blur: "off"` turns all blur off.

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

## M3 test checklist (test machine)
- [ ] `install.sh --deps` offers matugen; MELLOW starts with and without it.
- [ ] Panel trigger shows network / Bluetooth / mute / battery icons matching reality.
- [ ] Control Center: brightness and volume sliders move the real values (drag, click,
      wheel, arrow keys); clicking the volume icon mutes.
- [ ] Tiles: Internet toggles Wi-Fi; Bluetooth toggles the adapter; Microphone mutes the
      default source; Power mode cycles (only shown with power-profiles-daemon);
      Dark theme switches the whole shell and persists across restarts.
- [ ] Wi-Fi page (chevron or Right arrow): networks listed while open; connect to a saved
      network; password field for a new WPA network; disconnect; switch in header.
- [ ] Bluetooth page: paired devices connect/disconnect; battery % where reported.
- [ ] Keyboard: `mellow:controlCenter` focuses the first control; Tab cycles; Escape goes
      back from a detail page, then closes. Pointer opens show no focus ring.
- [ ] Wallpaper & style (from the Control Center or `mellow:studio`): gallery lists
      `~/Pictures/Wallpapers`; selecting shows a preview with generated colours and a
      contrast line; seed chips change the colours; Dark/Light preview.
- [ ] Apply sets the wallpaper (per display or all) and theme; Revert restores the
      previous wallpaper, scheme and mode. Escape / Close / backdrop click closes.
- [ ] Note: MELLOW's wallpaper sits on the background layer; stop other wallpaper
      daemons (hyprpaper, swww) or they may draw on top. `Config.wallpaper.draw: false`
      turns MELLOW's wallpaper off.

## M4 test checklist (test machine)
- [ ] Meta (released alone) opens the launcher from the bottom; Meta+other keys do not.
- [ ] Typing goes straight into the search field; results rank sensibly ("fire" →
      Firefox, "term" → terminals); arrows/Tab move the selection; Return launches;
      Escape clears, then closes; a click outside closes.
- [ ] Empty search: pinned apps first (pin mark), then all apps A–Z.
- [ ] A Terminal=true app (e.g. btop, Vim) opens in the configured terminal.
- [ ] Dock: running indicator pill on running apps, longer on the focused one; running
      apps that are not pinned appear after a divider; click focuses / cycles windows;
      middle click (or Shift+Return) opens a new instance.
- [ ] Meta+Tab Overview: workspaces of the focused monitor with window previews at
      their positions; active workspace and focused window marked.
- [ ] Overview keyboard: arrows/Tab select, Up/Down jump workspace, Return focuses,
      Delete closes, 1–9 opens a workspace, Shift+1–9 moves the selected window.
- [ ] Overview pointer: click focuses; click empty area opens the workspace; middle click
      or × closes; drag a window onto another workspace or "New workspace" moves it.
- [ ] Overview updates when windows open/close while it is shown.

## M5 test checklist (test machine)
- [ ] Light and dark (Control Center → Dark theme): bar, Island, Control Center, Dock,
      Launcher, Overview and Studio are readable; Overview title/hint sit on chips.
- [ ] Blur (`Config.effects.blur`): "subtle" — Control Center, Launcher, Dock and the
      expanded Island are slightly translucent over a blur; "expressive" — more
      translucent, and Overview/Studio blur the whole screen behind them; "off" — opaque.
- [ ] With Hyprland blur disabled (`decoration:blur:enabled = false`, then reload) the
      surfaces turn opaque without restarting MELLOW.
- [ ] `Config.motion.reduced: true`: every surface opens and closes instantly; the seek
      bar wave stands still; nothing ignores input while animating.
