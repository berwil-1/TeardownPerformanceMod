#include "../utility/math.lua"
#include "../utility/general.lua"

counter = {}

counter.init = function()
	counter.name = "counter"
	counter.data.delta = {}
	counter.data.deltaMax = {}
	counter.data.deltaMin = {}
	counter.data.deltaAverage = {}
	counter.data.body = 0
	counter.data.shape = 0
	counter.data.fire = 0
end

local delta, deltaAverage, body, shape, fire
counter.tick = function(ticks, deltaTime)
	counter.data.delta[#counter.data.delta + 1] = deltaTime
	if ticks % 6 == 0 then
		local max, min, average = MaxMinAverage(counter.data.delta)
		counter.data.deltaMax[#counter.data.deltaMax + 1] = max
		counter.data.deltaMin[#counter.data.deltaMin + 1] = min
		counter.data.deltaAverage[#counter.data.deltaAverage + 1] = average
	end

	if #counter.data.delta > counter.options.duration then table.remove(counter.data.delta, 1) end
	if #counter.data.deltaMax > counter.options.duration then table.remove(counter.data.deltaMax, 1) end
	if #counter.data.deltaMin > counter.options.duration then table.remove(counter.data.deltaMin, 1) end
	if #counter.data.deltaAverage > counter.options.duration then table.remove(counter.data.deltaAverage, 1) end

	counter.data.body = #FindBodies("", true)
	counter.data.shape = #FindShapes("", true)
	counter.data.fire = GetFireCount()
end

counter.draw = function(draws)
	-- Keep the information visible until next update
	delta = Clone(counter.data.delta)
	if draws % math.max(60 - counter.options.frequency, 1) == 0 then
		deltaMax = Clone(counter.data.deltaMax)
		deltaMin = Clone(counter.data.deltaMin)
		deltaAverage = Clone(counter.data.deltaAverage)
		body = counter.data.body
		shape = counter.data.shape
		fire = counter.data.fire
	end

	local data = {
		counter.options.frameCount and { Round(1 / Average(deltaAverage and deltaAverage or {60}), counter.options.accuracy), "FPS" } or nil,
		counter.options.frameCountMax and { Round(1 / Min(deltaMin and deltaMin or {60}), counter.options.accuracy), "MAX" } or nil,
		counter.options.frameCountMin and { Round(1 / Max(deltaMax and deltaMax or {60}), counter.options.accuracy), "MIN" } or nil,
		counter.options.bodyCount and { body and body or 0, "BOD" } or nil,
		counter.options.shapeCount and { shape and shape or 0, "SHA" } or nil,
		counter.options.fireCount and { fire and fire or 0, "FIR" } or nil
	}

	-- Find max text width over all the data
	local textWidth = 0
	UiFont("MOD/assets/font/libsans.ttf", 24)
	for _,value in pairs(data) do
		textWidth = math.max(UiGetTextSize(value[1]), textWidth)
	end

	-- Background
	if counter.options.background then
		local count = Count(data)
		local backWidth = counter.options.graph and 460 or math.max(100 + counter.options.accuracy * 12, 120)
		local backHeight = math.max(40 + count * 20, counter.options.graph and 120 or 0)
		interface.color(visual.hslrgb(counter.options.backColor[1], counter.options.backColor[2], counter.options.backColor[3]), counter.options.backColor[4])
		UiRect(backWidth, backHeight)
	end
	
	-- Graph
	if counter.options.graph then
		interface.text({ text = "dt = " .. Round(GetTimeStep(), 3, 0.005), size = 12, alignment = "left middle", translate = { x = 260, y = 15 } }, theme.text)
		UiPush()
			UiTranslate(120, 135)
			for index = 2, #delta do
				for time = 0, 1, 0.2 do
					local x = Lerp(index - 1, index, time) * 5
					local y = -Clamp(Lerp(delta[index - 1], delta[index], time) * 3000, 30, 100)

					interface.text({ text = ".", alignment = "center middle", translate = { x = x, y = y }, font = "MOD/assets/font/libsans.ttf" }, theme.text)
				end
			end
		UiPop()
	end

	-- Values
	UiPush()
		UiTranslate(15, 30)
		for _,value in pairs(data) do
			textWidth = UiGetTextSize(value[1])
			interface.text({ text = value[1], alignment = "left middle", translate = { x = 0, y = 0 } }, Merge(visual.hslrgb(counter.options.textColor[1], counter.options.textColor[2], counter.options.textColor[3]), {counter.options.textColor[4]}))
			interface.text({ text = value[2], size = 12, alignment = "left middle", translate = { x = textWidth - 4, y = -4 } }, Merge(visual.hslrgb(counter.options.textColor[1], counter.options.textColor[2], counter.options.textColor[3]), {counter.options.textColor[4]}))	
			UiTranslate(0, 20)
		end
	UiPop()
end

local accuracyHeld, frequencyHeld
counter.interface = function()
	UiTranslate(30, 30)

	UiPush()
		-- General
		interface.color(theme.background)
		UiRect(400, 40)
		
		interface.text({ text = "GENERAL", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, theme.text)
		UiTranslate(0, 40)
		
		if interface.buttonSwitch("COUNTER", 400, 60, counter.options.enabled) then
			counter.options.enabled = not counter.options.enabled
		end
		UiTranslate(0, 60)
		
		if interface.buttonSwitch("BACKGROUND", 400, 60, counter.options.background) then
			counter.options.background = not counter.options.background
		end
		UiTranslate(0, 60)

		if interface.buttonText({ text = "RESET", alignment = "left middle", translate = { x = 15, y = 30 } }, 400, 60, theme.buttonReset, theme.text) then
			for name,value in pairs(counter.default) do
				counter.options[name] = Clone(value)
			end
		end
		UiTranslate(0, 90)

		-- FPS
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "FPS", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, theme.text)
		UiTranslate(0, 40)

		if interface.buttonSwitch("SHOW FPS", 400, 60, counter.options.frameCount) then
			counter.options.frameCount = not counter.options.frameCount
		end
		UiTranslate(0, 60)
		
		if interface.buttonSwitch("SHOW MAX", 400, 60, counter.options.frameCountMax) then
			counter.options.frameCountMax = not counter.options.frameCountMax
		end
		UiTranslate(0, 60)
		
		if interface.buttonSwitch("SHOW MIN", 400, 60, counter.options.frameCountMin) then
			counter.options.frameCountMin = not counter.options.frameCountMin
		end
		UiTranslate(0, 60)

		if options.general.experimental then
			if interface.buttonSwitch("SHOW GRAPH", 400, 60, counter.options.graph) then
				counter.options.graph = not counter.options.graph
			end
			UiTranslate(0, 60)
		end

		counter.options.accuracy, accuracyHeld = interface.slider("ACCURACY", Round(counter.options.accuracy, 0, 0.5), 400, 60, 0, 5, theme.button, theme.background, nil, nil, accuracyHeld)
		UiTranslate(0, 60)
		
		counter.options.frequency, frequencyHeld = interface.slider("FREQUENCY", Round(counter.options.frequency, 0, 0.5), 400, 60, 0, 60, theme.button, theme.background, nil, nil, frequencyHeld)
		UiTranslate(0, 90)
	UiPop()
	UiTranslate(430, 0)

	UiPush()
		-- Body
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "BODY", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)

		if interface.buttonSwitch("SHOW BODY", 400, 60, counter.options.bodyCount) then
			counter.options.bodyCount = not counter.options.bodyCount
		end
		UiTranslate(0, 90)

		-- Shape
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "SHAPE", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)

		if interface.buttonSwitch("SHOW SHAPE", 400, 60, counter.options.shapeCount) then
			counter.options.shapeCount = not counter.options.shapeCount
		end
		UiTranslate(0, 90)

		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "FIRE", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)

		if interface.buttonSwitch("SHOW FIRE", 400, 60, counter.options.fireCount) then
			counter.options.fireCount = not counter.options.fireCount
		end
		UiTranslate(0, 90)
	UiPop()
	UiTranslate(430, 0)

	UiPush()
		-- Text
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "TEXT", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)

		counter.options.textColor = interface.colorPicker(counter.options.textColor, 400/480)
		UiTranslate(0, 430)

		-- Background
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "BACKGROUND", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)

		counter.options.backColor = interface.colorPicker(counter.options.backColor, 400/480)
	UiPop()
end