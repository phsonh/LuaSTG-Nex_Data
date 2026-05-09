local M = {}

function M.Factor(mode, t)
    t = tonumber(t) or 0

    if t < 0 then
        t = 0
    elseif t > 1 then
        t = 1
    end

    mode = tonumber(mode) or 0

    if mode == 0 then
        return t
    elseif mode == 1 then
        return t * t
    elseif mode == 4 then
        local u = 1 - t
        return 1 - u * u
    elseif mode == 8 then
        return 3 * t * t - 2 * t * t * t
    end

    return t
end

function M.Lerp(a, b, t, mode)
    local f = M.Factor(mode, t)
    return a + (b - a) * f
end

return M