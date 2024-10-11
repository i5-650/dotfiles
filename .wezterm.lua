-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
-- config.color_scheme = 'AdventureTime'

config.font = wezterm.font('Jetbrains Mono', { weight = 'Bold', italic = false })
config.font_size = 14
config.color_scheme = 'Mariana'
config.window_background_opacity = 0.95

-- and finally, return the configuration to wezterm
return config
