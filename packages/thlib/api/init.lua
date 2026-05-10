local class = require("class.class")

local Unit = require("class.unit")
local Visual = require("class.visual")
local Ani = require("class.ani")

local StateMachine = require("system.state_machine")
local Scene = require("runtime.scene")
local SceneManager = require("runtime.scene_manager")

local Resource = require("resource")
local Render = require("render")
local View = require("view")
local Audio = require("audio")
local Debug = require("debug.init")
local Task = require("system.task")
local Math = require("math_ext")

local M = {}

local installed = false

local function export(name, value)
    rawset(_G, name, value)
end

function M.install()
    if installed then
        return
    end

    installed = true

    export("Class", class.Class)

    export("Unit", Unit)
    export("Visual", Visual)
    export("Ani", Ani)

    export("StateMachine", StateMachine)
    export("Scene", Scene)
    export("SceneManager", SceneManager)

    export("Resource", Resource)
    export("Render", Render)
    export("View", View)
    export("Audio", Audio)
    export("Debug", Debug)
    export("Task", Task)
    export("Math", Math)
end

return M