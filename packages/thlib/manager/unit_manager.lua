local Unit = require("class.unit")
local unit_native = require("native.unit")
local Task = require("system.task")

local M = {}

local units = {}

local native_fields = {
    id = true,
    alive = true,
    timer = true,

    x = true,
    y = true,

    vx = true,
    vy = true,

    ax = true,
    ay = true,

    rot = true,
}

local readonly_native_fields = {
    id = true,
    alive = true,
    timer = true,
}

local function is_unit_class(class)
    local cur = class

    while cur do
        if cur == Unit or rawget(cur, "__is_unit_base") then
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

local function install_unit_proxy(class)
    if rawget(class, "__unit_proxy_installed") then
        return
    end

    local frame = lookup_class_member(class, "frame")
    local after_frame = lookup_class_member(class, "after_frame")

    class.__has_frame = frame ~= nil and frame ~= Unit.frame
    class.__has_after_frame = after_frame ~= nil and after_frame ~= Unit.after_frame

    class.__index = function(obj, key)
        local value = lookup_class_member(class, key)

        if value ~= nil then
            return value
        end

        if native_fields[key] then
            local native = rawget(obj, "native")

            if native then
                return native[key]
            end
        end

        return nil
    end

    class.__newindex = function(obj, key, value)
        if native_fields[key] then
            if readonly_native_fields[key] then
                error("field '" .. tostring(key) .. "' is readonly", 2)
            end

            local native = rawget(obj, "native")

            if native then
                native[key] = value
                return
            end
        end

        rawset(obj, key, value)
    end

    class.__unit_proxy_installed = true
end

function M.spawn(class, ...)
    assert(type(class) == "table", "Unit.New(class, ...): class must be a class table")
    assert(is_unit_class(class), "Unit.New(class, ...): class must inherit from Unit")

    install_unit_proxy(class)

    local native = unit_native.new()

    local self = setmetatable({
        native = native,
        __alive = true,
        __class = class,
    }, class)

    units[#units + 1] = self

    if self.init then
        self:init(...)
    end

    return self
end

function M.delete(unit)
    if unit == nil then
        return
    end

    if unit.__alive ~= true then
        return
    end

    Task.Clear(unit)

    unit.__alive = false

    if unit.del then
        unit:del()
    end

    local native = rawget(unit, "native")

    if native and native.alive == true then
        native:delete()
    end
end

function M.is_valid(unit)
    if unit == nil or unit.__alive ~= true then
        return false
    end

    local native = rawget(unit, "native")

    return native ~= nil and native.alive == true
end

local function is_alive_fast(unit)
    return unit ~= nil and unit.__alive == true
end

function M.update_all()
    -- 依赖上一轮 C++ / native.unit.lua 中加入的 begin_frame。

    if unit_native.begin_frame then
        unit_native.begin_frame()
    end

    local frame_count = #units

    for i = 1, frame_count do
        local unit = units[i]

        if is_alive_fast(unit) then
            local class = rawget(unit, "__class")

            if class and class.__has_frame then
                unit:frame()
            end

            if rawget(unit, "task") ~= nil then
                Task.Do(unit)
            end
        end
    end

    unit_native.update_all()

    for i = 1, frame_count do
        local unit = units[i]

        if is_alive_fast(unit) then
            local class = rawget(unit, "__class")

            if class and class.__has_after_frame then
                unit:after_frame()
            end
        end
    end

    local total_count = #units
    local write_index = 1

    for read_index = 1, total_count do
        local unit = units[read_index]

        if is_alive_fast(unit) then
            units[write_index] = unit
            write_index = write_index + 1
        end
    end

    for i = write_index, total_count do
        units[i] = nil
    end
end

function M.clear()
    for i = #units, 1, -1 do
        local unit = units[i]

        if unit and unit.__alive == true then
            M.delete(unit)
        end

        units[i] = nil
    end

    unit_native.clear()
end

function M.count()
    return #units
end

return M