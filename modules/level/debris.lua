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

function DebrisModule:shape(shape)
    local voxels = GetShapeVoxelCount(shape)
	local broken = IsShapeBroken(shape)

    --if settings.general.debug then
    if broken and voxels < 50 then
		DrawShapeOutline(shape, 1, 1, 1, 1)
	end
end

function DebrisModule:enabled()
    return false
end