local api         = require "api"
local SimpleTimer = require "game.core.SimpleTimer"
local Logger      = require "logger.Logger"
local Common      = require "util.Common"



-- inner class
---@class LinearMoverData
---@field velocityX number
---@field velocityY number
---@field velocityZ number
---@field duration number

---@class MoverComponent
---@field bindEntity Unit
---@field bindMoverIndex integer
---@field linearMoverDataMap table<integer, LinearMoverData>
---@field linearMoverTimers table<integer, SimpleTimer>
---@field surroundVelocity table
---@field surroundCenterPosition Vector3
---@field surroundEntity Unit
---@field moverIdCount integer
---@field destroyed boolean
local MoverComponent = {}
MoverComponent.__index = MoverComponent

local logger = Logger.new("MoverComponent")

local SURROUND_CENTER_ENTITY_PRESET_ID = 0

---@param linearMoverDataMap table<integer, LinearMoverData>
local function recalculateLinearVelocity(linearMoverDataMap)
    local x = 0
    local y = 0
    local z = 0

    for moverId, moverData in pairs(linearMoverDataMap) do
        x = x + moverData.velocityX
        y = y + moverData.velocityY
        z = z + moverData.velocityZ
    end

    return math.Vector3(x, y, z)
end

---Constructor
function MoverComponent.new(bindEntity, bindMoverIndex)
    local self = setmetatable({
        bindEntity = bindEntity,
        bindMoverIndex = bindMoverIndex,
        linearMoverDataMap = {},
        linearMoverTimers = {},
        surroundVelocity = { x = 0, y = 0, z = 0 },
        surroundCenterPosition = nil,
        surroundEntity = nil,
        moverIdCount = 0,
    }, MoverComponent)
    return self
end

function MoverComponent:updateLinearVelocity()
    local reloadVelocity = recalculateLinearVelocity(self.linearMoverDataMap)
    api.base.setLinearMotorVelocity(self.bindEntity, self.bindMoverIndex, reloadVelocity, false)
end

function MoverComponent:getBindEntity()
    return self.bindEntity
end

---@param velocity Vector3
---@param duration number
function MoverComponent:addLinearMover(velocity, duration)
    self.moverIdCount = self.moverIdCount + 1
    local moverId = self.moverIdCount

    local stdDuration = duration

    if duration == nil or duration < 0 then
        stdDuration = -1
    end

    local linearMoverData = {
        velocityX = velocity.x,
        velocityY = velocity.y,
        velocityZ = velocity.z,
        duration = stdDuration,
    }

    self.linearMoverDataMap[moverId] = linearMoverData
    self:updateLinearVelocity()

    if stdDuration >= 0 then
        local timer = SimpleTimer.new(stdDuration, false)

        timer:setTask(function()
            timer:stop()
            if self.destroyed then
                return
            end

            self:updateLinearVelocity()
        end)

        self.linearMoverTimers[moverId] = timer
    end
end

function MoverComponent:initSurroundMover(angularVelocity, center, duration, followRotation)
    local centerEntity = nil
    
    
    if self.surroundEntity == nil then
       
        centerEntity = api.base.createEntity(
            SURROUND_CENTER_ENTITY_PRESET_ID,
            center,
            math.Quaternion(0, 0, 0),
            math.Vector3(0, 0, 0)
        )
    else
        logger:error("")
    end

    self.surroundVelocity = { x = angularVelocity.x, y = angularVelocity.y, z = angularVelocity.z }
    self.surroundEntity = centerEntity
    self.surroundCenterPosition = center
    api.base.addSurroundMotor(self.bindEntity, centerEntity, angularVelocity, duration, followRotation)
end

function MoverComponent:setSurroundMoverVelocity(velocity)

end

function MoverComponent:stopSurroundMoverVelocity()

end

function MoverComponent:getSurroundMoverVelocity()
    return math.Vector3(self.surroundVelocity.x, self.surroundVelocity.y, self.surroundVelocity.z)
end

function MoverComponent:removeLinearMover(index)

end

function MoverComponent:destroy()

end

return MoverComponent
