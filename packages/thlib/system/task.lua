local M = {}

M.stack = {}
M.co = {}

local coroutine_create = coroutine.create
local coroutine_resume = coroutine.resume
local coroutine_status = coroutine.status
local coroutine_yield = coroutine.yield

local math_floor = math.floor
local math_ceil = math.ceil
local debug_traceback = debug.traceback

local function to_integer(value, default)
    value = tonumber(value)

    if value == nil then
        return default
    end

    if value >= 0 then
        return math_floor(value)
    else
        return math_ceil(value)
    end
end

local function set_has_task(target, value)
    if target ~= nil then
        rawset(target, "__has_task", value and true or false)
    end
end

local function traceback(co, err)
    return tostring(err)
        .. "\n========== coroutine traceback ==========\n"
        .. debug_traceback(co)
        .. "\n========== C traceback =========="
end

function M.New(target, f)
    assert(target ~= nil, "Task.New(target, f): target is nil")
    assert(type(f) == "function", "Task.New(target, f): f must be function")

    local list = rawget(target, "task")

    if list == nil then
        list = {}
        rawset(target, "task", list)
    end

    local co = coroutine_create(f)

    list[#list + 1] = co

    set_has_task(target, true)

    return co
end

function M.Do(target)
    if target == nil then
        return
    end

    local list = rawget(target, "task")

    if list == nil then
        set_has_task(target, false)
        return
    end

    local write_index = 1
    local read_count = #list

    for read_index = 1, read_count do
        local co = list[read_index]
        local keep = false

        if co and coroutine_status(co) ~= "dead" then
            M.stack[#M.stack + 1] = target
            M.co[#M.co + 1] = co

            local ok, err = coroutine_resume(co)

            M.stack[#M.stack] = nil
            M.co[#M.co] = nil

            if not ok then
                error(traceback(co, err), 2)
            end

            if rawget(target, "task") ~= list then
                local new_list = rawget(target, "task")
                set_has_task(target, new_list ~= nil and #new_list > 0)
                return
            end

            keep = coroutine_status(co) ~= "dead"
        end

        if keep then
            list[write_index] = co
            write_index = write_index + 1
        end
    end

    for i = write_index, read_count do
        list[i] = nil
    end

    if write_index == 1 then
        rawset(target, "task", nil)
        set_has_task(target, false)
    else
        set_has_task(target, true)
    end
end

function M.Clear(target, keep_self)
    if target == nil then
        return
    end

    local list = rawget(target, "task")

    if list == nil then
        set_has_task(target, false)
        return
    end

    if keep_self then
        local current = M.co[#M.co]
        local keep = false

        if current then
            for i = 1, #list do
                if list[i] == current then
                    keep = true
                    break
                end
            end
        end

        rawset(target, "task", nil)
        set_has_task(target, false)

        if keep then
            rawset(target, "task", { current })
            set_has_task(target, true)
        end

        return
    end

    rawset(target, "task", nil)
    set_has_task(target, false)
end

function M.Wait(t)
    t = to_integer(t, 1)

    if t < 1 then
        t = 1
    end

    for _ = 1, t do
        coroutine_yield()
    end
end

function M.W(t)
    return M.Wait(t)
end

function M.Until(t)
    t = to_integer(t, 0)

    while true do
        local self = M.GetSelf()

        if self == nil then
            return
        end

        if (self.timer or 0) >= t then
            return
        end

        coroutine_yield()
    end
end

function M.GetSelf()
    local current = M.stack[#M.stack]

    if current == nil then
        return nil
    end

    if current.taskself ~= nil then
        return current.taskself
    end

    return current
end

function M.IsRunning()
    return M.co[#M.co] ~= nil
end

function M.Current()
    return M.co[#M.co]
end

return M