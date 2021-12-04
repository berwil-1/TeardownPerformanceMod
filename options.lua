#include "assets/scripts/util.lua"



hook.add("base.draw", "performance.draw", function()
	UiAlign("center")
	UiTranslate(UiCenter(), UiMiddle())

	UiFont("bold.ttf", 100)
	UiColor(1, 1, 1, 1)
	UiText("PERFORMANCE MOD v2.7")

	UiTranslate(-120, 50)
	UiFont("bold.ttf", 32)
	if UiTextedButton("Keybind » ALT + " .. (HasKey("savegame.mod.keybind") and GetString("savegame.mod.keybind"):upper() or "P"), "center middle", 240, 60, {0, 0, 0, .5}, {1, 1, 1, 1}) then
		SetString("savegame.mod.keybind", "?")
	end

	UiTranslate(75, 450)
	UiFont("bold.ttf", 12)
	if UiTextedButton("CLEAR OPTIONS", "center middle", 120, 30, {0, 0, 0, .5}, {1, 0, 0, 1}) then
		ClearKey("savegame.mod")
	end
end)

hook.add("api.key.pressed", "performance.key.pressed", function(key)
	if GetString("savegame.mod.keybind") == "?" and key:len() == 1 then
		SetString("savegame.mod.keybind", key)
	end
end)



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