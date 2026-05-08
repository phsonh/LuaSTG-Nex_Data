local M = {}

function M.Class(base)
    local cls = {}
    cls.__index = cls
    cls.__base = base

    if base then
        setmetatable(cls, {
            __index = base,
            __call = function(c, ...)
                return New(c, ...)
            end,
        })
    else
        setmetatable(cls, {
            __call = function(c, ...)
                return New(c, ...)
            end,
        })
    end

    return cls
end

return M
