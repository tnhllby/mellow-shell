# MELLOW — handoff prompt for a new session

Paste everything below the line into a new Claude Code session started in
`~/Projects/Shell/mellow-shell`.

---

You are continuing work on **MELLOW**, an original Hyprland desktop shell built with
Quickshell/QML, in `~/Projects/Shell/mellow-shell` (git repo, branch `main`, nothing
pushed). Before changing code read `CLAUDE.md`, `DESIGN.md`, `ARCHITECTURE.md`,
`ROADMAP.md`, `docs/DECISIONS.md`, `docs/RUNNING.md` and `docs/M5_STATUS.md`.
Follow CLAUDE.md's workflow: inspect, propose the smallest change, implement only the
current milestone, test, report exactly what was and was not verified, update docs.

## Status
- M0–M4 done and confirmed by the user on both machines.
- **M5 — visual polish: in progress** (details in `docs/M5_STATUS.md`). Done so far:
  light/dark pass (Overview text on chips, wider contrast check), reduced-motion audit,
  blur modes, translucent bar/frame chrome, 44 px bar, workspace app icons, equal
  inner corners, card outline/rim fixes. The user runs MELLOW live on the host and
  reports issues with screenshots and recordings.
- **Remaining M5:** frame and multi-monitor polish, dimensional iconography,
  animated theme change. Ask the user which comes next.
- **Then M6:** settings UI, validated config, and an installer that writes MELLOW's
  Hyprland keybindings **and the `xray = false` layer rule** (sourced snippet, backed
  up, removable by `uninstall.sh`).

Latest commits: `564875a` shifted Control Center blur fix + faint card outline;
`5d29da4` blur inset (light rim) + icon only on the active workspace; `64f23e3` 44 px
bar, workspace icons, glass pills, equal corners; `eb04cde` translucent blurred chrome;
`dbc1076` Dock blur + blur ahead of cards; `ccdcc86` M5 light/dark, blur, motion.

## Environments and safety (strict)
- **Dev host** (where you run): EndeavourOS laptop, Hyprland 0.56.2 with a **Lua
  config**, Quickshell 0.3.2, Qt 6.12, Intel+NVIDIA, monitors HDMI-A-1 1920×1080 at 0,0
  (Dell P2217H, DDC/CI on i2c bus 1) and eDP-1 1366×768 at 1920,0, scale 1 (HDMI is not
  always connected; check `hyprctl monitors`). It is the user's daily driver. They run
  MELLOW live (`qs -c mellow`, via their own link `~/.config/quickshell/mellow` → this
  repo), often alongside end-4's illogical-impulse (`qs -c ii`). **Repo edits
  hot-reload into their live session**, so broken code is visible to them immediately.
- Host Hyprland blur: `decoration:blur:xray = true`, size 10, passes 3.
- **Test PC**: clean Arch + Hyprland, installed with `./install.sh`.
- Never modify the host's `~/.config` (including Hyprland config: give the user
  snippets instead), never install packages/fonts on the host, no autostart, nothing
  destructive. Do not run `hyprctl keyword`/reload against the live compositor.
- **Never inject input** into the live session: no cursor warps, clicks, typing or
  focus-grabbing surfaces.
- Reading the live instance's log is fine: `qs log -c mellow`.

## How to test visuals (scratchpad is wiped between sessions: recreate the scripts)
1. Copy the repo to `<scratchpad>/sim` (drop `.git`), then make it non-interactive:
   - `modules/Shortcuts.qml`: change `appid: "mellow"` to `"mellowsim"`, so it does not
     steal the live session's global shortcuts;
   - in every `modules/**/*.qml` (perl `-0pi`):
     `s/mask: Region \{\s*item: [^\n]*\n\s*\}/mask: Region {}/g`,
     `s/(WlrLayershell\.keyboardFocus:)[^\n]*/$1 WlrKeyboardFocus.None/g`,
     `s/(HyprlandFocusGrab \{\s*active:)[^\n]*/$1 false/g`.
2. Run with isolated state: `XDG_STATE_HOME=<scratchpad>/iso-dark timeout 8 qs -p <sim>`
   (put `{"mode":"dark","scheme":null}` or `"light"` in `iso-*/mellow/theme.json`).
3. Open surfaces over IPC: `qs -p <sim> ipc call mellow toggleControlCenter`
   (`toggleLauncher`, `toggleOverview`, `toggleDock`, `toggleIsland`, `openStudio`).
   They open on the **focused** monitor; capture that one with
   `grim -o <monitor>` (find it with `hyprctl -j monitors`, `focused`).
4. grep the log for WARN/ERROR. `qt.qpa.wayland.textinput` and MPRIS
   `dbus.properties` warnings are benign.
5. The live MELLOW (and `ii`) are on screen too: a second bar appears below the live
   one, and the two Islands overlap. That is a test artifact.
6. For pixel-level checks use `magick … -crop WxH+X+Y txt:-`; for animations take bursts
   of `grim -g` captures right after the IPC call. Pillow is not installed.
- Set blur mode in the copy by editing `core/Config.qml` (`effects.blur`).

## Commits
`git -c user.name=tnhllby -c user.email=bdvabidona@gmail.com commit`, message ending
with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Commit at the end of
each requested change; never push.

## User preferences and decisions
- Bar **44 px**, one chrome with the 4 px frame: rounded outer screen corners (22 px)
  with **black** outside them, all inner workspace corners 18 px (outer − frame).
  Bar, frame and bar pills are translucent over blur.
- Top-left workspace strip: **inactive workspaces show their number; the active one
  shows only its main app's icon** (last focused window there; number when empty).
  No active-window title in the bar. Clock, date, status at the right; Island centre.
- Dock on the **left** edge (auto-hide, 2 px edge-trigger surface).
- Launcher keeps a **faint** 1 px outline (`Theme.cardOutline`, outlineVariant at
  35 %). Island, Dock, Control Center and the workspace preview use a 2 px edge band
  in the card's own colour (`Theme.cardEdge`): the jagged blur edge looked "sharpy",
  and the band must stay unnoticeable (a tinted or denser band read as a ring).
  Overview keeps borders as markers.
- Overview always shows workspaces 1–6 (`Config.overview.defaultWorkspaces`), empty
  ones as plain cards; workspaces living on another monitor appear on that one.
- Hovering an inactive workspace number (with windows) shows a preview card under
  the bar after 300 ms (`modules/TopBar/WorkspacePreview.qml`).
- Blur: `Config.effects.blur` = "subtle" (default) | "expressive" | "off"; it falls back
  to off when Hyprland blur is disabled. The user wants blur everywhere (bar, pills,
  panels). For live-window blur (not just the wallpaper), the user adds in
  `hyprland.lua`:
  `hl.layer_rule({ name = "mellow-live-blur", match = { namespace = "^mellow:" }, xray = false })`
  (the classic-config syntax is unverified).
- Pixel-inspired Material 3 Expressive look, original; never copy other projects.
- Fonts: Google Sans Flex, Roboto Flex, Roboto Mono, Material Symbols Rounded,
  installed only by `install.sh --fonts`.
- Quick animations. The user writes short messages, often with screenshots or screen
  recordings (extract frames with ffmpeg). Reply in plain language.

## Architecture (as built)
- `shell.qml`: per screen: Wallpaper, TopBar, Island, WorkspaceFrame,
  FrameReservation ×3, Dock, ControlCenter, Launcher, WallpaperStudio, Overview (last).
  It also binds `Theme.compositorBlur` to `HyprlandService.blurEnabled` (core/ never
  imports integrations/).
- `core/`: Config (static settings), Theme (tokens; `effects` = blur mode, card and
  chrome opacity; `glass(color)`; `chrome`; `cardOutline`; `barPill.height/inner` derived
  from the bar height; `chromeShape.innerRadius` = outer − frame), ColorScheme/ThemeColors
  (generated by `tools/gen-palette.py`), ThemeState (`theme.json`), Typography, Motion,
  ShellState, Icons, Paths, ColorUtil (WCAG pairs actually drawn).
- `components/CardBlurRegion.qml`: blur region for a card. It takes the position from
  plain x/y (+ `offset` for nested cards; never `mapToItem`, which includes scale), is
  inset 1 px, and clamps corner radii as Qt draws them.
- `integrations/hyprland/HyprlandService.qml`: the only Hyprland access point;
  `dispatch(classic, lua)`, window focus/close/move, `hasRealFullscreen`, `blurEnabled`
  (`hyprctl getoption` at startup and on `configreloaded`), `lastFocused` per workspace
  and `mainWindowOn(workspace)`.
- `services/`: Media, SystemStats, Audio, Network, Bluetooth, Power, Brightness,
  Wallpaper, App.
- `modules/`: TopBar (WorkspaceStrip, StatusArea), Island, Frame, Dock, ControlCenter,
  Background, WallpaperStudio, Launcher, Overview, Shortcuts.

## Hard-won lessons (do not regress)
- Interactive surfaces are **always-mapped layer surfaces** whose `mask` is the card
  while open; never xdg-popups, and never toggle `visible` (with a focus grab, or on
  a blurred surface: re-creating the surface **drops its blur region**).
- Blur (`BackgroundEffect.blurRegion`, ext-background-effect, supported by Hyprland
  0.56):
  - Regions track item position/size but **not scale or opacity**: enable the blur
    only once a card is fully open/slid in (`opacity === 1 && scale === 1`, `y === 0`,
    `x === restX`), and drop it as soon as closing starts.
  - A region **outside the surface** makes Hyprland blur the whole surface: never
    leave a region on an off-screen card.
  - Rounded and concave shapes: `Region` radii plus nested `Intersection.Subtract`
    (used for the bar fillets and the frame ring).
  - With xray on, the blur shows the wallpaper; a card's antialiased edge then showed
    it as a light rim, hence the 1 px inset.
- Quickshell service singletons (Pipewire, UPower, Networking, Bluetooth) only
  initialise when referenced in bindings at startup.
- QML's JS has no `Array.flatMap`; properties named `onX` are signal handlers (Material
  `onX` roles are `contentX`); `left`/`top` are final on Items; a `readonly` property
  cannot be animated; setting `exclusiveZone` overrides `ExclusionMode.Ignore`. An unset
  per-corner radius reads as `radius`.
- Hyprland applies exclusive zones in layer and creation order; the bar draws the inner
  fillets itself.
- Toggling a PanelWindow's `visible` from a property that depends on `screen` loops.
- `ScreencopyView.captureFrame()` only after the first capture (`hasContent`).
- A release bind only sends the global shortcut's `released` signal.
- `//@ pragma Env QT_LOGGING_RULES=…` does **not** filter logs; `qs --log-rules` does.
- Verify every Quickshell type/property against the installed qmltypes in
  `/usr/lib/qt6/qml/Quickshell/`; Hyprland Lua API stubs are in
  `/usr/share/hypr/stubs/hl.meta.lua` (example config: `/usr/share/hypr/hyprland.lua`).

## Known open points / unverified
- On screen: the Launcher's faint outline; workspace icons updating live
  (focus changes, closing windows, moving windows between workspaces); the xray layer
  rule; the `configreloaded` blur-off path; the workspace hover preview with a real pointer
  (only tested with a faked hover in the copy).
- Overview previews are captures taken on open (not live); one monitor at a time.
- Wallpaper revert keeps one step; no Span placement; DND / night light not shown.
- Launch history only counts launches made through MELLOW.

Start by reading the docs above, then ask the user what to do next (remaining M5
items, or any issues they noticed).
