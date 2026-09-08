#include "../../util/debug.lua"
#include "../module.lua"

OverlayModule = Module:extend()

function OverlayModule.new(settings)
    local self = Module.new("OverlayModule", settings)
    return setmetatable(self, OverlayModule)
end

function OverlayModule:init()
    DebugPrint("awd")
    Debug("OverlayModule:init()")
end

function OverlayModule:update(dt)
    DebugWatch("Fps", GetFps())
end

function OverlayModule:draw()
end
