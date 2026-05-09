local API = require("api")
local loop = require("runtime.loop")
local Debug = require("debug.init")

local M = {}

function M.init()
    API.install()

    Debug.Print("[thlib.runtime] init")

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

    Debug.Print("[thlib.runtime] shutdown")

    unit_manager.clear()
    visual_manager.clear()
end

function M.event(event, ...)
end

return M