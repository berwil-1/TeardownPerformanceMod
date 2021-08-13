#include "core.lua"
#include "window.lua"

-- Variables
local data = {"Performance Mod", 2.0} -- [1]: Name [2]: Version [3]: Curve Presets [4]: FPS
local options = {}
local optionsFound = 0
local curvePresets = {}
local defaultOptions = {
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
	controller = {
		enabled = false,
		locked = false,
		color = {1, 1, 1},
		intensity = 0,
		colorControl = false,
		intensityControl = true
	},
	cleaner = {
		enabled = false,
		locked = false,
		curve = 1,
		multiplier = 0.2,
		fallbackSize = 10,
		removeVisibleDebris = true,
		removeActiveDebris = true
	},
	stabilizer = {
		enabled = false,
		locked = false,
		curve = 1,
		multiplier = 0.2,
		fallbackSize = 10,
		stabilizeVisibleDebris = true,
		stabilizeActiveObjects = false
	}
}



-- Init event call, executed on level load
hook.add("base.init", "performance.init", function()
	-- Check if the user uses a pre v2 version, if true then switch over to use the newer system.
	if not HasKey("savegame.mod.version") or GetFloat("savegame.mod.version") < data[2] then
		ClearKey("savegame.mod")
		SetFloat("savegame.mod.version", data[2])
		SetString("savegame.mod.keybind", "p")
	end

	for _ in pairs(util.unserialize(GetString("savegame.mod.options"))) do optionsFound = optionsFound + 1 end
	options = (HasKey("savegame.mod.options") and optionsFound > 1) and util.unserialize(GetString("savegame.mod.options")) or defaultOptions
	data[3] = {{"CONSTANT", function(value) return options.cleaner.fallbackSize end}, {"LINEAR", function(value) return math.max(60 - value, 0) end}, {"EXPONENTIAL", function(value) return math.max(30.07462 - (0.00003718851 / -0.1998865) * (1 - math.exp(1) ^ (0.1998865 * value)), 0) end}, {"INVERSE", function(value) return 3.48986 * 10 ^ 12 * value ^ -7.491398 end}}

	InitCore(data, options)
	InitWindow(data, options)
end)

hook.add("base.draw", "performance.draw", function()
	DrawWindow()
end)

hook.add("base.tick", "performance.tick", function(dt)
	TickWindow(dt)
	TickCore(dt)
end)