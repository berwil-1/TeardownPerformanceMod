#include "../../util/debug.lua"
#include "../module.lua"

-- fire = {
--     enabled = false,
--     performance = false,
--     fireLimit = 200,
--     fireSpread = 1,
-- }

FireModule = Module:extend()

function FireModule.new(settings)
    local self = Module.new("Fire", settings)
    return setmetatable(self, FireModule)
end

function FireModule:init()
    Debug("FireModule:init()")
    self.data.fireCount = GetFireCount()
end

function FireModule:tick(dt)
    Debug("FireModule:tick()")
    if self.data.fireCount ~= GetFireCount() then
        dispatchModules("fireCountUpdate", GetFireCount())
    end
    self.data.fireCount = GetFireCount()
end

function FireModule:fireCountUpdate(count)
    if count >= self.settings.fireLimit then
        Warn("Fire amount is " .. count)
    else
        Info("Fire amount is " .. count)
    end
end

function FireModule:enabled()
    return false
end
