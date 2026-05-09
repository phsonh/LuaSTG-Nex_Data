local Unit = require("class.unit")

local M = {}

M.enabled = true
M.title_enabled = true
M.update_interval = 30

local frame_count = 0
local last_clock = os.clock()
local fps = 0

local base_title = nil

local function get_base_title()
    if base_title ~= nil then
        return base_title
    end

    if type(setting) == "table" and setting.title then
        base_title = tostring(setting.title)
    else
        base_title = "LuaSTG-Nex"
    end

    return base_title
end

local function get_unit_count()
    return Unit.Count()
end

function M.update()
    if not M.enabled then
        return
    end

    frame_count = frame_count + 1

    if frame_count % M.update_interval ~= 0 then
        return
    end

    local now = os.clock()
    local dt = now - last_clock

    if dt > 0 then
        fps = M.update_interval / dt
    end

    last_clock = now

    if M.title_enabled and lstg.SetTitle then
        lstg.SetTitle(string.format(
            "%s | Unit=%d | FPS=%.1f",
            get_base_title(),
            get_unit_count(),
            fps
        ))
    end
end

function M.get_fps()
    return fps
end

function M.get_unit_count()
    return get_unit_count()
end

return M