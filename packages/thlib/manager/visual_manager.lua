local Visual = require("class.visual")
local Ani = require("class.ani")
local Unit = require("class.unit")
local Task = require("system.task")

local M = {}

local visuals = {}
local next_visual_order = 0

-- render_all() 复用这些数组，避免每帧为每个 visual 创建临时 table。
local render_indices = {}
local render_anis = {}
local render_layers = {}
local render_orders = {}

local function render_less(a, b)
    local layer_a = render_layers[a] or 0
    local layer_b = render_layers[b] or 0

    if layer_a ~= layer_b then
        return layer_a < layer_b
    end

    return (render_orders[a] or 0) < (render_orders[b] or 0)
end


local function is_visual_class(class)
    local cur = class

    while cur do
        if cur == Visual or rawget(cur, "__is_visual_base") then
            return true
        end

        cur = rawget(cur, "__base")
    end

    return false
end

local function is_ani_class(class)
    local cur = class

    while cur do
        if cur == Ani or rawget(cur, "__is_ani_base") then
            return true
        end

        cur = rawget(cur, "__base")
    end

    return false
end

local function is_valid_master(master)
    if master == nil then
        return true
    end

    return Unit.IsValid(master)
end

function M.spawn(class, master, ...)
    assert(type(class) == "table", "Visual.New(class, master, ...): class must be a class table")
    assert(is_visual_class(class), "Visual.New(class, master, ...): class must inherit from Visual")

    next_visual_order = next_visual_order + 1

    local self = setmetatable({
        __alive = true,

        master = master,
        auto_delete_with_master = master ~= nil,

        layer = 0,
        order = next_visual_order,

        visible = true,
    }, class)

    visuals[#visuals + 1] = self

    if self.init then
        self:init(master, ...)
    end

    return self
end

function M.delete(visual)
    if visual == nil then
        return
    end

    if visual.__alive ~= true then
        return
    end

    visual.__alive = false

    if visual.del then
        visual:del()
    end
end

function M.is_valid(visual)
    return visual ~= nil and visual.__alive == true
end

function M.spawn_ani(class, master, visual, ...)
    assert(type(class) == "table", "spawn_ani(class, master, visual, ...): class must be a class table")
    assert(is_ani_class(class), "spawn_ani(class, master, visual, ...): class must inherit from Ani")

    local self = setmetatable({
        __alive = true,
        master = master,
        visual = visual,
        timer = 0,
    }, class)

    if self.init then
        self:init(master, visual, ...)
    end

    return self
end

function M.delete_ani(ani)
    if ani == nil then
        return
    end

    if ani.__alive ~= true then
        return
    end

    ani.__alive = false

    Task.Clear(ani)

    if ani.del then
        ani:del()
    end
end

function M.is_ani_valid(ani)
    return ani ~= nil and ani.__alive == true
end

function M.update_all()
    local frame_count = #visuals

    for read_index = 1, frame_count do
        local visual = visuals[read_index]

        if M.is_valid(visual) then
            if visual.auto_delete_with_master and not is_valid_master(visual.master) then
                M.delete(visual)
            end
        end

        if M.is_valid(visual) then
            if visual._update then
                visual:_update()
            end
        end
    end

    -- 和 UnitManager 一样，这里压缩当前 #visuals。
    -- 这样 visual update 过程中新增 visual 时，不会因为旧 visual 删除导致洞数组。
    local total_count = #visuals
    local write_index = 1

    for read_index = 1, total_count do
        local visual = visuals[read_index]

        if M.is_valid(visual) then
            visuals[write_index] = visual
            write_index = write_index + 1
        end
    end

    for i = write_index, total_count do
        visuals[i] = nil
    end
end

function M.render_all()
    local render_count = 0

    for i = 1, #visuals do
        local visual = visuals[i]

        if M.is_valid(visual) and visual.visible ~= false then
            local ani = visual.current_ani

            if ani and ani.__alive == true and ani.visible ~= false then
                render_count = render_count + 1

                render_indices[render_count] = render_count
                render_anis[render_count] = ani
                render_layers[render_count] = ani.layer ~= nil and ani.layer or visual.layer or 0
                render_orders[render_count] = visual.order or 0
            end
        end
    end

    for i = render_count + 1, #render_indices do
        render_indices[i] = nil
    end

    if render_count > 1 then
        table.sort(render_indices, render_less)
    end

    for i = 1, render_count do
        local slot = render_indices[i]
        local ani = render_anis[slot]

        if ani and ani.__alive == true and ani.visible ~= false and ani.render then
            ani:render()
        end
    end

    -- 释放 ani 引用，避免已经删除的 ani 被 render cache 延长生命周期。
    for i = 1, render_count do
        render_anis[i] = nil
        render_layers[i] = nil
        render_orders[i] = nil
    end
end

function M.clear()
    for i = #visuals, 1, -1 do
        local visual = visuals[i]

        if visual and visual.__alive == true then
            M.delete(visual)
        end

        visuals[i] = nil
    end

    next_visual_order = 0
end

function M.count()
    return #visuals
end

return M