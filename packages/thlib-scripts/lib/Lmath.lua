---=====================================
---luastg math
---=====================================

----------------------------------------
---常量

PI = math.pi
PIx2 = math.pi * 2
PI_2 = math.pi * 0.5
PI_4 = math.pi * 0.25
SQRT2 = math.sqrt(2)
SQRT3 = math.sqrt(3)
SQRT2_2 = math.sqrt(0.5)
GOLD = 360 * (math.sqrt(5) - 1) / 2

----------------------------------------
---数学函数

int = math.floor
abs = math.abs
max = math.max
min = math.min
rnd = math.random
sqrt = math.sqrt

math.mod = math.mod or math.fmod
mod = math.mod

---获得数字的符号(1/-1/0)
function sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

---获得(x,y)向量的模长
function hypot(x, y)
    return sqrt(x * x + y * y)
end

---阶乘，目前用于组合数和贝塞尔曲线
local fac = {}
function Factorial(num)
    if num < 0 then
        error("Can't get factorial of a minus number.")
    end
    if num < 2 then
        return 1
    end
    num = int(num)
    if fac[num] then
        return fac[num]
    end
    local result = 1
    for i = 1, num do
        if fac[i] then
            result = fac[i]
        else
            result = result * i
            fac[i] = result
        end
    end
    return result
end

---组合数，目前用于贝塞尔曲线
function combinNum(ord, sum)
    if sum < 0 or ord < 0 then
        error("Can't get combinatorial of minus numbers.")
    end
    ord = int(ord)
    sum = int(sum)
    return Factorial(sum) / (Factorial(ord) * Factorial(sum - ord))
end

--------------------------------------------------------------------------------
--- 弹幕逻辑随机数发生器，用于支持 replay 系统

local ENABLE_NEW_RNG = false

if ENABLE_NEW_RNG then
    -- 2019 年的新一代 xoshiro256** 随机数发生器
    local random = require("random")
    ran = random.xoshiro512ss()
else
    -- 2006 年的 WELL512 随机数发生器
    ran = lstg.Rand()
end



function lerp_to(unit, struct, lerp_mode, lerp_time, target_value)
    local start_value = unit[struct]
    local target_value = target_value
    local delta = target_value - start_value
    local duration = math.floor(lerp_time)
    local mode = math.floor(lerp_mode)

    if duration <= 0 or mode == 16 then
        unit[struct] = target_value
        return
    end


    local formula
    if mode == 0 then formula = function(x) return x end
    elseif mode == 1 then formula = function(x) return x^2 end
    elseif mode == 2 then formula = function(x) return x^3 end
    elseif mode == 3 then formula = function(x) return x^4 end
    elseif mode == 4 then formula = function(x) return 1-(1-x)^2 end
    elseif mode == 5 then formula = function(x) return 1-(1-x)^3 end
    elseif mode == 6 then formula = function(x) return 1-(1-x)^4 end
    elseif mode == 8 then formula = function(x) return 3*x^2 - 2*x^3 end
    elseif mode >= 9 and mode <= 14 then
        local p = (mode == 9 or mode == 12) and 2 or ((mode == 10 or mode == 13) and 3 or 4)
        local is_out_in = mode >= 12
        formula = function(x)
            local is_first = x < 0.5
            local sx = is_first and (x * 2) or ((x - 0.5) * 2)
            local sr
            if not is_out_in then -- easeInOut
                sr = is_first and (sx^p) or (1 - (1 - sx)^p)
            else -- easeOutIn
                sr = is_first and (1 - (1 - sx)^p) or (sx^p)
            end
            return is_first and (sr / 2) or (0.5 + sr / 2)
        end
    elseif mode == 15 then formula = function(x) return (x < 1) and 0 or 1 end
    elseif mode == 18 then formula = function(x) return math.sin(x * math.pi / 2) end
    elseif mode == 19 then formula = function(x) return 1 - math.cos(x * math.pi / 2) end
    elseif mode == 20 or mode == 21 then
        local is_sin_cos = (mode == 20)
        formula = function(x)
            if x < 0.5 then
                local sx = x * 2
                return ((is_sin_cos) and math.sin(sx * math.pi / 2) or (1 - math.cos(sx * math.pi / 2))) / 2
            else
                local sx = (x - 0.5) * 2
                return 0.5 + ((is_sin_cos) and (1 - math.cos(sx * math.pi / 2)) or math.sin(sx * math.pi / 2)) / 2
            end
        end
    else
        formula = function(x) return x end
        --默认线性
    end


    task.New(unit, function()
        for t = 1, duration do
            task.Wait(1)
            unit[struct] = start_value + delta * formula(t / duration)
        end
        unit[struct] = target_value
    end)
end

--示例:lerp_to(self,"vscale",0,60,3),把自身的vscale缩放在60帧之内以0号插值模式变成3