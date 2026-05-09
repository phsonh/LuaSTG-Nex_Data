local Renderer = require("native.renderer")

local M = {}

function M.Sprite(img, x, y, rot, scale_x, scale_y, blend, a, r, g, b, z)
    assert(img ~= nil, "Render.Sprite(img, ...): img is nil")

    return Renderer.Sprite(
        img,
        x or 0,
        y or 0,
        rot or 0,
        scale_x or 1,
        scale_y or scale_x or 1,
        blend or "",
        a or 255,
        r or 255,
        g or 255,
        b or 255,
        z or 0.5
    )
end

return M