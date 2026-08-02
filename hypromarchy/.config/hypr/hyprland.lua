-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Load user modules and the installed Omarchy defaults.
package.path = os.getenv("HOME")
  .. "/.config/?.lua;"
  .. (os.getenv("OMARCHY_PATH") or (os.getenv("HOME") .. "/.local/share/omarchy"))
  .. "/?.lua;"
  .. package.path

require("default.hypr.omarchy")

-- Personal overrides are loaded after Omarchy defaults.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")
require("hypr.envs")
require("hypr.workspace-layouts")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Free-sync / variable refresh rate (VVR) for gaming monitors.
hl.config({ misc = { vrr = 2 } })
