local task = require("system.task")
local unpack = table.unpack or unpack
local Visual = {}
Visual.__index = Visual
Visual.__is_visual_base = true

function Visual:init(master)
    self.master = master

    self.chips = {}
    self.chip_defs = {}

    self.current_name = nil
    self.current_chip = nil

    self.visible = true
end

function Visual:addChip(name, chip_class, ...)
    assert(type(name) == "string", "Visual:addChip(name, chip_class, ...): name must be a string")
    assert(type(chip_class) == "table", "Visual:addChip(name, chip_class, ...): chip_class must be a class table")

    local visual_manager = require("manager.visual_manager")

    local args = { ... }

    local chip = visual_manager.spawn_chip(chip_class, self.master, self, unpack(args))

    self.chips[name] = chip
    self.chip_defs[name] = {
        class = chip_class,
        args = args,
    }

    -- 第一个 chip 默认成为当前 chip。
    -- 注意：这里不要调用 play，否则会 init 两次。
    if self.current_chip == nil then
        self.current_name = name
        self.current_chip = chip
    end

    return chip
end

function Visual:getChip(name)
    return self.chips[name]
end

function Visual:_resetChip(name)
    local chip = self.chips[name]
    local def = self.chip_defs[name]

    assert(chip ~= nil, "Visual:_resetChip(name): unknown chip '" .. tostring(name) .. "'")
    assert(def ~= nil, "Visual:_resetChip(name): missing chip def '" .. tostring(name) .. "'")

    task.Clear(chip)

    chip.timer = 0
    chip.__alive = true

    if chip.init then
        chip:init(self.master, self, unpack(def.args))
    end

    return chip
end

function Visual:_stopChip(chip)
    if chip == nil then
        return
    end

    task.Clear(chip)
    chip.timer = 0
end

function Visual:play(name)
    local chip = self.chips[name]

    assert(chip ~= nil, "Visual:play(name): unknown chip '" .. tostring(name) .. "'")

    -- 旧 chip 停止，不保留播放进度。
    if self.current_chip and self.current_chip ~= chip then
        self:_stopChip(self.current_chip)
    end

    -- 目标 chip 重新播放。
    chip = self:_resetChip(name)

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
    self.chip_defs = {}

    self.current_name = nil
    self.current_chip = nil
end

function Visual:_update()
    local chip = self.current_chip

    if chip and chip.__alive == true then
        chip.timer = (chip.timer or 0) + 1

        if chip.frame then
            chip:frame()
        end

        task.Do(chip)
    end
end

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