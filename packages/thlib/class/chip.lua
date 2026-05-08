local Render = require("driver.render")

local Chip = {}
Chip.__index = Chip
Chip.__is_chip_base = true

function Chip:init(master, visual)
    self.master = master
    self.visual = visual

    self.img = "img_void"
    self.space = "local"

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

    self.visible = true
    self.timer = 0
end

function Chip:frame()
end

function Chip:render()
    if self.visible == false then
        return
    end

    local img = self.img or "img_void"

    local draw_x = self.x or 0
    local draw_y = self.y or 0

    if self.space ~= "world" then
        local master = self.master
        if master then
            draw_x = master.x + draw_x
            draw_y = master.y + draw_y
        end
    end

    Render.Sprite(
        img,
        draw_x,
        draw_y,
        self.rot or 0,
        self.scale_x or 1,
        self.scale_y or 1,
        self.blend or "",
        self.a or 255,
        self.r or 255,
        self.g or 255,
        self.b or 255,
        self.z or 0.5
    )
end

function Chip:del()
end

function Chip:isValid()
    return self.__alive == true
end

function Chip:delete()
    if self.__alive ~= true then
        return
    end

    self.__alive = false
    if self.del then
        self:del()
    end
end

return Chip
