#include "umf/umf_3d.lua"



-- Variables
local version = 2.0
local tick = 0
local frames = {}
local framesPerSecond = 60
local options = {}
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
local window = {
	enabled = false,
	interact = false,
	navbar = true,
	page = 1,
	pages = {
		-- INFO COUNTER
		{
			name = "counter",
			title = "INFO COUNTER",
			draw = function(x0, y0, x1, y1)
				-- Account for navbar size and draw background.
				UiAlign("left")
				UiTranslate(x0, 0)
				UiColor(0, 0, 0, .8)
				UiRect(x1, y1)

				-- Draw counter full-size preview background
				UiPush()
					UiTranslate(1080, 0)
					local backColor = visual.hslrgb(options.counter.backColor[1][1], options.counter.backColor[1][2], options.counter.backColor[1][3])
					UiColor(backColor[1], backColor[2], backColor[3], options.counter.backColor[2])
					UiRect(600, y1)

					local textColor = visual.hslrgb(options.counter.textColor[1][1], options.counter.textColor[1][2], options.counter.textColor[1][3])
					UiColor(textColor[1], textColor[2], textColor[3], options.counter.textColor[2])

					local counts = {{options.counter.frameCount, GetFrameCount(), "FPS"}, {options.counter.bodyCount, GetBodyCount(), "BOD"}, {options.counter.shapeCount, GetShapeCount(), "SHA"}, {options.counter.fireCount, GetFireCount(), "FIR"}}
					
					UiTranslate(25, 75)
					for countIteration = 1, 4 do
						if counts[countIteration][1] then
							UiPush()
								UiAlign("left middle")
								UiFont("bold.ttf", 100)
								UiText(counts[countIteration][2])

								UiAlign("right")
								UiTranslate(550, 0)
								UiFont("bold.ttf", 60)
								UiText(counts[countIteration][3])
							UiPop()
							UiTranslate(0, 100)
						end
					end
				UiPop()

				-- Draw settings elements
				UiWindow(1320 - x0, y1, false)
				UiPush()
					UiTranslate(30, 30)
					UiFont("bold.ttf", 18)

					-- Left side elements
					UiPush()
						-- Button text
						UiPush()
							UiColor(1, 1, 1, 1)
							UiAlign("center middle")

							if UiTextedButton(options.counter.enabled and "ENABLED" or "DISABLED", "center middle", 240, 60, options.counter.enabled and {0, 1, 0, .5} or {1, 0, 0, .5}, {1, 1, 1, 1}) then options.counter.enabled = not options.counter.enabled end
							UiTranslate(240, 0)
							if UiTextedButton("RESET", "center middle", 240, 60, {1, 0, 0, .5}, {1, 1, 1, 1}) then options.counter = util.unserialize(util.serialize(defaultOptions.counter)) end
						UiPop()

						-- Alignment window
						UiTranslate(0, 90)
						UiColor(0, 0, 0, .5)
						UiRect(UiCenter() - 60, 108 / 192 * (UiCenter() - 60))
						UiPush()
							UiTranslate(420 / 1920 * options.counter.position[1], (270 - y1 / 10) / 1080 * options.counter.position[2])
							UiColor(0, 0, 0, .5)
							UiRect(60, y1 / 10)
						UiPop()
						
						-- Alignment buttons
						UiTranslate(0, 108 / 192 * (UiCenter() - 60))
						UiPush()
							local buttonPositions = {{"TL", {0, 0}}, {"TM", {x1 / 2, 0}}, {"TR", {x1, 0}}, {"ML", {0, y1 / 2}}, {"MR", {x1, y1 / 2}}, {"BL", {0, y1}}, {"BM", {x1 / 2, y1}}, {"BR", {x1, y1}}}
							UiFont("bold.ttf", 16)

							for buttonIteration = 1, #buttonPositions do
								if UiTextedButton(buttonPositions[buttonIteration][1], "center middle", 60, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
									options.counter.position = buttonPositions[buttonIteration][2]
								end
								UiTranslate(60, 0)
							end
						UiPop()

						-- Background color picker
						UiTranslate(0, 90)
						UiPush()
							UiPush()
								UiColor(0, 0, 0, .7)
								UiRect(240, 30)

								UiAlign("center middle")
								UiTranslate(120, 15)
								UiColor(1, 1, 1, 1)
								UiText("BACKGROUND COLOR")
							UiPop()

							UiTranslate(0, 30)
							options.counter.backColor[1] = UiColorPicker(options.counter.backColor[1], .5)
						UiPop()

						-- Text color picker
						UiTranslate(240, 0)
						UiPush()
							UiPush()
								UiColor(0, 0, 0, .7)
								UiRect(240, 30)

								UiAlign("center middle")
								UiTranslate(120, 15)
								UiColor(1, 1, 1, 1)
								UiText("TEXT COLOR")
							UiPop()
							
							UiTranslate(0, 30)
							options.counter.textColor[1] = UiColorPicker(options.counter.textColor[1], .5)
						UiPop()
					UiPop()

					-- Right side elements
					UiPush()
						UiTranslate(540, 0)

						-- Delay slider
						UiPush()
							UiColor(0, 0, 0, .7)
							UiRect(480, 30)

							UiAlign("center middle")
							UiTranslate(240, 15)
							UiColor(1, 1, 1, 1)
							UiText("FPS FREQUENCY DELAY")
						UiPop()
						UiTranslate(0, 30)
						UiPush()
							options.counter.delay = Round(UiColoredSlider(options.counter.delay, 0, 60, 480, 60, {0, 0, 0, .5}, {0, 0, 0, .2}))
						UiPop()
						UiTranslate(0, 90)

						-- Extra modification buttons
						if UiTextedButton(options.counter.backColor[2] == 0.5 and "HIDE BACKGROUND" or "SHOW BACKGROUND", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
							options.counter.backColor[2] = options.counter.backColor[2] == .5 and 0 or 0.5
						end

						UiTranslate(0, 90)
						if UiTextedButton(options.counter.frameCount and "HIDE FRAME COUNT" or "SHOW FRAME COUNT", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
							options.counter.frameCount = not options.counter.frameCount
						end

						UiTranslate(0, 90)						
						if UiTextedButton(options.counter.bodyCount and "HIDE BODY COUNT" or "SHOW BODY COUNT", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
							options.counter.bodyCount = not options.counter.bodyCount
						end

						UiTranslate(0, 90)
						if UiTextedButton(options.counter.shapeCount and "HIDE SHAPE COUNT" or "SHOW SHAPE COUNT", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
							options.counter.shapeCount = not options.counter.shapeCount
						end

						UiTranslate(0, 90)
						if UiTextedButton(options.counter.fireCount and "HIDE FIRE COUNT" or "SHOW FIRE COUNT", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
							options.counter.fireCount = not options.counter.fireCount
						end

						UiTranslate(0, 90)
						if UiTextedButton(options.counter.accuracy == 0 and "MORE ACCURACY" or "LESS ACCURACY", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
							options.counter.accuracy = options.counter.accuracy == 2 and 0 or 2
						end
					UiPop()
				UiPop()
			end
		},

		-- LIGHT CONTROLLER
		{
			name = "controller",
			title = "LIGHT CONTROLLER",
			draw = function(x0, y0, x1, y1)
				-- Account for navbar size and draw background.
				UiAlign("left")
				UiTranslate(x0, 0)
				UiColor(0, 0, 0, .8)
				UiRect(x1, y1)

				-- Draw setting elements
				UiWindow(1320 - x0, y1, false)
				UiPush()
					UiTranslate(30, 30)
					UiFont("bold.ttf", 18)

					-- Draw controller flare preview.
					UiPush()
						local color = visual.hslrgb(options.controller.color[1], options.controller.color[2], options.controller.color[3])
						UiAlign("center middle")
						UiTranslate(1380, y1 / 2)

						UiColor(1, 1, 1, 1)
						UiImage("assets/gfx/previews/light_pole.png")

						UiTranslate(0, -220)
						UiColor(color[1], color[2], color[3], 1)
						UiImage("assets/gfx/previews/flare.png")
					UiPop()

					-- Left side elements
					UiPush()
						-- Button text
						UiPush()
							UiColor(1, 1, 1, 1)
							UiAlign("center middle")

							if UiTextedButton(options.controller.enabled and "ENABLED" or "DISABLED", "center middle", 240, 60, options.controller.enabled and {0, 1, 0, .5} or {1, 0, 0, .5}, {1, 1, 1, 1}) then options.controller.enabled = not options.controller.enabled end
							UiTranslate(240, 0)
							if UiTextedButton("RESET", "center middle", 240, 60, {1, 0, 0, .5}, {1, 1, 1, 1}) then options.controller = util.unserialize(util.serialize(defaultOptions.controller)) end
						UiPop()
					
						-- Text color picker
						UiTranslate(0, 90)
						UiPush()
							UiColor(0, 0, 0, .7)
							UiRect(480, 30)

							UiAlign("center middle")
							UiTranslate(240, 15)
							UiColor(1, 1, 1, 1)
							UiText("LIGHT COLOR")
						UiPop()
						UiTranslate(0, 30)
						options.controller.color = UiColorPicker(options.controller.color, 1)
					UiPop()

					-- Right side elements
					UiPush()
						UiTranslate(540, 0)

						-- Delay slider
						UiPush()
							UiColor(0, 0, 0, .7)
							UiRect(480, 30)

							UiAlign("center middle")
							UiTranslate(240, 15)
							UiColor(1, 1, 1, 1)
							UiText("LIGHT INTENSITY")
						UiPop()
						UiTranslate(0, 30)
						UiPush()
							options.controller.intensity = Round(UiColoredSlider(options.controller.intensity, 0, 10, 480, 60, {0, 0, 0, .5}, {0, 0, 0, .2}))
						UiPop()
						UiTranslate(0, 90)

						-- Extra modification buttons
						if UiTextedButton(options.controller.colorControl and "DISABLE COLOR" or "ENABLE COLOR", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
							options.controller.colorControl = not options.controller.colorControl
						end

						UiTranslate(0, 90)
						if UiTextedButton(options.controller.intensityControl and "DISABLE INTENSITY" or "ENABLE INTENSITY", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
							options.controller.intensityControl = not options.controller.intensityControl
						end
					UiPop()
				UiPop()
			end
		},

		-- DEBRIS CLEANER
		{
			name = "cleaner",
			title = "DEBRIS CLEANER",
			draw = function(x0, y0, x1, y1)
				-- Account for navbar size and draw background.
				UiAlign("left")
				UiTranslate(x0, 0)
				UiColor(0, 0, 0, .8)
				UiRect(x1, y1)

				-- Draw setting elements
				UiWindow(1320 - x0, y1, false)
				UiPush()
					UiTranslate(30, 30)
					UiFont("bold.ttf", 18)

					-- Draw cleaner debris preview.
					UiPush()
						UiAlign("center middle")
						UiTranslate(1380, y1 / 2)

						UiColor(1, 1, 1, 1)
						UiImage("assets/gfx/previews/debris.png")
					UiPop()

					-- Left side elements
					UiPush()
						UiPush()
							-- Button text
							UiPush()
								UiColor(1, 1, 1, 1)
								UiAlign("center middle")

								if UiTextedButton(options.cleaner.enabled and "ENABLED" or "DISABLED", "center middle", 240, 60, options.cleaner.enabled and {0, 1, 0, .5} or {1, 0, 0, .5}, {1, 1, 1, 1}) then options.cleaner.enabled = not options.cleaner.enabled end
								UiTranslate(240, 0)
								if UiTextedButton("RESET", "center middle", 240, 60, {1, 0, 0, .5}, {1, 1, 1, 1}) then options.cleaner = util.unserialize(util.serialize(defaultOptions.cleaner)) end
							UiPop()
						UiPop()

						-- Graph window
						local graphWidth = UiCenter() - 60
						UiTranslate(0, 90)
						UiColor(0, 0, 0, .2)
						UiRect(graphWidth, graphWidth)
						UiPush()
							UiAlign("left top")
							UiTranslate(10, 10)
							UiColor(1, 1, 1, 1)
							UiFont("bold.ttf", 12)
							UiText("SIZE")

							UiAlign("right bottom")
							UiTranslate(graphWidth - 20, graphWidth - 20)
							UiText("FPS")
						UiPop()
						UiTranslate(0, graphWidth)

						-- Graph function
						UiPush()
							local curveFunction = curvePresets[options.cleaner.curve][2]
							local previousY = curveFunction(30)
							for x = 31, 60 do
								UiDrawLine(graphWidth / 30, (curveFunction(x) - previousY) * (graphWidth / 30), 1, 1, 1, 1)
								UiTranslate(graphWidth / 30, (curveFunction(x) - previousY) * (graphWidth / 30))
								previousY = curveFunction(x)
							end
						UiPop()

						-- Curve buttons
						UiPush()
							UiFont("bold.ttf", 16)
							for buttonIteration = 1, #curvePresets do
								local curveName = curvePresets[buttonIteration][1]
								if UiTextedButton(curveName, "center middle", (UiCenter() - 60) / 4, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
									options.cleaner.curve = buttonIteration
								end
								UiTranslate((UiCenter() - 60) / 4, 0)
							end
						UiPop()
						UiTranslate(0, 90)

						-- Delay slider
						UiPush()
							UiColor(0, 0, 0, .7)
							UiRect(480, 30)

							UiAlign("center middle")
							UiTranslate(240, 15)
							UiColor(1, 1, 1, 1)
							UiText("SIZE MULTIPLIER")
						UiPop()
						UiTranslate(0, 30)
						UiPush()
							options.cleaner.multiplier = Round(UiColoredSlider(options.cleaner.multiplier, 0, 1, 480, 60, {0, 0, 0, .5}, {0, 0, 0, .2}), 2, .005)
						UiPop()
						UiTranslate(0, 90)
					UiPop()

					-- Right side elements
					UiPush()
						UiTranslate(540, 0)

						-- Extra modification buttons
						if UiTextedButton(options.cleaner.removeVisibleDebris and "IGNORE VISIBLE" or "REMOVE VISIBLE", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
							options.cleaner.removeVisibleDebris = not options.cleaner.removeVisibleDebris
						end

						UiTranslate(0, 90)
						if UiTextedButton(options.cleaner.removeActiveDebris and "IGNORE ACTIVE" or "REMOVE ACTIVE", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
							options.cleaner.removeActiveDebris = not options.cleaner.removeActiveDebris
						end
					UiPop()
				UiPop()
			end
		},

		-- OBJECT STABILIZER
		{
			name = "stabilizer",
			title = "OBJECT STABILIZER",
			draw = function(x0, y0, x1, y1)
				-- Account for navbar size and draw background.
				UiAlign("left")
				UiTranslate(x0, 0)
				UiColor(0, 0, 0, .8)
				UiRect(x1, y1)

				-- Draw setting elements
				UiWindow(1320 - x0, y1, false)
				UiPush()
					UiTranslate(30, 30)
					UiFont("bold.ttf", 18)

					-- Draw stabilizer object preview.
					UiPush()
						UiAlign("center middle")
						UiTranslate(1380, y1 / 2)

						UiColor(1, 1, 1, 1)
						UiImage("assets/gfx/previews/object.png")
					UiPop()

					-- Left side elements
					UiPush()
						UiPush()
							-- Button text
							UiPush()
								UiColor(1, 1, 1, 1)
								UiAlign("center middle")

								if UiTextedButton(options.stabilizer.enabled and "ENABLED" or "DISABLED", "center middle", 240, 60, options.stabilizer.enabled and {0, 1, 0, .5} or {1, 0, 0, .5}, {1, 1, 1, 1}) then options.stabilizer.enabled = not options.stabilizer.enabled end
								UiTranslate(240, 0)
								if UiTextedButton("RESET", "center middle", 240, 60, {1, 0, 0, .5}, {1, 1, 1, 1}) then options.stabilizer = util.unserialize(util.serialize(defaultOptions.stabilizer)) end
							UiPop()
						UiPop()

						-- Graph window
						local graphWidth = UiCenter() - 60
						local curvePresets = {{"CONSTANT", function(value) return options.stabilizer.fallbackSize end}, {"LINEAR", function(value) return 60 - value end}, {"EXPONENTIAL", function(value) return 30.07462 - (0.00003718851 / -0.1998865) * (1 - math.exp(1) ^ (0.1998865 * value)) end}, {"INVERSE", function(value) return 3.48986 * 10 ^ 12 * value ^ -7.491398 end}}
						UiTranslate(0, 90)
						UiColor(0, 0, 0, .2)
						UiRect(graphWidth, graphWidth)
						UiPush()
							UiAlign("left top")
							UiTranslate(10, 10)
							UiColor(1, 1, 1, 1)
							UiFont("bold.ttf", 12)
							UiText("SIZE")

							UiAlign("right bottom")
							UiTranslate(graphWidth - 20, graphWidth - 20)
							UiText("FPS")
						UiPop()
						UiTranslate(0, graphWidth)

						-- Graph function
						UiPush()
							local curveFunction = curvePresets[options.stabilizer.curve][2]
							local previousY = curveFunction(30)
							for x = 31, 60 do
								UiDrawLine(graphWidth / 30, (curveFunction(x) - previousY) * (graphWidth / 30), 1, 1, 1, 1)
								UiTranslate(graphWidth / 30, (curveFunction(x) - previousY) * (graphWidth / 30))
								previousY = curveFunction(x)
							end
						UiPop()

						-- Curve buttons
						UiPush()
							UiFont("bold.ttf", 16)
							for buttonIteration = 1, #curvePresets do
								local curveName = curvePresets[buttonIteration][1]
								if UiTextedButton(curveName, "center middle", (UiCenter() - 60) / 4, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
									options.stabilizer.curve = buttonIteration
								end
								UiTranslate((UiCenter() - 60) / 4, 0)
							end
						UiPop()
						UiTranslate(0, 90)

						-- Size slider
						UiPush()
							UiColor(0, 0, 0, .7)
							UiRect(480, 30)

							UiAlign("center middle")
							UiTranslate(240, 15)
							UiColor(1, 1, 1, 1)
							UiText("SIZE MULTIPLIER")
						UiPop()
						UiTranslate(0, 30)
						UiPush()
							options.stabilizer.multiplier = Round(UiColoredSlider(options.stabilizer.multiplier, 0, 1, 480, 60, {0, 0, 0, .5}, {0, 0, 0, .2}), 2, .005)
						UiPop()
						UiTranslate(0, 90)
					UiPop()

					-- Right side elements
					UiPush()
						UiTranslate(540, 0)

						-- Extra modification buttons
						if UiTextedButton(options.stabilizer.stabilizeVisibleDebris and "IGNORE VISIBLE" or "STABILIZE VISIBLE", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
							options.stabilizer.stabilizeVisibleDebris = not options.stabilizer.stabilizeVisibleDebris
						end

						UiTranslate(0, 90)
						if UiTextedButton(options.stabilizer.stabilizeActiveObjects and "IGNORE ACTIVE" or "STABILIZE ACTIVE", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
							options.stabilizer.stabilizeActiveObjects = not options.stabilizer.stabilizeActiveObjects
						end
					UiPop()
				UiPop()
			end
		}
	}
}



-- Init event call, executed on level load
hook.add("base.init", "performance.init", function()
	options = HasKey("savegame.mod.options") and util.unserialize(GetString("savegame.mod.options")) or defaultOptions
	curvePresets = {{"CONSTANT", function(value) return options.cleaner.fallbackSize end}, {"LINEAR", function(value) return math.max(60 - value, 0) end}, {"EXPONENTIAL", function(value) return math.max(30.07462 - (0.00003718851 / -0.1998865) * (1 - math.exp(1) ^ (0.1998865 * value)), 0) end}, {"INVERSE", function(value) return 3.48986 * 10 ^ 12 * value ^ -7.491398 end}}

	-- Check if the user uses a pre v2 version, if true then switch over to use the newer system.
	if not HasKey("savegame.mod.version") then
		ClearKey("savegame.mod")
		SetFloat("savegame.mod.version", version)
		SetString("savegame.mod.keybind", "p")
	end
end)

hook.add("base.draw", "performance.draw", function()
	local x0, y0, x1, y1 = UiSafeMargins()
	
	-- Draw the performance window
	if window.enabled then
		if window.interact then
			UiMakeInteractive()
		end

		UiPush()
			SetBool("hud.aimdot", false)
			UiWindow(x1 - x0, y1 - y0, true)
			UiAlign("center middle")
			UiColor(1, 1, 1, 1)

			if window.navbar then
				UiPush()
					UiPush()
						UiAlign("left")
						UiColor(0, 0, 0, .9)
						UiRect(240, y1)
						x0 = x0 + 240
					UiPop()

					for pageIteration = 1, #window.pages do
						local pageName = window.pages[pageIteration].name
						local pageOptions = options[pageName]
						local textColor = pageOptions.locked and {1, .9, .9} or (pageOptions.enabled and {.9, 1, .9} or {1, .95, .9})

						UiFont("bold.ttf", 18)
						if UiTextedButton(window.pages[pageIteration].title, "center middle", 240, 60, {0, 0, 0, 0}, {1, 1, 1}) then
							window.page = pageIteration
						end

						if window.page == pageIteration then
							UiPush()
								UiAlign("left")
								UiColor(1, 1, 1, .1)
								UiRect(240, 60)
							UiPop()
						end
						
						UiTranslate(0, 60)
					end
				UiPop()
			end

			UiPush()
				window.pages[window.page].draw(x0, y0, x1, y1)
			UiPop()
		UiPop()
	else
		-- Draw the information counter
		if options.counter.enabled then
			UiInformationCounter(0, 0, 1)
		end
	end
end)

hook.add("base.tick", "performance.tick", function(dt)
	-- Open the performance window and save options.
	if InputDown("alt") and InputPressed(GetString("savegame.mod.keybind")) then
		window.enabled = not window.enabled
		window.interact = not window.interact
		SetString("savegame.mod.options", util.serialize(options))
	elseif InputPressed("esc") then
		SetString("savegame.mod.options", util.serialize(options))
	end

	-- Average the FPS values
	if tick % options.counter.delay == 0 then
		framesPerSecond = 0
		for iteration = 1, #frames do
			framesPerSecond = framesPerSecond + frames[iteration]
		end
		framesPerSecond = framesPerSecond / 60
	end

	-- Iterate over all bodies in the scene every 20 ticks (1 / 3 of a in-game second at 60 FPS).
	if tick % 20 == 0 then
		local bodies = GetBodies()

		for bodyIteration = 1, #bodies do
			local body = bodies[bodyIteration]
			local shapes = GetBodyShapes(body)
			local bodyMass = GetBodyMass(body)
			local min, max = GetBodyBounds(body)

			for shapeIteration = 1, #shapes do
				local shape = shapes[shapeIteration]

				-- Lights controller
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
				if IsBodyBroken(body) and VecLength(VecSub(max, min)) < curvePresets[options.cleaner.curve][2](math.floor(framesPerSecond)) * options.cleaner.multiplier and (bodyMass > 0 and bodyMass < 200) then
					if (options.cleaner.removeActiveDebris or not IsBodyActive(body)) and (options.cleaner.removeVisibleDebris or not IsBodyVisible(body, 50)) and not (HasTag(body, "target") or HasTag(GetBodyShapes(body)[1], "alarmbox")) then
						Delete(body)
					end
				end
			end
		end
	end

	-- Modify the variables to fit the current data
	frames[tick % 60 + 1] = 1 / dt
	tick = tick + 1
end)



-- Global functions
	function GetBodies(require)
		QueryRequire(require and require or "")
		return QueryAabbBodies(Vec(-math.huge, -math.huge, -math.huge),Vec(math.huge, math.huge, math.huge))
	end
	function GetBodyCount(require)
		QueryRequire(require and require or "")
		return #QueryAabbBodies(Vec(-math.huge, -math.huge, -math.huge),Vec(math.huge, math.huge, math.huge))
	end

	function GetShapes(require)
		return QueryAabbShapes(Vec(-math.huge, -math.huge, -math.huge), Vec(math.huge, math.huge, math.huge))
	end
	function GetShapeCount(require)
		return #QueryAabbShapes(Vec(-math.huge, -math.huge, -math.huge), Vec(math.huge, math.huge, math.huge))
	end

-- Mathematical functions
	function Round(value, decimals, overflow)
		decimals = decimals or 0
		overflow = overflow or .5
		return math.floor((value + overflow) * 10 ^ decimals) / 10 ^ decimals
	end

	function GetFrameCount()
		local accuracy = math.pow(10, framesPerSecond >= 100 and math.max(options.counter.accuracy - 1, 0) or options.counter.accuracy)
		return math.floor(framesPerSecond * accuracy) / accuracy
	end

-- UI functions
	function UiDrawLine(dx, dy, r, g, b, a)
		UiPush()
			UiColor(r, g, b, a)
			UiRotate(math.atan2(-dy, dx) * 180 / math.pi)
			UiRect((dx * dx + dy * dy) ^ .5, 1)
		UiPop()
	end

	function UiEmptyButton(w, h, backColor)
		UiAlign("left")

		local info = {UiIsMouseInRect(w, h), InputPressed("lmb"), InputDown("lmb")}
		local colorOffset = (info[1] and info[3]) and .1 or 0

		-- Button background
		UiPush()
			UiColor(backColor[1] - colorOffset, backColor[2] - colorOffset, backColor[3] - colorOffset, backColor[4] ~= nil and backColor[4] or 1)
			UiRect(w, h)
		UiPop()

		return info
	end

	function UiTextedButton(text, align, w, h, backColor, textColor)
		local info = UiEmptyButton(w, h, backColor)
		local colorOffset = (info[1] and info[3]) and .1 or 0

		-- Button text
		UiPush()
			UiTranslate(w / 2 + ((info[1] and info[3]) and 2 or 0), h / 2 + ((info[1] and info[3]) and 2 or 0))
			UiAlign(align)
			UiColor(textColor[1] + colorOffset, textColor[2] + colorOffset, textColor[3] + colorOffset, textColor[4] ~= nil and textColor[4] or 1)
			UiText(text)
		UiPop()

		return info[1] and info[2], info[1] and info[3]
	end

	function UiColoredSlider(value, rangeMin, rangeMax, w, h, backColor, sliderColor)
		local info = {UiIsMouseInRect(w, h), InputPressed("lmb"), InputDown("lmb")}
		
		UiPush()
			-- Slider background
			UiAlign("left")
			UiColor(backColor[1], backColor[2], backColor[3], backColor[4] ~= nil and backColor[4] or 1)
			UiRect(w, h)
		UiPop()

		-- Slider button
		local valueWidth = w / rangeMax
		local widthValue = rangeMax / w
		local x = (info[1] and info[3]) and UiGetMousePos() or (valueWidth * value)
		local slider =  UiEmptyButton(x, h, sliderColor)

		return widthValue * x
	end

	function UiColorPicker(lastColor, scale)
		local size = (480 * scale)
		local mouseX, mouseY = UiGetMousePos()
		local positions = (UiIsMouseInRect(size, size) and InputDown("lmb")) and {1 / size * math.min(math.max(mouseX, 0), size), 1, 1 / size * math.min(math.max(mouseY, 0), size)} or lastColor
		local color = visual.hslrgb(positions[1], positions[2], positions[3])

		UiPush()
			UiScale(scale)
			UiColor(1, 1, 1, 1)
			UiImage("assets/gfx/palette/palette.png")
			UiPush()
				local invserseColorLightness = visual.hslrgb(0, 0, 1 - positions[3])
				UiAlign("center middle")
				UiTranslate(480 * positions[1], 480 * positions[3])
				UiScale(.1 / scale)
				UiColor(invserseColorLightness[1], invserseColorLightness[2], invserseColorLightness[3])
				UiImage("assets/gfx/palette/palette_pointer.png")
			UiPop()
		UiPop()

		return positions
	end

	function UiInformationCounter(x, y, scale)
		UiPush()
			local color = visual.hslrgb(options.counter.textColor[1][1], options.counter.textColor[1][2], options.counter.textColor[1][3])
			local xAlignments = {"left", "center", "right"}
			local yAlignments = {"top", "middle", "bottom"}
			local xAlignment = Round(2 * options.counter.position[1] / UiWidth())
			local yAlignment = Round(2 * options.counter.position[2] / UiHeight())

			local enabledCounts = 0
			local counts = {{options.counter.frameCount, GetFrameCount(), "FPS"}, {options.counter.bodyCount, GetBodyCount(), "BOD"}, {options.counter.shapeCount, GetShapeCount(), "SHA"}, {options.counter.fireCount, GetFireCount(), "FIR"}}
			for enabledCountsIteration = 1, #counts do
				enabledCounts = enabledCounts + (counts[enabledCountsIteration][1] and 1 or 0)
			end

			-- Draw the counter background
			local backgroundSize = 15 * enabledCounts * scale + (enabledCounts > 0 and 5 or 0) * scale
			local backgroundColor = visual.hslrgb(options.counter.backColor[1][1], options.counter.backColor[1][2], options.counter.backColor[1][3])
			UiAlign(xAlignments[xAlignment + 1] .. yAlignments[yAlignment + 1])
			UiTranslate(options.counter.position[1] + x, options.counter.position[2] + y)
			UiColor(backgroundColor[1], backgroundColor[2], backgroundColor[3], options.counter.backColor[2])
			UiRect(60 * scale, backgroundSize)

			-- Configure counter text sizes and color
			UiAlign("left middle")
			UiTranslate(-30 * xAlignment * scale, -backgroundSize * (yAlignment / 2) + 10 * options.counter.size)
			UiFont("bold.ttf", options.counter.textSize * scale)
			UiColor(color[1], color[2], color[3], options.counter.textColor[2])

			for countIteration = 1, #counts do
				local count = counts[countIteration]

				if count[1] then
					UiPush()
						UiFont("bold.ttf", options.counter.textSize * scale - 4 * math.floor(count[2] / 10000))
						UiText(count[2])

						UiAlign("right")
						UiTranslate(60 * scale, 0)
						UiFont("bold.ttf", 8 * scale)
						UiText(count[3])
					UiPop()
					UiTranslate(0, 15 * scale)
				end
			end
		UiPop()
	end