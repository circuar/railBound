local PositionDirectionEnum = require "common.enum.PositionDirectionEnum"
local Logger                = require "logger.Logger"
local api                   = require "api"


---@class FinalLinkedRail:GridUnit
---@field position Vector3
---@field finalLinkedData table
---@field trainConnectSpaceLength number
---@field trainGroupId integer
---@field enterTrainInstanceArray Train[]
---@field spaceLengthPointer number
---@field levelManager LevelManager
local FinalLinkedRail   = {}
FinalLinkedRail.__index = FinalLinkedRail

local logger            = Logger.new("FinalLinkedRail")


function FinalLinkedRail.new(directionMask, chiralityMask, position, extraData, levelManager)
    local self = setmetatable({
        position = position,
        finalLinkedData = extraData,
        trainConnectSpaceLength = extraData.trainSpaceLength,
        trainGroupId = extraData.group,
        enterTrainInstanceArray = {},
        spaceLengthPointer = extraData.trainSpaceLength,
        levelManager = levelManager
    }, FinalLinkedRail)
    return self
end

function FinalLinkedRail:checkEnterPermit(enterDirection)
    return enterDirection == PositionDirectionEnum.LEFT
end

function FinalLinkedRail:fault()
    logger:error("This method is usually not called, please check that the relevant logic is correct.")
    error()
end

function FinalLinkedRail:isFault()
    return false
end

function FinalLinkedRail:destroy()

end

function FinalLinkedRail:forward(enterChannelMask)
    return { 0, 0, 0, 0 }
end

function FinalLinkedRail:isFixed()
    return true
end

---comment
---@param trainInstance Train
function FinalLinkedRail:onEnter(trainInstance)
    table.insert(self.enterTrainInstanceArray, trainInstance)
    local collisionDelay = self.spaceLengthPointer / trainInstance.getTrainSpeed()
    if trainInstance:getGroupId() ~= self.trainGroupId then
        api.setTimeout(function()
            trainInstance:fault()
            self.levelManager:trainFailedSignal(trainInstance.trainId)
        end, collisionDelay)
    end
    for sequenceIndex, train in ipairs(self.enterTrainInstanceArray) do

    end
    self.spaceLengthPointer = self.spaceLengthPointer - trainInstance:getTrainLength()
end

function FinalLinkedRail:onLeave(trainInstance)

end

function FinalLinkedRail:reset()

end

function FinalLinkedRail:launch()

end

return FinalLinkedRail
