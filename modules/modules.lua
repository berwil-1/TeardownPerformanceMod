#include "../settings/settings.lua"
#include "../util/debug.lua"

#include "level/fire.lua"
#include "level/debris.lua"
#include "module.lua"

local Settings = getSettings()
local Modules = {}

function dispatchModules(method, ...)
    for _, module in pairs(Modules) do
        if module:enabled() and module[method] then
            module[method](module, ...)
        end
    end
end

function setupModules()
    Debug("setupModules() called")
    
    -- Setup all Modules with parameters
    Modules = { 
        --Module.new("General", Settings.general),
        FireModule.new(Settings.fire),
        DebrisModule.new(Settings.debris),
    }
end
