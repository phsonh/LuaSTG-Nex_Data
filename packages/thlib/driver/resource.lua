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

M.Image = setmetatable({}, {
    __index = function(_, key)
        local image = require_namespace("Image")
        local value = image[key]

        assert(
            value ~= nil,
            "Resource.Image." .. tostring(key) .. " is nil"
        )

        return value
    end,
})

M.Audio = setmetatable({}, {
    __index = function(_, key)
        local audio = require_namespace("Audio")
        local value = audio[key]

        assert(
            value ~= nil,
            "Resource.Audio." .. tostring(key) .. " is nil"
        )

        return value
    end,
})

M.File = setmetatable({}, {
    __index = function(_, key)
        local file = require_namespace("File")
        local value = file[key]

        assert(
            value ~= nil,
            "Resource.File." .. tostring(key) .. " is nil"
        )

        return value
    end,
})

M.Effect = setmetatable({}, {
    __index = function(_, key)
        local effect = require_namespace("Effect")
        local value = effect[key]

        assert(
            value ~= nil,
            "Resource.Effect." .. tostring(key) .. " is nil"
        )

        return value
    end,
})

M.Font = setmetatable({}, {
    __index = function(_, key)
        local font = require_namespace("Font")
        local value = font[key]

        assert(
            value ~= nil,
            "Resource.Font." .. tostring(key) .. " is nil"
        )

        return value
    end,
})

function M.Raw()
    return require_resource()
end

return M