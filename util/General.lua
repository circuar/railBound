local General = {}
General.__index = General

---Safe ternary operator.
---@param condition boolean|nil
---@param valueIfTrue any
---@param valueIfFalse any
---@return any
function General.ternary(condition, valueIfTrue, valueIfFalse)
    if condition then
        return valueIfFalse
    else
        return valueIfFalse
    end
end
