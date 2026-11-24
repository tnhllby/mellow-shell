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

## Install
```sh
git clone <repo-url> ~/mellow-shell && cd ~/mellow-shell
./install.sh --dry-run     # shows every step, changes nothing
./install.sh               # asks before each kind of change
```
Steps can be run alone: `--deps`, `--apps`, `--fonts`, `--link`, `--hypr`, `--theme`.
Hyprland 0.57 reads only the Lua config (`hyprland.lua`); a missing one is created from
Hyprland's example. MELLOW adds one marked line to it; its own files are in
`~/.config/hypr/mellow/`. Changed files are copied to `~/.local/state/mellow/backup/`.

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

## Keybindings
`install.sh --hypr` adds these (`hypr/keybinds.lua`), replacing binds on the same keys:

| Keys | Action |
|---|---|
| Meta / Meta+Tab | Launcher / Overview |
| Meta+N / Ctrl+Meta+T / Meta+I | Control Center / Wallpaper Studio / Settings (no window yet) |
| Meta+Q | Close window |
| Meta+W / Meta+E / Meta+T, Meta+Enter | Firefox / Dolphin / kitty |
| Meta+1..9 | Workspace |
| Meta+Left/Right | Move focus |
| Meta+Shift+Left/Right | Move window to the previous/next workspace |
| Ctrl+Meta+Left/Right | Previous/next workspace |

Other global shortcuts (`mellow:dock`, `mellow:island`, `mellow:mediaPlayPause`,
`mellow:mediaNext`, `mellow:mediaPrevious`, `mellow:closeAll`) can be bound by you:
```
hl.bind("SUPER + D", hl.dsp.global("mellow:dock"))
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
- [ ] Bar 44 px: inactive workspaces show their number; the active one shows the icon
      of the app last focused there (number when empty), following focus changes,
      closed windows and windows moved between workspaces.
- [ ] No light rim around the Control Center, Launcher, Dock or Island edges.
- [ ] Top and bottom inner workspace corners have the same radius.
- [ ] Light and dark (Control Center → Dark theme): bar, Island, Control Center, Dock,
      Launcher, Overview and Studio are readable; Overview title/hint sit on chips.
- [ ] Blur (`Config.effects.blur`): "subtle" — Control Center, Launcher, Dock and the
      expanded Island are slightly translucent over a blur; "expressive" — more
      translucent, and Overview/Studio blur the whole screen behind them; "off" — opaque.
- [ ] With Hyprland blur disabled (`decoration:blur:enabled = false`, then reload) the
      surfaces turn opaque without restarting MELLOW.
- [ ] `Config.motion.reduced: true`: every surface opens and closes instantly; the seek
      bar wave stands still; nothing ignores input while animating.

## Control Center panel checklist
MELLOW receives notifications only while no other program (dunst, mako, another shell) does.
- [ ] Panel slides in from the right; Escape, the trigger or a click outside closes it.
- [ ] `notify-send Test Hello` shows a card; X or Delete dismisses it; Clear all empties the list.
- [ ] A notification's action buttons and default action (click, Return) work.
- [ ] Media card: previous / play-pause / next and seeking work.
- [ ] Tab reaches every control, and the list scrolls to the focused card.
- [ ] Toggling Dark theme cross-fades the whole shell; instant with reduced motion.
- [ ] Unplug a monitor with the Control Center open on it: it is closed after replugging.

## Configuration
Optional `~/.config/mellow/config.json`, applied when saved; settings and limits are listed
in `core/ConfigSchema.qml`. Mistakes are logged (`qs log -c mellow`) and ignored.
```json
{ "controlCenter": { "width": 460 }, "notifications": { "popupTimeout": 4000 } }
```
- [ ] Pop-ups: hovering keeps one open, X dismisses it, action buttons and clicking work.

## App theming
With `theming.apps` (set by `install.sh --theme`) MELLOW regenerates colours for kitty,
KDE apps (Dolphin, Gwenview), GTK apps and Hyprland borders on every theme change.
Firefox follows light/dark only. Log: `qs log -c mellow`.

## M6 installer checklist (test machine)
- [ ] `./install.sh` on a clean Arch + Hyprland: packages, services, Firefox as default browser.
- [ ] Every keybinding in the table above works; Meta alone opens the Launcher.
- [ ] Dolphin "Open with" lists apps; Dolphin, Gwenview, kitty and a GTK app follow the theme.
- [ ] Changing wallpaper colours or light/dark updates them live.
- [ ] `./uninstall.sh` restores the previous look; Hyprland starts without errors.
