#include "../settings/settings.lua"

local Settings = getSettings()

local Modules = {
    { settings = Settings.mod, data = {} },
    { settings = Settings.overlay, data = {} },
    { settings = Settings.debris, data = {} },
    { settings = Settings.fire, data = {} },
    { settings = Settings.light, data = {} },
    { settings = Settings.fog, data = {} }
}

function setupModules()
    for idx, md in pairs(Modules) do
        DebugWatch(idx, md)
    end
end