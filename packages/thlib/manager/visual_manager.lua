local Visual = require("class.visual")
local Chip = require("class.chip")

local M = {}

local visuals = {}
local next_order = 0
local dirty_sort = false

local function class_inherits(class, base, marker)
    local cur = class
    while cur do
        if cur == base or rawget(cur, marker) then
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
    assert(class_inherits(class, Visual, "__is_visual_base"), "NewVisual(class, master, ...): class must inherit from Visual")

    next_order = next_order + 1

    local self = setmetatable({
        __alive = true,
        master = master,
        auto_delete_with_master = true,
        layer = 0,
        order = next_order,
        visible = true,
    }, class)

    visuals[#visuals + 1] = self
    dirty_sort = true

    if self.init then
        self:init(master, ...)
    end

    return self
end

function M.spawn_chip(class, master, visual, ...)
    assert(type(class) == "table", "NewChip(class, master, visual, ...): class must be a class table")
    assert(class_inherits(class, Chip, "__is_chip_base"), "NewChip(class, master, visual, ...): class must inherit from Chip")

    local self = setmetatable({
        __alive = true,
        master = master,
        visual = visual,
    }, class)

    if self.init then
        self:init(master, visual, ...)
    end

    return self
end

function M.delete(visual)
    if visual and visual.delete then
        visual:delete()
    end
end

function M.delete_chip(chip)
    if chip and chip.delete then
        chip:delete()
    end
end

function M.is_valid(visual)
    return visual ~= nil and visual.__alive == true
end

function M.is_chip_valid(chip)
    return chip ~= nil and chip.__alive == true
end

local function sort_visuals()
    table.sort(visuals, function(a, b)
        local la = a.layer or 0
        local lb = b.layer or 0

        if la ~= lb then
            return la < lb
        end

        return (a.order or 0) < (b.order or 0)
    end)

    dirty_sort = false
end

function M.update_all()
    local write_index = 1

    for read_index = 1, #visuals do
        local v = visuals[read_index]

        if M.is_valid(v) and v.auto_delete_with_master and not is_valid_master(v.master) then
            M.delete(v)
        end

        if M.is_valid(v) then
            if v._update then
                v:_update()
            end

            visuals[write_index] = v
            write_index = write_index + 1
        end
    end

    for i = write_index, #visuals do
        visuals[i] = nil
    end

    dirty_sort = true
end

function M.render_all()
    if dirty_sort then
        sort_visuals()
    end

    for i = 1, #visuals do
        local v = visuals[i]
        if M.is_valid(v) and v.visible ~= false and v._render then
            v:_render()
        end
    end
end

function M.clear()
    for i = #visuals, 1, -1 do
        local v = visuals[i]
        if v and v.delete then
            v:delete()
        end
        visuals[i] = nil
    end

    next_order = 0
    dirty_sort = false
end

function M.count()
    return #visuals
end

return M
