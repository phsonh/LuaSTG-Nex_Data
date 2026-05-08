local M = {}

local function default_color()
    if Color then
        return Color(255, 255, 255, 255)
    end
    if lstg.Color then
        return lstg.Color(255, 255, 255, 255)
    end
    return nil
end

function M.RenderEx(img, x, y, z, rot, hscale, vscale, blend, color)
    assert(lstg.RenderEx, "lstg.RenderEx is nil")
    return lstg.RenderEx(
        img,
        x or 0,
        y or 0,
        z or 0.5,
        rot or 0,
        hscale or 1,
        vscale or hscale or 1,
        blend or "mul+alpha",
        color or default_color()
    )
end

function M.DrawSprite(img, x, y, z, rot, hscale, vscale, blend, color)
    return M.RenderEx(img, x, y, z, rot, hscale, vscale, blend, color)
end

return M