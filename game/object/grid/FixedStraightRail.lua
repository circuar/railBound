local GridUnit = require "game.interface.GridUnit"
local Logger = require "logger.Logger"
local Global = require "common.Global"
local PositionDirectionEnum = require "common.enum.PositionDirectionEnum"

---@class FixedStraightRail:GridUnit
---@field private direction integer
local FixedStraightRail = {}
FixedStraightRail.__index = FixedStraightRail
setmetatable(FixedStraightRail, GridUnit)

local logger = Logger.new("FixedStraightRail")

---constructor
function FixedStraightRail.new(directionMask)
    local self = {}


    local topBit = directionMask[1]
    local rightBit = directionMask[2]
    local bottomBit = directionMask[3]
    local leftBit = directionMask[4]

    if topBit and bottomBit then
        self.direction = 0
    elseif leftBit and rightBit then
        self.direction = 1
    else
        logger:error("invalid directionMask construct param: " .. topBit .. " " .. rightBit ..
            " " .. bottomBit .. " " .. leftBit)
    end

    setmetatable(self, FixedStraightRail)
    return self
end

function FixedStraightRail:createAssociatedEntity()

end

function FixedStraightRail:destroyAssociatedEntity()
    
end

---Check if the direction is accessible
---@param enterDirection PositionDirectionEnum
function FixedStraightRail:checkEnterPermit(enterDirection)
    if self.direction == 0 then
        return enterDirection == PositionDirectionEnum.TOP or enterDirection == PositionDirectionEnum.BOTTOM
    else
        return enterDirection == PositionDirectionEnum.LEFT or enterDirection == PositionDirectionEnum.RIGHT
    end
end

---@param enterDirection PositionDirectionEnum
---@return PositionDirectionEnum
function FixedStraightRail:forward(enterDirection)
    if self.direction == 1 then
        if enterDirection == PositionDirectionEnum.LEFT then
            return PositionDirectionEnum.RIGHT
        else
            return PositionDirectionEnum.LEFT
        end
    else
        if enterDirection == PositionDirectionEnum.TOP then
            return PositionDirectionEnum.BOTTOM
        else
            return PositionDirectionEnum.TOP
        end
    end
end

---train enter
---@param trainInstance Train
function FixedStraightRail:onEnter(trainInstance)
    local gridDuration = Global.LOGIC_FRAME_INTERVAL * Global.GAME_GRID_TRAIN_FRAME_COUNT
    local gridSpeed = Global.GAME_GRID_SIZE / gridDuration
    if self.direction == 0 then
        trainInstance:addVelocity(math.Vector3(0, 0, gridSpeed), gridDuration)
    else
        trainInstance:addVelocity(math.Vector3(gridSpeed, 0, 0), gridDuration)
    end
end

return FixedStraightRail
