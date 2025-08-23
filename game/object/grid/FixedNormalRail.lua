-- FixedNormalRail.lua
local Logger            = require "logger.Logger"
local Array             = require "util.Array"
local api               = require "api"
local Common            = require "util.Common"
local GameResource      = require "common.GameResource"
local Global            = require "common.Global"

---@class FixedNormalRail:GridUnit
---@field private initParamData table
---@field private directionMask table
---@field private chiralityMask integer
---@field private gridPosition table
---@field private position Vector3
---@field private levelManager LevelManager
---@field private associatedEntities table
---@field private blocking boolean
---@field private fault boolean
---@field private waiting boolean
---@field private trainForwardData table[]
---@field private startGridUnit boolean
---@field private startTrainInstance Train
local FixedNormalRail   = {}
FixedNormalRail.__index = FixedNormalRail

local logger            = Logger.new("FixedNormalRail")

---Constructor
function FixedNormalRail.new(directionMask, chiralityMask, gridPosition, position, extraData, levelManager)
    local initParamData = {
        directionMask = directionMask,
        chiralityMask = chiralityMask,
        gridPosition = gridPosition,
        extraData = extraData,
        levelManager = levelManager
    }

    local self = setmetatable({
        initParamData = initParamData,
        directionMask = Array.copy(directionMask),
        chiralityMask = chiralityMask,
        gridPosition = { row = gridPosition.row, col = gridPosition.col },
        position = math.Vector3(position.x, position.y, position.z),
        levelManager = levelManager,
        associatedEntities = {},
        blocking = false,
        waiting = false,
        fault = false,
        trainForwardData = {},
        startGridUnit = false,
        startTrainInstance = nil
    }, FixedNormalRail)

    return self
end

--- Check specific direction whether can enter.
---@param enterDirection PositionDirectionEnum
---@return boolean
function FixedNormalRail:checkEnterPermit(enterDirection)
    return self.directionMask[enterDirection] == 1
end

function FixedNormalRail:destroy()
    for key, entity in pairs(self.associatedEntities) do
        api.base.destroyEntity(entity)
    end
end

---@param enterDirection PositionDirectionEnum
---@return table
function FixedNormalRail:forward(enterDirection)
    return Common.gridPositionMove(self.gridPosition.row, self.gridPosition.col, self:forwardDirection(enterDirection))
end

---@param enterDirection PositionDirectionEnum
---@return PositionDirectionEnum
function FixedNormalRail:forwardDirection(enterDirection)
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

function FixedNormalRail:isBlocking()
    return self.blocking
end

function FixedNormalRail:isFault()
    return self.fault
end

function FixedNormalRail:isFixed()
    return true
end

function FixedNormalRail:isBusy()
    return #self.trainForwardData > 0
end

function FixedNormalRail:launch()
    logger:error("This method should not be called in this class, please check the configuration file or level logic.")
    error()
end

function FixedNormalRail:render()
    local zeroDirection = Array.find(self.directionMask, 0)

    local straightRotation = -(zeroDirection % 2) * math.pi / 2
    local straightRailEntity = api.base.createEntity(
        GameResource.RAIL_ENTITY_FIXED_STRAIGHT_PRESET_ID,
        self.position,
        math.Quaternion(0, straightRotation, 0),
        math.Vector3(1, 1, 1)
    )

    self.associatedEntities.straight = straightRailEntity

    local channelCount = Array.countElement(self.directionMask, 1)
    if channelCount == 3 then
        local cornerRotation = 0

        if self.chiralityMask == 0 then
            cornerRotation = (zeroDirection - 1 - 2) % 4 * math.pi / 2
        else
            cornerRotation = (zeroDirection - 1 + 1) % 4 * math.pi / 2
        end

        self.associatedEntities.corner = api.base.createEntity(
            GameResource.RAIL_ENTITY_SINGLE_CORNER_PRESET_ID,
            self.position,
            math.Quaternion(0, cornerRotation, 0),
            math.Vector3(1, 1, 1)
        )
    end
end

function FixedNormalRail:mirror()
    logger:error("This method should not be called in this class, please check the configuration file or level logic.")
    error()
end

---comment
---@param trainInstance Train
---@param enterDirection PositionDirectionEnum
function FixedNormalRail:preEnter(trainInstance, enterDirection)
    local trainForwardData = {
        trainId = trainInstance:getTrainId(),
        trainInstance = trainInstance,
        enterDirection = enterDirection,
        forwardDirection = self:forwardDirection(enterDirection)
    }

    table.insert(self.trainForwardData, trainForwardData)

    logger:debug("Train will enter this grid unit. GridPosition: " ..
        tostring(self.gridPosition) .. ", trainId: " .. trainInstance:getTrainId() .. ".")
end

function FixedNormalRail:onEnter(trainInstance)
    local forwardDataIndex = Array.find(self.trainForwardData, trainInstance, function(arrayElem, specificElem)
        return specificElem:getTrainId() == arrayElem.trainId
    end)

    local forwardData = self.trainForwardData[forwardDataIndex]

    local referencePosition = self.position +
        Common.directionToVector(forwardData.enterDirection) * Global.GAME_GRID_SIZE / 2
    local swerve = forwardData.enterDirection ~= forwardData.forwardDirection

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

function FixedNormalRail:preSignal()

end

function FixedNormalRail:onIntermediate()
    local forwardData = self.trainForwardData[1]
    ---@type Train
    local trainInstance = forwardData.trainInstance

    local swerve = forwardData.enterDirection ~= nil and forwardData.enterDirection ~= forwardData.forwardDirection

    if swerve then
        local referencePosition = self.position +
            Common.directionToVector(forwardData.enterDirection) * Global.GAME_GRID_SIZE / 2
        local swerveMask = Common.ternary(
            (forwardData.enterDirection + 1 - 1) % 4 + 1 == forwardData.forwardDirection, 0, 1)
        trainInstance:intermediateSwerve(referencePosition, Common.directionReverse(forwardData.enterDirection),
            swerveMask)
    else
        trainInstance:straight(self.position, forwardData.forwardDirection)
    end
end

function FixedNormalRail:wait()
    self.waiting = true
end

function FixedNormalRail:onLeave()
    self.trainForwardData = {}
end

function FixedNormalRail:isWaiting()
    return self.waiting
end

function FixedNormalRail:setFault()
    self.fault = true
end

function FixedNormalRail:setLevelManager(levelManager)
    self.levelManager = levelManager
end

---comment
---@param trainInstance Train
function FixedNormalRail:bindInitTrainInstance(trainInstance)
    self.startTrainInstance = trainInstance
    self.startGridUnit = true

    local forwardDirection = trainInstance:initForwardDirection()

    local trainForwardData = {
        trainId = trainInstance:getTrainId(),
        trainInstance = trainInstance,
        enterDirection = nil,
        forwardDirection = forwardDirection
    }

    table.insert(self.trainForwardData, trainForwardData)
end

return FixedNormalRail
