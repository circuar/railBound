local api = require "api"
local SimpleTimer = require "game.core.SimpleTimer"
local Logger = require "logger.Logger"

-- inner class
---@class LinearMoverData
---@field velocityX number
---@field velocityY number
---@field velocityZ number
---@field duration number

---@class LinearMoverComponent
---@field bindEntity Unit
---@field linearMoverDataMap table<integer, LinearMoverData>
---@field linearMoverTimers table<integer, SimpleTimer>
---@field moverIdCount integer
---@field destroyed boolean
local LinearMoverComponent = {}
LinearMoverComponent.__index = LinearMoverComponent

local logger = Logger.new("LinearMoverComponent")

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
function LinearMoverComponent.new(bindEntity)
    local self = setmetatable({
        bindEntity = bindEntity,
        linearMoverDataMap = {},
        linearMoverTimers = {},
        moverIdCount = 0,
    }, LinearMoverComponent)
    return self
end

function LinearMoverComponent:updateLinearVelocity()
    local reloadVelocity = recalculateLinearVelocity(self.linearMoverDataMap)
    api.base.setLinearVelocity(self.bindEntity, reloadVelocity)
end

function LinearMoverComponent:getBindEntity()
    return self.bindEntity
end

---@param velocity Vector3
---@param duration number
function LinearMoverComponent:addLinearMover(velocity, duration)
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
            self.linearMoverDataMap[moverId] = nil
            self:updateLinearVelocity()
        end)

        self.linearMoverTimers[moverId] = timer
        timer:run()
    end

    return moverId
end

function LinearMoverComponent:resetMoverVelocity(index, velocity)
    local velocityData = self.linearMoverDataMap[index]

    if velocityData == nil then
        logger:error("The designated mover does not exist, moverId: " .. index)
    end

    velocityData.velocityX = velocity.x
    velocityData.velocityY = velocity.y
    velocityData.velocityZ = velocity.z

    self:updateLinearVelocity()
end

function LinearMoverComponent:removeLinearMover(index)
    self.linearMoverDataMap[index] = nil

    if self.linearMoverTimers[index] ~= nil then
        self.linearMoverTimers[index]:stop()
        self.linearMoverTimers[index] = nil
    end

    self:updateLinearVelocity()
end

function LinearMoverComponent:removeAllLinearMover()
    for moverId, timer in pairs(self.linearMoverTimers) do
        timer:stop()
    end
    api.base.setLinearVelocity(self.bindEntity, math.Vector3(0, 0, 0))
    self.linearMoverTimers = {}
    self.linearMoverDataMap = {}
end

return LinearMoverComponent
