local M = {}

local screen = {
    resx = 640,
    resy = 480,

    width = 640,
    height = 480,

    scale = 1,
    dx = 0,
    dy = 0,
}

local raw_default_world = {
    l = -192,
    r = 192,
    b = -224,
    t = 224,

    boundl = -224,
    boundr = 224,
    boundb = -256,
    boundt = 256,

    scrl = 32,
    scrr = 416,
    scrb = 16,
    scrt = 464,

    pl = -192,
    pr = 192,
    pb = -224,
    pt = 224,

    mask = 15,
}

local default_world = {}
local world = {}

local world_offset = {
    center_x = 0,
    center_y = 0,

    scale_x = 1,
    scale_y = 1,

    dx = 0,
    dy = 0,
}

local function copy_table(src)
    local dst = {}
    for k, v in pairs(src) do
        dst[k] = v
    end
    return dst
end

local function get_default_resolution()
    local resx = 640
    local resy = 480

    if type(setting) == "table" then
        resx = setting.resx or resx
        resy = setting.resy or resy
    end

    return resx, resy
end

local function apply_bound()
    if lstg.SetBound and world.boundl then
        lstg.SetBound(world.boundl, world.boundr, world.boundb, world.boundt)
    end
end

local function require_view_api()
    assert(lstg.SetOrtho, "lstg.SetOrtho is nil")
    assert(lstg.SetViewport, "lstg.SetViewport is nil")
    assert(lstg.SetScissorRect, "lstg.SetScissorRect is nil")
end

default_world = copy_table(raw_default_world)
world = copy_table(default_world)

function M.ResetScreen(resx, resy, no_reset_world)
    resx = resx or select(1, get_default_resolution())
    resy = resy or select(2, get_default_resolution())

    screen.resx = resx
    screen.resy = resy

    if resx > resy then
        screen.width = 640
        screen.height = 480
    else
        -- 暂时保留 legacy 竖屏逻辑
        screen.width = 396
        screen.height = 528
    end

    local h_scale = resx / screen.width
    local v_scale = resy / screen.height

    screen.scale = math.min(h_scale, v_scale)

    local base_aspect = screen.width / screen.height
    local real_aspect = resx / resy

    if real_aspect >= base_aspect then
        screen.dx = (resx - screen.scale * screen.width) * 0.5
        screen.dy = 0
    else
        screen.dx = 0
        screen.dy = (resy - screen.scale * screen.height) * 0.5
    end

    if not no_reset_world then
        M.ResetWorld()
        M.ResetWorldOffset()
    end
end

function M.GetScreen()
    return copy_table(screen)
end

function M.GetWorld()
    return copy_table(world)
end

function M.GetDefaultWorld()
    return copy_table(default_world)
end

function M.ResetWorld()
    world = copy_table(default_world)
    lstg.world = world
    apply_bound()
end

function M.RawResetWorld()
    default_world = copy_table(raw_default_world)
    world = copy_table(raw_default_world)
    lstg.world = world
    apply_bound()
end

function M.SetDefaultWorld(scr_l, scr_b, width, height, bound, mask)
    bound = bound or 32
    mask = mask or 15

    default_world = {
        l = -width / 2,
        r = width / 2,
        b = -height / 2,
        t = height / 2,

        boundl = -width / 2 - bound,
        boundr = width / 2 + bound,
        boundb = -height / 2 - bound,
        boundt = height / 2 + bound,

        scrl = scr_l,
        scrr = scr_l + width,
        scrb = scr_b,
        scrt = scr_b + height,

        pl = -width / 2,
        pr = width / 2,
        pb = -height / 2,
        pt = height / 2,

        mask = mask,
    }
end

function M.SetWorld(scr_l, scr_b, width, height, bound, mask)
    bound = bound or 32
    mask = mask or 15

    world.l = -width / 2
    world.r = width / 2
    world.b = -height / 2
    world.t = height / 2

    world.boundl = -width / 2 - bound
    world.boundr = width / 2 + bound
    world.boundb = -height / 2 - bound
    world.boundt = height / 2 + bound

    world.scrl = scr_l
    world.scrr = scr_l + width
    world.scrb = scr_b
    world.scrt = scr_b + height

    world.pl = -width / 2
    world.pr = width / 2
    world.pb = -height / 2
    world.pt = height / 2

    world.mask = mask

    lstg.world = world
    apply_bound()
end

function M.ResetWorldOffset()
    world_offset.center_x = 0
    world_offset.center_y = 0
    world_offset.scale_x = 1
    world_offset.scale_y = 1
    world_offset.dx = 0
    world_offset.dy = 0
end

function M.SetWorldOffset(center_x, center_y, scale_x, scale_y, dx, dy)
    world_offset.center_x = center_x or 0
    world_offset.center_y = center_y or 0
    world_offset.scale_x = scale_x or 1
    world_offset.scale_y = scale_y or 1
    world_offset.dx = dx or 0
    world_offset.dy = dy or 0
end

function M.SetRenderRect(l, r, b, t, scr_l, scr_r, scr_b, scr_t)
    require_view_api()

    lstg.SetOrtho(l, r, b, t)

    lstg.SetViewport(
        scr_l * screen.scale + screen.dx,
        scr_r * screen.scale + screen.dx,
        scr_b * screen.scale + screen.dy,
        scr_t * screen.scale + screen.dy
    )

    lstg.SetScissorRect(
        scr_l * screen.scale + screen.dx,
        scr_r * screen.scale + screen.dx,
        scr_b * screen.scale + screen.dy,
        scr_t * screen.scale + screen.dy
    )

    if lstg.SetFog then
        lstg.SetFog()
    end
end

function M.SetViewMode(mode)
    mode = mode or "world"

    if mode == "world" then
        local w = world
        local offset = world_offset

        local world_width = w.r - w.l
        local world_height = w.t - w.b

        local set_width = world_width / offset.scale_x
        local set_height = world_height / offset.scale_y

        local set_dx = offset.dx / offset.scale_x
        local set_dy = offset.dy / offset.scale_y

        local l = offset.center_x - set_width / 2 + set_dx
        local r = offset.center_x + set_width / 2 + set_dx
        local b = offset.center_y - set_height / 2 + set_dy
        local t = offset.center_y + set_height / 2 + set_dy

        M.SetRenderRect(l, r, b, t, w.scrl, w.scrr, w.scrb, w.scrt)
        lstg.viewmode = "world"
        return
    end

    if mode == "ui" then
        M.SetRenderRect(
            0,
            screen.width,
            0,
            screen.height,
            0,
            screen.width,
            0,
            screen.height
        )
        lstg.viewmode = "ui"
        return
    end

    error("Render.SetViewMode: invalid mode '" .. tostring(mode) .. "'", 2)
end

function M.WorldToUI(x, y)
    local w = world

    return
        w.scrl + (w.scrr - w.scrl) * (x - w.l) / (w.r - w.l),
        w.scrb + (w.scrt - w.scrb) * (y - w.b) / (w.t - w.b)
end

function M.UIToWorld(x, y)
    local w = world

    return
        w.l + (w.r - w.l) * (x - w.scrl) / (w.scrr - w.scrl),
        w.b + (w.t - w.b) * (y - w.scrb) / (w.scrt - w.scrb)
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

M.ResetScreen()

return M