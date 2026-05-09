local M = {}

local VIEW_WIDTH = 640
local VIEW_HEIGHT = 480
local HALF_VIEW_WIDTH = VIEW_WIDTH / 2
local HALF_VIEW_HEIGHT = VIEW_HEIGHT / 2

local function require_view_api()
    assert(lstg.SetOrtho, "lstg.SetOrtho is nil")
    assert(lstg.SetViewport, "lstg.SetViewport is nil")
    assert(lstg.SetScissorRect, "lstg.SetScissorRect is nil")
end

function M.SetViewMode(mode)
    mode = mode or "world"

    require_view_api()

    if mode == "world" then
        lstg.SetOrtho(
            -HALF_VIEW_WIDTH,
            HALF_VIEW_WIDTH,
            -HALF_VIEW_HEIGHT,
            HALF_VIEW_HEIGHT
        )

        lstg.SetViewport(0, VIEW_WIDTH, 0, VIEW_HEIGHT)
        lstg.SetScissorRect(0, VIEW_WIDTH, 0, VIEW_HEIGHT)

        if lstg.SetFog then
            lstg.SetFog()
        end

        return
    end

    if mode == "ui" then
        lstg.SetOrtho(0, VIEW_WIDTH, 0, VIEW_HEIGHT)
        lstg.SetViewport(0, VIEW_WIDTH, 0, VIEW_HEIGHT)
        lstg.SetScissorRect(0, VIEW_WIDTH, 0, VIEW_HEIGHT)

        if lstg.SetFog then
            lstg.SetFog()
        end

        return
    end

    error("Render.SetViewMode: invalid mode '" .. tostring(mode) .. "'", 2)
end

function M.Sprite(img, x, y, rot, scale_x, scale_y, blend, a, r, g, b, z)
    assert(img ~= nil, "Render.Sprite: img is nil")
    assert(lstg.Renderer and lstg.Renderer.Sprite, "lstg.Renderer.Sprite is nil")

    return lstg.Renderer.Sprite(
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