local Array = require "common.Array"
local GameResource = require "common.GameResource"
local api = require "api"
local Logger = require "logger.Logger"

---@class TrainStartRail:GridUnit
---@field private directionMask integer[]
---@field private channelCount integer
---@field private position Vector3
---@field private entityList Unit[]
---@field private initialTrainId integer
---@field private initialTrainInstance Train
---@field private runningTrainInstanceList Train[]
---@field private fault boolean
---@field private levelManager LevelManager
local TrainStartRail = {}
TrainStartRail.__index = TrainStartRail

local logger = Logger.new("TrainStartRail")


local function renderEntity(directionMask, position)
    local directionFlag = Array.find(directionMask, 1)
    local entityList = {}
    -- create straight rail entity
    if directionFlag == 1 then
        entityList[1] = api.base.createEntity(
            GameResource.GAME_RAIL_ENTITY_FIXED_STRAIGHT_PRESET_ID,
            position,
            math.Quaternion(0, 0, 0),
            math.Vector3(1, 1, 1)
        )
    else
        entityList[1] = api.base.createEntity(
            GameResource.GAME_RAIL_ENTITY_FIXED_STRAIGHT_PRESET_ID,
            position,
            math.Quaternion(0, math.pi / 2, 0),
            math.Vector3(1, 1, 1)
        )
    end
    return entityList
end

function TrainStartRail.new(directionMask, chiralityMask, position, extraData, levelManager)
    local self = setmetatable({
        directionMask = directionMask,
        channelCount = 2,
        position = position,
        entityList = {},
        initialTrainId = nil,
        initialTrainInstance = nil,
        runningTrainInstanceList = {},
        fault = false,
        levelManager = levelManager
    }, TrainStartRail)

    self.entityList[1] = renderEntity(self.directionMask, self.position)

    return self
end

function TrainStartRail:setTrain(trainId, trainInstance)
    self.initialTrainId = trainId
    self.initialTrainInstance = trainInstance
    self.runningTrainInstanceList[1] = trainInstance
end

---Override
---@param enterDirection PositionDirectionEnum
function TrainStartRail:checkEnterPermit(enterDirection)
    return self.directionMask[enterDirection] == 1
end

-- ---Override
-- ---@return integer[]
-- function TrainStartRail:getDirectionMask()
--     return self.directionMask
-- end

---Override
---@return boolean
function TrainStartRail:isFixed()
    return true
end

---Override
function TrainStartRail:onEnter(trainInstance)
    table.insert(self.runningTrainInstanceList, trainInstance)
    if #self.runningTrainInstanceList then
        -- Because onEnter() is usually called at the same time on the timeline,
        -- if onEnter() of the same object is called twice, it means that the
        -- direction of Train entry must be opposite, and isFault will be
        -- detected in the next onEnter loop, and if the return value is false,
        -- it will not enter, so here only the number of train instances held
        -- needs to be judged.
        self.fault = true
    end
end

function TrainStartRail:onLeave(trainInstance)
    Array.removeElement(self.runningTrainInstanceList, trainInstance)
end

function TrainStartRail:forward(enterDirection)
    return (enterDirection - 1 + 2) % 4 + 1
end

function TrainStartRail:reset()
end

function TrainStartRail:destroy()

end

function TrainStartRail:isFault()
    return self.fault
end

return TrainStartRail
