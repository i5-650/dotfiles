local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Mocha" -- Remplace par ton thème dark préféré
	else
		return "Catppuccin Latte" -- Remplace par ton thème light préféré
	end
end

-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- You can specify some parameters to influence the font selection;
-- for example, this selects a Bold, Italic font variant.
config.font = wezterm.font("JetBrains Mono")

config.font_size = 14
config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.window_background_opacity = 0.90
config.macos_window_background_blur = 20

return config
