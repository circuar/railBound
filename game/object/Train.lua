local Array   = require "util.Array"
local api     = require "api"
local Common  = require "util.Common"

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
---@field private entities table
local Train   = {}
Train.__index = Train

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
        mediacy = false,
        mediacyDirection = nil,
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

---@param distance number
---@param duration number
---@param startPosition Vector3?
function Train:straight(distance, duration, startPosition)
    if startPosition then
        api.base.setEntityPosition(self.entities.base, startPosition)
    end
end

function Train:swerve(angle, duration)

end

function Train:halfStraight()

end

function Train:halfSwerve()

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
