local PositionDirectionEnum = require "common.enum.PositionDirectionEnum"
---@class GridUnit
local GridUnit = {}
GridUnit.__index = GridUnit

---if the train will enter this unit, you can call this method to know which
---output channel will be next used.
---
--- This method is used to determine the direction in which the train instance
--- should move to the next position in the current unit.
---
--- This method does not guarantee correct output in the case of erroneous
--- input.
---
--- It is necessary to check the return value of `checkEnterPermit()` before
--- calling this method.
---@param enterDirection PositionDirectionEnum
---@return table
function GridUnit:forward(enterDirection) return {} end

--- Obtain the direction in which the train leaves the GridUnit when entering
--- from a specified direction under the current conditions.
---@param enterDirection PositionDirectionEnum
---@return PositionDirectionEnum
function GridUnit:forwardDirection(enterDirection)
    return PositionDirectionEnum.CENTER
end

function GridUnit:checkEnterPermit(enterDirection) end

function GridUnit:destroy() end

---when a train enter this grid unit, you can call this method to proxy action
---of the train.
---
---this function can change grid unit status.
---@param trainInstance any
function GridUnit:onEnter(trainInstance) end

function GridUnit:wait(trainInstance) end

function GridUnit:resume(trainInstance) end

function GridUnit:onLeave(trainInstance) end

---reset this grid unit status
function GridUnit:reset() end

function GridUnit:isFixed() end

function GridUnit:isFault() end

function GridUnit:fault() end

function GridUnit:await() end

return GridUnit
