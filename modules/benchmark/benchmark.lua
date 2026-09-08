#include "../../util/debug.lua"
#include "../module.lua"

BenchmarkModule = Module:extend()

function BenchmarkModule.new(settings)
    local self = Module.new("Benchmark", settings)
    return setmetatable(self, BenchmarkModule)
end

function BenchmarkModule:init()
    Debug("BenchmarkModule:init()")

    DebugPrint(GetString("game.levelid"))
    DebugPrint(GetString("game.levelpath"))
    DebugPrint(GetString("loading.level_id"))
end

function BenchmarkModule:update(dt)
end

function BenchmarkModule:draw()
end
