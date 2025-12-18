#version 2

#include "menu/menu.lua"
--#include "settings/settings.lua"
#include "modules/modules.lua"
#include "util/debug.lua"

function server.init()
    Debug("server.init called")
    
    setupSettings()
    setupModules()

end

function server.tick(dt)
end

function server.update(dt)
    local playerId = GetLocalPlayer()
end

function client.init()
    Debug("client.init called")
end

function client.tick(dt)
end

function client.update(dt)
end

function client.draw()
end