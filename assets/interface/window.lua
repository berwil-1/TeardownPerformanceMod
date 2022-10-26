-- Utility
--#include "../../variable.lua"
#include "interface.lua"

local interface = interface
local selected = modules[1]
local forbiddenModules = {debris = true, fire = true, render = true}

function InterfaceNavigation()
	-- Transparent background
	interface.color({0.0, 0.0, 0.0, 0.75}, 0.75)
	UiRect(UiWidth(), UiHeight())

	-- Top black bar
	interface.color(theme.top_bar)
	UiRect(UiWidth(), 100)

	-- Left black bar
	interface.color(theme.left_bar)
	UiRect(400, UiHeight())

	UiColor(1, 1, 1, 1)
	UiImage("MOD/assets/image/logo/logo.png", 10, 70, 420, 236)
	UiTranslate(0, 100)

	for _, module in pairs(modules) do
		if not (options.general.speedrun and forbiddenModules[module.name] ~= nil) then
	        if module.interface and not (module.experimental and not options.general.experimental) then
	        	if interface.buttonText({ text = string.upper(module.name), alignment = "left middle", translate = { x = 15, y = 30 }, font = module.name == selected.name and theme.textFontBold or theme.textFont }, 400, 60, theme.button, theme.text, theme.buttonPressed) then
					selected = module
				end

				if module.options.enabled ~= nil and (not module.options.hidden) then
					interface.text({ text = module.options.enabled and "ON" or "OFF", alignment = "right middle", translate = { x = 385, y = 30 }, font = theme.textFont }, module.options.enabled and theme.textEnabled or theme.textDisabled)
				end

				UiTranslate(0, 60)
	        end
    	end
    end
end

function InformationSection()
	UiTranslate(0, UiHeight() - 120)

	interface.color(theme.background)
	UiRect(400, 120)

	if options.general.speedrun then
		interface.text({ text = "WARNING", alignment = "left middle", translate = { x = 15, y = 30 }, font = theme.textFontBold }, theme.text)
		interface.text({ text = "The speedrun mode will disable some", alignment = "left middle", translate = { x = 15, y = 60 }, font = theme.textFont }, theme.text)
		interface.text({ text = "features of this mod.", alignment = "left middle", translate = { x = 15, y = 90 }, font = theme.textFont }, theme.text)
	end
end

function DrawInterface()
	UiMakeInteractive()

	UiPush()
		InterfaceNavigation()
	UiPop()

	UiPush()
		InformationSection()
	UiPop()

	if selected.interface then
		UiPush()
			UiTranslate(400, 100)
			selected.interface()
		UiPop()
	end
end