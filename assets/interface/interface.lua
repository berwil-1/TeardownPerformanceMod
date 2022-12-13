interface = {}

interface.color = function(color, alpha)
	UiColor(color[1], color[2], color[3], color[4] and color[4] or (alpha and alpha or 1))
end

interface.font = function(font, size)
	UiFont(font and font or theme.textFont, size and size or 24)
end

interface.drawLine = function(dx, dy, color, alpha)
	UiPush()
		interface.color(color, alpha)
		UiRotate(math.atan2(-dy, dx) * 180 / math.pi)
		UiRect((dx * dx + dy * dy) ^ .5, 1)
	UiPop()
end

interface.text = function(text, colorNormal, colorPressed, pressed, down)
	local color = (down and colorPressed ~= nil) and colorPressed or colorNormal

	UiPush()
		interface.color(color, 1)
		interface.font(text.font, text.size)
		UiAlign(text.alignment and text.alignment or "left top")
		UiTranslate((text.translate.x and text.translate.x or 0) + (down and 2 or 0), (text.translate.y and text.translate.y or 0) + (down and 2 or 0))
		UiText(text.text)
	UiPop()

	return pressed, down
end

interface.button = function(width, height, colorNormal, colorPressed)
	local inside = UiIsMouseInRect(width, height)
	local pressed = inside and InputPressed("usetool")
	local down = inside and InputDown("usetool")
	local color = (down and colorPressed ~= nil) and colorPressed or colorNormal

	-- Button background
	UiPush()
		interface.color(color, 1)
		UiAlign("left")
		UiRect(width, height)
	UiPop()

	return pressed, down
end

interface.buttonText = function(text, width, height, backColorNormal, textColorNormal, backColorPressed, textColorPressed)
	local pressed, down = interface.button(width, height, backColorNormal, backColorPressed)
	interface.text(text, textColorNormal, textColorPressed, pressed, down)

	return pressed, down
end

interface.buttonSwitch = function(text, width, height, state)
	local pressed, down = interface.buttonText({ text = state and "ENABLED" or "DISABLED", alignment = "right middle", translate = { x = width - 15, y = height / 2 } }, width, height, theme.button, state and theme.textEnabled or theme.textDisabled, theme.buttonPressed)
	interface.text({ text = text, alignment = "left middle", translate = { x = 15, y = height / 2 } }, theme.text)
	return pressed, down
end

interface.slider = function(text, value, width, height, min, max, backColorNormal, sliderColorNormal, backColorPressed, sliderColorPressed, held)
	local inside = UiIsMouseInRect(width, height)
	local pressed = inside and InputPressed("usetool")
	local down = inside and InputDown("usetool")
	local backColor = (down and backColorPressed ~= nil) and backColorPressed or backColorNormal
	local sliderColor = (down and sliderColorPressed ~= nil) and sliderColorPressed or sliderColorNormal

	-- Slider background
	local widthToValue = (max - min) / width
	local valueToWidth = width / (max - min)
	local x = (down or (held and InputDown("usetool"))) and math.max(math.min(UiGetMousePos(), width), 0) or valueToWidth * (value - min)

	UiPush()
		UiAlign("left")
		interface.color(backColor, 1)
		UiRect(x, height)
		interface.color(sliderColor, 1)
		UiTranslate(math.max(x - 16, 0), 0)
		UiRect(16, height)
	UiPop()

	interface.text({ text = text, alignment = "left middle", translate = { x = 15, y = height / 2 } }, theme.text)
	interface.text({ text = value, alignment = "right middle", translate = { x = width - 15, y = height / 2 } }, theme.text)
	return min + widthToValue * x, down
end

interface.colorPicker = function(lastPositions, scale)
	local size = 480 * scale
	local x, y = UiGetMousePos()
	local positions = (UiIsMouseInRect(size, size) and InputDown("usetool")) and { 1 / size * math.min(math.max(x, 0), size), 1, 1 / size * math.min(math.max(y, 0), size), lastPositions[4] and lastPositions[4] or 0.5 } or lastPositions
	local color = visual.hslrgb(positions[1], positions[2], positions[3])

	UiPush()
		UiScale(scale)
		UiColor(1, 1, 1, 1)
		UiImage("assets/image/palette/palette.png")
		UiPush()
			local invserseColorLightness = visual.hslrgb(0, 0, 1 - positions[3])
			UiAlign("center middle")
			UiTranslate(480 * positions[1], 480 * positions[3])
			UiScale(0.1 / scale)
			UiColor(invserseColorLightness[1], invserseColorLightness[2], invserseColorLightness[3])
			UiImage("assets/image/palette/palette_pointer.png")
		UiPop()
	UiPop()

	return positions
end