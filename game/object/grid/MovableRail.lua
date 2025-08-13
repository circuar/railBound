---@class MovableRail:GridUnit
local MovableRail = {}
MovableRail.__index = MovableRail

local MAX_CHANNEL = 3

---Constructor
function MovableRail.new()
    local self = setmetatable({
        directionMask = { 0, 1, 0, 1 },
        chiralityMask = 1,
        associatedEntityList = {

        }
    }, MovableRail)
    return self
end



function MovableRail:forward()
    
end

function MovableRail:mirror()
    
end

return MovableRail
