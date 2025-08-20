-- FixedNormalRail.lua
local Logger                = require "logger.Logger"
local Array                 = require "util.Array"
local api                   = require "api"
local Common                = require "util.Common"
local PositionDirectionEnum = require "common.enum.PositionDirectionEnum"
local GameResource          = require "common.GameResource"

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
---@field private trainList Train[]
---@field private trainForwardData table[]
local FixedNormalRail       = {}
FixedNormalRail.__index     = FixedNormalRail

local logger                = Logger.new("FixedNormalRail")

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
        fault = false,
        trainList = {},
        trainForwardData = {}
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
    return #self.trainList > 0
end

function FixedNormalRail:launch()
    logger:error("This method should not be called in this class, please check the configuration file or level logic.")
    error()
end

function FixedNormalRail:render()
    local zeroDirection = Array.find(self.directionMask, 0)

    local straightRotation = -(zeroDirection % 2) * math.pi / 2
    local straightRailEntity = api.base.createEntity(
        GameResource.GAME_RAIL_ENTITY_FIXED_STRAIGHT_PRESET_ID,
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
        print("===========chiralityMask: " .. self.chiralityMask)
        print(cornerRotation)
        self.associatedEntities.corner = api.base.createEntity(
            GameResource.GAME_RAIL_ENTITY_CORNER_PRESET_ID,
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

function FixedNormalRail:onEnter(trainInstance, enterDirection)
    table.insert(self.trainList, trainInstance)
    local forwardData = {
        enterDirection = enterDirection,
        leaveDirection = self:forwardDirection(enterDirection),
        wait = false
    }
    table.insert(self.trainForwardData, forwardData)
end

function FixedNormalRail:wait(trainInstance, enterDirection)
    table.insert(self.trainList, trainInstance)
    local forwardData = {
        enterDirection = enterDirection,
        wait = true
    }
end

function FixedNormalRail:setLevelManager(levelManager)
    self.levelManager = levelManager
end

return FixedNormalRail
