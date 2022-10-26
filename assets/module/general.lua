general = {}

general.init = function()
	general.name = "general"
end

general.tick = function(ticks, deltaTime, bodies, shapes)
	
end

general.draw = function()
	loadstring("\105\102\32\111\112\116\105\111\110\115\46\103\101\110\101\114\97\108\46\115\112\101\101\100\114\117\110\32\116\104\101\110\10\9\9\85\105\84\114\97\110\115\108\97\116\101\40\85\105\87\105\100\116\104\40\41\32\45\32\52\50\44\32\49\48\41\10\9\9\85\105\73\109\97\103\101\40\34\77\79\68\47\97\115\115\101\116\115\47\105\109\97\103\101\47\105\99\111\110\47\115\112\101\101\100\114\117\110\46\112\110\103\34\41\10\9\101\110\100\10")()
end

general.interface = function()
	UiTranslate(30, 30)

	-- General
	interface.color(theme.background)
	UiRect(400, 40)
	
	interface.text({ text = "GENERAL", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
	UiTranslate(0, 40)

	if interface.buttonSwitch("ADVANCED MODE", 400, 60, general.options.advanced) then
		general.options.advanced = not general.options.advanced
	end
	UiTranslate(0, 60)
	
	if inMenu then
		if interface.buttonSwitch("SPEEDRUN MODE", 400, 60, general.options.speedrun) then
			general.options.speedrun = not general.options.speedrun
		end
		UiTranslate(0, 60)
	end
	
	if interface.buttonSwitch("EXPERIMENTAL MODE", 400, 60, general.options.experimental) then
		general.options.experimental = not general.options.experimental
	end
	UiTranslate(0, 60)
	
	if interface.buttonSwitch("DEBUG MODE", 400, 60, general.options.debug) then
		general.options.debug = not general.options.debug
	end
	UiTranslate(0, 60)

	if interface.buttonText({ text = "RESET ALL", alignment = "left middle", translate = { x = 15, y = 30 } }, 400, 60, theme.buttonReset, theme.text) then
		for _,module in pairs(modules) do
			module.options = Clone(module.default)
		end
	end
	UiTranslate(0, 90)

	-- Keybind
	interface.color(theme.background)
	UiRect(400, 40)
	interface.text({ text = "KEYBINDS", alignment = "center middle", translate = { x = 200, y = 20 }, font = "MOD/assets/font/libsans_bold.ttf" }, {1, 1, 1, 1})
	UiTranslate(0, 40)

	if interface.buttonText({ text = "ALT + " .. string.upper(general.options.keybind), alignment = "right middle", translate = { x = 385, y = 30 } }, 400, 60, theme.button, theme.text, theme.buttonPressed) then
		general.options.keybind = "?"
	end
	interface.text({ text = "OPEN/CLOSE", alignment = "left middle", translate = { x = 15, y = 30 } }, theme.text)
	UiTranslate(0, 90)
end

general.pressed = function(key)
	if general.options.keybind == "?" and key:len() == 1 then
		general.options.keybind = key
	end
end