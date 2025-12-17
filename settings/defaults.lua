#include "../exts/umf/umf_utils.lua"

MOD_NAME = "Performance Mod"
AUTHOR = "CoolJWB"
VERSION = 4.0

local DEFAULT_SETTINGS = {
    mod = {
        enabled = true,
        keybind = "p",
        visible = false,
        advanced = true,
        speedrun = false,
        experimental = false,
        debug = false,
    },
    overlay = {
        enabled = false,
        position = { 0, 0 },
        size = 1,
        textSize = 16,
        textColor = { 1, 1, 1, 1 },
        backColor = { 0, 0, 0, 0.5 },
        accuracy = 2,
        frequency = 10,
        duration = 60,
        background = true,
        graph = false,
        estimate = false,
        frameCount = true,
        frameCountMax = true,
        frameCountMin = true,
        bodyCount = false,
        shapeCount = false,
        fireCount = false,
    },
    debris = {
        enabled = false,
        smart = true,
        cleaner = true,
        particle = false,
        stabilizer = false,
        collider = true,
        collideLevel = true,
        cleanerVoxelCount = 50,
        particleAmount = 2,
        stabilizerVoxelCount = 50,
        stabilizerRadius = 20,
        stabilizerForce = 0.1,
        colliderVoxelCount = 100,
    },
    fire = {
        enabled = false,
        performance = false,
        fireLimit = 200,
        fireSpread = 1,
    },
    light = {
        enabled = false,
        shadowLimit = 32,
        lampLimit = 1,
        lampColor = { 1, 1, 1, 1 },
    },
    fog = {
        enabled = false,
        fogStart = 50,
        fogEnd = 200,
        fogAmount = 0.9,
        fogExponent = 8,
    },
}

function getSettingsDefault()
    return Clone(DEFAULT_SETTINGS)
end
