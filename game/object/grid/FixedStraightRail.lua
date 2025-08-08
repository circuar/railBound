local GridUnit = require "game.interface.GridUnit"
local Logger = require "logger.Logger"

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

function FixedStraightRail:forward(enterChannelMask)
    if self.direction == 1 then
        if enterChannelMask[2] == 1 then
            return { 0, 0, 0, 1 }
        elseif enterChannelMask[4] == 1 then
            return { 0, 1, 0, 0 }
        else
            return { 0, 0, 0, 0 }
        end
    else
        if enterChannelMask[1] == 1 then
            return { 0, 0, 1, 0 }
        elseif enterChannelMask[3] then
            return { 1, 0, 0, 0 }
        else
            return { 0, 0, 0, 0 }
        end
    end
end

function FixedStraightRail:onEnter(trainInstance)

end

return FixedStraightRail
