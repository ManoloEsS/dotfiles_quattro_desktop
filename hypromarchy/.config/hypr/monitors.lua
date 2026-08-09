-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Straight 1x setup for low-resolution displays like 1080p or 1440p,
-- or for ultrawide monitors like 34" 3440x1440.
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Acer 34" ultrawide (primary, position 0x0).
hl.monitor({ output = "desc:Acer Technologies ED340CU J0 54520961D3W01", mode = "3440x1440@120", position = "0x0", scale = omarchy_monitor_scale, bitdepth = 10, sdrbrightness = 0.85 })

-- Samsung 24" portrait monitor to the left of the Acer.
hl.monitor({ output = "desc:Samsung Electric Company LF24T35 HCNR501668", mode = "1920x1080@74.97", position = "-1080x0", scale = omarchy_monitor_scale, transform = 1, bitdepth = 10, sdrbrightness = 0.85 })

-- Workspace assignments.
hl.workspace_rule({
  workspace = "1",
  monitor = "desc:Samsung Electric Company LF24T35 HCNR501668",
})
hl.workspace_rule({ workspace = "2", monitor = "desc:Acer Technologies ED340CU J0 54520961D3W01", default = true })

-- Portrait/rotated secondary monitor example (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
