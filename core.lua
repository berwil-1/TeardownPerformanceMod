#include "umf/umf_core.lua"
#include "assets/script/util.lua"

local data
local options
local totalTicks = 0
local frames = {}



function InitCore(dataReference, optionsReference)
	data = dataReference
	options = optionsReference
end

function TickCore(dt)
	-- Average the FPS values every time the total amount of ticks match with the delay.
	if totalTicks % options.counter.delay == 0 then
		data[4] = 0
		for iteration = 1, #frames do
			data[4] = data[4] + frames[iteration]
		end
		data[4] = data[4] / 60
	end

	-- Iterate over all bodies in the scene every 20 ticks (1 / 3 of a in-game second at 60 FPS).
	if totalTicks % 20 == 0 then
		local bodies = GetBodies()

		for bodyIteration = 1, #bodies do
			local body = bodies[bodyIteration]
			local shapes = GetBodyShapes(body)
			local bodyMass = GetBodyMass(body)
			local min, max = GetBodyBounds(body)

			for shapeIteration = 1, #shapes do
				local shape = shapes[shapeIteration]

				-- The controller for all lights in the level, 
				if options.controller.enabled then
					local lights = GetShapeLights(shape)
					
					for lightIteration = 1, #lights do
						local light = lights[lightIteration]
						local lightColor = visual.hslrgb(options.controller.color[1], options.controller.color[2], options.controller.color[3])
						
						if options.controller.colorControl then SetLightColor(light, lightColor[1], lightColor[2], lightColor[3]) end
						if options.controller.intensityControl and options.controller.intensity > .1 then SetLightIntensity(light, options.controller.intensity) else SetLightEnabled(light, false) end
					end
				end

				-- Object stabilizer
				if options.stabilizer.enabled and VecLength(VecSub(max, min)) < 10 then
					if VecLength(VecSub(GetShapeWorldTransform(shape).pos, GetPlayerPos())) > 25 then
						local velocity = GetBodyVelocity(body)
						if IsBodyDynamic(body) and (options.stabilizer.stabilizeActiveObjects or not IsBodyActive(body)) and (options.stabilizer.stabilizeVisibleDebris or not IsBodyVisible(body, 50)) then
							SetBodyDynamic(body, false)
						end
					elseif not IsBodyDynamic(body) then
						SetBodyDynamic(body, true)
						SetBodyVelocity(body, Vec(0, 0, 0))
					end
				end
			end

			-- Debris cleaner
			if options.cleaner.enabled then
				if IsBodyBroken(body) and VecLength(VecSub(max, min)) < curvePresets[options.cleaner.curve][2](math.floor(data[4])) * options.cleaner.multiplier and (bodyMass > 0 and bodyMass < 200) then
					if (options.cleaner.removeActiveDebris or not IsBodyActive(body)) and (options.cleaner.removeVisibleDebris or not IsBodyVisible(body, 50)) and not (HasTag(body, "target") or HasTag(GetBodyShapes(body)[1], "alarmbox")) then
						Delete(body)
					end
				end
			end
		end
	end

	-- Modify the variables to fit the current data
	frames[totalTicks % 60 + 1] = 1 / dt
	totalTicks = totalTicks + 1
end