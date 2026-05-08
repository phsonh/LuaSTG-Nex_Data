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
    assert(type(name) == "string", "Visual:addChip(name, chip_class, ...): name must be a string")
    assert(type(chip_class) == "table", "Visual:addChip(name, chip_class, ...): chip_class must be a class table")

    local visual_manager = require("manager.visual_manager")

    local chip = visual_manager.spawn_chip(chip_class, self.master, self, ...)

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

    assert(chip ~= nil, "Visual:play(name): unknown chip '" .. tostring(name) .. "'")

    self.current_name = name
    self.current_chip = chip

    return chip
end

function Visual:isValid()
    return self.__alive == true
end

function Visual:delete()
    if self.__alive ~= true then
        return
    end

    self.__alive = false

    self:del()
end

function Visual:del()
    local visual_manager = require("manager.visual_manager")

    for _, chip in pairs(self.chips) do
        visual_manager.delete_chip(chip)
    end

    self.chips = {}
    self.current_name = nil
    self.current_chip = nil
end

-- Internal API.
-- Visual 是容器，用户不要重写这个。
function Visual:_update()
    local chip = self.current_chip

    if chip and chip.__alive == true then
        chip.timer = (chip.timer or 0) + 1

        if chip.frame then
            chip:frame()
        end
    end
end

-- Internal API.
-- Visual 是容器，用户不要重写这个。
function Visual:_render()
    if self.visible == false then
        return
    end

    local chip = self.current_chip

    if chip and chip.__alive == true then
        if chip.render then
            chip:render()
        end
    end
end

return Visual