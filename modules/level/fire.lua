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
end

function FireModule:fireCountUpdate(count)
    if count >= self.fireLimit then
        
    end
end

function FireModule:enabled()
    return true
end