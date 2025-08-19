local Array                            = require "util.Array"
local api                              = require "api"
local Common                           = require "util.Common"
local Global                           = require "common.Global"
local PositionDirectionEnum            = require "common.enum.PositionDirectionEnum"

---@class Train
---@field private initTrainData table
---@field private initPosition Vector3
---@field private trainId integer
---@field private sequenceId integer
---@field private trainType string
---@field private trainGroup integer
---@field private gridPosition table
---@field private initDirectionMask integer[]
---@field private direction PositionDirectionEnum
---@field private intermediate boolean
---@field private entities table
local Train                            = {}
Train.__index                          = Train

local TRAIN_SPEED                      = Global.GAME_GRID_SIZE /
    (Global.GAME_GRID_LOOP_FRAME_COUNT * Global.LOGIC_FRAME_INTERVAL)
local SURROUND_CENTER_ENTITY_PRESET_ID = 1
function Train.getTrainSpeed()
    return TRAIN_SPEED
end

function Train.new(trainData, initPosition)
    local self = setmetatable({
        initTrainData = trainData,
        initPosition = initPosition,

        trainId = trainData.trainId,
        sequenceId = trainData.sequenceId,
        trainType = trainData.trainType,
        trainGroup = trainData.trainGroup,
        gridPosition = {
            row = trainData.gridPosition.row,
            col = trainData.gridPosition.col,
        },
        directionMask = Array.copy(trainData.directionMask),
        direction = Array.find(trainData.directionMask, 1),
        intermediate = false,
        entities = {}
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

---@param referencePos Vector3
---@param towards PositionDirectionEnum
---@param gridPos table
function Train:straight(referencePos, towards, gridPos)
    local trainBaseEntity = self.entities.base

    api.base.setEntityPosition(trainBaseEntity, referencePos)

    local rotationY = (1 - towards) * math.pi / 2
    api.base.setRotation(trainBaseEntity, math.Quaternion(0, rotationY, 0))

    self.direction = towards
    self.gridPosition.row = gridPos.row
    self.gridPosition.col = gridPos.col

    local velocity = Common.directionToVector(towards) * TRAIN_SPEED
    local duration = Global.GAME_GRID_SIZE / TRAIN_SPEED
    api.base.addLinearMotor(trainBaseEntity, velocity, duration, false)
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

    api.base.addLinearMotor(trainBaseEntity, velocity, duration, false)

    self.intermediate = not self.intermediate
end

---@param referencePos Vector3
---@param centerPos Vector3
---@param initialTowards AxisDirectionEnum
---@param swerveMask integer
---@param gridPos table
function Train:swerve(referencePos, centerPos, initialTowards, swerveMask, gridPos)
    local trainBaseEntity = self.entities.base

    api.base.setEntityPosition(trainBaseEntity, referencePos)

    self.gridPosition.row = gridPos.row
    self.gridPosition.col = gridPos.col

    local centerEntity = api.base.createEntity(
        SURROUND_CENTER_ENTITY_PRESET_ID,
        centerPos,
        math.Quaternion(0, 0, 0),
        math.Vector3(1, 1, 1)
    )

    local initRotation = (1 - initialTowards) * math.pi / 2
    api.base.setRotation(trainBaseEntity, math.Quaternion(0, initRotation, 0))

    local duration = Global.LOGIC_FRAME_INTERVAL * Global.GAME_GRID_LOOP_FRAME_COUNT
    local angularSpeed = math.pi / 2 / duration
    if swerveMask == 1 then
        angularSpeed = -angularSpeed
    end
    local angularVelocity = math.Vector3(0, angularSpeed, 0)

    api.base.addSurroundMotor(trainBaseEntity, centerEntity, angularVelocity, duration, true)

    api.setTimeout(function()
        api.base.destroyEntity(centerEntity)
    end, 1.0)
end



function Train:intermediateSwerve(referencePos, centerPos, initialTowards, swerveMask, gridPos)

end

function Train:initForward()
    local initDirection = self:initForwardDirection()
    return Common.gridPositionMove(self.initTrainData.gridPosition.row, self.initTrainData.gridPosition.col,
        initDirection)
end

function Train:initForwardDirection()
    return self.initTrainData.direction
end

return Train
