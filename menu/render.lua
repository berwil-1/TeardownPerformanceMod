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

local BOX_COLOR = { 1.0, 1.0, 1.0, 0.12 }
local BOX_CORNER_RADIUS = 4

local TOGGLE_WIDTH = 44
local TOGGLE_HEIGHT = 24
local TOGGLE_KNOB_INSET = 3
local TOGGLE_KNOB_RADIUS = TOGGLE_HEIGHT / 2 - TOGGLE_KNOB_INSET
local TOGGLE_ON_COLOR = { 0.35, 0.75, 0.45, 1.0 }
local TOGGLE_OFF_COLOR = { 1.0, 1.0, 1.0, 0.15 }
local TOGGLE_KNOB_COLOR = { 1.0, 1.0, 1.0, 1.0 }

local SLIDER_TRACK_WIDTH = 200
local SLIDER_TRACK_HEIGHT = 6
local SLIDER_THUMB_WIDTH = 10
local SLIDER_THUMB_HEIGHT = 22
local SLIDER_THUMB_IMAGE = "MOD/assets/Line_L.png"
local SLIDER_VALUE_WIDTH = 52
local SLIDER_VALUE_GAP = 12
local SLIDER_FILL_COLOR = { 0.35, 0.75, 0.45, 1.0 }

local SWATCH_WIDTH = 44
local SWATCH_HEIGHT = 24
local SWATCH_BORDER = 2

local COLOR_PANEL_WIDTH = 260
local COLOR_PANEL_PADDING = 12
local COLOR_PANEL_GAP = 4
local COLOR_PANEL_COLOR = { 0.08, 0.08, 0.08, 0.98 }
local COLOR_CHANNEL_HEIGHT = 34
local COLOR_CHANNEL_LABEL_WIDTH = 18
local COLOR_CHANNEL_TRACK_WIDTH = 140
local COLOR_CHANNEL_VALUE_WIDTH = 44
local COLOR_CHANNEL_STEP = 0.01
local COLOR_CHANNEL_LABELS = { "R", "G", "B", "A" }

local PREVIEW_WIDTH = 240
local PREVIEW_HEIGHT = 135
local PREVIEW_ROW_HEIGHT = 170
local PREVIEW_CHIP_WIDTH = 56
local PREVIEW_CHIP_HEIGHT = 18
local PREVIEW_BACKGROUND_COLOR = { 1.0, 1.0, 1.0, 0.06 }
local PREVIEW_BORDER_COLOR = { 1.0, 1.0, 1.0, 0.18 }
local PREVIEW_CHIP_COLOR = { 0.35, 0.75, 0.45, 1.0 }

local OVERLAY_ROWS = {
    {
        key = "enabled",
        type = "toggle",
        label = "Overlay",
        description = "Show the performance overlay while playing.",
    },
    {
        key = "position",
        type = "position",
        height = PREVIEW_ROW_HEIGHT,
        label = "Overlay position",
        description = "Drag the marker to place the overlay on screen.",
    },
    {
        key = "size",
        type = "slider",
        label = "Overlay size",
        description = "Scales the whole overlay panel.",
        minimum = 0.5,
        maximum = 3.0,
        step = 0.1,
        format = "%.1fx",
    },
    {
        key = "textColor",
        type = "color",
        label = "Text color",
        description = "Color of the overlay text.",
    },
    {
        key = "accuracy",
        type = "slider",
        label = "Decimal places",
        description = "How many decimals the numbers are printed with.",
        minimum = 0,
        maximum = 4,
        step = 1,
        format = "%.0f",
    },
    {
        key = "frequency",
        type = "slider",
        label = "Update frequency",
        description = "How often the overlay values are refreshed.",
        minimum = 1,
        maximum = 60,
        step = 1,
        format = "%.0f/s",
    },
}

local openColorKey = nil
local grabbedPositionKey = nil
local pendingValues = {}

local function setOverlaySetting(name, value)
    local settings = getSettings()
    settings.overlay[name] = value
    saveSettings()
end

local function clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end
    if value > maximum then
        return maximum
    end
    return value
end

local function snapValue(value, minimum, maximum, step)
    local snapped = math.floor(value / step + 0.5) * step
    return clamp(snapped, minimum, maximum)
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

local function drawRowChrome(Menu, row, rowHeight)
    if UiIsMouseInRect(ROW_WIDTH, rowHeight) then
        UiPush()
            UiColor(Menu.sidebarHoverColor)
            UiRoundedRect(ROW_WIDTH, rowHeight, ROW_CORNER_RADIUS)
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
end

local function drawRowButton(rowHeight)
    local clicked = false
    UiPush()
        clicked = UiBlankButton(ROW_WIDTH, rowHeight)
    UiPop()
    return clicked
end

local function drawDivider(Menu, rowHeight)
    UiPush()
        UiTranslate(ROW_INSET_X, rowHeight)
        UiColor(Menu.dividerColor)
        UiRect(ROW_WIDTH - ROW_INSET_X * 2, 1)
    UiPop()
end

local function drawSliderTrack(fraction, trackWidth)
    UiPush()
        UiAlign("left middle")
        UiColor(BOX_COLOR)
        UiRoundedRect(trackWidth, SLIDER_TRACK_HEIGHT, SLIDER_TRACK_HEIGHT / 2)

        if fraction > 0 then
            UiColor(SLIDER_FILL_COLOR)
            UiRoundedRect(trackWidth * fraction, SLIDER_TRACK_HEIGHT,
                          SLIDER_TRACK_HEIGHT / 2)
        end
    UiPop()

    UiAlign("center middle")
    UiSliderThumbSize(SLIDER_THUMB_WIDTH, SLIDER_THUMB_HEIGHT)
    return UiSlider(SLIDER_THUMB_IMAGE, "x", fraction * trackWidth, 0, trackWidth)
end

local function drawSlider(Menu, row, savedValue)
    local displayValue = pendingValues[row.key] or savedValue
    local fraction = (displayValue - row.minimum) / (row.maximum - row.minimum)

    UiPush()
        UiTranslate(ROW_WIDTH - ROW_INSET_X, ROW_HEIGHT / 2)
        UiAlign("right middle")
        UiColor(Menu.textColor)
        UiFont("regular.ttf", CONTROL_FONT_SIZE)
        UiText(string.format(row.format, displayValue))
    UiPop()

    local thumbOffsetX = 0
    local released = false

    UiPush()
        UiTranslate(ROW_WIDTH - ROW_INSET_X - SLIDER_VALUE_WIDTH -
                    SLIDER_VALUE_GAP - SLIDER_TRACK_WIDTH,
                    ROW_HEIGHT / 2)
        thumbOffsetX, released = drawSliderTrack(fraction, SLIDER_TRACK_WIDTH)
    UiPop()

    local draggedValue = snapValue(
        row.minimum + (thumbOffsetX / SLIDER_TRACK_WIDTH) * (row.maximum - row.minimum),
        row.minimum, row.maximum, row.step)

    if released then
        pendingValues[row.key] = nil
        if draggedValue ~= savedValue then
            setOverlaySetting(row.key, draggedValue)
        end
    elseif draggedValue ~= displayValue then
        pendingValues[row.key] = draggedValue
    end
end

local function drawSwatch(color)
    UiPush()
        UiTranslate(ROW_WIDTH - ROW_INSET_X - SWATCH_WIDTH,
                    (ROW_HEIGHT - SWATCH_HEIGHT) / 2)

        UiPush()
            UiTranslate(-SWATCH_BORDER, -SWATCH_BORDER)
            UiColor(PREVIEW_BORDER_COLOR)
            UiRoundedRect(SWATCH_WIDTH + SWATCH_BORDER * 2,
                          SWATCH_HEIGHT + SWATCH_BORDER * 2,
                          BOX_CORNER_RADIUS)
        UiPop()

        UiColor(color)
        UiRoundedRect(SWATCH_WIDTH, SWATCH_HEIGHT, BOX_CORNER_RADIUS)
    UiPop()
end

local function drawColorPanel(Menu, key, color)
    local panelHeight = COLOR_PANEL_PADDING * 2 + #COLOR_CHANNEL_LABELS * COLOR_CHANNEL_HEIGHT
    local insidePanel = false

    UiPush()
        UiModalBegin()
        UiTranslate(ROW_WIDTH - ROW_INSET_X - COLOR_PANEL_WIDTH,
                    (ROW_HEIGHT + SWATCH_HEIGHT) / 2 + COLOR_PANEL_GAP)
        UiAlign("top left")

        insidePanel = UiIsMouseInRect(COLOR_PANEL_WIDTH, panelHeight)

        UiColor(COLOR_PANEL_COLOR)
        UiRoundedRect(COLOR_PANEL_WIDTH, panelHeight, BOX_CORNER_RADIUS)

        UiTranslate(COLOR_PANEL_PADDING, COLOR_PANEL_PADDING)

        for channel, channelLabel in ipairs(COLOR_CHANNEL_LABELS) do
            local pendingKey = key .. "." .. channel
            local savedValue = color[channel]
            local displayValue = pendingValues[pendingKey] or savedValue

            UiPush()
                UiPush()
                    UiTranslate(0, COLOR_CHANNEL_HEIGHT / 2)
                    UiAlign("left middle")
                    UiColor(Menu.textMutedColor)
                    UiFont("bold.ttf", CONTROL_FONT_SIZE)
                    UiText(channelLabel)
                UiPop()

                UiPush()
                    UiTranslate(COLOR_CHANNEL_LABEL_WIDTH + SLIDER_VALUE_GAP,
                                COLOR_CHANNEL_HEIGHT / 2)
                    local thumbOffsetX, released =
                        drawSliderTrack(displayValue, COLOR_CHANNEL_TRACK_WIDTH)

                    local draggedValue = snapValue(
                        thumbOffsetX / COLOR_CHANNEL_TRACK_WIDTH,
                        0.0, 1.0, COLOR_CHANNEL_STEP)

                    if released then
                        pendingValues[pendingKey] = nil
                        if draggedValue ~= savedValue then
                            color[channel] = draggedValue
                            saveSettings()
                        end
                    elseif draggedValue ~= displayValue then
                        pendingValues[pendingKey] = draggedValue
                        color[channel] = draggedValue
                    end
                UiPop()

                UiPush()
                    UiTranslate(COLOR_CHANNEL_LABEL_WIDTH + SLIDER_VALUE_GAP +
                                COLOR_CHANNEL_TRACK_WIDTH + SLIDER_VALUE_GAP +
                                COLOR_CHANNEL_VALUE_WIDTH,
                                COLOR_CHANNEL_HEIGHT / 2)
                    UiAlign("right middle")
                    UiColor(Menu.textColor)
                    UiFont("regular.ttf", CONTROL_FONT_SIZE)
                    UiText(string.format("%.2f", displayValue))
                UiPop()
            UiPop()
            UiTranslate(0, COLOR_CHANNEL_HEIGHT)
        end
        UiModalEnd()
    UiPop()

    return insidePanel
end

local function drawPositionPreview(Menu, row, position)
    local previewOffsetX = ROW_WIDTH - ROW_INSET_X - PREVIEW_WIDTH
    local previewOffsetY = (PREVIEW_ROW_HEIGHT - PREVIEW_HEIGHT) / 2
    local travelWidth = PREVIEW_WIDTH - PREVIEW_CHIP_WIDTH
    local travelHeight = PREVIEW_HEIGHT - PREVIEW_CHIP_HEIGHT

    UiPush()
        UiTranslate(previewOffsetX, previewOffsetY)
        UiAlign("top left")

        UiPush()
            UiColor(PREVIEW_BORDER_COLOR)
            UiRect(PREVIEW_WIDTH, PREVIEW_HEIGHT)
            UiTranslate(1, 1)
            UiColor(PREVIEW_BACKGROUND_COLOR)
            UiRect(PREVIEW_WIDTH - 2, PREVIEW_HEIGHT - 2)
        UiPop()

        local insidePreview = UiIsMouseInRect(PREVIEW_WIDTH, PREVIEW_HEIGHT)
        local mouseOffsetX, mouseOffsetY = UiGetMousePos()

        if grabbedPositionKey == nil and insidePreview and
           UiReceivesInput() and InputPressed("lmb") then
            grabbedPositionKey = row.key
        end

        if grabbedPositionKey == row.key then
            if InputDown("lmb") then
                position[1] = clamp((mouseOffsetX - PREVIEW_CHIP_WIDTH / 2) /
                                    travelWidth, 0.0, 1.0)
                position[2] = clamp((mouseOffsetY - PREVIEW_CHIP_HEIGHT / 2) /
                                    travelHeight, 0.0, 1.0)
            else
                grabbedPositionKey = nil
                saveSettings()
            end
        end

        UiPush()
            UiTranslate(position[1] * travelWidth, position[2] * travelHeight)
            UiColor(PREVIEW_CHIP_COLOR)
            UiRoundedRect(PREVIEW_CHIP_WIDTH, PREVIEW_CHIP_HEIGHT, BOX_CORNER_RADIUS)
        UiPop()
    UiPop()

    UiPush()
        UiTranslate(previewOffsetX - SLIDER_VALUE_GAP,
                    PREVIEW_ROW_HEIGHT / 2)
        UiAlign("right middle")
        UiColor(Menu.textMutedColor)
        UiFont("regular.ttf", CONTROL_FONT_SIZE)
        UiText(string.format("%.2f, %.2f", position[1], position[2]))
    UiPop()
end

function drawRender(Menu, page)
    local overlay = getSettings().overlay

    UiPush()
        UiAlign("top left")

        local totalHeight = 0
        local openColorOffsetY = nil

        for index, row in ipairs(OVERLAY_ROWS) do
            local rowHeight = row.height or ROW_HEIGHT

            UiPush()
                drawRowChrome(Menu, row, rowHeight)

                if row.type == "toggle" then
                    drawToggle(overlay[row.key])
                    if drawRowButton(rowHeight) then
                        setOverlaySetting(row.key, not overlay[row.key])
                    end
                elseif row.type == "slider" then
                    drawSlider(Menu, row, overlay[row.key])
                elseif row.type == "color" then
                    drawSwatch(overlay[row.key])
                    if openColorKey == row.key then
                        openColorOffsetY = totalHeight
                    elseif drawRowButton(rowHeight) then
                        openColorKey = row.key
                    end
                elseif row.type == "position" then
                    drawPositionPreview(Menu, row, overlay[row.key])
                end

                if index < #OVERLAY_ROWS then
                    drawDivider(Menu, rowHeight)
                end
            UiPop()

            UiTranslate(0, rowHeight)
            totalHeight = totalHeight + rowHeight
        end

        if openColorOffsetY then
            UiPush()
                UiTranslate(0, openColorOffsetY - totalHeight)
                local insidePanel = drawColorPanel(Menu, openColorKey,
                                                   overlay[openColorKey])

                if InputPressed("lmb") and not insidePanel then
                    openColorKey = nil
                end
            UiPop()
        end
    UiPop()
end
