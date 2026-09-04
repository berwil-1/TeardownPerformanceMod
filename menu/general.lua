#include "../settings/settings.lua"

local ROW_WIDTH = 720
local ROW_HEIGHT = 60
local ROW_CORNER_RADIUS = 6
local ROW_INSET_X = 12

local LABEL_FONT_SIZE = 16
local LABEL_OFFSET_Y = 13
local DESCRIPTION_FONT_SIZE = 14
local DESCRIPTION_OFFSET_Y = 36
local CONTROL_FONT_SIZE = 14

local TOGGLE_WIDTH = 44
local TOGGLE_HEIGHT = 24
local TOGGLE_KNOB_INSET = 3
local TOGGLE_KNOB_RADIUS = TOGGLE_HEIGHT / 2 - TOGGLE_KNOB_INSET
local TOGGLE_ON_COLOR = { 0.35, 0.75, 0.45, 1.0 }
local TOGGLE_OFF_COLOR = { 1.0, 1.0, 1.0, 0.15 }
local TOGGLE_KNOB_COLOR = { 1.0, 1.0, 1.0, 1.0 }

local BOX_COLOR = { 1.0, 1.0, 1.0, 0.12 }
local BOX_CORNER_RADIUS = 4

local KEYBIND_WIDTH = 88
local KEYBIND_HEIGHT = 28
local KEYBIND_CAPTURE_COLOR = { 0.95, 0.75, 0.35, 1.0 }
local CANCEL_CAPTURE_KEY = "esc"
local IGNORED_CAPTURE_KEYS = { lmb = true, rmb = true, mmb = true }

local UI_SCALE_MINIMUM = 0.5
local UI_SCALE_MAXIMUM = 1.5
local UI_SCALE_STEP = 0.1
local SLIDER_TRACK_WIDTH = 200
local SLIDER_TRACK_HEIGHT = 6
local SLIDER_THUMB_WIDTH = 22
local SLIDER_THUMB_HEIGHT = 22
local SLIDER_THUMB_IMAGE = "MOD/assets/Line_L.png"
local SLIDER_VALUE_WIDTH = 52
local SLIDER_VALUE_GAP = 12
local SLIDER_FILL_COLOR = { 0.35, 0.75, 0.45, 1.0 }

local DROPDOWN_WIDTH = 160
local DROPDOWN_HEIGHT = 28
local DROPDOWN_OPTION_HEIGHT = 32
local DROPDOWN_PANEL_GAP = 4
local DROPDOWN_PANEL_COLOR = { 0.08, 0.08, 0.08, 0.98 }

local PRESET_OPTIONS = {
    { value = "off", label = "Off" },
    { value = "light", label = "Light" },
    { value = "balanced", label = "Balanced" },
    { value = "aggressive", label = "Aggressive" },
}

local ROWS = {
    {
        key = "preset",
        type = "dropdown",
        label = "Performance preset",
        description = "Global starting point for every module. Individual settings can still be changed after.",
    },
    {
        key = "advanced",
        type = "toggle",
        label = "Advanced settings",
        description = "Show every setting, including the ones meant for tuning by hand.",
    },
    {
        key = "experimental",
        type = "toggle",
        label = "Experimental features",
        description = "Enable features still in testing. These may lower performance instead of raising it.",
    },
    {
        key = "speedrun",
        type = "toggle",
        label = "Speedrun mode",
        description = "Disable every module that is not allowed while speedrunning.",
    },
    {
        key = "debug",
        type = "toggle",
        label = "Debug output",
        description = "Print debug messages from the mod to the console.",
    },
    {
        key = "uiScale",
        type = "slider",
        label = "Menu scale",
        description = "Size of this menu. Applied when the slider is released.",
    },
    {
        key = "keybind",
        type = "keybind",
        label = "Menu keybind",
        description = "Key that opens and closes this menu.",
    },
}

local capturingKeybind = false
local openDropdownKey = nil
local pendingSliderValues = {}

local function setGeneralSetting(name, value)
    local settings = getSettings()
    settings.general[name] = value
    saveSettings()
end

local function snapUiScale(value)
    local snapped = math.floor(value / UI_SCALE_STEP + 0.5) * UI_SCALE_STEP
    if snapped < UI_SCALE_MINIMUM then
        return UI_SCALE_MINIMUM
    end
    if snapped > UI_SCALE_MAXIMUM then
        return UI_SCALE_MAXIMUM
    end
    return snapped
end

local function findPresetLabel(value)
    for _, option in ipairs(PRESET_OPTIONS) do
        if option.value == value then
            return option.label
        end
    end
    return value
end

local function updateKeybindCapture()
    local pressedKey = InputLastPressedKey()
    if pressedKey == "" or IGNORED_CAPTURE_KEYS[pressedKey] then
        return
    end

    if pressedKey ~= CANCEL_CAPTURE_KEY then
        setGeneralSetting("keybind", pressedKey)
    end
    capturingKeybind = false
end

local function drawRowChrome(Menu, row)
    local hovered = UiIsMouseInRect(ROW_WIDTH, ROW_HEIGHT)

    if hovered then
        UiPush()
            UiColor(Menu.sidebarHoverColor)
            UiRoundedRect(ROW_WIDTH, ROW_HEIGHT, ROW_CORNER_RADIUS)
        UiPop()
    end

    UiPush()
        UiTranslate(ROW_INSET_X, LABEL_OFFSET_Y)
        UiColor(Menu.textColor)
        UiFont("regular.ttf", LABEL_FONT_SIZE)
        UiText(row.label)
    UiPop()

    UiPush()
        UiTranslate(ROW_INSET_X, DESCRIPTION_OFFSET_Y)
        UiColor(Menu.textMutedColor)
        UiFont("regular.ttf", DESCRIPTION_FONT_SIZE)
        UiText(row.description)
    UiPop()

    return hovered
end

local function drawRowButton()
    local clicked = false
    UiPush()
        clicked = UiBlankButton(ROW_WIDTH, ROW_HEIGHT)
    UiPop()
    return clicked
end

local function drawDivider(Menu)
    UiPush()
        UiTranslate(ROW_INSET_X, ROW_HEIGHT)
        UiColor(Menu.dividerColor)
        UiRect(ROW_WIDTH - ROW_INSET_X * 2, 1)
    UiPop()
end

local function drawToggle(enabled)
    UiPush()
        UiTranslate(ROW_WIDTH - ROW_INSET_X - TOGGLE_WIDTH,
                    (ROW_HEIGHT - TOGGLE_HEIGHT) / 2)

        UiColor(enabled and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR)
        UiRoundedRect(TOGGLE_WIDTH, TOGGLE_HEIGHT, TOGGLE_HEIGHT / 2)

        local knobCenterX = TOGGLE_HEIGHT / 2
        if enabled then
            knobCenterX = TOGGLE_WIDTH - TOGGLE_HEIGHT / 2
        end

        UiTranslate(knobCenterX, TOGGLE_HEIGHT / 2)
        UiAlign("center middle")
        UiColor(TOGGLE_KNOB_COLOR)
        UiCircle(TOGGLE_KNOB_RADIUS)
    UiPop()
end

local function drawKeybindBox(Menu, keyName, capturing)
    UiPush()
        UiTranslate(ROW_WIDTH - ROW_INSET_X - KEYBIND_WIDTH,
                    (ROW_HEIGHT - KEYBIND_HEIGHT) / 2)

        UiColor(BOX_COLOR)
        UiRoundedRect(KEYBIND_WIDTH, KEYBIND_HEIGHT, BOX_CORNER_RADIUS)

        UiTranslate(KEYBIND_WIDTH / 2, KEYBIND_HEIGHT / 2)
        UiAlign("center middle")
        UiFont("bold.ttf", CONTROL_FONT_SIZE)

        if capturing then
            UiColor(KEYBIND_CAPTURE_COLOR)
            UiText("Press key")
        else
            UiColor(Menu.textColor)
            UiText(string.upper(keyName))
        end
    UiPop()
end

local function drawDropdownBox(Menu, value)
    UiPush()
        UiTranslate(ROW_WIDTH - ROW_INSET_X - DROPDOWN_WIDTH,
                    (ROW_HEIGHT - DROPDOWN_HEIGHT) / 2)

        UiColor(BOX_COLOR)
        UiRoundedRect(DROPDOWN_WIDTH, DROPDOWN_HEIGHT, BOX_CORNER_RADIUS)

        UiTranslate(DROPDOWN_WIDTH / 2, DROPDOWN_HEIGHT / 2)
        UiAlign("center middle")
        UiColor(Menu.textColor)
        UiFont("regular.ttf", CONTROL_FONT_SIZE)
        UiText(findPresetLabel(value))
    UiPop()
end

local function drawSlider(Menu, row, savedValue)
    local displayValue = pendingSliderValues[row.key] or savedValue
    local fraction = (displayValue - UI_SCALE_MINIMUM) /
                     (UI_SCALE_MAXIMUM - UI_SCALE_MINIMUM)

    UiPush()
        UiTranslate(ROW_WIDTH - ROW_INSET_X, ROW_HEIGHT / 2)
        UiAlign("right middle")
        UiColor(Menu.textColor)
        UiFont("regular.ttf", CONTROL_FONT_SIZE)
        UiText(string.format("%.1fx", displayValue))
    UiPop()

    local trackOffsetX = ROW_WIDTH - ROW_INSET_X - SLIDER_VALUE_WIDTH -
                         SLIDER_VALUE_GAP - SLIDER_TRACK_WIDTH

    UiPush()
        UiTranslate(trackOffsetX, ROW_HEIGHT / 2)

        UiPush()
            UiAlign("left middle")
            UiColor(BOX_COLOR)
            UiRoundedRect(SLIDER_TRACK_WIDTH, SLIDER_TRACK_HEIGHT,
                          SLIDER_TRACK_HEIGHT / 2)

            if fraction > 0 then
                UiColor(SLIDER_FILL_COLOR)
                UiRoundedRect(SLIDER_TRACK_WIDTH * fraction, SLIDER_TRACK_HEIGHT,
                              SLIDER_TRACK_HEIGHT / 2)
            end
        UiPop()

        UiAlign("center middle")
        UiSliderThumbSize(SLIDER_THUMB_WIDTH, SLIDER_THUMB_HEIGHT)
        local thumbOffsetX, released = UiSlider(SLIDER_THUMB_IMAGE, "x",
                                                fraction * SLIDER_TRACK_WIDTH,
                                                0, SLIDER_TRACK_WIDTH)
    UiPop()

    local draggedValue = snapUiScale(UI_SCALE_MINIMUM +
        (thumbOffsetX / SLIDER_TRACK_WIDTH) * (UI_SCALE_MAXIMUM - UI_SCALE_MINIMUM))

    if released then
        pendingSliderValues[row.key] = nil
        if draggedValue ~= savedValue then
            setGeneralSetting(row.key, draggedValue)
        end
    elseif draggedValue ~= displayValue then
        pendingSliderValues[row.key] = draggedValue
    end
end

local function drawDropdownPanel(Menu, currentValue)
    local panelHeight = #PRESET_OPTIONS * DROPDOWN_OPTION_HEIGHT
    local selectedValue = nil
    local insidePanel = false

    UiPush()
        UiModalBegin()
        UiTranslate(ROW_WIDTH - ROW_INSET_X - DROPDOWN_WIDTH,
                    (ROW_HEIGHT + DROPDOWN_HEIGHT) / 2 + DROPDOWN_PANEL_GAP)
        UiAlign("top left")

        insidePanel = UiIsMouseInRect(DROPDOWN_WIDTH, panelHeight)

        UiColor(DROPDOWN_PANEL_COLOR)
        UiRoundedRect(DROPDOWN_WIDTH, panelHeight, BOX_CORNER_RADIUS)

        for _, option in ipairs(PRESET_OPTIONS) do
            local isCurrent = option.value == currentValue

            UiPush()
                if UiIsMouseInRect(DROPDOWN_WIDTH, DROPDOWN_OPTION_HEIGHT) then
                    UiColor(Menu.sidebarHoverColor)
                    UiRoundedRect(DROPDOWN_WIDTH, DROPDOWN_OPTION_HEIGHT,
                                  BOX_CORNER_RADIUS)
                end

                UiPush()
                    UiTranslate(ROW_INSET_X, DROPDOWN_OPTION_HEIGHT / 2)
                    UiAlign("left middle")
                    UiColor(isCurrent and Menu.textColor or Menu.textMutedColor)
                    UiFont(isCurrent and "bold.ttf" or "regular.ttf", CONTROL_FONT_SIZE)
                    UiText(option.label)
                UiPop()

                if UiBlankButton(DROPDOWN_WIDTH, DROPDOWN_OPTION_HEIGHT) then
                    selectedValue = option.value
                end
            UiPop()
            UiTranslate(0, DROPDOWN_OPTION_HEIGHT)
        end
        UiModalEnd()
    UiPop()

    return selectedValue, insidePanel
end

function isCapturingKeybind()
    return capturingKeybind
end

function drawGeneral(Menu, page)
    local general = getSettings().general

    if capturingKeybind then
        updateKeybindCapture()
    end

    UiPush()
        UiAlign("top left")

        local openDropdownOffsetY = nil

        for index, row in ipairs(ROWS) do
            UiPush()
                drawRowChrome(Menu, row)

                if row.type == "toggle" then
                    drawToggle(general[row.key])
                    if drawRowButton() then
                        setGeneralSetting(row.key, not general[row.key])
                    end
                elseif row.type == "slider" then
                    drawSlider(Menu, row, general[row.key])
                elseif row.type == "dropdown" then
                    drawDropdownBox(Menu, general[row.key])
                    if openDropdownKey == row.key then
                        openDropdownOffsetY = (index - 1) * ROW_HEIGHT
                    elseif drawRowButton() then
                        openDropdownKey = row.key
                    end
                elseif row.type == "keybind" then
                    drawKeybindBox(Menu, general[row.key], capturingKeybind)
                    if drawRowButton() then
                        capturingKeybind = not capturingKeybind
                    end
                end

                if index < #ROWS then
                    drawDivider(Menu)
                end
            UiPop()
            UiTranslate(0, ROW_HEIGHT)
        end

        if openDropdownOffsetY then
            UiPush()
                UiTranslate(0, openDropdownOffsetY - #ROWS * ROW_HEIGHT)
                local selectedValue, insidePanel =
                    drawDropdownPanel(Menu, general[openDropdownKey])

                if selectedValue then
                    setGeneralSetting(openDropdownKey, selectedValue)
                    openDropdownKey = nil
                elseif InputPressed("lmb") and not insidePanel then
                    openDropdownKey = nil
                end
            UiPop()
        end
    UiPop()
end
