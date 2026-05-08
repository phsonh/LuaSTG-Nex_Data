local unit_manager = require("manager.unit_manager")
local visual_manager = require("manager.visual_manager")
local Render = require("driver.render")

local M = {}

function M.frame()
    unit_manager.update_all()
    visual_manager.update_all()
    return false
end

function M.render()
    lstg.BeginScene()

    Render.SetViewMode("world")

    visual_manager.render_all()

    lstg.EndScene()
end

return M