local Scene = require("runtime.scene")

local M = {}

local unpack = table.unpack or unpack

local registry = {}
local current_scene = nil
local current_name = nil

local next_name = nil
local next_args = nil

local exit_signal = false
local clear_world_on_switch = true

local function pack_args(...)
    return {
        n = select("#", ...),
        ...
    }
end

local function unpack_args(args)
    if args == nil then
        return
    end

    return unpack(args, 1, args.n or #args)
end

local function is_scene_class(class)
    local cur = class

    while cur do
        if cur == Scene or rawget(cur, "__is_scene_base") then
            return true
        end

        cur = rawget(cur, "__base")
    end

    return false
end

local function make_instance(name, class, ...)
    local self = setmetatable({
        __scene_name = name,
        timer = 0,
    }, class)

    if self.init then
        self:init(...)
    end

    return self
end

local function clear_world()
    local unit_manager = require("manager.unit_manager")
    local visual_manager = require("manager.visual_manager")

    -- 先清 Unit，让 Unit:del() 有机会主动删除自己的 Visual。
    -- 然后再清 Visual，兜底清掉无主 Visual。
    unit_manager.clear()
    visual_manager.clear()
end

local function apply_next_scene()
    if next_name == nil then
        return
    end

    local name = next_name
    local args = next_args

    next_name = nil
    next_args = nil

    local class = registry[name]
    assert(class ~= nil, "SceneManager: unknown scene '" .. tostring(name) .. "'")

    if current_scene and current_scene.onDestroy then
        current_scene:onDestroy()
    end

    if clear_world_on_switch then
        clear_world()
    end

    current_name = name
    current_scene = make_instance(name, class, unpack_args(args))

    if current_scene.onCreate then
        current_scene:onCreate(unpack_args(args))
    end
end

function M.init()
    registry = {
        ["__default__"] = Scene,
    }

    current_name = "__default__"
    current_scene = make_instance("__default__", Scene)

    next_name = nil
    next_args = nil

    exit_signal = false
    clear_world_on_switch = true

    if current_scene.onCreate then
        current_scene:onCreate()
    end
end

function M.shutdown()
    if current_scene and current_scene.onDestroy then
        current_scene:onDestroy()
    end

    current_scene = nil
    current_name = nil
    next_name = nil
    next_args = nil
    exit_signal = false
end

function M.register(name, class)
    assert(type(name) == "string", "SceneManager.register(name, class): name must be string")
    assert(name ~= "", "SceneManager.register(name, class): name must not be empty")
    assert(type(class) == "table", "SceneManager.register(name, class): class must be table")
    assert(is_scene_class(class), "SceneManager.register(name, class): class must inherit from Scene")

    registry[name] = class

    return class
end

M.add = M.register

function M.goto(name, ...)
    assert(type(name) == "string", "SceneManager.goto(name, ...): name must be string")
    assert(registry[name] ~= nil, "SceneManager.goto(name, ...): unknown scene '" .. tostring(name) .. "'")

    next_name = name
    next_args = pack_args(...)

    return M
end

M.setNext = M.goto
M.switch = M.goto

function M.update()
    apply_next_scene()

    if current_scene == nil then
        return exit_signal
    end

    current_scene.timer = (current_scene.timer or 0) + 1

    if current_scene.onUpdate then
        current_scene:onUpdate()
    end

    return exit_signal
end

function M.render()
    if current_scene and current_scene.onRender then
        current_scene:onRender()
    end
end

function M.current()
    return current_scene
end

function M.getCurrent()
    return current_scene
end

function M.getName()
    return current_name
end

function M.setExitSignal(value)
    exit_signal = not not value
end

function M.getExitSignal()
    return exit_signal
end

function M.exit()
    exit_signal = true
end

function M.setClearWorldOnSwitch(value)
    clear_world_on_switch = not not value
end

function M.getClearWorldOnSwitch()
    return clear_world_on_switch
end

function M.on_focus_lost()
    if current_scene and current_scene.onDeactivated then
        current_scene:onDeactivated()
    end
end

function M.on_focus_gain()
    if current_scene and current_scene.onActivated then
        current_scene:onActivated()
    end
end

M.onDeactivated = M.on_focus_lost
M.onActivated = M.on_focus_gain

return M