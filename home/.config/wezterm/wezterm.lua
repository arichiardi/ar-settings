-- vim: set ft=lua:
local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- Layers are evaluated in sorted glob order, so numeric prefixes set the
-- order. Each layer returns a function that mutates the shared config.
-- Files that do not apply to this machine return nothing and are skipped.
local function load_dir(dir)
  wezterm.add_to_config_reload_watch_list(dir)
  for _, file in ipairs(wezterm.glob(dir .. '/*.lua')) do
    local layer = dofile(file)
    if type(layer) == 'function' then
      layer(config)
    end
  end
end

-- Tracked layers: shared base and per-OS overrides.
load_dir(wezterm.config_dir .. '/conf.d')

-- Machine-private layers. This directory is not part of the repo.
load_dir(wezterm.home_dir .. '/.config/wezterm/local.d')

return config
