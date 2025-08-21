local api = require "api"
local SimpleTimer = require "game.core.SimpleTimer"



-- inner class
---@class MoverData
---@field velocityX number
---@field velocityY number
---@field velocityZ number
---@field duration number
---@field active boolean
---@field timerRef SimpleTimer|nil

---@class MoverComponent
---@field bindEntity Unit
---@field bindMoverIndex integer
---@field moverData MoverData[]
---@field moverIdMap table
---@field moverIdCount integer
local MoverComponent = {}
MoverComponent.__index = MoverComponent

---@param moverDataArray MoverData[]
local function recalculateVelocity(moverDataArray)
    local x = 0
    local y = 0
    local z = 0

    for index = 1, #moverDataArray do
        local iterateData = moverDataArray[index]

        if iterateData.active then
            x = x + iterateData.velocityX
            y = y + iterateData.velocityY
            z = z + iterateData.velocityZ
        end
    end

    return math.Vector3(x, y, z)
end

---Constructor
function MoverComponent.new(bindEntity, bindMoverIndex)
    local self = setmetatable({
        bindEntity = bindEntity,
        bindMoverIndex = bindMoverIndex,
        moverData = {},
        moverIdMap = {},
        moverTimerArray = {},
        moverIdCount = 1,
    }, MoverComponent)
    return self
end

function MoverComponent:getBindEntity()
    return self.bindEntity
end

function MoverComponent:updateVelocity()
    local reloadVelocity = recalculateVelocity(self.moverData)
    api.base.setLinearMotorVelocity(self.bindEntity, self.bindMoverIndex, reloadVelocity, false)
end

---comment
---@param velocity Vector3
---@param duration number
function MoverComponent:addLinearMotor(velocity, duration)
    local moverId = self.moverIdCount

    self.moverIdMap[moverId] = #self.moverData + 1
    self.moverIdCount = self.moverIdCount + 1

    local timer = nil
    local stdDuration = duration

    if duration and duration >= 0 then
        timer = SimpleTimer.new(duration, false)
        timer:setTask(function()
            timer:stop()
            self.moverData[self.moverIdMap[moverId]].active = false
        end)
    else
        stdDuration = -1
    end

    ---@type MoverData
    local moverData = {
        velocityX = velocity.x,
        velocityY = velocity.y,
        velocityZ = velocity.z,
        duration = stdDuration,
        active = true,
        timerRef = timer
    }

    table.insert(self.moverData, moverData)
end

function MoverComponent:addSurroundMotor(angularVelocity, center, duration)

end

function MoverComponent:destroy()

end

return MoverComponent
