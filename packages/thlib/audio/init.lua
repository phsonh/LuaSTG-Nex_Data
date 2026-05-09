local Resource = require("resource")

local M = {}

function M.LoadSound(name, path)
    return Resource.Audio.LoadSound(name, path)
end

function M.LoadMusic(name, path, ...)
    return Resource.Audio.LoadMusic(name, path, ...)
end

function M.PlaySound(name, ...)
    return Resource.Audio.PlaySound(name, ...)
end

function M.PlayMusic(name, ...)
    return Resource.Audio.PlayMusic(name, ...)
end

function M.StopMusic(...)
    if Resource.Audio.StopMusic then
        return Resource.Audio.StopMusic(...)
    end
end

function M.Raw()
    return Resource.Audio
end

return M