local class = require("class.class")

local Unit = require("class.unit")
local Visual = require("class.visual")
local Chip = require("class.chip")

local unit_manager = require("manager.unit_manager")
local visual_manager = require("manager.visual_manager")

local Resource = require("driver.resource")
local Render = require("driver.render")
local Console = require("console.init")

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

    -- class
    export("Class", class.Class)

    -- base classes
    export("Unit", Unit)
    export("Visual", Visual)
    export("Chip", Chip)

    -- unit lifecycle
    export("New", unit_manager.spawn)
    export("Del", unit_manager.delete)
    export("Kill", unit_manager.delete)
    export("IsValid", unit_manager.is_valid)

    -- visual lifecycle
    export("NewVisual", visual_manager.spawn)
    export("DelVisual", visual_manager.delete)
    export("IsVisualValid", visual_manager.is_valid)

    -- script include
    export("Include", function(path)
        return lstg.DoFile(path)
    end)

    -- motion helpers
    export("SetV", function(obj, v, angle)
        local r = math.rad(angle)
        obj.vx = v * math.cos(r)
        obj.vy = v * math.sin(r)
        obj.rot = angle
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

    -- namespaces
    export("Resource", Resource)
    export("Render", Render)
    export("Console", Console)
end

return M