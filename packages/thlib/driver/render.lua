local M = {}

function M.SetViewMode(mode)
    mode = mode or "world"

    if mode == "world" then
        -- 新 THlib 临时 world 坐标：
        -- 中心是 (0, 0)，屏幕范围是 x=-320..320, y=-240..240
        lstg.SetOrtho(-320, 320, -240, 240)
        lstg.SetViewport(0, 640, 0, 480)
        lstg.SetScissorRect(0, 640, 0, 480)

        if lstg.SetFog then
            lstg.SetFog()
        end

        return
    end

    if mode == "ui" then
        -- UI 坐标：
        -- 左下角是 (0, 0)，右上角是 (640, 480)
        lstg.SetOrtho(0, 640, 0, 480)
        lstg.SetViewport(0, 640, 0, 480)
        lstg.SetScissorRect(0, 640, 0, 480)

        if lstg.SetFog then
            lstg.SetFog()
        end

        return
    end

    error("Render.SetViewMode: invalid mode '" .. tostring(mode) .. "'")
end

function M.Sprite(img, x, y, rot, scale_x, scale_y, blend, a, r, g, b, z)
    assert(img ~= nil, "Render.Sprite: img is nil")
    assert(lstg.Render, "lstg.Render is nil")

    -- v0 先只确认可见性。
    -- blend / color 之后我们单独接新 C++ 绘制 API。
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

function M.DrawSprite(img, x, y, z, rot, scale_x, scale_y, blend, color)
    return M.Sprite(img, x, y, rot, scale_x, scale_y, blend, 255, 255, 255, 255, z)
end

return M