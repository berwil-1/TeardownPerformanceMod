-- Utility
#include "../../variable.lua"
#include "interface.lua"

local selected = modules[1]

function InterfaceNavigation()
	-- Transparent background
	interface.color(theme.background)
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
        if module.interface and not (module.experimental and not options.general.experimental) then
        	if interface.buttonText({ text = string.upper(module.name), alignment = "left middle", translate = { x = 15, y = 30 }, font = module.name == selected.name and theme.textFontBold or theme.textFont }, 400, 60, theme.button, theme.text, theme.buttonPressed) then
				selected = module
			end

			if module.options.enabled ~= nil then
				interface.text({ text = module.options.enabled and "ON" or "OFF", alignment = "right middle", translate = { x = 385, y = 30 }, font = theme.textFont }, module.options.enabled and theme.textEnabled or theme.textDisabled)
			end

			UiTranslate(0, 60)
        end
    end
end

function DrawInterface()
	UiMakeInteractive()

	UiPush()
		InterfaceNavigation()
	UiPop()

	if selected.interface then
		UiPush()
			UiTranslate(400, 100)
			selected.interface()
		UiPop()
	end
end