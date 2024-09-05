local misc_config = {}

function misc_config.apply_to_config(config)
	config.front_end = "WebGpu"
	config.max_fps = 120
end

return misc_config
