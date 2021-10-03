#include "core.lua"
#include "window.lua"

-- Variables
local initModules = {InitCore, InitWindow}
local data = {"Performance Mod", 2.5} -- Data stored in here will follow the format as follows [1]: Mod name [2]: Mod version [3]: Curve presets [4]: Current FPS
local options = {{
	counter = {
		enabled = false,
		locked = false,
		position = {0, 0},
		size = 1,
		textSize = 16,
		textColor = {{0, 1, 1}, 1},
		backColor = {{0, 1, 0}, .5},
		accuracy = 0,
		delay = 0,
		scale = false,
		frameCount = true,
		bodyCount = false,
		shapeCount = false,
		fireCount = false
	},
	cleaner = {
		enabled = true,
		locked = false,
		curve = 2,
		multiplier = 0.2,
		removeVisibleDebris = true,
		removeActiveDebris = true
	},
	stabilizer = {
		enabled = true,
		locked = false,
		curve = 1,
		multiplier = 0.2,
		stabilizeVisibleObjects = true,
		stabilizeActiveObjects = false
	},
	fire = {
		enabled = true,
		locked = false,
		amount = 200,
		spread = 1
	},
	sun = {
		enabled = true,
		locked = false,
		brightness = 1,
		length = 32
	},
	light = {
		enabled = false,
		locked = false,
		color = {1, 1, 1},
		intensity = 0,
		colorControl = false,
		intensityControl = true
	},
	fog = {
		enabled = false,
		locked = false,
		amount = 1
	}
}} -- All the module options will be stored here as follows [1]: Fallback options [2]: Mod options



hook.add("base.init", "performance.init", function()
	-- Check if the user uses a version before 2.5 or invalid version number (version number shouldn't be less then 2.5).
	-- If true then switch over to use the post 2.5 system.
	if not HasKey("savegame.mod.version") or GetFloat("savegame.mod.version") < 2.5 then
		ClearKey("savegame.mod")
		SetFloat("savegame.mod.version", data[2])
		SetString("savegame.mod.keybind", "p")
	end

	-- If options are found stored in the savegame then count the options.
	-- If no options are found or the option amount is less than 4 it will use the fallback options.
	if HasKey("savegame.mod.options") and GetString("savegame.mod.options") ~= "" then
		local optionsFound = 0
		for _ in pairs(util.unserialize(GetString("savegame.mod.options"))) do optionsFound = optionsFound + 1 end
		options[2] = optionsFound < 4 and Clone(options[1]) or util.unserialize(GetString("savegame.mod.options"))
	else
		options[2] = Clone(options[1])
	end

	if GetString("savegame.mod.keybind") == "?" then
		SetString("savegame.mod.keybind", "p")
	end

	-- Initialize the functions used to draw curves or increase values in different ways.
	data[3] = {
		{"CONSTANT", function(value) return 10 end},
		{"LINEAR", function(value) return math.max(60 - value, 0) end},
		{"EXPONENTIAL", function(value) return math.max(30.07462 - (0.00003718851 / -0.1998865) * (1 - math.exp(1) ^ (0.1998865 * value)), 0) end},
		{"INVERSE", function(value) return 3.48986 * 10 ^ 12 * value ^ -7.491398 end}
	}

	-- Make init function calls to the required modules.
	for index,module in pairs(initModules) do
		module(data, options)
	end
end)

hook.add("base.draw", "performance.draw", function()
	DrawWindow()
end)

hook.add("base.tick", "performance.tick", function(dt)
	TickWindow(dt)
	TickCore(dt)
end)