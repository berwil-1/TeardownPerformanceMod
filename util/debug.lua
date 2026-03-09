function Debug(text)
    --DebugPrint("[DEBUG] " .. text)
end

function Info(text)
    DebugPrint("[INFO] " .. text)
end

function Warn(text)
    DebugPrint("[WARN] " .. text)
end

function Error(text)
    DebugPrint("[ERROR] " .. text)
end
