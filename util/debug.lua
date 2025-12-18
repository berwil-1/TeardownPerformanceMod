local count = 0

function Debug(text)
    DebugWatch(GetTime() .. " " .. count, "[DEBUG]" .. text)
    count = count + 1
end

function Info(text)
    DebugWatch(GetTime() .. " " .. count, "[INFO]" .. text)
    count = count + 1
end

function Warn(text)
    DebugWatch(GetTime() .. " " .. count, "[WARN]" .. text)
    count = count + 1
end

function Error(text)
    DebugWatch(GetTime() .. " " .. count, "[ERROR]" .. text)
    count = count + 1
end