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
        -- world 坐标：
        -- 屏幕中心是 (0, 0)
        -- 可见范围是 x=-320..320, y=-240..240
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
        -- ui 坐标：
        -- 左下角是 (0, 0)
        -- 右上角是 (640, 480)
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
    assert(lstg.Render, "lstg.Render is nil")

    -- v0 暂时只支持基础 sprite 渲染。
    -- blend / color 之后要接新的 C++ Render.SpriteEx。
    -- 这里不要静默假装支持，否则后面很难排查。
    if blend ~= nil and blend ~= "" then
        error("Render.Sprite: blend is not supported yet in Render v0", 2)
    end

    if a ~= nil and a ~= 255 then
        error("Render.Sprite: alpha/color is not supported yet in Render v0", 2)
    end

    if r ~= nil and r ~= 255 then
        error("Render.Sprite: alpha/color is not supported yet in Render v0", 2)
    end

    if g ~= nil and g ~= 255 then
        error("Render.Sprite: alpha/color is not supported yet in Render v0", 2)
    end

    if b ~= nil and b ~= 255 then
        error("Render.Sprite: alpha/color is not supported yet in Render v0", 2)
    end

    return lstg.Render(
        img,
        x or 0,
        y or 0,
        rot or 0,
        scale_x or 1,
        scale_y or scale_x or 1,
        z or 0.5
    )
end

return M