-- Personal environment overrides (loaded via require("hypr.envs") in hyprland.lua).

-- Fix for AMD GPU EGL sync issues.
hl.env("HYPRLAND_NO_EXTRA_SYNC", "1")

hl.env("COLORTERM", "truecolor")
