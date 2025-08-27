local Common = require "util.Common"
local Vector = {}
Vector.__index = Vector


---calculate the distance between two points
---@param pos1 Vector3
---@param pos2 Vector3
---@return number
function Vector.distanceBetween(pos1, pos2)
    return (pos2 - pos1):length()
end

function Vector.getVectorOrthogonalDirection(vector)
    if vector.x == 0 and vector.z == 0 then
        return 5
    end

    if math.abs(vector.x) >= math.abs(vector.z) then
        return Common.ternary(vector.x >= 0, 2, 4)
    else
        return Common.ternary(vector.z >= 0, 1, 3)
    end
end

return Vector
