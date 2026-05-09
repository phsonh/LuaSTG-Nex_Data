local M = {}

function M.Class(base)
    local cls = {}
    cls.__index = cls
    cls.__base = base

    if base then
        setmetatable(cls, {
            __index = base,
        })
    end

    return cls
end

return M