local runtime = require("runtime")

function GameInit()
    runtime.init()
end

function FrameFunc()
    return runtime.frame()
end

function RenderFunc()
    runtime.render()
end

function GameExit()
    runtime.shutdown()
end

function FocusLoseFunc()
end

function FocusGainFunc()
end

function EventFunc(event, ...)
    runtime.event(event, ...)
end
