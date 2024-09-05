local wezterm = require("wezterm")
local keymap_config = {}

function keymap_config.apply_to_config(config)
	config.leader = { key = "a", mods = "CTRL" }
	config.keys = {
		-- Turn off the default CMD-m Hide action, allowing CMD-m to
		-- be potentially recognized and handled by the tab
		{
			key = "t",
			mods = "CMD",
			action = wezterm.action.SpawnCommandInNewTab({
				cwd = wezterm.home_dir,
			}),
		},
		{
			key = "m",
			mods = "CMD",
			action = wezterm.action.DisableDefaultAssignment,
		},
		{
			key = "LeftArrow",
			mods = "OPT",
			action = wezterm.action({ SendString = "\x1bb" }),
		},
		{
			key = "RightArrow",
			mods = "OPT",
			action = wezterm.action({ SendString = "\x1bf" }),
		},
		{
			key = "LeftArrow",
			mods = "CMD",
			action = wezterm.action({ SendString = "\x1bOH" }),
		},
		{
			key = "RightArrow",
			mods = "CMD",
			action = wezterm.action({ SendString = "\x1bOF" }),
		},
		{
			key = "LeftArrow",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivateTabRelative(-1),
		},
		{
			key = "RightArrow",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivateTabRelative(1),
		},
		{
			key = "h",
			mods = "CTRL",
			action = wezterm.action.ActivatePaneDirection("Left"),
		},
		{
			key = "l",
			mods = "CTRL",
			action = wezterm.action.ActivatePaneDirection("Right"),
		},
		{
			key = "k",
			mods = "CTRL",
			action = wezterm.action.ActivatePaneDirection("Up"),
		},
		{
			key = "j",
			mods = "CTRL",
			action = wezterm.action.ActivatePaneDirection("Down"),
		},
	}
end

return keymap_config
