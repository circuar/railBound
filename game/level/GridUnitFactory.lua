local GridUnitClassEnum = require "common.enum.GridUnitClassEnum"
local FixedNormalRail = require "game.object.grid.FixedNormalRail"
local FixedCornerRail   = require "game.object.grid.FixedNormalRail"
local GridUnitFactory = {}
GridUnitFactory.__index = GridUnitFactory

local gridUnitClassMap = {
    [GridUnitClassEnum.RAIL_NORMAL_FIXED] = FixedNormalRail,
    [GridUnitClassEnum.RAIL_CORNER_FIXED] = FixedCornerRail,
}

--- Static factory method
---
---@param gridUnitClassType GridUnitClassEnum
---@param directionMask integer[]
---@param chiralityMask integer
---@param position Vector3
function GridUnitFactory.getInstance(gridUnitClassType, directionMask, chiralityMask, position)
    local gridUnitInstance = gridUnitClassMap[gridUnitClassType].new(directionMask, chiralityMask, position)
    return gridUnitInstance
end

return GridUnitFactory