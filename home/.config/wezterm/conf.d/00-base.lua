-- vim: set ft=lua:
local wezterm = require 'wezterm'

return function(config)
  -- vim: set ft=lua:
  local wezterm = require 'wezterm'

  -- The default term is 'xterm-256color'. I could change that to wezterms own
  -- terminfo with the following cmd:
  -- config.term = 'wezterm'

  config.font = wezterm.font_with_fallback {
    {family = 'JetBrainsMono Nerd Font Mono'},
    -- CJK coverage (Simplified Chinese, Japanese, Korean, Traditional)
    {family = 'Noto Sans CJK SC'},
    {family = 'Noto Sans CJK JP'},
    {family = 'Noto Sans CJK KR'},
    {family = 'Noto Sans CJK TC'},
    "Noto Color Emoji"
  }
  config.font_size = 12

  config.initial_cols = 100
  config.initial_rows = 30
  config.enable_tab_bar = false
  config.audible_bell = 'Disabled'
  config.color_scheme = 'tokyonight'

  config.visual_bell = {
    fade_in_duration_ms = 75,
    fade_out_duration_ms = 75,
    target = 'CursorColor',
  }

  config.exit_behavior_messaging = 'Verbose'
  config.window_close_confirmation = 'NeverPrompt'

  config.enable_kitty_keyboard = true

  config.keys = {
      -- Disable some default keymaps
      { key = "=", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
      { key = "H", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "L", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "J", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "K", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "T", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "W", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "Q", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "Z", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "N", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "P", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "F", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "X", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "+", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "_", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "M", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "R", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
      { key = "U", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },

      { key = "Tab", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
  }

  config.colors = {
    foreground = "#cccccc",
    background = "#2d2d2d",

    cursor_bg     = "#cccccc",
    cursor_border = "#cccccc",
    cursor_fg     = "#2d2d2d",

    ansi = {
      "#000000",
      "#f2777a",
      "#99cc99",
      "#f99157",
      "#6699cc",
      "#cc99cc",
      "#66cccc",
      "#d8d8d8",
    },

    brights = {
      "#666666",
      "#FF3334",
      "#9ec400",
      "#ffcc66",
      "#6699cc",
      "#b777e0",
      "#54ced6",
      "#f8f8f8",
    },

    -- Quick-select / hint overlay
    quick_select_label_fg   = { Color = "#181818" },
    quick_select_label_bg   = { Color = "#f4bf75" },
    quick_select_match_fg   = { Color = "#181818" },
    quick_select_match_bg   = { Color = "#ac4242" },
  }

end
