local API = require("api")
local loop = require("runtime.loop")
local SceneManager = require("runtime.scene_manager")
local Debug = require("debug.init")

local M = {}

function M.init()
    API.install()
    SceneManager.init()

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

    SceneManager.shutdown()

    unit_manager.clear()
    visual_manager.clear()
end

function M.focus_lost()
    SceneManager.on_focus_lost()
end

function M.focus_gain()
    SceneManager.on_focus_gain()
end

function M.event(event, ...)
    local scene = SceneManager.current()

    if scene and scene.event then
        return scene:event(event, ...)
    end
end

return M