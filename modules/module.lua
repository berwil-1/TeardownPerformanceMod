#include "../exts/umf/umf_utils.lua"
#include "../util/debug.lua"

Module = {}
Module.__index = Module

function Module.new(name, settings)
    Debug("Module.new(name=" .. name .. ", settings=" .. 
        util.serialize(settings) .. ")")
    return setmetatable({
        name = name,
        settings = settings,
        data = {}
    }, Module)
end

function Module:extend()
    local cls = {}
    cls.__index = cls
    return setmetatable(cls, self)
end

function Module:init()
    Debug("Module:init() in " .. self.name)
end

function Module:tick(dt)
end

function Module:update(dt)
end

function Module:draw()
end

function Module:enabled()
    return self.settings and self.settings.enabled ~= false
end