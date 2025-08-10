local Vector = {}
Vector.__index = Vector


---calculate the distance between two points
---@param pos1 Vector3
---@param pos2 Vector3
---@return number
function Vector.distanceBetween(pos1, pos2)
    return (pos2 - pos1):length()
end

return Vector