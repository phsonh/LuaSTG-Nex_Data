local M = {}

local sin = math.sin
local pi = math.pi
local pi_2 = math.pi * 0.5

local lerp_table = {
    [0] = function(a, b, i)
        return a + (b - a) * i
    end,

    [1] = function(a, b, i)
        return a + (b - a) * i ^ 2
    end,

    [2] = function(a, b, i)
        return a + (b - a) * i ^ 3
    end,

    [3] = function(a, b, i)
        return a + (b - a) * i ^ 4
    end,

    [4] = function(a, b, i)
        return a + (b - a) * (1 - (i - 1) ^ 2)
    end,

    [5] = function(a, b, i)
        return a + (b - a) * (1 - (i - 1) ^ 3)
    end,

    [6] = function(a, b, i)
        return a + (b - a) * (1 - (i - 1) ^ 4)
    end,

    [7] = function(a, b, i)
        return a + b * i
    end,

    [8] = function(a, b, i)
        return a + (b - a) * (3 * i ^ 2 - 2 * i ^ 3)
    end,

    [9] = function(a, b, i)
        if i <= 0.5 then
            return a + (b - a) * 2 * i ^ 2
        else
            local t = i - 1
            return a + (b - a) * (-2 * t ^ 2 + 1)
        end
    end,

    [10] = function(a, b, i)
        if i <= 0.5 then
            return a + (b - a) * 2 * i ^ 3
        else
            local t = i - 1
            return a + (b - a) * (-2 * t ^ 3 + 1)
        end
    end,

    [11] = function(a, b, i)
        if i <= 0.5 then
            return a + (b - a) * 2 * i ^ 4
        else
            local t = i - 1
            return a + (b - a) * (-2 * t ^ 4 + 1)
        end
    end,

    [12] = function(a, b, i)
        local t = i - 0.5

        if i <= 0.5 then
            return a + (b - a) * (-2 * t ^ 2 + 0.5)
        else
            return a + (b - a) * (2 * t ^ 2 + 0.5)
        end
    end,

    [13] = function(a, b, i)
        local t = i - 0.5

        if i <= 0.5 then
            return a + (b - a) * (-2 * t ^ 3 + 0.5)
        else
            return a + (b - a) * (2 * t ^ 3 + 0.5)
        end
    end,

    [14] = function(a, b, i)
        local t = i - 0.5

        if i <= 0.5 then
            return a + (b - a) * (-2 * t ^ 4 + 0.5)
        else
            return a + (b - a) * (2 * t ^ 4 + 0.5)
        end
    end,

    [15] = function(a, b, i)
        return a + (b - a) * (i == 1 and 1 or 0)
    end,

    [16] = function(a, b, i)
        return a + (b - a)
    end,

    [17] = function(a, b, i)
        return a + b * i ^ 2
    end,

    [18] = function(a, b, i)
        return a + (b - a) * sin(i * pi_2)
    end,

    [19] = function(a, b, i)
        return a + (b - a) * (1 - sin(i * pi_2))
    end,

    [20] = function(a, b, i)
        if i * 2 >= 1 then
            return a + (b - a) * ((1 - sin((1 - i) * pi)) * 0.5 + 0.5)
        else
            return a + (b - a) * (sin(i * pi) * 0.5)
        end
    end,

    [21] = function(a, b, i)
        if i * 2 >= 1 then
            return a + (b - a) * (sin((i - 0.5) * pi) * 0.5 + 0.5)
        else
            return a + (b - a) * ((1 - sin(i * pi)) * 0.5)
        end
    end,

    [22] = function(a, b, i)
        local t = i - 0.25
        return a + (b - a) * ((t ^ 2 / 0.5625) - 0.11111111) / 0.8888889
    end,

    [23] = function(a, b, i)
        local t = i - 0.3
        return a + (b - a) * ((t ^ 2 / 0.49) - 0.18367349) / 0.8163265
    end,

    [24] = function(a, b, i)
        local t = i - 0.35
        return a + (b - a) * ((t ^ 2 / 0.4225) - 0.28994083) / 0.71005917
    end,

    [25] = function(a, b, i)
        local t = i - 0.38
        return a + (b - a) * ((t ^ 2 / 0.3844) - 0.37565035) / 0.62434965
    end,

    [26] = function(a, b, i)
        local t = i - 0.4
        return a + (b - a) * ((t ^ 2 / 0.36) - 0.44444445) / 0.55555558
    end,

    [27] = function(a, b, i)
        local t = 0.75 - i
        return a + (b - a) * (1 - ((t * t / 0.5625) - 0.11111111) / 0.8888889)
    end,

    [28] = function(a, b, i)
        local t = 0.7 - i
        return a + (b - a) * (1 - ((t * t / 0.49) - 0.18367349) / 0.8163265)
    end,

    [29] = function(a, b, i)
        local t = 0.65 - i
        return a + (b - a) * (1 - ((t * t / 0.4225) - 0.28994083) / 0.71005917)
    end,

    [30] = function(a, b, i)
        local t = 0.62 - i
        return a + (b - a) * (1 - ((t * t / 0.3844) - 0.37565035) / 0.62434965)
    end,

    [31] = function(a, b, i)
        local t = 0.6 - i
        return a + (b - a) * (1 - ((t * t / 0.36) - 0.44444445) / 0.55555558)
    end,
}

M.Table = lerp_table

function M.Lerp(a, b, i, mode)
    mode = mode or 0
    i = i or 0

    local f = lerp_table[mode] or lerp_table[0]
    return f(a, b, i)
end

function M.Factor(mode, i)
    return M.Lerp(0, 1, i, mode)
end

return M