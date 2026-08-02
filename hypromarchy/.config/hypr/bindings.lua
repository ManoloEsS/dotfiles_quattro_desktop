-- Personal keybindings loaded after Omarchy defaults.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Send a single Ctrl+<key> chord to the focused surface (used for universal cut).
local function send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down", window = "activewindow" }))

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up", window = "activewindow" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

-- =====================================================
-- CONFLICTS WITH OMARCHY DEFAULTS
-- =====================================================

-- Navigation overrides (HJKL focus)
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")

-- Workspace cycling (comma/period)
hl.unbind("SUPER + COMMA")
hl.unbind("SUPER + SHIFT + COMMA")

-- Displaced tiling defaults → relocated
hl.unbind("SUPER + O")
hl.unbind("SUPER + P")
hl.unbind("SUPER + code:61")
hl.unbind("SUPER + ALT + code:61")

-- Remove workspace TAB cycling (using comma/period instead)
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
hl.unbind("SUPER + CTRL + TAB")

-- App launcher overrides
hl.unbind("SUPER + RETURN")
hl.unbind("SUPER + ALT + RETURN")

-- Unbind SUPER+W (Close window → moving to Q); keep SUPER+X (Universal cut)
hl.unbind("SUPER + W")

-- Volume override: 2% steps instead of default
hl.unbind("XF86AudioRaiseVolume")
hl.unbind("XF86AudioLowerVolume")

-- =====================================================
-- VOLUME: 2% steps
-- =====================================================
o.bind("XF86AudioRaiseVolume", "Volume up 2%", "omarchy-swayosd-client --output-volume +2", { locked = true, repeating = true })
o.bind("XF86AudioLowerVolume", "Volume down 2%", "omarchy-swayosd-client --output-volume -2", { locked = true, repeating = true })

-- =====================================================
-- HJKL NAVIGATION (layout-aware)
-- =====================================================
o.bind("SUPER + H", "Focus left", hl.dsp.layout("focus l"))
o.bind("SUPER + J", "Focus down", hl.dsp.layout("focus d"))
o.bind("SUPER + K", "Focus up", hl.dsp.layout("focus u"))
o.bind("SUPER + L", "Focus right", hl.dsp.layout("focus r"))
o.bind("SUPER + SHIFT + H", "Swap left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap right", hl.dsp.window.swap({ direction = "r" }))

-- =====================================================
-- WORKSPACE CYCLING
-- =====================================================
o.bind("SUPER + comma", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("SUPER + period", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))

-- =====================================================
-- DISPLACED DEFAULTS → NEW HOMES
-- =====================================================
o.bind("SUPER + SLASH", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + ALT + SLASH", "Show key bindings", "omarchy-menu-keybindings")
o.bind("SUPER + BACKSLASH", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
o.bind("SUPER + SHIFT + I", "Toggle scrolling/master layout", "$HOME/.config/hypr/omarchy-hyprland-workspace-layout-scrolling-master-toggle")
o.bind("SUPER + SHIFT + O", "Pop window out", "omarchy-hyprland-window-pop")
o.bind("SUPER + SHIFT + CTRL + SLASH", "Cycle monitor scaling", "omarchy-hyprland-monitor-scaling-cycle")
o.bind("SUPER + SHIFT + CTRL + ALT + SLASH", "Cycle monitor scaling backwards", "omarchy-hyprland-monitor-scaling-cycle --reverse")
o.bind("SUPER + ALT + PERIOD", "Dismiss last notification", "makoctl dismiss")
o.bind("SUPER + SHIFT + ALT + PERIOD", "Dismiss all notifications", "makoctl dismiss --all")

-- =====================================================
-- COLUMN RESIZE
-- =====================================================
o.bind("SUPER + R", "Expand window left", hl.dsp.layout("colresize +conf"))
o.bind("SUPER + SHIFT + R", "Shrink window left", hl.dsp.layout("colresize -conf"))
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
o.bind("SUPER + W", "Universal cut", send_shortcut_once("CTRL", "X"))

-- =====================================================
-- APP LAUNCHERS (personal overrides)
-- =====================================================
o.bind("SUPER + RETURN", "Terminal", { omarchy = "terminal" })
o.bind("SUPER + ALT + RETURN", "Tmux", { omarchy = "terminal-tmux" })
o.bind("SUPER + E", "Yazi", o.launch("xdg-terminal-exec yazi"))

-- =====================================================
-- MASTER LAYOUT
-- =====================================================
o.bind("SUPER + semicolon", "Swap with master", hl.dsp.layout("swapwithmaster auto"))
o.bind("SUPER + Y", "Cycle next", hl.dsp.layout("cyclenext loop"))
o.bind("SUPER + SHIFT + Y", "Cycle previous", hl.dsp.layout("cycleprev loop"))
o.bind("SUPER + m", "Promote window", hl.dsp.layout("promote"))
o.bind("SUPER + N", "Roll next", hl.dsp.layout("rollnext"))
o.bind("SUPER + P", "Roll previous", hl.dsp.layout("rollprev"))
o.bind("SUPER + a", "Add master", hl.dsp.layout("addmaster"))
o.bind("SUPER + z", "Remove master", hl.dsp.layout("removemaster"))

-- Preserve Omarchy's pseudo-window action after using Super+P for rollprev.
o.bind("SUPER + ALT + P", "Pseudo window", hl.dsp.window.pseudo())
o.bind("SUPER + u", "Master factor 0.70", hl.dsp.layout("mfact exact 0.70"))
o.bind("SUPER + i", "Master factor 0.66", hl.dsp.layout("mfact exact 0.66"))
o.bind("SUPER + O", "Master factor 0.50", hl.dsp.layout("mfact exact 0.5"))

-- =====================================================
-- SCROLLING LAYOUT
-- =====================================================
o.bind("SUPER + SHIFT + n", "Move window left", hl.dsp.window.move({ direction = "l" }))
o.bind("SUPER + SHIFT + p", "Move window right", hl.dsp.window.move({ direction = "r" }))
o.bind("SUPER + SHIFT + m", "Promote window", hl.dsp.layout("promote"))
o.bind("SUPER + SHIFT + comma", "Swap column left", hl.dsp.layout("swapcol l"))
o.bind("SUPER + SHIFT + period", "Swap column right", hl.dsp.layout("swapcol r"))
