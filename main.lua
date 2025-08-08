-- main.lua

local Logger            = require "logger.Logger"
local GlobalGameManager = require "game.GlobalGameManager"

local logger = Logger.new("main")
logger:info("start ...")

GlobalGameManager.run()
