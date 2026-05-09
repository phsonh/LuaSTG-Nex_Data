local Unit = {}
Unit.__index = Unit
Unit.__is_unit_base = true

local atan2 = math.atan2 or function(y, x)
    return math.atan(y, x)
end

function Unit:init()
end

function Unit:frame()
end

function Unit:after_frame()
end

function Unit:del()
end

function Unit:isValid()
    return Unit.IsValid(self)
end

function Unit:delete()
    Unit.Del(self)
end

function Unit.New(class, ...)
    local manager = require("manager.unit_manager")
    return manager.spawn(class, ...)
end

function Unit.Del(unit)
    local manager = require("manager.unit_manager")
    return manager.delete(unit)
end

function Unit.Kill(unit)
    return Unit.Del(unit)
end

function Unit.IsValid(unit)
    local manager = require("manager.unit_manager")
    return manager.is_valid(unit)
end

function Unit.Count()
    local manager = require("manager.unit_manager")
    return manager.count()
end

function Unit.SetV(obj, v, angle, update_rot)
    v = v or 0
    angle = angle or 0

    local r = math.rad(angle)

    obj.vx = v * math.cos(r)
    obj.vy = v * math.sin(r)

    if update_rot ~= false then
        obj.rot = angle
    end
end

function Unit.SetA(obj, a, angle)
    a = a or 0
    angle = angle or 0

    local r = math.rad(angle)

    obj.ax = a * math.cos(r)
    obj.ay = a * math.sin(r)
end

function Unit.Dist(a, b)
    local dx = (a.x or 0) - (b.x or 0)
    local dy = (a.y or 0) - (b.y or 0)

    return math.sqrt(dx * dx + dy * dy)
end

function Unit.Angle(a, b)
    return math.deg(atan2((b.y or 0) - (a.y or 0), (b.x or 0) - (a.x or 0)))
end

return Unit