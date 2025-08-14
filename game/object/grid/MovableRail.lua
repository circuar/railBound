local Array = require "util.Array"
local Common = require "util.Common"
---@class MovableRail:GridUnit
local MovableRail = {}
MovableRail.__index = MovableRail

local MAX_CHANNEL = 3

---Constructor
function MovableRail.new(directionMask, chiralityMask, position, extraData, levelManager)
    local directionMaskCopy = Common.ternary(directionMask == nil, { 0, 1, 0, 1 }, Array.copy(directionMask))
    local self = setmetatable({
        directionMask = directionMaskCopy,
        chiralityMask = chiralityMask or 1,
        position = position,
        associatedEntityList = {

        },
        levelManager = levelManager
    }, MovableRail)
    return self
end

function MovableRail:forward()

end

function MovableRail:mirror()

end

return MovableRail
