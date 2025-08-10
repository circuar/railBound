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

return Common