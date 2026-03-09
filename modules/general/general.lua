#include "../../util/debug.lua"
#include "../module.lua"

GeneralModule = Module:extend()

function GeneralModule.new(settings)
    local self = Module.new("General", settings)
    return setmetatable(self, GeneralModule)
end

function GeneralModule:init()
    Debug("GeneralModule:init()")
end

function GeneralModule:update(dt)
end

function GeneralModule:draw()
end
