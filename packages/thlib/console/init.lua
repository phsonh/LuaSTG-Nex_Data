local M = {}

function M.Log(level, ...)
    return lstg.Log(2, level, ...)
end

function M.Info(...)
    return lstg.Log(2, ...)
end

function M.Warn(...)
    return lstg.Log(1, ...)
end

function M.Error(...)
    return lstg.Log(0, ...)
end

function M.Print(...)
    return lstg.Log(2, ...)
end

return M