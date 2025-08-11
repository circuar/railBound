-- main.lua

local Logger            = require "logger.Logger"
local GlobalGameManager = require "game.GlobalGameManager"
local LogLevel          = require "logger.LogLevel"
local api               = require "api"
local GameLoader        = require "game.core.GameLoader"

Logger.setGlobalLogLevel(LogLevel.DEBUG)

local logger = Logger.new("main")
logger:info("start ...")

GlobalGameManager.run()

api.setTimeout(function()
    GameLoader.instance():initGame(1)
end, 10.0)
