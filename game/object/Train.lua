local Array                 = require "util.Array"
local api                   = require "api"
local Common                = require "util.Common"
local Global                = require "common.Global"
local PositionDirectionEnum = require "common.enum.PositionDirectionEnum"
local Logger                = require "logger.Logger"
local GameResource          = require "common.GameResource"
local TrainTypeEnum         = require "common.enum.TrainTypeEnum"
local LinearMoverComponent  = require "game.object.LinearMoverComponent"


---@class Train
---@field private initTrainData table
---@field private initPosition Vector3
---@field private initDirection PositionDirectionEnum
---@field private trainId integer
---@field private sequenceId integer
---@field private trainType TrainTypeEnum
---@field private trainGroup integer
---@field private gridPosition table
---@field private initDirectionMask integer[]
---@field private direction PositionDirectionEnum
---@field private intermediate boolean
---@field private entities table
---@field private linearMotorProxy LinearMoverComponent
local Train   = {}
Train.__index = Train

local logger  = Logger.new("Train")


local TRAIN_SPEED                      = Global.GAME_GRID_SIZE /
    (Global.GAME_GRID_LOOP_FRAME_COUNT * Global.LOGIC_FRAME_INTERVAL)
local SURROUND_CENTER_ENTITY_PRESET_ID = 102818 -- test
-- local SURROUND_CENTER_ENTITY_PRESET_ID = 1101635
local TRAIN_MODEL_LENGTH               = 7.0

function Train.getTrainSpeed()
    return TRAIN_SPEED
end

function Train.getModelLength()
    return TRAIN_MODEL_LENGTH
end

function Train.getInitForwardDuration()
    return (Global.GAME_GRID_SIZE - TRAIN_MODEL_LENGTH) / 2 / TRAIN_SPEED
end

function Train.new(trainData, initPosition)
    local initDirection = Array.find(trainData.directionMask, 1)


    local self = setmetatable({
        initTrainData = trainData,
        initPosition = initPosition,

        initDirection = initDirection,

        trainId = trainData.trainId,
        sequenceId = trainData.sequenceId,
        trainType = trainData.trainType,
        trainGroup = trainData.trainGroup,
        gridPosition = {
            row = trainData.gridPosition.row,
            col = trainData.gridPosition.col,
        },
        directionMask = Array.copy(trainData.directionMask),
        direction = initDirection,
        intermediate = false,
        entities = {},
        linearMotorProxy = nil
    }, Train)
    return self
end

function Train:getInitPosition()
    return self.initPosition
end

function Train:getTrainId()
    return self.trainId
end

function Train:getSequenceId()
    return self.sequenceId
end

function Train:getTrainGroup()
    return self.trainGroup
end

function Train:getGridPosition()
    return { row = self.gridPosition.row, col = self.gridPosition.col }
end

function Train:setGridPosition(row, col)
    self.gridPosition.row = row
    self.gridPosition.col = col
end

function Train:getDirectionMask()
    return Array.copy(self.initDirectionMask)
end

function Train:getDirection()
    return self.direction
end

function Train:getTrainType()
    return self.trainType
end

---@param referencePos Vector3
---@param towards PositionDirectionEnum
---@param gridPos table
function Train:straight(referencePos, towards, gridPos)
    if self.intermediate then
        logger:error(
            "If the current train instance is in the intermediate state, exit the intermediate state before calling the current method.")
        error()
    end

    local trainBaseEntity = self.entities.base

    api.base.setEntityPosition(trainBaseEntity, referencePos)

    local rotationY = (1 - towards) * math.pi / 2
    api.base.setRotation(trainBaseEntity, math.Quaternion(0, rotationY, 0))

    self.direction = towards
    self.gridPosition.row = gridPos.row
    self.gridPosition.col = gridPos.col

    local velocity = Common.directionToVector(towards) * TRAIN_SPEED
    local duration = Global.GAME_GRID_SIZE / TRAIN_SPEED

    -- api.base.addLinearMotor(trainBaseEntity, velocity, duration, false)
    self.linearMotorProxy:addLinearMover(velocity, duration)
end

function Train:intermediateStraight(referencePos, towards, gridPos)
    local trainBaseEntity = self.entities.base

    local velocity = Common.directionToVector(towards) * TRAIN_SPEED
    local duration = Global.GAME_GRID_SIZE / TRAIN_SPEED / 2

    if not self.intermediate then
        api.base.setEntityPosition(trainBaseEntity, referencePos)

        local rotationY = (1 - towards) * math.pi / 2
        api.base.setRotation(trainBaseEntity, math.Quaternion(0, rotationY, 0))

        self.direction = towards
        self.gridPosition.row = gridPos.row
        self.gridPosition.col = gridPos.col
    end

    -- api.base.addLinearMotor(trainBaseEntity, velocity, duration, false)
    self.linearMotorProxy:addLinearMover(velocity, duration)

    self.intermediate = not self.intermediate
end

---@param referencePos Vector3
---@param initialTowards PositionDirectionEnum
---@param swerveMask integer
---@param gridPos table
function Train:swerve(referencePos, initialTowards, swerveMask, gridPos)
    if self.intermediate then
        logger:error(
            "If the current train instance is in the intermediate state, exit the intermediate state before calling the current method.")
        error()
    end

    local trainBaseEntity = self.entities.base

    api.base.setEntityPosition(trainBaseEntity, referencePos)

    self.gridPosition.row = gridPos.row
    self.gridPosition.col = gridPos.col
    self.direction = Common.ternary(swerveMask == 0, (initialTowards - 1 - 1) % 4 + 1, (initialTowards - 1 + 1) % 4 + 1)



    local initRotation = (initialTowards - 1) * math.pi / 2
    api.base.setRotation(trainBaseEntity, math.Quaternion(0, initRotation, 0))

    local duration = Global.LOGIC_FRAME_INTERVAL * Global.GAME_GRID_LOOP_FRAME_COUNT
    local angularSpeed = 90 / duration
    local centerPos = nil

    if swerveMask == 1 then
        centerPos = referencePos + Common.directionToVector((initialTowards - 1 + 1) % 4 + 1) * Global.GAME_GRID_SIZE / 2
    else
        angularSpeed = -angularSpeed
        centerPos = referencePos + Common.directionToVector((initialTowards - 1 - 1) % 4 + 1) * Global.GAME_GRID_SIZE / 2
    end

    local centerEntity = api.base.createEntity(
        SURROUND_CENTER_ENTITY_PRESET_ID,
        centerPos,
        math.Quaternion(0, 0, 0),
        math.Vector3(1, 1, 1)
    )

    local angularVelocity = math.Vector3(0, angularSpeed, 0)

    api.base.addSurroundMotor(trainBaseEntity, centerEntity, angularVelocity, duration, true)

    api.setTimeout(function()
        api.base.destroyEntity(centerEntity)
    end, 1.0)
end

function Train:intermediateSwerve(referencePos, initialTowards, swerveMask, gridPos)
    local trainBaseEntity = self.entities.base

    if self.intermediate then
        api.base.setEntityPosition(trainBaseEntity, referencePos)

        local rotationY = (1 - initialTowards) * math.pi / 2
        api.base.setRotation(trainBaseEntity, math.Quaternion(0, rotationY, 0))

        self.gridPosition.row = gridPos.row
        self.gridPosition.col = gridPos.col
        self.direction = Common.ternary(swerveMask == 0, (initialTowards - 1 - 1) % 4 + 1,
            (initialTowards - 1 + 1) % 4 + 1)
    end

    local duration = Global.LOGIC_FRAME_INTERVAL * Global.GAME_GRID_LOOP_FRAME_COUNT / 2
    local angularSpeed = 90 / 2 / duration
    local centerPos = nil

    if swerveMask == 1 then
        centerPos = referencePos + Common.directionToVector((initialTowards - 1 + 1) % 4 + 1) * Global.GAME_GRID_SIZE / 2
    else
        angularSpeed = -angularSpeed
        centerPos = referencePos + Common.directionToVector((initialTowards - 1 - 1) % 4 + 1) * Global.GAME_GRID_SIZE / 2
    end

    local centerEntity = api.base.createEntity(
        SURROUND_CENTER_ENTITY_PRESET_ID,
        centerPos,
        math.Quaternion(0, 0, 0),
        math.Vector3(1, 1, 1)
    )

    local angularVelocity = math.Vector3(0, angularSpeed, 0)

    api.base.addSurroundMotor(trainBaseEntity, centerEntity, angularVelocity, duration, true)

    api.setTimeout(function()
        api.base.destroyEntity(centerEntity)
    end, 1.0)
end

function Train:boundFaultStraight(referencePos, towards, gridPos)
    self.gridPosition.row = gridPos.row
    self.gridPosition.col = gridPos.col

    local base = self.entities.base

    local initialRotationY = (towards - 1) * math.pi / 2
    api.base.setRotation(base, math.Quaternion(0, initialRotationY, 0))
    api.base.setEntityPosition(base, referencePos)

    local straightDistance = Global.GAME_GRID_SIZE - 1 / 2 * TRAIN_MODEL_LENGTH
    local duration = straightDistance / TRAIN_SPEED

    local velocity = Common.directionToVector(towards) * TRAIN_SPEED

    self.linearMotorProxy:addLinearMover(velocity, duration)
end

function Train:initBoundFault()
    local distance = 1 / 2 * (Global.GAME_GRID_SIZE - TRAIN_MODEL_LENGTH)
    local duration = distance / TRAIN_SPEED

    local velocity = Common.directionToVector(self.initDirection) * TRAIN_SPEED

    self.linearMotorProxy:addLinearMover(velocity, duration)
end

function Train:boundFaultSwerve(referencePos, initialTowards, swerveMask, gridPos)
    local trainBaseEntity = self.entities.base

    api.base.setEntityPosition(trainBaseEntity, referencePos)

    self.gridPosition.row = gridPos.row
    self.gridPosition.col = gridPos.col
    self.direction = Common.ternary(swerveMask == 0, (initialTowards - 1 - 1) % 4 + 1, (initialTowards - 1 + 1) % 4 + 1)

    local initRotation = (initialTowards - 1) * math.pi / 2
    api.base.setRotation(trainBaseEntity, math.Quaternion(0, initRotation, 0))

    local angularSpeed = 90 / (Global.LOGIC_FRAME_INTERVAL * Global.GAME_GRID_LOOP_FRAME_COUNT)
    local duration = 65 / angularSpeed

    local centerPos = nil

    if swerveMask == 1 then
        centerPos = referencePos + Common.directionToVector((initialTowards - 1 + 1) % 4 + 1) * Global.GAME_GRID_SIZE / 2
    else
        angularSpeed = -angularSpeed
        centerPos = referencePos + Common.directionToVector((initialTowards - 1 - 1) % 4 + 1) * Global.GAME_GRID_SIZE / 2
    end

    local centerEntity = api.base.createEntity(
        SURROUND_CENTER_ENTITY_PRESET_ID,
        centerPos,
        math.Quaternion(0, 0, 0),
        math.Vector3(1, 1, 1)
    )

    local angularVelocity = math.Vector3(0, angularSpeed, 0)

    api.base.addSurroundMotor(trainBaseEntity, centerEntity, angularVelocity, duration, true)

    api.setTimeout(function()
        api.base.destroyEntity(centerEntity)
    end, 1.0)
end

function Train:initForward()
    local initDirection = self:initForwardDirection()
    return Common.gridPositionMove(self.initTrainData.gridPosition.row, self.initTrainData.gridPosition.col,
        initDirection)
end

function Train:initForwardDirection()
    return self.initDirection
end

function Train:stopMotor()
    self.linearMotorProxy:removeAllLinearMover()
    api.base.removeSurroundMotor(self.entities.base)
end

function Train:render()
    local rotationY = (self:initForwardDirection() - 1) * math.pi / 2
    local entityGroup = api.base.createEntityGroup(
        GameResource.TRAIN_MODEL_GROUP_PRESET_ID,
        self.initPosition,
        math.Quaternion(0, rotationY, 0)
    )

    local base = api.base.getChildEntityList(entityGroup)[1]
    self.entities.base = base
    self.linearMotorProxy = LinearMoverComponent.new(base)
end

function Train:destroy()
    self.linearMotorProxy:removeAllLinearMover()
    for key, entity in pairs(self.entities) do
        api.base.destroyEntity(entity)
    end
end

function Train:reset()
    self:destroy()
    self:render()
end

function Train:showDirectionArrow()

end

function Train:hideDirectionArrow()

end

function Train:fault()
    if self.trainType == TrainTypeEnum.NORMAL then
        -- TODO: effect
    end
end

return Train
