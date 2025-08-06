local GameOperation = {}
GameOperation.__index = GameOperation

function GameOperation.new(before, after)
    local self = setmetatable({ beforeStatus = before, afterStatus = after }, GameOperation)
    return self
end

function GameOperation:rollback()
    
end

return GameOperation