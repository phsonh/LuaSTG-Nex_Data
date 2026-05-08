local Visual = require("class.visual")
local Chip = require("class.chip")

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

local function is_chip_class(class)
    local cur = class

    while cur do
        if cur == Chip or rawget(cur, "__is_chip_base") then
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

    if IsValid then
        return IsValid(master)
    end

    if master.isValid then
        return master:isValid()
    end

    return true
end

function M.spawn(class, master, ...)
    assert(type(class) == "table", "NewVisual(class, master, ...): class must be a class table")
    assert(is_visual_class(class), "NewVisual(class, master, ...): class must inherit from Visual")

    next_visual_order = next_visual_order + 1

    local self = setmetatable({
        __alive = true,

        master = master,
        auto_delete_with_master = true,

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

function M.spawn_chip(class, master, visual, ...)
    assert(type(class) == "table", "spawn_chip(class, master, visual, ...): class must be a class table")
    assert(is_chip_class(class), "spawn_chip(class, master, visual, ...): class must inherit from Chip")

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

function M.delete_chip(chip)
    if chip == nil then
        return
    end

    if chip.__alive ~= true then
        return
    end

    chip.__alive = false

    if chip.del then
        chip:del()
    end
end

function M.is_chip_valid(chip)
    return chip ~= nil and chip.__alive == true
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
    table.sort(visuals, function(a, b)
        local la = a.layer or 0
        local lb = b.layer or 0

        if la ~= lb then
            return la < lb
        end

        return (a.order or 0) < (b.order or 0)
    end)

    for i = 1, #visuals do
        local visual = visuals[i]

        if M.is_valid(visual) and visual.visible ~= false then
            if visual._render then
                visual:_render()
            end
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