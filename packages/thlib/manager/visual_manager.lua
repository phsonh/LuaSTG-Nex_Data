local Visual = require("class.visual")
local Ani = require("class.ani")
local Unit = require("class.unit")
local Task = require("system.task")

local M = {}

local visuals = {}
local next_visual_order = 0

-- layer bucket 渲染缓存。
local layer_buckets = {}
local layer_keys = {}
local layer_seen = {}
local layer_key_count = 0

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

local function lookup_class_member(class, key)
    local cur = class

    while cur do
        local value = rawget(cur, key)

        if value ~= nil then
            return value
        end

        cur = rawget(cur, "__base")
    end

    return nil
end

local function install_ani_flags(class)
    if rawget(class, "__ani_flags_installed") then
        return
    end

    local frame = lookup_class_member(class, "frame")

    if frame == Ani.frame then
        frame = nil
    end

    local render = lookup_class_member(class, "render")

    if render == nil then
        render = Ani.render
    end

    class.__ani_frame_func = frame
    class.__ani_render_func = render

    class.__has_frame = frame ~= nil
    class.__ani_flags_installed = true
end

local function is_valid_master(master)
    if master == nil then
        return true
    end

    -- 性能优先：这里只检查 Lua 层生命标记，不跨 C++ 查 native.alive。
    -- UnitManager 删除 Unit 时会同步设置 __alive=false。
    return Unit.IsAliveFast(master)
end

local function clear_render_buckets()
    for i = 1, layer_key_count do
        local layer = layer_keys[i]
        local bucket = layer_buckets[layer]

        if bucket then
            for j = 1, bucket.n do
                bucket[j] = nil
            end

            bucket.n = 0
        end

        layer_seen[layer] = nil
        layer_keys[i] = nil
    end

    layer_key_count = 0
end

local function push_render_ani(layer, ani)
    local bucket = layer_buckets[layer]

    if bucket == nil then
        bucket = {
            n = 0,
        }

        layer_buckets[layer] = bucket
    end

    if layer_seen[layer] ~= true then
        layer_key_count = layer_key_count + 1
        layer_keys[layer_key_count] = layer
        layer_seen[layer] = true
    end

    local n = bucket.n + 1

    bucket.n = n
    bucket[n] = ani
end

function M.spawn(class, master, ...)
    assert(type(class) == "table", "Visual.New(class, master, ...): class must be a class table")
    assert(is_visual_class(class), "Visual.New(class, master, ...): class must inherit from Visual")

    next_visual_order = next_visual_order + 1

    local self = setmetatable({
        __alive = true,
        __class = class,

        master = master,
        auto_delete_with_master = master ~= nil,

        layer = 0,
        order = next_visual_order,

        visible = true,

        __has_task = false,
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

    Task.Clear(visual)

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

    install_ani_flags(class)

    local self = setmetatable({
        __alive = true,
        __class = class,

        master = master,
        visual = visual,

        timer = 0,

        __frame_func = class.__ani_frame_func,
        __render_func = class.__ani_render_func,

        __has_task = false,
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
    clear_render_buckets()

    for i = 1, #visuals do
        local visual = visuals[i]

        if M.is_valid(visual) and visual.visible ~= false then
            local ani = visual.current_ani

            if ani and ani.__alive == true and ani.visible ~= false then
                local layer = ani.layer

                if layer == nil then
                    layer = visual.layer or 0
                end

                push_render_ani(layer, ani)
            end
        end
    end

    if layer_key_count > 1 then
        table.sort(layer_keys)
    end

    for i = 1, layer_key_count do
        local layer = layer_keys[i]
        local bucket = layer_buckets[layer]

        for j = 1, bucket.n do
            local ani = bucket[j]

            if ani and ani.__alive == true and ani.visible ~= false then
                local render = ani.__render_func

                if render ~= nil then
                    render(ani)
                end
            end
        end
    end

    clear_render_buckets()
end

function M.clear()
    for i = #visuals, 1, -1 do
        local visual = visuals[i]

        if visual and visual.__alive == true then
            M.delete(visual)
        end

        visuals[i] = nil
    end

    clear_render_buckets()

    next_visual_order = 0
end

function M.count()
    return #visuals
end

return M