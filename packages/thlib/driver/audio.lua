local M = {}

function M.LoadSound(name, path)
    assert(lstg.LoadSound, "lstg.LoadSound is nil")
    return lstg.LoadSound(name, path)
end

function M.LoadMusic(name, path, loop_end, loop_length)
    assert(lstg.LoadMusic, "lstg.LoadMusic is nil")
    return lstg.LoadMusic(name, path, loop_end, loop_length)
end

function M.PlaySound(name, volume, pan)
    assert(lstg.PlaySound, "lstg.PlaySound is nil")
    return lstg.PlaySound(name, volume, pan)
end

function M.PlayMusic(name, ...)
    if lstg.PlayMusic then
        return lstg.PlayMusic(name, ...)
    end
    if _play_music then
        return _play_music(name, ...)
    end
    error("no music play api found")
end

return M