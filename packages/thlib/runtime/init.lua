local Lapi = require("Lapi")
local loop = require("runtime.loop")
local Console = require("console.init")

local M = {}

function M.init()
    Lapi.install()

    Console.Print("[thlib.runtime] init")

    lstg.DoFile("root.lua")
end

function M.frame()
    return loop.frame()
end

function M.render()
    loop.render()
end

function M.shutdown()
    local unit_manager = require("manager.unit_manager")
    local visual_manager = require("manager.visual_manager")

    Console.Print("[thlib.runtime] shutdown")

    visual_manager.clear()
    unit_manager.clear()
end

function M.event(event, ...)
end

return M
