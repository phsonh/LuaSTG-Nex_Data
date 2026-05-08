local unit_manager = require("manager.unit_manager")

local M = {}

function M.frame()
    unit_manager.update_all()
    return false
end

function M.render()
    lstg.BeginScene()
    -- VisualManager will be called here in the next phase.
    lstg.EndScene()
end

function M.shutdown()
    unit_manager.clear()
end

function M.event(event, ...)
end

return M
