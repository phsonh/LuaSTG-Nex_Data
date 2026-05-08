local Unit = require("class.unit")
local unit_driver = require("driver.unit")

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
    assert(type(class) == "table", "New(class, ...): class must be a class table")
    assert(is_unit_class(class), "New(class, ...): class must inherit from Unit")

    install_unit_proxy(class)

    local native = unit_driver.new()
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
    if unit and unit.delete then
        unit:delete()
    end
end

function M.is_valid(unit)
    return unit ~= nil
        and unit.__alive == true
        and unit.native ~= nil
        and unit.native:isValid()
end

function M.update_all()
    -- Phase 1 order:
    -- native movement/timer first, Lua behavior second.
    -- This keeps timer and position visible to frame() after native update.
    unit_driver.update_all()

    local write_index = 1
    for read_index = 1, #units do
        local u = units[read_index]
        if M.is_valid(u) then
            if u.frame then
                u:frame()
            end
            units[write_index] = u
            write_index = write_index + 1
        end
    end

    for i = write_index, #units do
        units[i] = nil
    end
end

function M.clear()
    for i = #units, 1, -1 do
        local u = units[i]
        if u and u.delete then
            u:delete()
        end
        units[i] = nil
    end
    unit_driver.clear()
end

function M.count()
    return #units
end

return M
