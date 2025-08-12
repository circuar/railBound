local GridUnitClassEnum = require "common.enum.GridUnitClassEnum"
local FixedStraightRail = require "game.object.grid.FixedStraightRail"
local FixedCornerRail   = require "game.object.grid.FixedCornerRail"
local GridUnitFactory = {}
GridUnitFactory.__index = GridUnitFactory

local gridUnitClassMap = {
    [GridUnitClassEnum.RAIL_STRAIGHT_FIXED] = FixedStraightRail,
    [GridUnitClassEnum.RAIL_CORNER_FIXED] = FixedCornerRail,
}

--- Static factory method
---
---@param gridUnitClassType GridUnitClassEnum
---@param directionMask integer[]
---@param chiralityMask integer
function GridUnitFactory.getInstance(gridUnitClassType, directionMask, chiralityMask)
    local gridUnitInstance = gridUnitClassMap[gridUnitClassType].new(directionMask, chiralityMask)
    return gridUnitInstance
end

return GridUnitFactory