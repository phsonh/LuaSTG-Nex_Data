local render_driver = require("driver.render")

local Visual = {}
Visual.__index = Visual
Visual.__is_visual_base = true

function Visual:init(master)
    self.master = master
end

function Visual:frame()
    local master = self.master

    if master and IsValid(master) then
        self.x = master.x
        self.y = master.y

        if self.follow_rot ~= false then
            self.rot = master.rot or 0
        end
    end
end

function Visual:render()
    if self.visible == false then
        return
    end

    if self.img == nil then
        return
    end

    render_driver.Drawsprite(
        self.img,
        self.x,
        self.y,
        self.z,
        self.rot,
        self.hscale,
        self.vscale,
        self.blend,
        self.color
    )
end

function Visual:isValid()
    return self.__alive == true
end

function Visual:delete()
    self.__alive = false
end

function Visual:del()
end

return Visual