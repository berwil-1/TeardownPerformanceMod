#version 2

#include "menu/menu.lua"
--#include "settings/settings.lua"
#include "modules/modules.lua"
#include "util/debug.lua"

local menuVisible = false

function server.init()
    Debug("server.init() called")
    
    setupSettings()
    setupModules()

    dispatchModules("init")
end

function server.tick(dt)
    dispatchModules("tick")
    --serverTickModules(dt)

    local bodies = FindBodies("", true)
    local shapes = FindShapes("", true)
    local lights = FindLights("", true)

    for i = 1, #bodies do
        dispatchModules("body", bodies[i])
    end

    for i = 1, #shapes do
        dispatchModules("shape", shapes[i])
    end

    for i = 1, #lights do
        dispatchModules("light", lights[i])
    end
end

function server.update(dt)
    dispatchModules("update")
    --serverUpdateModules(dt)
end

function client.init()
    Debug("client.init() called")
end

function client.tick(dt)
    local id = GetLocalPlayer()

    if PauseMenuButton("Performance Mod", "main_bottom") or InputPressed("p", id) then
        menuVisible = not menuVisible
    end
end

function client.update(dt)
end

function client.draw()
    if menuVisible then
        setupMenu()
        drawMenu()
    end
end