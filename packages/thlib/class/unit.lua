local Unit = {}
Unit.__index = Unit
Unit.__is_unit_base = true

function Unit:init()
end

function Unit:frame()
end

function Unit:after_frame()
end

function Unit:del()
end

function Unit:isValid()
    return self.__alive == true
        and self.native ~= nil
        and self.native:isValid()
end

function Unit:delete()
    if self.__alive ~= true then
        return
    end

    self.__alive = false

    if self.del then
        self:del()
    end

    if self.native and self.native:isValid() then
        self.native:delete()
    end
end

return Unit
