local loop = require("runtime.loop")

local M = {}

function M.init()
    local Lapi = require("Lapi")
    Lapi.install()

    Log(2, "[thlib.runtime] init")
    lstg.DoFile("root.lua")
end

function M.frame()
    return loop.frame()
end

function M.render()
    loop.render()
end

function M.shutdown()
    Log(2, "[thlib.runtime] shutdown")
    loop.shutdown()
end

function M.event(event, ...)
    loop.event(event, ...)
end

return M
