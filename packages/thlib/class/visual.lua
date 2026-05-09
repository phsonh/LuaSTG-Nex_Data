local Layer = require("constants.layer")

local unpack = table.unpack or unpack

local Visual = {}
Visual.__index = Visual
Visual.__is_visual_base = true

Visual.Layer = Layer

function Visual:init(master)
    self.master = master

    self.ani_defs = {}

    self.current_name = nil
    self.current_ani = nil

    self.next_name = nil

    self.state = "empty"

    self.visible = true
    self.layer = 0
end

function Visual:addAni(name, ani_class, ...)
    assert(type(name) == "string", "Visual:addAni(name, ani_class, ...): name must be a string")
    assert(type(ani_class) == "table", "Visual:addAni(name, ani_class, ...): ani_class must be a class table")

    self.ani_defs[name] = {
        class = ani_class,
        args = { ... },
    }

    return self
end

function Visual:getAni()
    return self.current_ani
end

function Visual:play(name)
    assert(self.ani_defs[name] ~= nil, "Visual:play(name): unknown ani '" .. tostring(name) .. "'")

    -- 不在这里立刻切换。
    -- 只把切换请求交给 Visual 状态机。
    self.next_name = name

    if self.state ~= "dead" then
        self.state = "switching"
    end

    return self
end

function Visual:_destroyCurrentAni()
    local ani = self.current_ani

    if ani == nil then
        self.current_name = nil
        self.current_ani = nil
        return
    end

    local visual_manager = require("manager.visual_manager")
    visual_manager.delete_ani(ani)

    self.current_name = nil
    self.current_ani = nil
end

function Visual:_createAni(name)
    local def = self.ani_defs[name]
    assert(def ~= nil, "Visual:_createAni(name): unknown ani '" .. tostring(name) .. "'")

    local visual_manager = require("manager.visual_manager")

    local ani = visual_manager.spawn_ani(
        def.class,
        self.master,
        self,
        unpack(def.args)
    )

    self.current_name = name
    self.current_ani = ani

    return ani
end

function Visual:_applyState()
    if self.state ~= "switching" then
        return
    end

    local name = self.next_name
    self.next_name = nil

    if name == nil then
        if self.current_ani then
            self.state = "playing"
        else
            self.state = "empty"
        end
        return
    end

    self:_destroyCurrentAni()
    self:_createAni(name)

    self.state = "playing"
end

function Visual:isValid()
    return Visual.IsValid(self)
end

function Visual:delete()
    Visual.Del(self)
end

function Visual:del()
    self.state = "dead"
    self.next_name = nil

    self:_destroyCurrentAni()

    self.ani_defs = {}
end

function Visual:_update()
    -- 状态机在 update 开头统一处理切换。
    -- 这样 play() 不会立刻改变渲染对象；
    -- 新 Ani 创建后，本帧会正常执行 frame/task；
    -- render 时不会出现未初始化的 x/y/rot。
    self:_applyState()

    if self.state ~= "playing" then
        return
    end

    local ani = self.current_ani

    if ani and ani.__alive == true then
        ani.timer = (ani.timer or 0) + 1

        if ani.frame then
            ani:frame()
        end

        if rawget(ani, "task") ~= nil then
            local Task = require("system.task")
            Task.Do(ani)
        end
    end
end

function Visual:_render()
    if self.visible == false then
        return
    end

    if self.state ~= "playing" then
        return
    end

    local ani = self.current_ani

    if ani and ani.__alive == true and ani.visible ~= false then
        if ani.render then
            ani:render()
        end
    end
end

function Visual.New(class, master, ...)
    local manager = require("manager.visual_manager")
    return manager.spawn(class, master, ...)
end

function Visual.Del(visual)
    local manager = require("manager.visual_manager")
    return manager.delete(visual)
end

function Visual.IsValid(visual)
    local manager = require("manager.visual_manager")
    return manager.is_valid(visual)
end

function Visual.Count()
    local manager = require("manager.visual_manager")
    return manager.count()
end

return Visual