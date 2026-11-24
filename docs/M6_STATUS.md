# M6 Status — Settings and release (in progress)

## Implemented
- Notification pop-ups (`notifications.popups`, `notifications.popupTimeout`).
- Validated, live-reloaded `config.json` (`core/ConfigSchema.qml`, `core/Config.qml`).
- Installer/uninstaller: packages, apps, services, Hyprland (Lua) setup, app theming.

## Verified on the development host (non-interactive copy, private D-Bus)
- Pop-ups, dark and light: slide-in, stack of three, app timeout (ms) and default
  timeout, critical ones stay, transient ones are not kept, none while the Control
  Center is open.
- Config: overrides at startup, wrong values and unknown keys reported and defaulted,
  broken JSON keeps the previous settings, atomic replace, delete and recreate.
- Installer in a fake home with stubbed pacman/sudo/systemctl: dry run changes nothing,
  rerun is identical, uninstall restores every edited file; Hyprland 0.57.2
  `--verify-config` accepts the result; kitty parses its theme.
- Theming triggers from MELLOW: off by default, on via config.json, follows light/dark.

## Unverified
- Pointer use of pop-ups (hover pause, close, actions); pop-ups over fullscreen windows.
- Every individual setting changed live.
- A real install: pacman, services, default browser, every keybinding (including that
  `hl.unbind` removes the example config's binds), Dolphin/Gwenview/GTK appearance, live
  recolouring of running apps, MELLOW's look under `QT_QPA_PLATFORMTHEME=kde` (log clean).

## Remaining
- Settings UI (contents to be decided by the user) and writing config.json.
- Diagnostics, performance review, fresh-install check.
