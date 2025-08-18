local PositionDirectionEnum = require "common.enum.PositionDirectionEnum"
local Common = {}
Common.__index = Common

---Safe ternary operator.
---@param condition boolean|nil
---@param valueIfTrue any
---@param valueIfFalse any
---@return any
function Common.ternary(condition, valueIfTrue, valueIfFalse)
    if condition then
        return valueIfTrue
    else
        return valueIfFalse
    end
end

---Reverse position direction enum.
---@param positionDirection PositionDirectionEnum
function Common.directionReverse(positionDirection)
    if positionDirection == PositionDirectionEnum.CENTER then
        return PositionDirectionEnum.CENTER
    end

    return (positionDirection - 1 + 2) % 4 + 1
end

--- Move the grid coordinates in the specified direction.
---@param row integer
---@param col integer
---@param direction PositionDirectionEnum
---@return table
function Common.gridPositionMove(row, col, direction)
    if direction == PositionDirectionEnum.TOP then
        return {row = row -1 , col = col}
    elseif direction == PositionDirectionEnum.RIGHT then
        return {row = row, col = col + 1}
    elseif direction == PositionDirectionEnum.BOTTOM then
        return {row = row + 1, col = col}
    elseif direction == PositionDirectionEnum.LEFT then
        return {row = row, col = col - 1}
    else
        return {row = row, col = col}
    end
end


return Common
