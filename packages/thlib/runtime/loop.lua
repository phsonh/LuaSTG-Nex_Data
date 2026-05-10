local SceneManager = require("runtime.scene_manager")
local unit_manager = require("manager.unit_manager")
local visual_manager = require("manager.visual_manager")
local View = require("view")
local Debug = require("debug.init")

local M = {}

function M.frame()
    SceneManager.update()

    unit_manager.update_all()
    visual_manager.update_all()

    if Debug.HUD and Debug.HUD.update then
        Debug.HUD.update()
    end

    return SceneManager.getExitSignal()
end

function M.render()
    lstg.BeginScene()

    View.SetViewMode("world")

    -- Scene:render() 适合画背景、UI 底层、特殊后处理入口。
    SceneManager.render()

    -- Visual 系统统一画 Unit / Bullet / Effect 的表现层。
    visual_manager.render_all()

    lstg.EndScene()
end

return M