#include "../util/debug.lua"
#include "../settings/settings.lua"
#include "general.lua"
#include "level.lua"
#include "benchmark.lua"
#include "render.lua"

local Menu = {}

local Pages = {
    {id = "general", label = "General", icon = "MOD/assets/Settings.png", func = drawGeneral},
    {id = "level",   label = "Level",   icon = "MOD/assets/Map.png", func = drawLevel},
    {id = "benchmark", label = "Benchmark", icon = "MOD/assets/Chart_Line.png", func = drawBenchmark},
    {id = "render", label = "Render", icon = "MOD/assets/Layers.png", func = drawRender},
}

local activePageId = "general"

function setupMenu()
    Debug("setupMenu() called")

    Menu = {
        -- Colors
        backgroundColor      = {0.0, 0.0, 0.0, 0.9},
        sidebarColor         = {0.0, 0.0, 0.0, 0.5},
        sidebarHoverColor    = {0.1, 0.1, 0.1, 1.0},
        sidebarActiveColor   = {0.15, 0.15, 0.15, 1.0},
        dividerColor         = {1.0, 1.0, 1.0, 0.06},
        textColor            = {1.0, 1.0, 1.0, 1.0},
        textMutedColor       = {0.7, 0.7, 0.7, 1.0},
        textDimColor         = {0.5, 0.5, 0.5, 1.0},

        -- Layout
        screen_width         = UiWidth(),
        screen_height        = UiHeight(),
        sidebar_width        = 260,
        sidebar_padding      = 16,
        logo_height          = 110,
        item_height          = 44,
        item_gap             = 4,
        content_padding_x    = 56,
        content_padding_y    = 56,
    }
end

function defaultText()
    Debug("defaultText() called")

    UiColor(Menu.textColor)
    UiFont("regular.ttf", 18)
    UiAlign("top left")
end

function drawMenu()
    Debug("drawMenu() called")

    UiMakeInteractive()
    drawMenuBackground()
    UiScale(getSettings().general.uiScale)
    drawSidebar()
    drawContent()
end

function drawMenuBackground()
    Debug("drawMenuBackground() called")

    UiPush()
        UiAlign("top left")
        UiColor(Menu.backgroundColor)
        UiRect(Menu.screen_width, Menu.screen_height)
    UiPop()
end

function drawSidebar()
    UiPush()
        UiAlign("top left")

        -- Sidebar fill
        UiPush()
            UiColor(Menu.sidebarColor)
            UiRect(Menu.sidebar_width, Menu.screen_height * 2)
        UiPop()

        -- Right-edge divider line that separates sidebar from content
        UiPush()
            UiTranslate(Menu.sidebar_width - 1, 0)
            UiColor(Menu.dividerColor)
            UiRect(1, Menu.screen_height)
        UiPop()

        drawLogoLockup()
        drawSidebarItems()
    UiPop()
end

function drawLogoLockup()
    UiPush()
        UiTranslate(Menu.sidebar_padding + 8, Menu.sidebar_padding + 14)
        UiAlign("top left")

        local title_size   = 28
        local version_size = 16
        local version_drop = math.floor(title_size * 0.4)
        local gap          = -6

        UiFont("bold.ttf", title_size)
        UiTextOutline(0.0, 0.0, 0.0, 2.0)
        UiColor(Menu.textColor)
        UiText("Performance Mod")

        local title_width = UiGetTextSize("Performance Mod")
        UiTranslate(title_width + gap, version_drop)
        UiFont("regular.ttf", version_size)
        UiTextOutline(0.0, 0.0, 0.0, 2.0)
        UiColor(Menu.textMutedColor)
        UiText("v4.0")
    UiPop()

    -- Horizontal divider underneath the logo lockup
    UiPush()
        UiTranslate(Menu.sidebar_padding, Menu.logo_height)
        UiColor(Menu.dividerColor)
        UiRect(Menu.sidebar_width - Menu.sidebar_padding * 2, 1)
    UiPop()
end

function drawSidebarItems()
    UiPush()
        UiTranslate(Menu.sidebar_padding,
                    Menu.logo_height + Menu.sidebar_padding)
        local item_width = Menu.sidebar_width - Menu.sidebar_padding * 2

        for _, page in ipairs(Pages) do
            if drawSidebarItem(page, item_width, Menu.item_height) then
                activePageId = page.id
            end
            UiTranslate(0, Menu.item_height + Menu.item_gap)
        end
    UiPop()
end

function drawSidebarItem(page, width, height)
    local hovered = UiIsMouseInRect(width, height)
    local active  = (page.id == activePageId)
    local clicked = hovered and InputPressed("lmb")

    UiPush()
        UiAlign("top left")

        -- Row background only paints when there's something to show
        if active then
            UiColor(Menu.sidebarActiveColor)
            UiRoundedRect(width, height, 6)
        elseif hovered then
            UiColor(Menu.sidebarHoverColor)
            UiRoundedRect(width, height, 6)
        end

        local icon_size = 22
        local icon_pad  = 14

        -- Icon (or placeholder square when the file isn't there yet)
        UiPush()
            UiTranslate(icon_pad, (height - icon_size) / 2)
            UiAlign("top left")
            UiColor(active and Menu.textColor or Menu.textMutedColor)
            if UiHasImage(page.icon) then
                UiImageBox(page.icon, icon_size, icon_size, 0, 0)
            else
                UiRoundedRect(icon_size, icon_size, 4)
            end
        UiPop()

        -- Label
        UiPush()
            UiTranslate(icon_pad + icon_size + 12, height / 2)
            UiAlign("left middle")
            UiColor(active and Menu.textColor or Menu.textMutedColor)
            UiFont(active and "bold.ttf" or "regular.ttf", 16)
            UiText(page.label)
        UiPop()
    UiPop()

    return clicked
end

function drawContent()
    UiPush()
        UiAlign("top left")
        UiTranslate(Menu.sidebar_width + Menu.content_padding_x,
                    Menu.content_padding_y)

        local active = getActivePage()
        drawContentHeader(active)
        UiTranslate(0, 110)
        drawContentPlaceholder(active)
    UiPop()
end

function getActivePage()
    for _, page in ipairs(Pages) do
        if page.id == activePageId then
            return page
        end
    end
    return Pages[1]
end

function drawContentHeader(page)
    UiPush()
        UiAlign("top left")

        -- Breadcrumb
        UiColor(Menu.textDimColor)
        UiFont("regular.ttf", 14)
        UiText("Performance Mod  >  " .. page.label)

        -- Page title
        UiTranslate(0, 28)
        UiColor(Menu.textColor)
        UiFont("bold.ttf", 36)
        UiText(page.label)
    UiPop()
end

function drawContentPlaceholder(page)
    UiPush()
        UiAlign("top left")
        page.func(Menu, page)
    UiPop()
end
