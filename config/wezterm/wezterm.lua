local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Color theme

config.color_scheme = "Catppuccin Mocha"

-- Appearance
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(config, {
	position = "top",
})

local appearance_config = require("appearance")
appearance_config.apply_to_config(config)

-- Keymap
local keymap_config = require("keymap")
keymap_config.apply_to_config(config)

-- tmux status

local weztmux = wezterm.plugin.require("https://github.com/sei40kr/wez-tmux")
weztmux.apply_to_config(config)

-- Font
local font_config = require("font")
font_config.apply_to_config(config)

-- Misc
local misc_config = require("misc")
misc_config.apply_to_config(config)

return config
