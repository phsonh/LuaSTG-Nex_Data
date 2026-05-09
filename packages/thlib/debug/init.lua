local M = {}

M.Console = require("debug.console")
M.HUD = require("debug.hud")

M.Print = M.Console.Print
M.Log = M.Console.Log
M.Info = M.Console.Info
M.Warn = M.Console.Warn
M.Error = M.Console.Error

return M