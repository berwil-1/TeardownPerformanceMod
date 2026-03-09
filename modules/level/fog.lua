#include "../../util/debug.lua"
#include "../module.lua"

FogModule = Module:extend()

function FogModule.new(settings)
    local self = Module.new("Fog", settings)
    return setmetatable(self, FogModule)
end

function FogModule:init()
    Debug("FogModule:init()")
end

function FogModule:update(dt)
end

function FogModule:draw()
end

function FogModule:fogUpdate()
    SetEnvironmentProperty("fogParams", self.settings.fogStart, 
        self.settings.fogEnd, self.settings.fogAmount, 
        self.settings.fogExponent)
end