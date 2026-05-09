local M = {}

function M.new()
    assert(lstg.Unit and lstg.Unit.new, "lstg.Unit.new is not registered")
    return lstg.Unit.new()
end

function M.update_all()
    assert(lstg.Unit and lstg.Unit.updateAll, "lstg.Unit.updateAll is not registered")
    return lstg.Unit.updateAll()
end

function M.clear()
    assert(lstg.Unit and lstg.Unit.clear, "lstg.Unit.clear is not registered")
    return lstg.Unit.clear()
end

function M.count()
    assert(lstg.Unit and lstg.Unit.count, "lstg.Unit.count is not registered")
    return lstg.Unit.count()
end

return M