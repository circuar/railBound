local api                   = require "api"
local Array                 = require "util.Array"
local PositionDirectionEnum = require "common.enum.PositionDirectionEnum"
local Global                = require "common.Global"
local Logger                = require "logger.Logger"


---@class Train
---@field trainId integer
---@field sequenceId integer
---@field trainType string
---@field trainGroup integer
---@field initGridPosition table
---@field currentGridPosition table
---@field initPosition Vector3
---@field directionMask integer[]
---@field initDirection PositionDirectionEnum
---@field currentDirection PositionDirectionEnum
---@field entityList Unit[]
---@field trainLength number
local Train = {}
Train.__index = Train

local logger = Logger.new("Train")

local TRAIN_LENGTH_MAP = {
    ["NORMAL"] = 8.0,
    ["TAIL"] = 7.0
}


local LINEAR_MOTOR_INDEX = 1
local START_EDGE_DISTANCE = 1.0
local INIT_FORWARD_DURATION = START_EDGE_DISTANCE / Global.GAME_GRID_SIZE * Global.GAME_GRID_LOOP_FRAME_COUNT /
    Global.LOGIC_FPS
local TRAIN_SPEED = Global.GAME_GRID_SIZE * Global.LOGIC_FPS / Global.GAME_GRID_LOOP_FRAME_COUNT

local function directionToRotation(trainDirection)
    return math.Quaternion(0, math.pi / 2 * (trainDirection - 1), 0)
end

local function directionToVector(trainDirection)
    if trainDirection == PositionDirectionEnum.TOP then
        return math.Vector3(0, 0, 1)
    elseif trainDirection == PositionDirectionEnum.RIGHT then
        return math.Vector3(1, 0, 0)
    elseif trainDirection == PositionDirectionEnum.BOTTOM then
        return math.Vector3(0, 0, -1)
    else
        return math.Vector3(-1, 0, 0)
    end
end

---constructor
---@return Train
function Train.new(trainData, position)
    local initRowPosition = trainData.position.row
    local initColPosition = trainData.position.col
    local direction = Array.find(trainData.directionMask, 1)
    local trainType = trainData.trainType

    local self = setmetatable({
        trainId = trainData.trainId,
        sequenceId = trainData.sequenceId,
        trainType = trainType,
        trainGroup = trainData.trainGroup,
        initGridPosition = { row = initRowPosition, col = initColPosition },
        currentGridPosition = { row = initRowPosition, col = initColPosition },
        initPosition = position,
        directionMask = trainData.directionMask,
        initDirection = direction,
        currentDirection = direction,
        entityList = {},
        trainLength = TRAIN_LENGTH_MAP[trainType]
    }, Train)

    return self
end

function Train.getInitForwardDuration()
    return INIT_FORWARD_DURATION
end

function Train.getTrainSpeed()
    return TRAIN_SPEED
end

function Train:getTrainLength()
    return self.trainLength
end

function Train:setPosition(position)
    api.base.setEntityPosition(self.entityList[1], position)
end

function Train:setVelocity(velocity)
    api.base.setLinearMotorVelocity(self.entityList[1], LINEAR_MOTOR_INDEX, velocity)
end

function Train:addLinearMotor(velocity, duration)
    api.base.setLinearMotorVelocity(self.entityList[1], LINEAR_MOTOR_INDEX, velocity)
    api.setTimeout(function()
        api.base.setLinearMotorVelocity(self.entityList[1], LINEAR_MOTOR_INDEX, math.Vector3(0, 0, 0))
    end, duration)
end

function Train:straight(direction)
    api.base.setRotation(self.entityList[1], directionToRotation(direction))
    local velocity = directionToVector(direction) * Global.GAME_GRID_SIZE / Global.GAME_GRID_LOOP_FRAME_COUNT *
        Global.LOGIC_FPS
    -- api.base.addLinearMotor(self.entityList[1], velocity, duration)
    api.base.setLinearMotorVelocity(self.entityList[1], LINEAR_MOTOR_INDEX, velocity)
end

function Train:swerve(direction)
    local trainCurrentPos = api.base.positionOf(self.entityList[1])
    local centerPos = trainCurrentPos + directionToVector(direction) * Global.GAME_GRID_SIZE / 2
    local center = api.base.createEntity(1, centerPos, math.Quaternion(0, 0, 0), math.Vector3(1, 1, 1))

    api.setTimeout(function()
        api.base.destroyEntity(center)
    end, Global.GAME_GRID_LOOP_FRAME_COUNT / Global.LOGIC_FPS + 0.5)

    local rotationCount = -(direction - self.currentDirection) % 4
    logger:debug("train id: " .. self.trainId .. ", rotation count: " .. rotationCount)
    api.base.addSurroundMotor(self.entityList[1], center, math.Vector3(0, rotationCount * math.pi / 2, 0),
        Global.GAME_GRID_LOOP_FRAME_COUNT / Global.LOGIC_FPS, true)
end

function Train:reset()
    api.base.setLinearMotorVelocity(self.entityList[1], LINEAR_MOTOR_INDEX, math.Vector3(0, 0, 0))
    api.base.setEntityPosition(self.entityList[1], self.initPosition)
    api.base.stopSurroundMotor(self.entityList[1])
    self.currentDirection = self.initDirection
    self.currentGridPosition = { row = self.initGridPosition.row, col = self.initGridPosition.col }
end

function Train:getCurrentDirection()
    return self.currentDirection
end

function Train:getCurrentGridPosition()
    return self.currentGridPosition
end

function Train:getGroupId()
    return self.trainGroup
end

function Train:getSequenceId()
    return self.sequenceId
end

function Train:runStartMotor()
    local velocity = TRAIN_SPEED * directionToVector(self.initDirection)
    self:addLinearMotor(velocity, INIT_FORWARD_DURATION)
end

function Train:initForward()
    local nextRow = self.initGridPosition.row + self.directionMask[PositionDirectionEnum.BOTTOM] -
        self.directionMask[PositionDirectionEnum.TOP]
    local nextCol = self.initGridPosition.col + self.directionMask[PositionDirectionEnum.RIGHT] -
        self.directionMask[PositionDirectionEnum.LEFT]

    return { row = nextRow, col = nextCol }
end

function Train:fault()

end

return Train
