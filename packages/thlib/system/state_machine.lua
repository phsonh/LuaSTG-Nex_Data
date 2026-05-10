local unpack = table.unpack or unpack

local M = {}

local StateMachine = {}
StateMachine.__index = StateMachine

local function pack_args(...)
    return {
        n = select("#", ...),
        ...
    }
end

local function unpack_args(args)
    if args == nil then
        return
    end

    return unpack(args, 1, args.n or #args)
end

function M.New(owner)
    return setmetatable({
        owner = owner,

        states = {},

        current_name = nil,
        current = nil,

        next_name = nil,
        next_args = nil,

        timer = 0,
    }, StateMachine)
end

function StateMachine:add(name, state)
    assert(type(name) == "string", "StateMachine:add(name, state): name must be string")
    assert(type(state) == "table", "StateMachine:add(name, state): state must be table")

    self.states[name] = state

    return self
end

function StateMachine:has(name)
    return self.states[name] ~= nil
end

function StateMachine:getName()
    return self.current_name
end

function StateMachine:getState()
    return self.current
end

function StateMachine:getTimer()
    return self.timer or 0
end

function StateMachine:request(name, ...)
    assert(type(name) == "string", "StateMachine:request(name, ...): name must be string")
    assert(self.states[name] ~= nil, "StateMachine:request(name, ...): unknown state '" .. tostring(name) .. "'")

    self.next_name = name
    self.next_args = pack_args(...)

    return self
end

StateMachine.goto = StateMachine.request

function StateMachine:force(name, ...)
    assert(type(name) == "string", "StateMachine:force(name, ...): name must be string")

    local next_state = self.states[name]
    assert(next_state ~= nil, "StateMachine:force(name, ...): unknown state '" .. tostring(name) .. "'")

    local owner = self.owner
    local prev_name = self.current_name
    local prev_state = self.current

    if prev_state and prev_state.leave then
        prev_state.leave(owner, name, ...)
    end

    self.current_name = name
    self.current = next_state
    self.timer = 0

    self.next_name = nil
    self.next_args = nil

    if next_state.enter then
        next_state.enter(owner, prev_name, ...)
    end

    return self
end

function StateMachine:_applyPending()
    local name = self.next_name

    if name == nil then
        return false
    end

    local args = self.next_args

    self.next_name = nil
    self.next_args = nil

    self:force(name, unpack_args(args))

    return true
end

function StateMachine:update(...)
    self:_applyPending()

    local state = self.current

    if state and state.update then
        state.update(self.owner, ...)
    end

    self.timer = (self.timer or 0) + 1
end

function StateMachine:render(...)
    local state = self.current

    if state and state.render then
        state.render(self.owner, ...)
    end
end

function StateMachine:clear()
    local state = self.current

    if state and state.leave then
        state.leave(self.owner, nil)
    end

    self.current_name = nil
    self.current = nil
    self.next_name = nil
    self.next_args = nil
    self.timer = 0
end

M.StateMachine = StateMachine

return M