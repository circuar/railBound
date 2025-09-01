-- main.lua

local Logger               = require "logger.Logger"
local GlobalGameManager    = require "game.GlobalGameManager"
local LogLevel             = require "logger.LogLevel"
local api                  = require "api"
local Train                = require "game.object.Train"
local LinearMoverComponent = require "game.object.LinearMoverComponent"
local LevelManager         = require "game.level.LevelManager"
local GameLoader           = require "game.core.GameLoader"
local GameResource         = require "common.GameResource"

Logger.setGlobalLogLevel(LogLevel.DEBUG)

local logger = Logger.new("main")
logger:info("start ...")

GlobalGameManager.run()



api.setTimeout(function()
    GameLoader.instance():initGame(0)
end, 3.0)

-- api.setTimeout(function()
--     LevelManager.instance():runLevel()
-- end, 7.0)


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
--         train:swerve(math.Vector3(-75, 0, -390), 2, 1)
--         -- train:swerve(math.Vector3(-75, 0, -390), 2, 0, { row = 1, col = 1 })
--         -- train:intermediateSwerve(math.Vector3(-75, 0, -390), 2, 0, { row = 1, col = 1 })
--         -- train:boundFaultStraight(math.Vector3(-75, 0, -390), 2, { row = 1, col = 1 })
--     end, 3.0)
--     api.setTimeout(function()
--         train.entities.base.add_linear_motor(math.Vector3(0, 1, 0), 10.0, false)
--     end, 4.1)
--     api.setTimeout(function()
--         train.entities.base.set_linear_velocity(math.Vector3(0, 0, 0))
--     end, 5.0)
-- end

-- local t = Train.new({
--     trainId = 1,
--     sequenceId = 1,
--     trainType = "NORMAL",
--     trainGroup = 1,
--     gridPosition = { row = 5, col = 3 },
--     directionMask = { 0, 1, 0, 0 }
-- }, math.Vector3(-75, 0, -390))

-- t:render()


-- api.setTimeout(function()
--     t:swerve(math.Vector3(-75, 0, -390), 2, 1)
-- end, 3.0)

-- api.setTimeout(function()
--     api.base.removeSurroundMotor(t.entities.base)
--     t:swerve(math.Vector3(-75, 0, -390), 2, 1)
-- end, 3.5)

-- api.setTimeout(function()
--     api.base.removeSurroundMotor(t.entities.base)
--     t:swerve(math.Vector3(-75, 0, -390), 2, 1)
-- end, 4.0)


-- local center = api.base.createEntity(GameResource.RAIL_ENTITY_FIXED_STRAIGHT_PRESET_ID, math.Vector3(-75, 0, -390),
--     math.Quaternion(0, 0,
--         0), math.Vector3(0, 0, 0))

-- local center1 = api.base.createEntity(GameResource.RAIL_ENTITY_FIXED_STRAIGHT_PRESET_ID, math.Vector3(-75, 0, -390),
--     math.Quaternion(0, 0,
--         0), math.Vector3(0, 0, 0))

-- local c = api.base.createEntity(GameResource.RAIL_ENTITY_FIXED_STRAIGHT_PRESET_ID, math.Vector3(-75, 0, -400),
--     math.Quaternion(0, 0,
--         0), math.Vector3(0, 0, 0))

-- api.setTimeout(function()
--     api.base.addSurroundMotor(c, center, math.Vector3(0, 90, 0), 1.0, true)
-- end, 3.0)
-- api.setTimeout(function()
--     api.base.addSurroundMotor(c, center, math.Vector3(0, 90, 0), 1.0, true)
-- end, 4.0)
-- api.setTimeout(function()
--     api.base.destroyEntity(center)
--     api.base.addSurroundMotor(c, center1, math.Vector3(0, 90, 0), 1.0, true)
-- end, 5.0)
