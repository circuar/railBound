-- main.lua

local Logger            = require "logger.Logger"
local GlobalGameManager = require "game.GlobalGameManager"
local LogLevel          = require "logger.LogLevel"
local api               = require "api"
local GameLoader        = require "game.core.GameLoader"
local LevelManager      = require "game.level.LevelManager"
local GameUI            = require "component.GameUI"

Logger.setGlobalLogLevel(LogLevel.DEBUG)

local logger = Logger.new("main")
logger:info("start ...")

-- GlobalGameManager.run()

---Test
-- api.setTimeout(function()
--     GameLoader.instance():initGame(1)
-- end, 10.0)
api.setTimeout(function()
    GameUI.showLevelSwitchAnim(0.0)
end, 1.0)
