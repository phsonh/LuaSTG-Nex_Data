local M = {}

function M.new()
    return lstg.Unit.new()
end

function M.delete(native)
    if native and native:isValid() then
        native:delete()
    end
end

function M.is_valid(native)
    return native ~= nil and native:isValid()
end

function M.update_all()
    lstg.Unit.updateAll()
end

function M.clear()
    lstg.Unit.clear()
end

function M.count()
    return lstg.Unit.count()
end

return M
