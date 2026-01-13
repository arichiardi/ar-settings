-- vim: set ft=lua:
local wezterm = require 'wezterm'

local config = {}

-- The default term is 'xterm-256color'. I could change that to wezterms own
-- terminfo with the following cmd:
-- config.term = 'wezterm'

config.font = wezterm.font 'Delugia Mono'
config.font_size = 11 

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
    { key = "1", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
    { key = "2", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
    { key = "3", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
    { key = "4", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
    { key = "5", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
    { key = "6", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
    { key = "7", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
    { key = "8", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
    { key = "9", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
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

    -- WezTerm fully supports the Kitty keyboard protocol, but `Ctrl -` currently
    -- doesn't emit a CSI-u sequence as expected. Manually send the correct
    -- escape code so it behaves consistently across terminals.
    { key = "-", mods = "CTRL", action = wezterm.action.SendString("\x1b[45;5u") },

    -- These are conventional macOS keymaps
    { key = 'f', mods = 'CMD|CTRL', action = wezterm.action.DisableDefaultAssignment },
    { key = 'h', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment },
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
 
  -- Quick‑select / hint overlay – use ColorSpec tables
  quick_select_label_fg   = { Color = "#181818" },
  quick_select_label_bg   = { Color = "#f4bf75" },
  quick_select_match_fg   = { Color = "#181818" },
  quick_select_match_bg   = { Color = "#ac4242" },

  -- Tab‑bar styling
  tab_bar = {
    background = "#2d2d2d",
    active_tab = {
      bg_color = "#2d2d2d",
      fg_color = "#cccccc",
    },
    inactive_tab = {
      bg_color = "#2d2d2d",
      fg_color = "#828482",
    },
    new_tab = {
      bg_color = "#2d2d2d",
      fg_color = "#cccccc",
    },
    new_tab_hover = {
      bg_color = "#f4bf75",
      fg_color = "#181818",
    },
  },  -- trailing comma required
}


return config

