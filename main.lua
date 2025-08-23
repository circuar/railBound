-- main.lua

local Logger               = require "logger.Logger"
local GlobalGameManager    = require "game.GlobalGameManager"
local LogLevel             = require "logger.LogLevel"
local api                  = require "api"
local Train                = require "game.object.Train"
local LinearMoverComponent = require "game.object.LinearMoverComponent"
local LevelManager         = require "game.level.LevelManager"
local GameLoader           = require "game.core.GameLoader"

Logger.setGlobalLogLevel(LogLevel.DEBUG)

local logger = Logger.new("main")
logger:info("start ...")

GlobalGameManager.run()



api.setTimeout(function()
    GameLoader.instance():initGame(0)
end, 3.0)




-- local test = api.base.getEntityById(1492576201)

-- local cm = LinearMoverComponent.new(test)
-- local index = cm:addLinearMover(math.Vector3(0, 1, 0), 10.0)
-- api.setTimeout(function()
--     cm:addLinearMover(math.Vector3(0, 1, 0), 10.0)
-- end, 5.0)


--- test train instance
-- do
--     local train = Train.new({
--         trainId = 1,
--         sequenceId = 1,
--         trainType = "NORMAL",
--         trainGroup = 1,
--         gridPosition = { row = 1, col = 1 },
--         directionMask = { 0, 1, 0, 0 }
--     }, math.Vector3(-75, 0, -390))

--     train:render()
--     api.setTimeout(function()
--         -- train:straight(math.Vector3(-75, 0, -390), 2, { row = 1, col = 1 })
--         -- train:intermediateStraight(math.Vector3(-75, 0, -390), 2, { row = 1, col = 1 })
--         -- train:swerve(math.Vector3(-75, 0, -390), 2, 1, { row = 1, col = 1 })
--         -- train:swerve(math.Vector3(-75, 0, -390), 2, 0, { row = 1, col = 1 })
--         -- train:intermediateSwerve(math.Vector3(-75, 0, -390), 2, 0, { row = 1, col = 1 })
--         -- train:boundFaultStraight(math.Vector3(-75, 0, -390), 2, { row = 1, col = 1 })
--         train:boundFaultSwerve(math.Vector3(-75, 0, -390), 2, 1, { row = 1, col = 1 })
--     end, 3.0)
--     api.setTimeout(function()
--         -- train:reset()
--         train:destroy()
--     end, 3.2)
-- end
