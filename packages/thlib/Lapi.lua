local class = require("class.class")
local Unit = require("class.unit")
local unit_manager = require("manager.unit_manager")

local M = {}
local installed = false

local function export(name, value)
    _G[name] = value
end

function M.install()
    if installed then
        return
    end
    installed = true

    -- class / unit DSL
    export("Class", class.Class)
    export("Unit", Unit)

    -- lifecycle
    export("New", unit_manager.spawn)
    export("Del", unit_manager.delete)
    export("Kill", unit_manager.delete)
    export("IsValid", unit_manager.is_valid)

    -- script loading
    export("Include", function(path)
        return lstg.DoFile(path)
    end)

    -- logging
    export("Log", lstg.Log)

    -- motion helpers, angle is in degrees
    export("SetV", function(obj, v, angle, update_rot)
        local r = math.rad(angle)
        obj.vx = v * math.cos(r)
        obj.vy = v * math.sin(r)
        if update_rot then
            obj.rot = angle
        end
    end)

    export("SetA", function(obj, a, angle)
        local r = math.rad(angle)
        obj.ax = a * math.cos(r)
        obj.ay = a * math.sin(r)
    end)

    export("Dist", function(a, b)
        local dx = a.x - b.x
        local dy = a.y - b.y
        return math.sqrt(dx * dx + dy * dy)
    end)

    export("Angle", function(a, b)
        return math.deg(math.atan2(b.y - a.y, b.x - a.x))
    end)
end

return M
