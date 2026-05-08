local Visual = {}
Visual.__index = Visual
Visual.__is_visual_base = true

function Visual:init(master)
    self.master = master
    self.chips = {}
    self.current_name = nil
    self.current_chip = nil
    self.visible = true
end

function Visual:addChip(name, chip_class, ...)
    local manager = require("manager.visual_manager")
    local chip = manager.spawn_chip(chip_class, self.master, self, ...)

    self.chips[name] = chip

    if self.current_chip == nil then
        self.current_name = name
        self.current_chip = chip
    end

    return chip
end

function Visual:getChip(name)
    return self.chips[name]
end

function Visual:play(name)
    local chip = self.chips[name]
    assert(chip, "Visual:play unknown chip '" .. tostring(name) .. "'")

    self.current_name = name
    self.current_chip = chip

    return chip
end

function Visual:_update()
    local chip = self.current_chip
    if chip and chip.__alive == true then
        chip.timer = (chip.timer or 0) + 1
        if chip.frame then
            chip:frame()
        end
    end
end

function Visual:_render()
    if self.visible == false then
        return
    end

    local chip = self.current_chip
    if chip and chip.__alive == true and chip.render then
        chip:render()
    end
end

function Visual:isValid()
    return self.__alive == true
end

function Visual:delete()
    if self.__alive ~= true then
        return
    end

    self.__alive = false
    if self.del then
        self:del()
    end
end

function Visual:del()
    for _, chip in pairs(self.chips) do
        if chip and chip.delete then
            chip:delete()
        end
    end
    self.chips = {}
    self.current_name = nil
    self.current_chip = nil
end

return Visual
