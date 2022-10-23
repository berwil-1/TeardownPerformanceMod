-- Interface
#include "assets/interface/window.lua"
#include "assets/umf/umf_meta.lua"

local init = function()
	for _, module in pairs(modules) do
		if module.init then
			module.init()
		end
	end
end

local ticks = 0
local bodies, shapes
local drawInterface = false
local tick = function(deltaTime)
	if InputDown("alt") and InputPressed(modules[1].options.keybind) then
		SetString("savegame.mod.options", util.serialize(options))
		drawInterface = not drawInterface
	end

	local bodies = FindBodies("", true)
	local shapes = FindShapes("", true)
	local lights = FindLights("", true)

	-- Iterate functions available on all entities once,
	-- hooks to bodies, shapes and lights should always be used since they minimize the amount of iterations needed.
	for _, module in pairs(modules) do
		if module.options.enabled then
			if module.tick then module.tick(ticks, deltaTime) end

			local bodyLength = #bodies
			local shapeLength = #shapes
			local lightLength = #lights

			for index = 1, math.max(bodyLength, shapeLength, lightLength) do
				if index <= bodyLength and module.body then module.body(bodies[index]) end
				if index <= shapeLength and module.shape then module.shape(shapes[index]) end
				if index <= lightLength and module.light then module.light(lights[index]) end
			end
		end
	end

	ticks = ticks + 1
end

local time = 0
local draws = 0
local draw = function()
	for _, module in pairs(modules) do
		if module.draw and module.options.enabled then
			UiPush()
				module.draw(draws)
			UiPop()
		end
	end

	draws = draws + 1
end

local interface = function()
	if drawInterface then
		UiPush()
			DrawInterface()
		UiPop()
	end
end

local pressed = function(key)
	for _, module in pairs(modules) do
		if module.pressed then
			UiPush()
				module.pressed(key)
			UiPop()
		end
	end
end

local released = function(key)
	for _, module in pairs(modules) do
		if module.released then
			UiPush()
				module.released(key)
			UiPop()
		end
	end
end

hook.add("base.init", "performance.init", init)
hook.add("base.tick", "performance.tick", tick)
hook.add("base.draw", "performance.draw", draw)
hook.add("base.draw", "performance.interface", interface)
hook.add("base.command.quickload", "performance.quickload", init)
hook.add("api.key.pressed", "performance.key.pressed", pressed)
hook.add("api.key.released", "performance.key.released", released)