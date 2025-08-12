local Array        = require "util.Array"
local Logger       = require "logger.Logger"
local api          = require "api"
local GameResource = require "common.GameResource"


---@class FixedNormalRail:GridUnit
---@field private directionMask integer[]
---@field private chiralityMask integer
---@field private channelCount integer
---@field private position Vector3
---@field private entityList Unit[]
local FixedNormalRail = {}
FixedNormalRail.__index = FixedNormalRail

local logger = Logger.new("FixedNormalRail")


local function rotationCornerRailCalc(directionMask)
    -- The preset created uses the top-right direction by default, and this
    -- function uses this direction to rotate operations.
    --
    -- ▲ y+         => PositionDirectionEnum.TOP
    -- │
    -- │
    -- └────► x+    => PositionDirectionEnum.RIGHT
    --
    -- rotationCalc({ 1, 0, 0, 1 }) = 4.7123
    -- rotationCalc({ 1, 1, 0, 0 }) = 0.0000
    -- rotationCalc({ 0, 1, 1, 0 }) = 1.5707
    -- rotationCalc({ 0, 0, 1, 1 }) = 3.1415
    local rotateAngle = 0
    local maskBitSearch = Array.find(directionMask, 1)
    if maskBitSearch == 1 and directionMask[#directionMask] == 1 then
        return 3 * math.pi / 2
    end
    return (maskBitSearch - 1) * math.pi / 2
end


---TODO init render grid unit


---Constructor
function FixedNormalRail.new(directionMask, chiralityMask, position)
    local channelCount = Array.countElement(directionMask, 1)
    local self = setmetatable({
        directionMask = Array.copy(directionMask),
        chiralityMask = chiralityMask,
        channelCount = channelCount,
        position = position
    }, FixedNormalRail)
    return self
end

---@param enterDirection PositionDirectionEnum
function FixedNormalRail:checkEnterPermit(enterDirection)
    return self.directionMask[enterDirection] == 1
end

---@return integer[]
function FixedNormalRail:getDirectionMask()
    return self.directionMask
end

---@return boolean
function FixedNormalRail:isFixed()
    return true
end

function FixedNormalRail:mirror()
    logger:error("This class usually doesn't support the mirror() method, " ..
        "check if the function is called correctly.")
    error()
end

function FixedNormalRail:onEnter(trainInstance)

end

function FixedNormalRail:reset()

end

function FixedNormalRail:destroy()
    logger:debug("Destroy component entity.")
    for index, value in ipairs(self.entityList) do
        api.base.destroyEntity(value)
    end
end

---comment
---@param enterDirection PositionDirectionEnum
---@return integer
function FixedNormalRail:forward(enterDirection)
    if self.channelCount == 2 then
        for index, value in ipairs(self.directionMask) do
            if value == 1 and index ~= enterDirection then
                return index
            end
        end
    else
        if self.directionMask[(enterDirection) % 4 + 1] == 1 and self.directionMask[(enterDirection - 2) % 4 + 1] == 1 then
            -- At this time, if the train enter from the vertical direction,
            -- need to judge which direction to exit according to the
            -- chiralityMask sign.
            --  ┌─────────┐
            --  ├─────────┤
            --  ├────┐    │
            --  │    │    │
            --  └────┴────┘
            --       ▲
            --       │
            if self.chiralityMask == 0 then
                -- left
                return (enterDirection) % 4 + 1
            else
                -- right
                return (enterDirection - 2) % 4 + 1
            end
        elseif self.directionMask[(enterDirection) % 4 + 1] == 1 then
            -- right enter
            if self.chiralityMask == 0 then
                return (enterDirection + 1) % 4 + 1
            else
                return (enterDirection) % 4 + 1
            end
        else
            -- left enter
            if self.chiralityMask == 0 then
                return (enterDirection - 2) % 4 + 1
            else
                return (enterDirection - 3) % 4 + 1
            end
        end
    end
    -- Usually not performed.
    return 1
end

return FixedNormalRail
