local Visual = require("class.visual")
local Ani = require("class.ani")
local Unit = require("class.unit")
local Task = require("system.task")

local M = {}

local visuals = {}
local next_visual_order = 0

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
    local write_index = 1

    for read_index = 1, #visuals do
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

            visuals[write_index] = visual
            write_index = write_index + 1
        end
    end

    for i = write_index, #visuals do
        visuals[i] = nil
    end
end

function M.render_all()
    local render_list = {}

    for i = 1, #visuals do
        local visual = visuals[i]

        if M.is_valid(visual) and visual.visible ~= false then
            local ani = visual.current_ani

            if ani and ani.__alive == true and ani.visible ~= false then
                render_list[#render_list + 1] = {
                    visual = visual,
                    ani = ani,
                    layer = ani.layer ~= nil and ani.layer or visual.layer or 0,
                    order = visual.order or 0,
                }
            end
        end
    end

    table.sort(render_list, function(a, b)
        if a.layer ~= b.layer then
            return a.layer < b.layer
        end

        return a.order < b.order
    end)

    for i = 1, #render_list do
        local ani = render_list[i].ani

        if ani.render then
            ani:render()
        end
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