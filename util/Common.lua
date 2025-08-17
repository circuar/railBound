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


return Common
