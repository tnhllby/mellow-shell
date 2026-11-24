-- Windows that match MELLOW's frame; border colours come from the theme.
local state = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
local ok, colors = pcall(dofile, state .. "/mellow/theme/hyprland.lua")
if not ok then
    colors = { active = "rgba(8bd6baff)", inactive = "rgba(404944ff)" }
end

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        col = { active_border = colors.active, inactive_border = colors.inactive },
    },
    decoration = {
        rounding = 18,
        blur = { enabled = true, size = 8, passes = 3 },
    },
})
