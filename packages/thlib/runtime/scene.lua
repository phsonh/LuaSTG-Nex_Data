local Scene = {}
Scene.__index = Scene
Scene.__is_scene_base = true

function Scene:init()
end

function Scene:getName()
    return self.__scene_name or "__unnamed__"
end

function Scene:getTimer()
    return self.timer or 0
end

function Scene:on_enter()
end

function Scene:on_leave()
end

function Scene:update()
end

function Scene:render()
end

function Scene:on_focus_lost()
end

function Scene:on_focus_gain()
end

-- OLC / legacy 命名兼容层。
function Scene:onCreate(...)
    return self:on_enter(...)
end

function Scene:onDestroy(...)
    return self:on_leave(...)
end

function Scene:onUpdate(...)
    return self:update(...)
end

function Scene:onRender(...)
    return self:render(...)
end

function Scene:onDeactivated(...)
    return self:on_focus_lost(...)
end

function Scene:onActivated(...)
    return self:on_focus_gain(...)
end

return Scene