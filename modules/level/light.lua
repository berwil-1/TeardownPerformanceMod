#include "../../util/debug.lua"
#include "../module.lua"

LightModule = Module:extend()

function LightModule.new(settings)
    local self = Module.new("Light", settings)
    return setmetatable(self, LightModule)
end

function LightModule:init()
    Debug("LightModule:init()")
end

function LightModule:update(dt)
end

function LightModule:draw()
end

function LightModule:light(light)
    SetLightIntensity(light, self.settings.lightIntensity)
end