-- Qt apps (Dolphin, Gwenview) take their colours from kdeglobals, and Dolphin
-- finds applications for "Open with".
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XDG_MENU_PREFIX", "arch-")
