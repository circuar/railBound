local GridUnitClassEnum = require "common.enum.GridUnitClassEnum"
local FixedNormalRail = require "game.object.grid.FixedNormalRail"
local Logger = require "logger.Logger"

---@class GridUnitFactory
local GridUnitFactory = {}
GridUnitFactory.__index = GridUnitFactory

local logger = Logger.new("GridUnitFactory")

local gridUnitClassMap = {
    [GridUnitClassEnum.RAIL_NORMAL_FIXED] = FixedNormalRail,
}


---@param gridUnitClassType GridUnitClassEnum
---@param directionMask integer[]
---@param chiralityMask integer
---@param position Vector3
function GridUnitFactory.getInstance(gridUnitClassType, directionMask, chiralityMask, position)
    logger:debug("Creating grid unit of type: " .. gridUnitClassType)
    local gridUnitInstance = gridUnitClassMap[gridUnitClassType].new(directionMask, chiralityMask, position)
    return gridUnitInstance
end

return GridUnitFactory
