local Visual = require("class.visual")

local M = {}

local visuals = {}
local next_order = 0
local dirty_sort = false

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

    next_order = next_order + 1

    local self = setmetatable({
        __alive = true,

        master = master,
        auto_delete_with_master = true,

        x = 0,
        y = 0,
        z = 0.5,

        layer = 0,
        order = next_order,

        rot = 0,
        hscale = 1,
        vscale = 1,

        img = nil,
        blend = "mul+alpha",
        color = nil,

        visible = true,
        timer = 0,
    }, class)

    visuals[#visuals + 1] = self
    dirty_sort = true

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

local function sort_visuals()
    table.sort(visuals, function(a, b)
        local la = a.layer or 0
        local lb = b.layer or 0

        if la ~= lb then
            return la < lb
        end

        local za = a.z or 0.5
        local zb = b.z or 0.5

        if za ~= zb then
            return za < zb
        end

        return (a.order or 0) < (b.order or 0)
    end)

    dirty_sort = false
end

function M.update_all()
    local write_index = 1

    for read_index = 1, #visuals do
        local v = visuals[read_index]

        if M.is_valid(v) then
            if v.auto_delete_with_master and not is_valid_master(v.master) then
                M.delete(v)
            end
        end

        if M.is_valid(v) then
            v.timer = (v.timer or 0) + 1

            if v.frame then
                v:frame()
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

        if M.is_valid(v) and v.visible ~= false then
            if v.render then
                v:render()
            end
        end
    end
end

function M.clear()
    for i = #visuals, 1, -1 do
        local v = visuals[i]

        if v and v.__alive == true then
            if v.del then
                v:del()
            end

            v.__alive = false
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