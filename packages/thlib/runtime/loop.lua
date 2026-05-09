local unit_manager = require("manager.unit_manager")
local visual_manager = require("manager.visual_manager")
local View = require("view")
local Debug = require("debug.init")

local M = {}

function M.frame()
    unit_manager.update_all()
    visual_manager.update_all()

    if Debug.HUD and Debug.HUD.update then
        Debug.HUD.update()
    end

    return false
end

function M.render()
    lstg.BeginScene()

    View.SetViewMode("world")
    visual_manager.render_all()

    lstg.EndScene()
end

return M