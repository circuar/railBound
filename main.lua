-- main.lua

local Logger            = require "logger.Logger"
local GlobalGameManager = require "game.GlobalGameManager"
local LogLevel          = require "logger.LogLevel"

Logger.setGlobalLogLevel(LogLevel.DEBUG)

local logger = Logger.new("main")
logger:info("start ...")

GlobalGameManager.run()
