local api = require "api"
---@class Train
---@field trainId integer
---@field trainGroup integer
---@field color string
---@field initPosition Vector3
---@field initTowards AxisDirectionEnum
---@field entity Unit
local Train = {}
Train.__index = Train

---constructor
---@param trainId integer
---@param position Vector3
---@param towards AxisDirectionEnum
---@return Train
function Train.new(trainId, trainGroup, color, position, towards)
    local self = setmetatable({
        trainId = trainId,
        trainGroup = trainGroup,
        color = color,
        initPosition = position,
        initTowards = towards,
        entity = nil
    }, Train)

    return self
end

function Train:setPosition(position)
end
function Train:addVelocity(velocity, duration)
    api.base.addLinearMotor(self.entity, velocity, duration, false)
end
function Train:swerve(direction, duration)

end

function Train:reset()
     
end



return Train