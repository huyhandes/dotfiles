local wezterm = require("wezterm")
local font_config = {}

function font_config.apply_to_config(config)
	config.font = wezterm.font_with_fallback({ "FiraCode Nerd Font", "JetBrains Mono" })
	config.font_size = 16
end

return font_config
