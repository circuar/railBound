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
---@field private levelManager LevelManager
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

function FixedNormalRail:renderEntity()
    local zeroDirection = Array.find(self.directionMask, 0)
    local entityList = {}
    -- create straight rail entity
    if zeroDirection % 2 == 0 then
        entityList[1] = api.base.createEntity(
            GameResource.GAME_RAIL_ENTITY_FIXED_STRAIGHT_PRESET_ID,
            self.position,
            math.Quaternion(0, 0, 0),
            math.Vector3(1, 1, 1)
        )
    else
        entityList[1] = api.base.createEntity(
            GameResource.GAME_RAIL_ENTITY_FIXED_STRAIGHT_PRESET_ID,
            self.position,
            math.Quaternion(0, math.pi / 2, 0),
            math.Vector3(1, 1, 1)
        )
    end


    if self.channelCount == 3 then
        entityList[2] = api.base.createEntity(
            GameResource.GAME_RAIL_ENTITY_CORNER_PRESET_ID,
            self.position,
            math.Quaternion(0, rotationCornerRailCalc(self.directionMask), 0),
            math.Vector3(1, 1, 1)
        )
    end
    return entityList
end

---Constructor
function FixedNormalRail.new(directionMask, chiralityMask, position, extraData, levelManager)
    local channelCount = Array.countElement(directionMask, 1)
    local self = setmetatable({
        directionMask = Array.copy(directionMask),
        chiralityMask = chiralityMask or 1,
        channelCount = channelCount,
        position = position,
        entityList = {},
        levelManager = levelManager
    }, FixedNormalRail)

    logger:debug("Create FixedNormalRail, directionMask = " ..
        table.concat(self.directionMask, ", ") .. ", chiralityMask = " .. self.chiralityMask)
    self.entityList = self:renderEntity()

    return self
end

---Override
---@param enterDirection PositionDirectionEnum
function FixedNormalRail:checkEnterPermit(enterDirection)
    return self.directionMask[enterDirection] == 1
end

-- ---Override
-- ---@return integer[]
-- function FixedNormalRail:getDirectionMask()
--     return self.directionMask
-- end

---Override
---@return boolean
function FixedNormalRail:isFixed()
    return true
end

---Override
function FixedNormalRail:isFault()

end



---Override
function FixedNormalRail:onEnter(trainInstance)

end

function FixedNormalRail:onLeave(trainInstance)

end

---Override
function FixedNormalRail:reset()

end

---Override
function FixedNormalRail:destroy()
    logger:debug("Destroy component entity.")
    for index, value in ipairs(self.entityList) do
        api.base.destroyEntity(value)
    end
end

---Override
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
