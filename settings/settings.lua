#include "../exts/umf/umf_utils.lua"
#include "defaults.lua"
#include "../util/debug.lua"

local Settings = getSettingsDefault()

local function mergeSettings(defaults, saved)
    local merged = {}
    for key, defaultValue in pairs(defaults) do
        local savedValue = saved[key]
        if type(defaultValue) == "table" then
            if type(savedValue) == "table" then
                merged[key] = mergeSettings(defaultValue, savedValue)
            else
                merged[key] = Clone(defaultValue)
            end
        elseif type(savedValue) == type(defaultValue) then
            merged[key] = savedValue
        else
            merged[key] = defaultValue
        end
    end
    return merged
end

function setupSettings()
    Debug("setupSettings() called")

    local hasVersion = HasKey("savegame.mod.version")
    local hasOldVersion = GetFloat("savegame.mod.version") < 3.0
    local hasOptions = HasKey("savegame.mod.options") and 
        GetString("savegame.mod.options") ~= ""

    -- If the user uses a version before 3.0, 
    -- switch over to use the newer settings system.
    if (not hasVersion) or hasOldVersion or (not hasOptions) then
        Debug("Pre 3.0 settings system, clearing keys...")
        ClearKey("savegame.mod")
        SetFloat("savegame.mod.version", VERSION)
        SetString("savegame.mod.options", util.serialize(Settings))
    end

    -- Introduce new settings of the mod to the current
    -- list of settings by appending old settings on
    -- every game launch.
    if HasKey("savegame.mod.options") then
        Debug("Loading settings...")
        Settings = getSettings()

        SetFloat("savegame.mod.version", VERSION)
        SetString("savegame.mod.options", util.serialize(Settings))
        Debug("Settings updated.")
    end
end

function getSettings()
    local unserialized = util.unserialize(GetString("savegame.mod.options"))

    Settings = mergeSettings(getSettingsDefault(), unserialized)
    Debug("Settings loaded!")

    return Settings
end

function saveSettings()
    SetString("savegame.mod.options", util.serialize(Settings))
    Debug("Settings updated.")
end

local function getSetting(path, default)
    local t = Settings
    for key in path:gmatch("[^.]+") do
        t = t[key]
        if t == nil then return default end
    end
    return t
end

local function setSetting(path, value)
    local t = Settings
    local keys = {}
    for k in path:gmatch("[^.]+") do keys[#keys+1] = k end
    for i = 1, #keys - 1 do
        t = t[keys[i]]
        if type(t) ~= "table" then return false end
    end
    t[keys[#keys]] = value
    return true
end
