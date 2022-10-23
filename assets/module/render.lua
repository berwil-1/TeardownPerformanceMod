render = {}

-- Rework all of this later, doesn't always increase performance.

local bodies = {}
local renderScale
function spawn()
	renderScale = render.options.renderDistance
	
	for index = 1, 4 do
		bodies[index] = Spawn("<voxbox size='" .. 100 * renderScale .. " 200 1' material='concrete' color='0 0 0'/>", Transform(Vec(0, 10, 0)))[1]
	end

	for index = 5, 6 do
		bodies[index] = Spawn("<voxbox size='" .. 100 * renderScale .. " " .. 100 * renderScale .. " 1' material='concrete' color='0 0 0'/>", Transform(Vec(0, 10, 0)))[1]
	end
end

function destroy()
	for index = 1, 6 do
		Delete(bodies[index])
	end
	bodies = {}
end

render.init = function()
	render.name = "render"
	render.experimental = true
	renderScale = render.options.renderDistance
	if render.options.enabled then spawn() end
end

render.tick = function()
	local middle = GetPlayerTransform().pos
	local directions = {
		Transform(VecSub(middle, Vec(5 * renderScale, 10, 5 * renderScale)), QuatEuler(0, 0, 0)),
		Transform(VecSub(middle, Vec(5 * renderScale, 10, -5 * renderScale)), QuatEuler(0, 0, 0)),
		Transform(VecSub(middle, Vec(5 * renderScale, 10, -5 * renderScale)), QuatEuler(0, 90, 0)),
		Transform(VecSub(middle, Vec(-5 * renderScale, 10, -5 * renderScale)), QuatEuler(0, 90, 0)),

		Transform(VecAdd(middle, Vec(-5 * renderScale, 10, -5 * renderScale)), QuatEuler(90, 0, 0)),
		Transform(VecAdd(middle, Vec(-5 * renderScale, -10, -5 * renderScale)), QuatEuler(90, 0, 0))
	}

	for index = 1, 6 do
		local body = bodies[index]
		SetShapeCollisionFilter(GetBodyShapes(body)[1], 4, 8)
		SetBodyVelocity(body, Vec(0, 0, 0))
		SetBodyTransform(body, directions[index])
	end
end

render.draw = function()
	
end

local distanceHeld
render.interface = function()
	UiTranslate(30, 30)

	UiPush()
		-- General
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "GENERAL", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)

		if interface.buttonSwitch("RENDER", 400, 60, render.options.enabled) then
			render.options.enabled = not render.options.enabled
			if render.options.enabled and #bodies < 6 then spawn() else destroy() end
		end
		UiTranslate(0, 60)

		if interface.buttonText({ text = "RESET", alignment = "left middle", translate = { x = 15, y = 30 } }, 400, 60, theme.buttonReset, theme.text) then
			for name,value in pairs(render.default) do
				render.options[name] = Clone(value)
			end

			destroy()
		end
		UiTranslate(0, 90)

		-- Render
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "RENDER", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)
		if interface.buttonText({ text = "RELOAD", alignment = "left middle", translate = { x = 15, y = 30 } }, 400, 60, theme.button, theme.text, theme.buttonPressed) then destroy() spawn() end
		UiTranslate(0, 60)
		render.options.renderDistance, distanceHeld = interface.slider("DISTANCE", Round(render.options.renderDistance, 0, 0.5), 400, 60, 1, 5, theme.button, theme.background, nil, nil, distanceHeld)
	UiPop()
end