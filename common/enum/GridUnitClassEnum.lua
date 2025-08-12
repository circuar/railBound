---@alias GridUnitClassEnum integer
local GridUnitClassEnum = {
    EMPTY = 0,
    
    RAIL_MOVABLE = 1,
    RAIL_NORMAL_FIXED = 2,
    RAIL_CORNER_FIXED = 4,
    RAIL_THREE_WAY_FIXED = 6,

    BARRIER_STAKE = 7,
    BARRIER_STONE = 8,
}

return GridUnitClassEnum