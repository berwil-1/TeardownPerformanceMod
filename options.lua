-- Interface
#include "assets/interface/window.lua"

inMenu = true

local init = function()
    for name, module in pairs(modules) do
        if module.init then
    		module.init()
        end
    end
end

local draws = 0
local draw = function()
    UiImage("MOD/assets/image/background/options.png")
    UiPush()
        DrawInterface()
    UiPop()

    draws = draws + 1
end

local pressed = function(key)
	if key == "esc" then
	   SetString("savegame.mod.options", util.serialize(options))
    end
    
    for name, module in pairs(modules) do
        if module.pressed then
            UiPush()
            	module.pressed(key)
            UiPop()
        end
    end
end

local released = function(key)
    for name, module in pairs(modules) do
        if module.released then
            UiPush()
            	module.released(key)
            UiPop()
        end
    end
end

hook.add("base.init", "performance.init", init)
hook.add("base.draw", "performance.draw", draw)
hook.add("api.key.pressed", "performance.key.pressed", pressed)
hook.add("api.key.released", "performance.key.released", released)