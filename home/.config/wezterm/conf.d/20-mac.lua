-- vim: set ft=lua:
local wezterm = require 'wezterm'

-- Mac-only overrides. Loaded from local.d, so it is not part of the repo.
if not wezterm.target_triple:find('darwin', 1, true) then
  return
end

return function(config)
  -- Fonts: no CJK fallback on this machine.
  config.font = wezterm.font_with_fallback {
    { family = 'JetBrainsMono Nerd Font Mono' },
    'Noto Color Emoji',
  }
  config.font_size = 16

  config.color_scheme = 'tokyonight'
  config.scrollback_lines = 65536

  config.colors = config.colors or {}
  config.colors.quick_select_label_fg = { Color = '#181818' }
  config.colors.quick_select_label_bg = { Color = '#f4bf75' }
  config.colors.quick_select_match_fg = { Color = '#181818' }
  config.colors.quick_select_match_bg = { Color = '#ac4242' }

  config.colors.tab_bar = config.colors.tab_bar or {}
  config.colors.tab_bar.inactive_tab = {
    bg_color = '#2d2d2d',
    fg_color = '#828482',
  }
  config.colors.tab_bar.new_tab_hover = {
    bg_color = '#f4bf75',
    fg_color = '#181818',
  }

  config.keys = config.keys or {}
  local mac_keys = {
    { key = '1', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment },
    { key = '2', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment },
    { key = '3', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment },
    { key = '4', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment },
    { key = '5', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment },
    { key = '6', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment },
    { key = '7', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment },
    { key = '8', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment },
    { key = '9', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment },

    -- These are conventional macOS keymaps
    { key = 'f', mods = 'CMD|CTRL', action = wezterm.action.DisableDefaultAssignment },
    { key = 'h', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment },

    -- Turn off the default CMD-m Hide action, allowing CMD-m to
    -- be potentially recognized and handled by the tab
    { key = 'm', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment },
  }

  for _, key in ipairs(mac_keys) do
    table.insert(config.keys, key)
  end
end
