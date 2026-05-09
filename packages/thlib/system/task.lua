local M = {}

M.stack = {}
M.co = {}

local function to_integer(value, default)
    value = tonumber(value)

    if value == nil then
        return default
    end

    if value >= 0 then
        return math.floor(value)
    else
        return math.ceil(value)
    end
end

local function traceback(co, err)
    return tostring(err)
        .. "\n========== coroutine traceback ==========\n"
        .. debug.traceback(co)
        .. "\n========== C traceback =========="
end

function M.New(target, f)
    assert(target ~= nil, "Task.New(target, f): target is nil")
    assert(type(f) == "function", "Task.New(target, f): f must be function")

    if target.task == nil then
        target.task = {}
    end

    local co = coroutine.create(f)
    table.insert(target.task, co)

    return co
end

function M.Do(target)
    if target == nil then
        return
    end

    local list = target.task

    if list == nil then
        return
    end

    local write_index = 1

    for read_index = 1, #list do
        local co = list[read_index]

        if co and coroutine.status(co) ~= "dead" then
            M.stack[#M.stack + 1] = target
            M.co[#M.co + 1] = co

            local ok, err = coroutine.resume(co)

            M.stack[#M.stack] = nil
            M.co[#M.co] = nil

            if not ok then
                error(traceback(co, err), 2)
            end
        end

        if target.task ~= list then
            return
        end

        if co and coroutine.status(co) ~= "dead" then
            list[write_index] = co
            write_index = write_index + 1
        end
    end

    for i = write_index, #list do
        list[i] = nil
    end

    if #list == 0 then
        target.task = nil
    end
end

function M.Clear(target, keep_self)
    if target == nil or target.task == nil then
        return
    end

    if keep_self then
        local current = M.co[#M.co]
        local keep = false

        if current then
            for i = 1, #target.task do
                if target.task[i] == current then
                    keep = true
                    break
                end
            end
        end

        target.task = nil

        if keep then
            target.task = { current }
        end

        return
    end

    target.task = nil
end

function M.Wait(t)
    t = to_integer(t, 1)

    if t < 1 then
        t = 1
    end

    for _ = 1, t do
        coroutine.yield()
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

        coroutine.yield()
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