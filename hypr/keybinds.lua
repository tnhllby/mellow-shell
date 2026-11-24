-- MELLOW keybindings. Existing binds on the same keys are replaced.
local function bind(keys, action, opts)
    hl.unbind(keys)
    hl.bind(keys, action, opts)
end

bind("SUPER + Q", hl.dsp.window.close())
bind("SUPER + W", hl.dsp.exec_cmd("firefox"))
bind("SUPER + E", hl.dsp.exec_cmd("dolphin"))
bind("SUPER + T", hl.dsp.exec_cmd("kitty"))
bind("SUPER + Return", hl.dsp.exec_cmd("kitty"))

-- Meta alone: the launcher acts when the key is released.
bind("SUPER + SUPER_L", hl.dsp.global("mellow:launcher"), { release = true })
bind("SUPER + TAB", hl.dsp.global("mellow:overview"))
bind("SUPER + N", hl.dsp.global("mellow:controlCenter"))
bind("SUPER + I", hl.dsp.global("mellow:settings"))
bind("CTRL + SUPER + T", hl.dsp.global("mellow:studio"))

for i = 1, 9 do
    bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
end

bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
bind("SUPER + SHIFT + left", hl.dsp.window.move({ workspace = "r-1" }))
bind("SUPER + SHIFT + right", hl.dsp.window.move({ workspace = "r+1" }))
bind("CTRL + SUPER + left", hl.dsp.focus({ workspace = "r-1" }))
bind("CTRL + SUPER + right", hl.dsp.focus({ workspace = "r+1" }))

-- Media keys, also while locked; held keys repeat.
local held = { locked = true, repeating = true }
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held)
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), held)
bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("qs -c mellow ipc call mellow brightnessStep 5"), held)
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qs -c mellow ipc call mellow brightnessStep -- -5"), held)
