local Renderer = require("native.renderer")

local M = {}

local sprite_func = nil

local function get_sprite()
    local f = sprite_func

    if f ~= nil then
        return f
    end

    f = Renderer.GetSprite()
    sprite_func = f

    return f
end

function M.Sprite(img, x, y, rot, scale_x, scale_y, blend, a, r, g, b, z)
    assert(img ~= nil, "Render.Sprite(img, ...): img is nil")

    local sx = scale_x

    if sx == nil then
        sx = 1
    end

    local sy = scale_y

    if sy == nil then
        sy = sx
    end

    return get_sprite()(
        img,
        x or 0,
        y or 0,
        rot or 0,
        sx,
        sy,
        blend or "",
        a or 255,
        r or 255,
        g or 255,
        b or 255,
        z or 0.5
    )
end

return M