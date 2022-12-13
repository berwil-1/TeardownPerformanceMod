light = {}

light.init = function()
	light.name = "light"
	shadowLimit = GetEnvironmentProperty("sunLength")
end

light.disable = function()
	SetEnvironmentProperty("sunLength", shadowLimit)
end

light.tick = function(ticks)
	if ticks % 10 == 0 then
		SetEnvironmentProperty("sunLength", light.options.shadowLimit)
	end
end

light.draw = function()
	
end

light.light = function(light)
	if options.light.lamp then
		local rgb = visual.hslrgb(options.light.lampColor[1], options.light.lampColor[2], options.light.lampColor[3])
		SetLightIntensity(light, options.light.lampLimit)
		SetLightColor(light, rgb[1], rgb[2], rgb[3])
	end
end

local shadowLimitHeld, lampLimitHeld
light.interface = function()
	UiTranslate(30, 30)

	UiPush()
		-- General
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "GENERAL", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)

		if interface.buttonSwitch("LIGHT", 400, 60, light.options.enabled) then
			if light.options.enabled then light.disable() end
			light.options.enabled = not light.options.enabled
		end
		UiTranslate(0, 60)

		if interface.buttonText({ text = "RESET", alignment = "left middle", translate = { x = 15, y = 30 } }, 400, 60, theme.buttonReset, theme.text) then
			for name,value in pairs(light.default) do
				light.options[name] = Clone(value)
			end
		end
		UiTranslate(0, 90)

		-- Lamp
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "LAMP", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)
		if interface.buttonSwitch("LAMP", 400, 60, options.light.lamp) then
			options.light.lamp = not options.light.lamp
		end
		UiTranslate(0, 60)
		light.options.lampLimit, lampLimitHeld = interface.slider("LIMIT", Round(light.options.lampLimit, 1, 0.05), 400, 60, 0, 10, theme.button, theme.background, nil, nil, lampLimitHeld)
		UiTranslate(0, 60)

		light.options.lampColor = interface.colorPicker(light.options.lampColor, 400/480)
		UiTranslate(0, 430)

		-- Shadow
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "SHADOW", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)
		light.options.shadowLimit, shadowLimitHeld = interface.slider("LIMIT", Round(light.options.shadowLimit, 0, 0.5), 400, 60, 0, 128, theme.button, theme.background, nil, nil, shadowLimitHeld)
	UiPop()
end