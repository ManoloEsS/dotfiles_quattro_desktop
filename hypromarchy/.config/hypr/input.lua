-- Keep only input settings that differ from Omarchy's defaults.

hl.config({
  input = {
    repeat_rate = 40,
    repeat_delay = 600,

    numlock_by_default = true,

    touchpad = {
      scroll_factor = 0.4,
    },
  },
})

-- Scroll nicely in the terminal.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
