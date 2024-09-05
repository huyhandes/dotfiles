local wezterm = require("wezterm")
local appearance_config = {}
function appearance_config.apply_to_config(config)
	local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
	config.window_background_opacity = 0.8
	config.macos_window_background_blur = 16
	config.window_decorations = "RESIZE"
	config.window_padding = {
		left = 2,
		right = 2,
		top = 0,
		bottom = 0,
	}
	config.cursor_blink_rate = 0
	config.colors = {
		tab_bar = {
			background = scheme.brights[0],
		},
	}
end

return appearance_config
