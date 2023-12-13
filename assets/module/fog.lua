fog = {}

fog.init = function()
	fog.name = "fog"
	fogStart, fogEnd, fogAmount, fogExponent = GetEnvironmentProperty("fogParams")
end

fog.disable = function()
	SetEnvironmentProperty("fogParams", fogStart, fogEnd, fogAmount, fogExponent)
end

fog.tick = function(ticks)
	if ticks % 10 == 0 then
		SetEnvironmentProperty("fogParams", fog.options.fogStart, fog.options.fogEnd, fog.options.fogAmount, fog.options.fogExponent)
	end
end

fog.draw = function()
	
end

local fogLimitHeld
fog.interface = function()
	UiTranslate(30, 30)

	UiPush()
		-- General
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "GENERAL", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)

		if interface.buttonSwitch({ text = "FOG", description = "FOG,Enable/disable this module.", alignment = "left middle", translate = { x = 15, y = 30 } }, 400, 60, fog.options.enabled) then
			if fog.options.enabled then fog.disable() end
			fog.options.enabled = not fog.options.enabled
		end
		UiTranslate(0, 60)

		if interface.buttonText({ text = "RESET", description = "RESET,Resets all settings for the current module.", alignment = "left middle", translate = { x = 15, y = 30 } }, 400, 60, theme.buttonReset, theme.text) then
			for name,value in pairs(fog.default) do
				fog.options[name] = Clone(value)
			end
		end
		UiTranslate(0, 90)

		-- Fog
		interface.color(theme.background)
		UiRect(400, 40)
		interface.text({ text = "FOG", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
		UiTranslate(0, 40)
		fog.options.fogStart, fogStartHeld = interface.slider({ text = "START", description = "START (NO IMPACT),Decides where fog should start.", alignment = "left middle", translate = { x = 15, y = 30 } }, Round(fog.options.fogStart, -1, 0.5), 400, 60, 0, 1000, theme.button, theme.background, nil, nil, fogStartHeld)
		UiTranslate(0, 60)
		fog.options.fogEnd, fogEndHeld = interface.slider({ text = "END", description = "END (NO IMPACT),Decides where fog should end.", alignment = "left middle", translate = { x = 15, y = 30 } }, Round(fog.options.fogEnd, -1, 0.5), 400, 60, 0, 1000, theme.button, theme.background, nil, nil, fogEndHeld)
		UiTranslate(0, 60)
		fog.options.fogAmount, fogAmountHeld = interface.slider({ text = "AMOUNT", description = "AMOUNT (NO IMPACT),Decides how much fog should be added.", alignment = "left middle", translate = { x = 15, y = 30 } }, Round(fog.options.fogAmount, 1, 0.05), 400, 60, 0, 1, theme.button, theme.background, nil, nil, fogAmountHeld)
		UiTranslate(0, 60)
		fog.options.fogExponent, fogExponentHeld = interface.slider({ text = "EXPONENT", description = "EXPONENT (NO IMPACT),Decides the fog falloff along the y-axis.", alignment = "left middle", translate = { x = 15, y = 30 } }, Round(fog.options.fogExponent, 1, 0.05), 400, 60, 0, 10, theme.button, theme.background, nil, nil, fogExponentHeld)
		UiTranslate(0, 60)
	UiPop()
end