#include "../../util/debug.lua"
#include "../module.lua"

DebrisModule = Module:extend()

function DebrisModule.new(settings)
    local self = Module.new("Debris", settings)
    return setmetatable(self, DebrisModule)
end

function DebrisModule:init()
    Debug("DebrisModule:init()")
end

function DebrisModule:update(dt)
end

function DebrisModule:draw()
end
