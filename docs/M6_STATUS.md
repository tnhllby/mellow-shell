# M6 Status — Settings and release (in progress)

## Implemented
- Notification pop-ups (`notifications.popups`, `notifications.popupTimeout`).
- Validated, live-reloaded `config.json` (`core/ConfigSchema.qml`, `core/Config.qml`).

## Verified on the development host (non-interactive copy, private D-Bus)
- Pop-ups, dark and light: slide-in, stack of three, app timeout (ms) and default
  timeout, critical ones stay, transient ones are not kept, none while the Control
  Center is open.
- Config: overrides at startup, wrong values and unknown keys reported and defaulted,
  broken JSON keeps the previous settings, atomic replace, delete and recreate.

## Unverified
- Pointer use of pop-ups (hover pause, close, actions); pop-ups over fullscreen windows.
- Every individual setting changed live.

## Remaining
- Settings UI (contents to be decided by the user) and writing config.json.
- Installer: Hyprland keybindings and the `xray = false` layer rule; uninstall.
- Diagnostics, performance review, fresh-install check.
