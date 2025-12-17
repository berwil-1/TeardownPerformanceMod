#include "menu/menu.lua"
#include "settings/settings.lua"
#include "modules/modules.lua"

function server.init()
    setupSettings()
    setupModules()
end

function server.tick(dt)
end


function client.init()
    
end

function client.tick(dt)
	local playerId = GetLocalPlayer()

    
end

function client.draw()
    UiFont("bold.ttf", 72)
    UiAlign("center middle") 

end