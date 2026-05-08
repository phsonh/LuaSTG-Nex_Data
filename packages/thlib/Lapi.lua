local class = require("class.class")
local Unit = require("class.unit")
local Visual = require("class.visual")
local Chip = require("class.chip")

local unit_manager = require("manager.unit_manager")
local visual_manager = require("manager.visual_manager")

local Resource = require("driver.resource")
local Render = require("driver.render")
local Audio = require("driver.audio")
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

    export("Class", class.Class)

    export("Unit", Unit)
    export("Visual", Visual)
    export("Chip", Chip)

    export("New", unit_manager.spawn)
    export("Del", unit_manager.delete)
    export("Kill", unit_manager.delete)
    export("IsValid", unit_manager.is_valid)

    export("NewVisual", visual_manager.spawn)
    export("DelVisual", visual_manager.delete)
    export("IsVisualValid", visual_manager.is_valid)

    export("NewChip", visual_manager.spawn_chip)
    export("DelChip", visual_manager.delete_chip)
    export("IsChipValid", visual_manager.is_chip_valid)

    export("Include", function(path)
        return lstg.DoFile(path)
    end)

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

    if _G.Color == nil and lstg.Color then
        export("Color", lstg.Color)
    end

    export("Resource", Resource)
    export("Render", Render)
    export("Audio", Audio)
    export("Console", Console)
end

return M
