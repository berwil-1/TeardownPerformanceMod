#include "../util/debug.lua"

local Menu = {}

function setupMenu()
    Debug("setupMenu() called")

    local width = math.ceil(UiWidth() / 3)
    width = width - math.fmod(width, 4)
    local height = UiHeight() - 200

    local center = math.ceil(UiCenter() / 3)
    center = center - math.fmod(center, 8)
    local middle = UiMiddle()

    Menu = {
        backgroundColor = {0.0, 0.0, 0.0, 0.5},
        buttonColor = {0.0, 0.0, 0.0, 0.5},
        buttonHoverColor = {0.0, 0.0, 0.0, 0.7},
        buttonPressColor = {0.0, 0.0, 0.0, 0.7},
        buttonTextColor = {1.0, 1.0, 1.0, 1.0},
        buttonTextHoverColor = {0.7, 0.7, 0.7, 1.0},
        buttonTextPressColor = {0.7, 0.7, 0.7, 1.0},
        width = width,
        height = height,
        top_left_x = UiCenter() - width / 2,
        top_left_y = UiMiddle() - height / 2,
        center_x = center + 50,
        middle_y = middle
    }
end

function defaultText()
    Debug("defaultText() called")
    UiColor(1.0, 1.0, 1.0, 1.0)
    UiFont("regular.ttf", 24)
    UiAlign("top left") 
end

function drawMenu()
    Debug("drawMenu() called")
    UiMakeInteractive()
    drawMenuBackground()
    drawTitle()
    drawModules()
end

function drawMenuBackground()
    Debug("drawMenuBackground() called")
    UiPush()
        UiColor(Menu.backgroundColor)
        UiAlign("top left")

        UiTranslate(Menu.top_left_x, Menu.top_left_y)
        UiRoundedRect(Menu.width, Menu.height, 10)

        UiClipRect(Menu.width, Menu.height / 10)
        UiColor(0.0, 0.0, 0.0, 0.8)
        UiRoundedRect(Menu.width, Menu.height / 10 + 10, 10)
    UiPop()
end

function drawTitle()
    UiPush()
        UiTranslate(Menu.top_left_x + 30, Menu.top_left_y + 30)
        defaultText()

        UiFont("bold.ttf", 48)
        UiText("Performance Mod")

        UiTranslate(320, 20)
        UiTextOutline(0.0, 0.0, 0.0, 2.0)
        UiFont("regular.ttf", 24)
        UiText("v4.0")
    UiPop()
end

function drawModuleButton(text, width, height, bold)
    local hovered = UiIsMouseInRect(width, height)
    local interact = InputDown("lmb") and hovered

    UiPush()
        -- Background
        UiPush()
            UiColor(hovered and Menu.buttonHoverColor or Menu.buttonColor)

            if interact then
                UiColor(Menu.buttonPressColor)
            end
            
            UiRoundedRect(width, height, 5)
            UiColor(Menu.buttonPressColor)
            UiRoundedRectOutline(width, height, 5, 1)
        UiPop()

        -- Text
        UiPush()
            UiTranslate(width / 2, height / 2)
            UiAlign("center middle")
            
            --UiTextOutline(0.0, 0.0, 0.0, 1.0)
            UiColor(hovered and Menu.buttonTextHoverColor or Menu.buttonTextColor)
            UiFont(bold and "bold.ttf" or "regular.ttf", 16)

            if interact then
                UiColor(Menu.buttonTextPressColor)
                UiTranslate(2, 2)
            end

            UiText(text)
        UiPop()
    UiPop()

    return interact
end

function drawModules()
    UiPush()
        UiTranslate(Menu.top_left_x + 10, Menu.top_left_y + Menu.height / 10 + 10)

        local width = math.ceil(Menu.width / 4)
        local height = 48

        drawModuleButton("GENERAL", width - 20, height, true)
        UiTranslate(width, 0)
        drawModuleButton("BENCH", width - 20, height)
        UiTranslate(width, 0)
        drawModuleButton("VISUALS", width - 20, height)
        UiTranslate(width, 0)
        drawModuleButton("LEVEL", width - 20, height)
        UiTranslate(width, 0)
        
    UiPop()
end
