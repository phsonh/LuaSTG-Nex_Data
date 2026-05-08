local M = {}

local function require_resource()
    assert(lstg.Resource, "lstg.Resource is nil; C++ Resource API is not registered")
    return lstg.Resource
end

setmetatable(M, {
    __index = function(_, key)
        return require_resource()[key]
    end,
})

function M.Raw()
    return require_resource()
end

return M
