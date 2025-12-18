#include "../exts/umf/umf_utils.lua"
#include "defaults.lua"
#include "../util/debug.lua"

local Settings = getSettingsDefault()

function setupSettings()
    Debug("setupSettings called")

    local hasVersion = HasKey("savegame.mod.version")
    local hasOldVersion = GetFloat("savegame.mod.version") < 3.0
    local hasOptions = HasKey("savegame.mod.options") and 
        GetString("savegame.mod.options") ~= ""

    -- If the user uses a version before 3.0, 
    -- switch over to use the newer settings system.
    if (not hasVersion) or hasOldVersion or (not hasOptions) then
        Debug("Pre 3.0 settings system, clearing keys...")
        ClearKey("savegame.mod")
        SetFloat("savegame.mod.version", version)
        SetString("savegame.mod.options", util.serialize(Settings))
    end

    -- Introduce new settings of the mod to the current
    -- list of settings by appending old settings on
    -- every game launch.
    if HasKey("savegame.mod.options") then
        Debug("Loading settings...")
        local unserialized = util.unserialize(GetString("savegame.mod.options"))
        
        for name, setting in pairs(unserialized) do
            Settings[name] = setting
        end
        Debug("Settings loaded!")

        SetFloat("savegame.mod.version", VERSION)
        SetString("savegame.mod.options", util.serialize(Settings))
        Debug("Settings updated.")
    end
end

function getSettings()
    return Settings
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
