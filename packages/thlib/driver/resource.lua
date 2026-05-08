local M = {}

function M.LoadTexture(name, path, mipmap)
    assert(lstg.LoadTexture, "lstg.LoadTexture is nil")
    return lstg.LoadTexture(name, path, mipmap or false)
end

function M.LoadImage(name, texture, x, y, w, h, a, b, rect)
    assert(lstg.LoadImage, "lstg.LoadImage is nil")
    return lstg.LoadImage(name, texture, x, y, w, h, a, b, rect)
end

function M.LoadImageFromTexture(name, texture, ...)
    assert(lstg.LoadImageFromTexture, "lstg.LoadImageFromTexture is nil")
    return lstg.LoadImageFromTexture(name, texture, ...)
end

function M.LoadAnimation(...)
    assert(lstg.LoadAnimation, "lstg.LoadAnimation is nil")
    return lstg.LoadAnimation(...)
end

function M.LoadSprite(...)
    assert(lstg.LoadSprite, "lstg.LoadSprite is nil")
    return lstg.LoadSprite(...)
end

function M.RemoveResource(pool, type_name, name)
    if lstg.RemoveResource then
        return lstg.RemoveResource(pool, type_name, name)
    end
end

return M