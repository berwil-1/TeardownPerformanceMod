-- UMF
#include "../umf/umf_meta.lua"

-- Utility
#include "../utility/general.lua"

-- Modules
#include "../module/general.lua"
#include "../module/counter.lua"
#include "../module/cleaner.lua"
#include "../module/stabilizer.lua"
#include "../module/fire.lua"
#include "../module/sun.lua"
#include "../module/light.lua"
#include "../module/fog.lua"

version = 3.0
name = "Performance Mod"
options = {
	general = {
		keybind = "p",
		theme = "dark",
		speedrun = false,
		experimental = false
	},
	counter = {
		enabled = true,
		position = {0, 0},
		size = 1,
		textSize = 16,
		textColor = {{0, 1, 1}, 1},
		backColor = {{0, 1, 0}, .5},
		accuracy = 2,
		frequency = 60,
		duration = 60,
		graph = false,
		estimate = false,
		frameCount = true,
		bodyCount = false,
		shapeCount = false,
		fireCount = false,
		performance = true
	},
	cleaner = {
		enabled = true,
		version = 0.7,
		multiplier = 0.2,
		removeVisible = true,
		removeActive = true
	},
	stabilizer = {
		enabled = true,
		version = 0.7,
		multiplier = 0.2,
		stabilizeVisible = true,
		stabilizeActive = false
	},
	fire = {
		enabled = false,
		version = 0.8,
		amount = 200,
		spread = 1
	},
	sun = {
		enabled = false,
		version = 0.8,
		brightness = 1,
		length = 32
	},
	light = {
		enabled = false,
		version = 0.7,
		color = {1, 1, 1},
		intensity = 0,
		colorControl = false,
		intensityControl = true
	},
	fog = {
		enabled = false,
		version = 0.8,
		amount = 1
	}
}

-- Check if the user uses a version before 3.0 or invalid version number (version number shouldn't be less then 3.0).
-- If true then switch over to use the post 3.0 system.
if (HasKey("savegame.mod.version") == false or GetFloat("savegame.mod.version") < 3.0) or (HasKey("savegame.mod.options") == false or GetString("savegame.mod.options") == "") then
	ClearKey("savegame.mod")
	SetFloat("savegame.mod.version", version)
	SetString("savegame.mod.options", util.serialize(options))
end
optionsDefault = Clone(options)
options = HasKey("savegame.mod.options") and util.unserialize(GetString("savegame.mod.options")) or options

modules = {
	general = Merge(general, { options = options.general, data = {} }),
	counter = Merge(counter, { options = options.counter, data = {} }),
	--cleaner = Merge(cleaner, { options = options.cleaner, data = {} }),
	--stabilizer = Merge(stabilizer, { options = options.stabilizer, data = {} }),
	--fire = Merge(fire, { options = options.fire, data = {} }),
	--sun = Merge(sun, { options = options.sun, data = {} }),
	--light = Merge(light, { options = options.light, data = {} }),
	--fog = Merge(fog, { options = options.fog, data = {} })
}

themes = {
	light = {
		background = {0, 0, 0, 0.75}, top_bar = { 0, 0, 0, 0.9 }, left_bar = { 0, 0, 0, 0.5 }, text = { 1, 1, 1, 1 }
	},
	dark = {
		background = {0, 0, 0, 0.75},
		top_bar = { 0, 0, 0, 0.9 },
		left_bar = { 0, 0, 0, 0.5 },

		text = { 1, 1, 1, 1 },
		textEnabled = { 0, 1, 0, 1 },
		textDisabled = { 1, 0, 0, 1 },
		button = { 0, 0, 0, 0.5 },
		buttonPressed = { 0.05, 0.05, 0.05, 0.5 }
	}
}