local M = {}

function M.set_v(obj, v, angle, update_rot)
    local r = math.rad(angle)
    obj.vx = v * math.cos(r)
    obj.vy = v * math.sin(r)
    if update_rot then
        obj.rot = angle
    end
end

function M.set_a(obj, a, angle)
    local r = math.rad(angle)
    obj.ax = a * math.cos(r)
    obj.ay = a * math.sin(r)
end

function M.dist(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

function M.angle(a, b)
    return math.deg(math.atan2(b.y - a.y, b.x - a.x))
end

return M
