local Renderer = require("native.renderer")
local Task = require("system.task")

local Ani = {}
Ani.__index = Ani
Ani.__is_ani_base = true

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

function Ani:init(master, visual)
    self.master = master
    self.visual = visual

    self.img = "img_void"

    self.x = 0
    self.y = 0
    self.rot = 0

    self.scale_x = 1
    self.scale_y = 1

    self.blend = ""

    self.a = 255
    self.r = 255
    self.g = 255
    self.b = 255

    self.z = 0.5

    self.visible = true
    self.layer = nil

    self.timer = 0
end

function Ani:frame()
end

function Ani.RenderDefault(self)
    if self.visible == false then
        return
    end

    local sx = self.scale_x

    if sx == nil then
        sx = 1
    end

    local sy = self.scale_y

    if sy == nil then
        sy = sx
    end

    return get_sprite()(
        self.img or "img_void",
        self.x or 0,
        self.y or 0,
        self.rot or 0,
        sx,
        sy,
        self.blend or "",
        self.a or 255,
        self.r or 255,
        self.g or 255,
        self.b or 255,
        self.z or 0.5
    )
end

Ani.render = Ani.RenderDefault

function Ani:isValid()
    return self.__alive == true
end

function Ani:delete()
    if self.__alive ~= true then
        return
    end

    self.__alive = false

    Task.Clear(self)

    if self.del then
        self:del()
    end
end

function Ani:del()
end

return Ani