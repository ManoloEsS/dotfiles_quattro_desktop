-- Change the default Omarchy look'n'feel.

local active_border_color = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 }

hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 3,

    col = {
      active_border = active_border_color,
    },

    -- niri-like side-scrolling layout as the default.
    layout = "scrolling",
  },

  master = {
    allow_small_split = false,
    special_scale_factor = 1.0,
    mfact = 0.7,

    new_status = "slave",
    new_on_top = false,
    new_on_active = "none",

    orientation = "right",
    slave_count_for_center_master = 2,
    center_master_fallback = "left",

    smart_resizing = true,
    drop_at_cursor = true,
    always_keep_position = false,
  },

  decoration = {
    -- Square window corners.
    rounding = 0,

    blur = {
      enabled = true,
      size = 5,
      ignore_opacity = true,
      passes = 1,
      special = true,
      brightness = 0.9,
      contrast = 0.75,
      noise = 0.01,
      vibrancy = 0.1696,
    },
  },

  scrolling = {
    column_width = 0.5,
    explicit_column_widths = "0.30, 0.5, 0.70, 1.0",
  },
})

-- Rotating active border (hyprlang: animation = borderangle, 1, 64, linear, loop).
hl.animation({ leaf = "borderangle", enabled = true, speed = 64, bezier = "linear", style = "loop" })
