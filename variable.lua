-- UMF
#include "assets/umf/umf_meta.lua"
#include "assets/umf/umf_utils.lua"

-- Utility
#include "assets/utility/general.lua"

-- Interface
#include "assets/interface/interface.lua"

-- Modules
#include "assets/module/general.lua"
#include "assets/module/counter.lua"
#include "assets/module/debris.lua"
#include "assets/module/fire.lua"
#include "assets/module/light.lua"
#include "assets/module/fog.lua"
#include "assets/module/render.lua"

name = "Performance Mod"
author = "CoolJWB"
version = 3.0

options = {
	general = {
		enabled = true,
		keybind = "p",
		theme = "dark",
		advanced = true,
		speedrun = false,
		hidden = true,
		experimental = false,
		debug = false
	},
	counter = {
		enabled = false,
		position = {0, 0},
		size = 1,
		textSize = 16,
		textColor = {1, 1, 1, 1},
		backColor = {0, 0, 0, 0.5},
		accuracy = 2,
		frequency = 10,
		duration = 60,
		background = true,
		graph = false,
		estimate = false,
		frameCount = true,
		frameCountMax = true,
		frameCountMin = true,
		bodyCount = false,
		shapeCount = false,
		fireCount = false
	},
	debris = {
		enabled = false,
		smart = true,
		cleaner = true,
		particle = false,
		stabilizer = false,
		collider = true,
		collideLevel = true,
		cleanerVoxelCount = 50,
		particleAmount = 2,
		stabilizerVoxelCount = 50,
		stabilizerRadius = 20,
		stabilizerForce = 0.1,
		colliderVoxelCount = 100
	},
	fire = {
		enabled = false,
		performance = false,
		fireLimit = 200,
		fireSpread = 1
	},
	light = {
		enabled = false,
		shadowLimit = 32,
		lampLimit = 1,
		lampColor = {1, 1, 1, 1}
	},
	fog = {
		enabled = false,
		fogStart = 50,
		fogEnd = 200,
		fogAmount = 0.9,
		fogExponent = 8
	},
	render = {
		enabled = false,
		renderDistance = 4
	}
}
local default = Clone(options)

-- Check if the user uses a version before 3.0 or invalid version number (version number shouldn't be less then 3.0).
-- If true then switch over to use the post 3.0 system.
if (HasKey("savegame.mod.version") == false or GetFloat("savegame.mod.version") < 3.0) or (HasKey("savegame.mod.options") == false or GetString("savegame.mod.options") == "") then
	ClearKey("savegame.mod")
	SetFloat("savegame.mod.version", version)
	SetString("savegame.mod.options", util.serialize(options))
end

-- Overwrite existing options with those found in the savegame.
-- This is done so that new options don't get overwritten on new version launch.
if HasKey("savegame.mod.options") then
	local unserialized = util.unserialize(GetString("savegame.mod.options"))

	for name, option in pairs(unserialized) do
		options[name] = option
	end

	SetFloat("savegame.mod.version", version)
	SetString("savegame.mod.options", util.serialize(options))
end


modules = {
	Merge(general, { options = options.general, default = default.general, data = {} }),
	Merge(counter, { options = options.counter, default = default.counter, data = {} }),
	Merge(debris, { options = options.debris, default = default.debris, data = {} }),
	Merge(fire, { options = options.fire, default = default.fire, data = {} }),
	Merge(light, { options = options.light, default = default.light, data = {} }),
	Merge(fog, { options = options.fog, default = default.fog, data = {} }),
	Merge(render, { options = options.render, default = default.render, data = {} }),
}

-- This is a list of themes available.
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
		textFont = "MOD/assets/font/libsans.ttf",
		textFontBold = "MOD/assets/font/libsans_bold.ttf",

		button = { 0, 0, 0, 0.5 },
		buttonPressed = { 0.05, 0.05, 0.05, 0.5 },
		buttonReset = { 0.5, 0, 0, 0.5 }
	}
}
theme = themes.dark