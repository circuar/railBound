local Logger = require "logger.Logger"
local Array = require "util.Array"
local api = require "api"
local Common = require "util.Common"
local Global = require "common.Global"

---@class MovableRail:GridUnit
---@field initParamData table
---@field position Vector3
---@field directionMask integer[]
---@field associatedEntities table
---@field gridPosition table
---@field chiralityMask integer
---@field trainList Train[]
---@field blocking boolean
---@field fault boolean
---@field waiting boolean
---@field trainForwardData table
---@field levelManager LevelManager
local MovableRail = {}
MovableRail.__index = MovableRail

local logger = Logger.new("MovableRail")

---Constructor
---@param directionMask integer[]
---@param chiralityMask integer
---@param gridPosition table
---@param position Vector3
---@param extraData table
---@param levelManager LevelManager
function MovableRail.new(directionMask, chiralityMask, gridPosition, position, extraData, levelManager)
    local initParamData = {
        directionMask = directionMask,
        chiralityMask = chiralityMask,
        gridPosition = gridPosition,
        position = position,
        extraData = extraData,
        levelManager = levelManager
    }

    local self = setmetatable({
        initParamData = initParamData,
        position = math.Vector3(position.x, position.y, position.z),
        directionMask = Array.copy(directionMask),
        gridPosition = { row = gridPosition.row, col = gridPosition.col },
        chiralityMask = chiralityMask,
        trainList = {},
        blocking = false,
        fault = false,
        waiting = false,
        trainForwardData = {}
    }, MovableRail)
    return self
end

function MovableRail:bindInitTrainInstance()
    logger:error("This method should not be called in this class, please check the configuration file or level logic.")
    error()
end

function MovableRail:checkEnterPermit(enterDirection)
    return self.directionMask[enterDirection] == 1
end

function MovableRail:destroy()
    for key, entity in pairs(self.associatedEntities) do
        api.base.destroyEntity(entity)
    end
end

function MovableRail:forward(enterDirection)
    return Common.gridPositionMove(self.gridPosition.row, self.gridPosition.col, self:forwardDirection(enterDirection))
end

---@param enterDirection PositionDirectionEnum
---@return PositionDirectionEnum
function MovableRail:forwardDirection(enterDirection)
    local channelCount = Array.countElement(self.directionMask, 1)
    local forwardDirection = 0

    if channelCount == 2 then
        for index, value in ipairs(self.directionMask) do
            if value == 1 and index ~= enterDirection then
                forwardDirection = index
            end
        end
    else
        local zeroDirection = Array.find(self.directionMask, 0)
        local verticalDirection = (zeroDirection - 1 + 2) % 4 + 1

        if enterDirection == verticalDirection then
            if self.chiralityMask == 0 then
                forwardDirection = (enterDirection - 1 + 1) % 4 + 1
            else
                forwardDirection = (enterDirection - 1 - 1) % 4 + 1
            end
        else
            local relativeDirection = Common.ternary(
                (verticalDirection - 1 + 1) % 4 + 1 == enterDirection,
                0,
                1
            )

            if relativeDirection == self.chiralityMask then
                return verticalDirection
            else
                return (enterDirection - 1 + 2) % 4 + 1
            end
        end
    end

    return forwardDirection
end

function MovableRail:getDirectionMask()
    return Array.copy(self.directionMask)
end

function MovableRail:getSingleHoldingTrain()
    return self.trainList[1]
end

function MovableRail:isBlocking()
    return self.blocking
end

function MovableRail:isBusy()
    return #self.trainList > 0
end

function MovableRail:isFault()
    return self.fault
end

function MovableRail:isFixed()
    return false
end

function MovableRail:isWaiting()
    return self.waiting
end

function MovableRail:launch()
    logger:error("This method should not be called in this class, please check the configuration file or level logic.")
    error()
end

function MovableRail:onEnter(trainInstance)
    local forwardDataIndex = Array.find(self.trainForwardData, trainInstance, function(arrayElem, specificElem)
        return specificElem:getTrainId() == arrayElem.trainId
    end)

    local forwardData = self.trainForwardData[forwardDataIndex]

    local referencePosition = self.position +
        Common.directionToVector(forwardData.enterDirection) * Global.GAME_GRID_SIZE / 2
    local swerve = Common.directionReverse(forwardData.enterDirection) ~= forwardData.forwardDirection

    if #self.trainForwardData > 1 then
        self.fault = true
        self.levelManager:trainFailedSignal(trainInstance)

        if swerve then
            local swerveMask = Common.ternary(
                (forwardData.enterDirection + 1 - 1) % 4 + 1 == forwardData.forwardDirection, 0, 1)
            trainInstance:swerveFault(referencePosition, Common.directionReverse(forwardData.enterDirection), swerveMask)
        else
            trainInstance:straightFault(referencePosition, Common.directionReverse(forwardData.enterDirection))
        end
    else
        if swerve then
            local swerveMask = Common.ternary(
                (forwardData.enterDirection + 1 - 1) % 4 + 1 == forwardData.forwardDirection, 0, 1)
            trainInstance:swerve(referencePosition, Common.directionReverse(forwardData.enterDirection), swerveMask)
        else
            trainInstance:straight(referencePosition, Common.directionReverse(forwardData.enterDirection))
        end
    end
end

function MovableRail:onIntermediate()
    
end

function MovableRail:onLeave()

end

function MovableRail:preEnter(trainInstance, enterDirection)
    
end

function MovableRail:preSignal()
    
end

function MovableRail:render()

end

function MovableRail:reset()
    
end

function MovableRail:setFault()

end

function MovableRail:setLevelManager(levelManager)
    self.levelManager = levelManager
end

return MovableRail
