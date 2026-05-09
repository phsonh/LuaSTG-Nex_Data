local M = {}

local function require_resource()
    assert(lstg.Resource, "lstg.Resource is nil; C++ Resource API is not registered")
    return lstg.Resource
end

local function require_namespace(name)
    local resource = require_resource()
    local namespace = resource[name]

    assert(
        namespace,
        "lstg.Resource." .. tostring(name) .. " is nil; C++ Resource." .. tostring(name) .. " API is not registered"
    )

    return namespace
end

local function namespace_proxy(name)
    return setmetatable({}, {
        __index = function(_, key)
            local namespace = require_namespace(name)
            local value = namespace[key]

            assert(
                value ~= nil,
                "Resource." .. tostring(name) .. "." .. tostring(key) .. " is nil"
            )

            return value
        end,
    })
end

M.Image = namespace_proxy("Image")
M.Audio = namespace_proxy("Audio")
M.File = namespace_proxy("File")
M.Effect = namespace_proxy("Effect")
M.Font = namespace_proxy("Font")

function M.Include(path)
    assert(type(path) == "string", "Resource.Include(path): path must be a string")
    return lstg.DoFile(path)
end

function M.Raw()
    return require_resource()
end

return M