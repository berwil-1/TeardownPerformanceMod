#include "assets/scripts/util.lua"

local data
local options
local draws = 0
local fallbackOptions
local window



function InitWindow(dataReference, optionsReference)
	data = dataReference
	fallbackOptions = optionsReference[1]
	options = optionsReference[2]
	window = {
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
					-- Account for navbar size and draw background
					UiAlign("left")
					UiTranslate(x0, 0)
					UiColor(0, 0, 0, .8)
					UiRect(x1, y1)

					-- Draw counter full-size preview background
					UiPush()
						UiTranslate(1110, 0)
						local backColor = visual.hslrgb(options.counter.backColor[1][1], options.counter.backColor[1][2], options.counter.backColor[1][3])
						UiColor(backColor[1], backColor[2], backColor[3], options.counter.backColor[2])
						UiRect(600, y1)

						local textColor = visual.hslrgb(options.counter.textColor[1][1], options.counter.textColor[1][2], options.counter.textColor[1][3])
						UiColor(textColor[1], textColor[2], textColor[3], options.counter.textColor[2])

						local counts = {{options.counter.frameCount, CalculateFrameAccuracy(data[4], options), "FPS"}, {options.counter.bodyCount, GetBodyCount(VecSub(GetPlayerPos(), Vec(100, 100, 100)), VecAdd(GetPlayerPos(), Vec(100, 100, 100))), "BOD"}, {options.counter.shapeCount, GetShapeCount(VecSub(GetPlayerPos(), Vec(100, 100, 100)), VecAdd(GetPlayerPos(), Vec(100, 100, 100))), "SHA"}, {options.counter.fireCount, GetFireCount(), "FIR"}}
						
						UiTranslate(25, 75)
						for countIteration = 1, 4 do
							if counts[countIteration][1] then
								UiPush()
									UiAlign("left middle")
									UiFont("bold.ttf", 100)
									UiText(counts[countIteration][2])

									UiAlign("right")
									UiTranslate(520, 0)
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
							-- Enable and reset buttons
							UiPush()
								UiColor(1, 1, 1, 1)
								UiAlign("center middle")

								if UiTextedButton(options.counter.enabled and "ENABLED" or "DISABLED", "center middle", 240, 60, options.counter.enabled and {0, 1, 0, .5} or {1, 0, 0, .5}, {1, 1, 1, 1}) then options.counter.enabled = not options.counter.enabled end
								UiTranslate(240, 0)
								if UiTextedButton("RESET", "center middle", 240, 60, {1, 0, 0, .5}, {1, 1, 1, 1}) then options.counter = Clone(fallbackOptions.counter)	end
							UiPop()
							UiTranslate(0, 90)

							-- Alignment window title
							UiPush()
								UiColor(0, 0, 0, .7)
								UiRect(480, 30)

								UiAlign("center middle")
								UiTranslate(240, 15)
								UiColor(1, 1, 1, 1)
								UiText("POSITION")
							UiPop()
							UiTranslate(0, 30)
							
							-- Alignment buttons
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
							UiTranslate(0, 90)

							-- Background color picker
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
							UiTranslate(240, 0)

							-- Text color picker
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

							-- FPS update delay title
							UiPush()
								UiColor(0, 0, 0, .7)
								UiRect(480, 30)

								UiAlign("center middle")
								UiTranslate(240, 15)
								UiColor(1, 1, 1, 1)
								UiText("FPS UPDATE DELAY")
							UiPop()
							UiTranslate(0, 30)

							-- FPS update delay slider
							UiPush()
								options.counter.delay = Round(UiColoredSlider(options.counter.delay, 0, 60, 480, 60, {0, 0, 0, .5}, {0, 0, 0, .2}))
							UiPop()
							UiTranslate(0, 90)

							-- Extra modification buttons
							if UiTextedButton(options.counter.backColor[2] == 0.5 and "BACKGROUND SHOWN" or "BACKGROUND HIDDEN", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
								options.counter.backColor[2] = options.counter.backColor[2] == .5 and 0 or 0.5
							end
							UiTranslate(0, 90)

							if UiTextedButton(options.counter.frameCount and "FRAME COUNT SHOWN" or "FRAME COUNT HIDDEN", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
								options.counter.frameCount = not options.counter.frameCount
							end
							UiTranslate(0, 90)						

							if UiTextedButton(options.counter.bodyCount and "BODY COUNT SHOWN" or "BODY COUNT HIDDEN", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
								options.counter.bodyCount = not options.counter.bodyCount
							end
							UiTranslate(0, 90)

							if UiTextedButton(options.counter.shapeCount and "SHAPE COUNT SHOWN" or "SHAPE COUNT", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
								options.counter.shapeCount = not options.counter.shapeCount
							end
							UiTranslate(0, 90)

							if UiTextedButton(options.counter.fireCount and "FIRE COUNT SHOWN" or "SHOW FIRE COUNT", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
								options.counter.fireCount = not options.counter.fireCount
							end
							UiTranslate(0, 90)

							if UiTextedButton(options.counter.accuracy == 0 and "LOW ACCURACY" or "HIGH ACCURACY", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
								options.counter.accuracy = options.counter.accuracy == 2 and 0 or 2
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
					-- Account for navbar size and draw background
					UiAlign("left")
					UiTranslate(x0, 0)
					UiColor(0, 0, 0, .8)
					UiRect(x1, y1)

					-- Draw module description
					UiPush()
						UiTranslate(1110, 0)

						UiColor(0, 0, 0, .5)
						UiRect(600, y1)
						UiTranslate(300, 30)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("DESCRIPTION")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("The debris cleaner works by removing small voxels that cause lots of physics calculations and are barely visible, this makes destruction of large objects much faster.")
						UiTranslate(0, 120)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("USAGE")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("The debris size multiplier defines how large objects you want to remove, the larger the objects the faster destructions will be. The optional buttons if set to ignore visible/active will make debris only be removed while seen/moved.")
						UiTranslate(0, 150)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("PERFORMANCE")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("HIGH performance module with MEDIUM artifacts, good for LOW CPU usage. If used correctly a very powerful module to make sure you can get maximal framerates during destruction.")
						UiTranslate(0, 120)
					UiPop()

					-- Draw setting elements
					UiWindow(1320 - x0, y1, false)
					UiPush()
						UiTranslate(30, 30)
						UiFont("bold.ttf", 18)

						-- Left side elements
						UiPush()
							UiPush()
								-- Enable and reset buttons
								UiPush()
									UiColor(1, 1, 1, 1)
									UiAlign("center middle")

									if UiTextedButton(options.cleaner.enabled and "ENABLED" or "DISABLED", "center middle", 240, 60, options.cleaner.enabled and {0, 1, 0, .5} or {1, 0, 0, .5}, {1, 1, 1, 1}) then options.cleaner.enabled = not options.cleaner.enabled end
									UiTranslate(240, 0)
									if UiTextedButton("RESET", "center middle", 240, 60, {1, 0, 0, .5}, {1, 1, 1, 1}) then options.cleaner = Clone(fallbackOptions.cleaner) end
								UiPop()
							UiPop()
							UiTranslate(0, 90)

							-- Debris size title
							UiPush()
								UiColor(0, 0, 0, .7)
								UiRect(480, 30)

								UiAlign("center middle")
								UiTranslate(240, 15)
								UiColor(1, 1, 1, 1)
								UiText("DEBRIS SIZE (HIGHER = FASTER)")
							UiPop()
							UiTranslate(0, 30)

							-- Debris size slider
							UiPush()
								options.cleaner.multiplier = Round(UiColoredSlider(options.cleaner.multiplier, 0, 1, 480, 60, {0, 0, 0, .5}, {0, 0, 0, .2}), 2, .005)
							UiPop()
							UiTranslate(0, 90)
						UiPop()

						-- Right side elements
						UiPush()
							UiTranslate(540, 0)

							-- Extra modification buttons
							if UiTextedButton(options.cleaner.removeVisibleDebris and "REMOVING VISIBLE" or "IGNORING VISIBLE", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
								options.cleaner.removeVisibleDebris = not options.cleaner.removeVisibleDebris
							end
							UiTranslate(0, 90)

							if UiTextedButton(options.cleaner.removeActiveDebris and "REMOVING ACTIVE" or "IGNORING ACTIVE", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
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
					-- Account for navbar size and draw background
					UiAlign("left")
					UiTranslate(x0, 0)
					UiColor(0, 0, 0, .8)
					UiRect(x1, y1)

					-- Draw module description
					UiPush()
						UiTranslate(1110, 0)

						UiColor(0, 0, 0, .5)
						UiRect(600, y1)
						UiTranslate(300, 30)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("DESCRIPTION")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("The object stabilizer works by making all objects far away from the player static, this makes destruction of large objects much faster.")
						UiTranslate(0, 120)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("USAGE")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("The object size multiplier defines how large objects you want to freeze, the larger the objects the faster destructions will be. The optional buttons if set to ignore visible make objects only be frozen while not seen.")
						UiTranslate(0, 150)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("PERFORMANCE")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("MEDIUM performance module with HIGH artifacts, good for LOW CPU usage. A game changer in specific cases, overall average.")
						UiTranslate(0, 120)
					UiPop()

					-- Draw setting elements
					UiWindow(1320 - x0, y1, false)
					UiPush()
						UiTranslate(30, 30)
						UiFont("bold.ttf", 18)

						-- Left side elements
						UiPush()
							UiPush()
								-- Enable and reset buttons
								UiPush()
									UiColor(1, 1, 1, 1)
									UiAlign("center middle")

									if UiTextedButton(options.stabilizer.enabled and "ENABLED" or "DISABLED", "center middle", 240, 60, options.stabilizer.enabled and {0, 1, 0, .5} or {1, 0, 0, .5}, {1, 1, 1, 1}) then options.stabilizer.enabled = not options.stabilizer.enabled end
									UiTranslate(240, 0)
									if UiTextedButton("RESET", "center middle", 240, 60, {1, 0, 0, .5}, {1, 1, 1, 1}) then options.stabilizer = Clone(fallbackOptions.stabilizer) end
								UiPop()
							UiPop()
							UiTranslate(0, 90)

							-- Size slider
							UiPush()
								UiColor(0, 0, 0, .7)
								UiRect(480, 30)

								UiAlign("center middle")
								UiTranslate(240, 15)
								UiColor(1, 1, 1, 1)
								UiText("SIZE MULTIPLIER (HIGHER = FASTER)")
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
							if UiTextedButton(options.stabilizer.stabilizeVisibleObjects and "STABILIZING VISIBLE" or "IGNORING VISIBLE", "center middle", 480, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
								options.stabilizer.stabilizeVisibleObjects = not options.stabilizer.stabilizeVisibleObjects
							end
						UiPop()
					UiPop()
				end
			},

			-- FIRE
			{
				name = "fire",
				title = "FIRE CONTROLLER",
				draw = function(x0, y0, x1, y1)
					-- Account for navbar size and draw background
					UiAlign("left")
					UiTranslate(x0, 0)
					UiColor(0, 0, 0, .8)
					UiRect(x1, y1)

					-- Draw module description
					UiPush()
						UiTranslate(1110, 0)

						UiColor(0, 0, 0, .5)
						UiRect(600, y1)
						UiTranslate(300, 30)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("DESCRIPTION")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("The fire controller works by limiting fire to a specific amount so that you can be destructive without massive frame drops.")
						UiTranslate(0, 120)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("USAGE")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("The fire amount defines how much fire that should be allowed, not fully accurate but works overall. The spread will decide how fast the fire can spread, keep this to a minimum in most cases.")
						UiTranslate(0, 150)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("PERFORMANCE")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("HIGH performance module with LOW artifacts, good for LOW CPU and gpu usage. Really useful in most scenarios where fires are in the way of higher framerates or the other way around.")
						UiTranslate(0, 120)
					UiPop()

					-- Draw setting elements
					UiWindow(1320 - x0, y1, false)
					UiPush()
						UiTranslate(30, 30)
						UiFont("bold.ttf", 18)
						
						-- Left side elements
						UiPush()
							UiPush()
								-- Enable and reset buttons
								UiPush()
									UiColor(1, 1, 1, 1)
									UiAlign("center middle")

									if UiTextedButton(options.fire.enabled and "ENABLED" or "DISABLED", "center middle", 240, 60, options.fire.enabled and {0, 1, 0, .5} or {1, 0, 0, .5}, {1, 1, 1, 1}) then options.fire.enabled = not options.fire.enabled end
									UiTranslate(240, 0)
									if UiTextedButton("RESET", "center middle", 240, 60, {1, 0, 0, .5}, {1, 1, 1, 1}) then options.fire = Clone(fallbackOptions.fire) end
								UiPop()
							UiPop()
							UiTranslate(0, 90)

							-- Amount title
							UiPush()
								UiColor(0, 0, 0, .7)
								UiRect(480, 30)

								UiAlign("center middle")
								UiTranslate(240, 15)
								UiColor(1, 1, 1, 1)
								UiText("AMOUNT (LOWER = FASTER)")
							UiPop()
							UiTranslate(0, 30)

							-- Amount slider
							UiPush()
								options.fire.amount = Round(UiColoredSlider(options.fire.amount, 0, 10000, 480, 60, {0, 0, 0, .5}, {0, 0, 0, .2}), -2, 50)
							UiPop()
							UiTranslate(0, 90)

							UiPush()
								UiColor(0, 0, 0, .7)
								UiRect(480, 30)

								UiAlign("center middle")
								UiTranslate(240, 15)
								UiColor(1, 1, 1, 1)
								UiText("SPREAD (LOWER = FASTER)")
							UiPop()
							UiTranslate(0, 30)
							UiPush()
								options.fire.spread = Round(UiColoredSlider(options.fire.spread, 0, 100, 480, 60, {0, 0, 0, .5}, {0, 0, 0, .2}), 0, 0.5)
							UiPop()
							UiTranslate(0, 90)
						UiPop()

						-- Right side elements
						UiPush()
							UiTranslate(540, 0)
						UiPop()
					UiPop()
				end
			},

			-- SUN
			{
				name = "sun",
				title = "SUN CONTROLLER",
				draw = function(x0, y0, x1, y1)
					-- Account for navbar size and draw background
					UiAlign("left")
					UiTranslate(x0, 0)
					UiColor(0, 0, 0, .8)
					UiRect(x1, y1)

					-- Draw module description
					UiPush()
						UiTranslate(1110, 0)

						UiColor(0, 0, 0, .5)
						UiRect(600, y1)
						UiTranslate(300, 30)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("DESCRIPTION")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("The sun controller works by limiting sunrays in the scene, this makes general gameplay more enjoyable but sadly less visibly pleasing.")
						UiTranslate(0, 120)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("USAGE")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("The brightness will limit the amount of sun in the scene so that rays fade faster, the shadow length works the same but only for shadows.")
						UiTranslate(0, 150)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("PERFORMANCE")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("MEDIUM performance module with HIGH artifacts, good for LOW GPU usage. Will make the scene look very dull for a small increase in FPS, great for larger maps.")
						UiTranslate(0, 120)
					UiPop()

					-- Draw setting elements
					UiWindow(1320 - x0, y1, false)
					UiPush()
						UiTranslate(30, 30)
						UiFont("bold.ttf", 18)

						-- Left side elements
						UiPush()
							UiPush()
								-- Enable and reset buttons
								UiPush()
									UiColor(1, 1, 1, 1)
									UiAlign("center middle")

									if UiTextedButton(options.sun.enabled and "ENABLED" or "DISABLED", "center middle", 240, 60, options.sun.enabled and {0, 1, 0, .5} or {1, 0, 0, .5}, {1, 1, 1, 1}) then options.sun.enabled = not options.sun.enabled end
									UiTranslate(240, 0)
									if UiTextedButton("RESET", "center middle", 240, 60, {1, 0, 0, .5}, {1, 1, 1, 1}) then options.sun = Clone(fallbackOptions.sun) end
								UiPop()
							UiPop()
							UiTranslate(0, 90)

							-- Brightness slider
							UiPush()
								UiColor(0, 0, 0, .7)
								UiRect(480, 30)

								UiAlign("center middle")
								UiTranslate(240, 15)
								UiColor(1, 1, 1, 1)
								UiText("BRIGHTNESS (LOWER = FASTER)")
							UiPop()
							UiTranslate(0, 30)
							UiPush()
								options.sun.brightness = Round(UiColoredSlider(options.sun.brightness, 0, 1, 480, 60, {0, 0, 0, .5}, {0, 0, 0, .2}), 2, .005)
							UiPop()
							UiTranslate(0, 90)

							-- Shadow length slider
							UiPush()
								UiColor(0, 0, 0, .7)
								UiRect(480, 30)

								UiAlign("center middle")
								UiTranslate(240, 15)
								UiColor(1, 1, 1, 1)
								UiText("SHADOW LENGTH (LOWER = FASTER)")
							UiPop()
							UiTranslate(0, 30)
							UiPush()
								options.sun.length = Round(UiColoredSlider(options.sun.length, 0, 256, 480, 60, {0, 0, 0, .5}, {0, 0, 0, .2}), 0, 0)
							UiPop()
						UiPop()

						-- Right side elements
						UiPush()
							UiTranslate(540, 0)
						UiPop()
					UiPop()
				end
			},

			-- LIGHT
			{
				name = "light",
				title = "LIGHT CONTROLLER",
				draw = function(x0, y0, x1, y1)
					-- Account for navbar size and draw background
					UiAlign("left")
					UiTranslate(x0, 0)
					UiColor(0, 0, 0, .8)
					UiRect(x1, y1)

					-- Draw module description
					UiPush()
						UiTranslate(1110, 0)

						UiColor(0, 0, 0, .5)
						UiRect(600, y1)
						UiTranslate(300, 30)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("DESCRIPTION")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("The light controller works by having light sources dimmed (except the sun, see sun controller module).")
						UiTranslate(0, 120)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("USAGE")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("The light intensity will change the lights intensity so that less or more rays are bounced in the scene.")
						UiTranslate(0, 150)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("PERFORMANCE")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("Low performance module with LOW artifacts, good for LOW CPU and GPU usage. Not very powerful and should not be enabled unless you want to squeeze out every frame possible.")
						UiTranslate(0, 120)
					UiPop()

					-- Draw setting elements
					UiWindow(1320 - x0, y1, false)
					UiPush()
						UiTranslate(30, 30)
						UiFont("bold.ttf", 18)

						-- Left side elements
						UiPush()
							-- Enable and reset buttons
							UiPush()
								UiColor(1, 1, 1, 1)
								UiAlign("center middle")

								if UiTextedButton(options.light.enabled and "ENABLED" or "DISABLED", "center middle", 240, 60, options.light.enabled and {0, 1, 0, .5} or {1, 0, 0, .5}, {1, 1, 1, 1}) then options.light.enabled = not options.light.enabled end
								UiTranslate(240, 0)
								if UiTextedButton("RESET", "center middle", 240, 60, {1, 0, 0, .5}, {1, 1, 1, 1}) then options.light = Clone(fallbackOptions.light) end
							UiPop()
							UiTranslate(0, 90)

							-- Intensity title
							UiPush()
								UiColor(0, 0, 0, .7)
								UiRect(480, 30)

								UiAlign("center middle")
								UiTranslate(240, 15)
								UiColor(1, 1, 1, 1)
								UiText("LIGHT INTENSITY (LOWER = FASTER)")
							UiPop()
							UiTranslate(0, 30)

							-- Intensity slider
							UiPush()
								options.light.intensity = Round(UiColoredSlider(options.light.intensity, 0, 10, 480, 60, {0, 0, 0, .5}, {0, 0, 0, .2}))
							UiPop()
							UiTranslate(0, 90)
						UiPop()

						-- Right side elements
						UiPush()
							UiTranslate(540, 0)
						UiPop()
					UiPop()
				end
			},

			-- FOG
			{
				name = "fog",
				title = "FOG CONTROLLER",
				draw = function(x0, y0, x1, y1)
					-- Account for navbar size and draw background
					UiAlign("left")
					UiTranslate(x0, 0)
					UiColor(0, 0, 0, .8)
					UiRect(x1, y1)

					-- Draw module description
					UiPush()
						UiTranslate(1110, 0)

						UiColor(0, 0, 0, .5)
						UiRect(600, y1)
						UiTranslate(300, 30)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("DESCRIPTION")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("The fog controller works by removing fog in the distance as it does not seem to have an impact on the framerate.")
						UiTranslate(0, 120)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("USAGE")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("The fog amount will change how thick the fog is (if fog is used in the scene).")
						UiTranslate(0, 150)

						UiFont("bold.ttf", 36)
						UiColor(1, 1, 1, 1)
						UiAlign("center top")
						UiText("PERFORMANCE")
						UiTranslate(0, 45)

						UiFont("regular.ttf", 18)
						UiWordWrap(300)
						UiText("Very LOW performance module with very LOW artifacts, not very useful but added to remove extra effects.")
						UiTranslate(0, 120)
					UiPop()

					-- Draw setting elements
					UiWindow(1320 - x0, y1, false)
					UiPush()
						UiTranslate(30, 30)
						UiFont("bold.ttf", 18)

						-- Left side elements
						UiPush()
							UiPush()
								-- Enable and reset buttons
								UiPush()
									UiColor(1, 1, 1, 1)
									UiAlign("center middle")

									if UiTextedButton(options.fog.enabled and "ENABLED" or "DISABLED", "center middle", 240, 60, options.fog.enabled and {0, 1, 0, .5} or {1, 0, 0, .5}, {1, 1, 1, 1}) then options.fog.enabled = not options.fog.enabled end
									UiTranslate(240, 0)
									if UiTextedButton("RESET", "center middle", 240, 60, {1, 0, 0, .5}, {1, 1, 1, 1}) then options.fog = Clone(fallbackOptions.fog) end
								UiPop()
							UiPop()
							UiTranslate(0, 90)

							-- Amount title
							UiPush()
								UiColor(0, 0, 0, .7)
								UiRect(480, 30)

								UiAlign("center middle")
								UiTranslate(240, 15)
								UiColor(1, 1, 1, 1)
								UiText("AMOUNT (LOWER = FASTER)")
							UiPop()
							UiTranslate(0, 30)

							-- Amount slider
							UiPush()
								options.fog.amount = Round(UiColoredSlider(options.fog.amount, 0, 1, 480, 60, {0, 0, 0, .5}, {0, 0, 0, .2}), 2, .005)
							UiPop()
							UiTranslate(0, 90)
						UiPop()

						-- Right side elements
						UiPush()
							UiTranslate(540, 0)
						UiPop()
					UiPop()
				end
			}
		}
	}
end

function TickWindow(dt)
	-- If the ALT button was pressed, toggle the performance window and save the options.
	-- This is used to make sure the settings were fully saved as no changes can be made without the window shown.
	if (InputDown("alt") and InputPressed(GetString("savegame.mod.keybind"))) or PauseMenuButton("Performance Mod") then
		window.enabled = not window.enabled
		window.interact = not window.interact
		SetString("savegame.mod.options", util.serialize(options))
	end
end

function DrawWindow()
	local x0, y0, x1, y1 = UiSafeMargins()
	
	-- Draw the performance window
	if window.enabled then
		if window.interact then
			UiMakeInteractive()
			if InputPressed("lmb") then
				SetString("savegame.mod.options", util.serialize(options))
			end
		end

		UiPush()
			SetBool("hud.aimdot", false)
			UiWindow(x1 - x0, y1 - y0, true)
			UiAlign("center middle")
			UiColor(1, 1, 1, 1)

			-- The left side navigation bar.
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
						local textColor = pageOptions.enabled and {.9, 1, .9} or {1, .9, .9}

						if HasVersion(pageOptions.version) then
							UiFont("bold.ttf", 18)
							if UiTextedButton(window.pages[pageIteration].title, "center middle", 240, 60, {0, 0, 0, 0}, pageOptions.enabled and {0, 1, 0} or {1, 0, 0}) then
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
			UiInformationCounter(0, 0, 1, data, options)
		end
	end
	
	draws = draws + 1
end