local GridUnitClassEnum = require "common.enum.GridUnitClassEnum"
local FixedNormalRail = require "game.object.grid.FixedNormalRail"
local Logger = require "logger.Logger"
local FinalLinkedRail = require "game.object.grid.FinalLinkedRail"

---@class GridUnitFactory
local GridUnitFactory = {}
GridUnitFactory.__index = GridUnitFactory

local logger = Logger.new("GridUnitFactory")

local gridUnitClassMap = {
    [GridUnitClassEnum.RAIL_NORMAL_FIXED] = FixedNormalRail,
    [GridUnitClassEnum.RAIL_FINAL] = FinalLinkedRail

}


---@param gridUnitClassType GridUnitClassEnum
---@param directionMask integer[]
---@param chiralityMask integer
---@param extraData table?
---@param position Vector3
function GridUnitFactory.getInstance(
    gridUnitClassType,
    directionMask,
    chiralityMask,
    gridPosition,
    position,
    extraData,
    levelManager
)
    logger:debug("Creating grid unit of type: " .. gridUnitClassType)
    local gridUnitInstance = gridUnitClassMap[gridUnitClassType].new(
        directionMask,
        chiralityMask,
        gridPosition,
        position,
        extraData,
        levelManager
    )
    return gridUnitInstance
end

return GridUnitFactory
