#include "../../util/debug.lua"
#include "../module.lua"

Overlay = Module:extend()

function Overlay.new(settings)
    local self = Module.new("Overlay", settings)
    return setmetatable(self, Overlay)
end

function Overlay:init()
    Debug("Overlay:init()")
end

function Overlay:update(dt)
end

function Overlay:draw()
end
