local Array = require "util.Array"


---@class FixedCornerRail:GridUnit
local FixedCornerRail = {}
FixedCornerRail.__index = FixedCornerRail

local function rotationCalc(directionMask)
    -- The preset created uses the top-right direction by default, and this
    -- function uses this direction to rotate operations.
    --
    -- ^ y        => PositionDirectionEnum.TOP
    -- |
    -- |----> x   => PositionDirectionEnum.RIGHT
    --
    -- rotationCalc({ 1, 0, 0, 1 }) = 4.7123
    -- rotationCalc({ 1, 1, 0, 0 }) = 0.0000
    -- rotationCalc({ 0, 1, 1, 0 }) = 1.5707
    -- rotationCalc({ 0, 0, 1, 1 }) = 3.1415
    local rotateAngle = 0
    local maskBitSearch = Array.find(directionMask, 1)
    if maskBitSearch == 1 and directionMask[#directionMask] == 1 then
        return 3 * math.pi / 2
    end
    return (maskBitSearch - 1) * math.pi / 2
end

---Constructor
function FixedCornerRail.new(directionMask, chiralityMask)
    local self = setmetatable({
        directionMask = directionMask
    }, FixedCornerRail)
   return self
end

function FixedCornerRail:forward(enterDirection)
    
end




return FixedCornerRail