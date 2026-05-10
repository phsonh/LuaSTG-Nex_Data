local Layer = require("constants.layer")
local StateMachine = require("system.state_machine")
local Task = require("system.task")

local unpack = table.unpack or unpack

local Visual = {}
Visual.__index = Visual
Visual.__is_visual_base = true

Visual.Layer = Layer

local visual_manager_cache = nil

local function get_visual_manager()
    if visual_manager_cache == nil then
        visual_manager_cache = require("manager.visual_manager")
    end

    return visual_manager_cache
end

local function install_state_machine(self)
    local fsm = StateMachine.New(self)

    fsm:add("empty", {
        enter = function(owner)
            owner.state = "empty"
        end,

        update = function(owner)
            if owner:_consumePlayRequest() then
                owner:_updateCurrentAni()
            end
        end,
    })

    fsm:add("playing", {
        enter = function(owner)
            owner.state = "playing"
        end,

        update = function(owner)
            owner:_consumePlayRequest()
            owner:_updateCurrentAni()
        end,

        render = function(owner)
            owner:_renderCurrentAni()
        end,
    })

    fsm:add("dead", {
        enter = function(owner)
            owner.state = "dead"
        end,
    })

    self.fsm = fsm
    fsm:force("empty")
end

function Visual:init(master)
    self.master = master

    self.ani_defs = {}

    self.current_name = nil
    self.current_ani = nil

    self.next_name = nil

    self.visible = true
    self.layer = 0

    self.state = "empty"

    install_state_machine(self)
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

function Visual:getState()
    if self.fsm then
        return self.fsm:getName()
    end

    return self.state
end

function Visual:getStateMachine()
    return self.fsm
end

function Visual:play(name)
    assert(self.ani_defs[name] ~= nil, "Visual:play(name): unknown ani '" .. tostring(name) .. "'")

    -- play() 不立刻销毁 / 创建 ani。
    -- 只登记切换请求，在 Visual:_update() 的状态机边界统一处理。
    self.next_name = name

    if self.state ~= "dead" then
        self.state = "switching"
    end

    return self
end

function Visual:switch(name)
    -- 立即切换版本。调试、过场、UI 有时会需要。
    assert(self.ani_defs[name] ~= nil, "Visual:switch(name): unknown ani '" .. tostring(name) .. "'")

    self.next_name = name
    self:_consumePlayRequest()

    return self
end

function Visual:_destroyCurrentAni()
    local ani = self.current_ani

    if ani == nil then
        self.current_name = nil
        self.current_ani = nil
        return
    end

    get_visual_manager().delete_ani(ani)

    self.current_name = nil
    self.current_ani = nil
end

function Visual:_createAni(name)
    local def = self.ani_defs[name]
    assert(def ~= nil, "Visual:_createAni(name): unknown ani '" .. tostring(name) .. "'")

    local ani = get_visual_manager().spawn_ani(
        def.class,
        self.master,
        self,
        unpack(def.args)
    )

    self.current_name = name
    self.current_ani = ani

    return ani
end

function Visual:_consumePlayRequest()
    local name = self.next_name

    if name == nil then
        return false
    end

    self.next_name = nil

    self:_destroyCurrentAni()
    self:_createAni(name)

    self.state = "playing"

    if self.fsm then
        self.fsm:force("playing")
    end

    return true
end

function Visual:_updateCurrentAni()
    if self.state ~= "playing" then
        return
    end

    local ani = self.current_ani

    if ani == nil or ani.__alive ~= true then
        return
    end

    ani.timer = (ani.timer or 0) + 1

    local class = rawget(ani, "__class")

    if class == nil then
        if ani.frame then
            ani:frame()
        end
    elseif class.__has_frame then
        ani:frame()
    end

    if rawget(ani, "task") ~= nil then
        Task.Do(ani)
    end
end

function Visual:_renderCurrentAni()
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

function Visual:isValid()
    return Visual.IsValid(self)
end

function Visual:delete()
    Visual.Del(self)
end

function Visual:del()
    self.next_name = nil

    if self.fsm then
        self.fsm:force("dead")
    else
        self.state = "dead"
    end

    self:_destroyCurrentAni()

    self.ani_defs = {}
end

function Visual:_update()
    if self.fsm then
        self.fsm:update()
        return
    end

    self:_consumePlayRequest()
    self:_updateCurrentAni()
end

function Visual:_render()
    if self.fsm then
        self.fsm:render()
        return
    end

    self:_renderCurrentAni()
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