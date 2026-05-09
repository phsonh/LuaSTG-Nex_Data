local M = {}

function M.Sprite(...)
    assert(lstg.Renderer and lstg.Renderer.Sprite, "lstg.Renderer.Sprite is not registered")
    return lstg.Renderer.Sprite(...)
end

return M