local M = {}

local sprite_func = nil

local function resolve_sprite()
    local f = sprite_func

    if f ~= nil then
        return f
    end

    assert(lstg.Renderer and lstg.Renderer.Sprite, "lstg.Renderer.Sprite is not registered")

    f = lstg.Renderer.Sprite
    sprite_func = f

    return f
end

function M.GetSprite()
    return resolve_sprite()
end

function M.Sprite(...)
    return resolve_sprite()(...)
end

function M.ResetCache()
    sprite_func = nil
end

return M