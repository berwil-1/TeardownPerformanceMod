#include "../settings/settings.lua"
#include "../util/debug.lua"

#include "level/fire.lua"
#include "module.lua"

local Settings = getSettings()
local Modules = {}

function dispatchModules(method, ...)
    Debug("dispatchModules() called")
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
        --Module.new("General", Settings.mod),
        --Module.new("Overlay", Settings.overlay),
        --Module.new("Debris", Settings.debris),
        FireModule.new(Settings.fire),
        --Module.new("Light", Settings.light),
        --Module.new("Fog", Settings.fog),
    }
end