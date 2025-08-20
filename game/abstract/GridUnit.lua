local PositionDirectionEnum = require "common.enum.PositionDirectionEnum"
local Train                 = require "game.object.Train"
---@class GridUnit
local GridUnit              = {}
GridUnit.__index            = GridUnit

--- If the train will enter this unit, you can call this method to know which
--- output grid unit will be next used.
---
--- This method does not guarantee correct output in the case of erroneous
--- input. It is necessary to check the return value of `checkEnterPermit()`
--- before calling this method.
---@param enterDirection PositionDirectionEnum
---@return table
function GridUnit:forward(enterDirection) return { row = nil, col = nil } end

--- Obtain the direction in which the train leaves the GridUnit when entering
--- from a specified direction under the current conditions.
---@param enterDirection PositionDirectionEnum
---@return PositionDirectionEnum
function GridUnit:forwardDirection(enterDirection) return PositionDirectionEnum.CENTER end

--- Check whether it is allowed to enter gridUnit in the specified direction.
---@param enterDirection PositionDirectionEnum
---@return boolean
function GridUnit:checkEnterPermit(enterDirection) return false end

--- Create and render associated entities.
function GridUnit:render() end

--- Destroy associated entities.
function GridUnit:destroy() end

---when a train enter this grid unit, you can call this method to proxy action
---of the train.
---
---this function can change grid unit status.
---@param trainInstance Train
function GridUnit:onEnter(trainInstance, enterDirection) end

--- Corresponding trigger when leaving.
---@param trainInstance Train
function GridUnit:onLeave(trainInstance) end

function GridUnit:isBlocking() end

function GridUnit:isWaiting() end

function GridUnit:isBusy() end

---@return Train
function GridUnit:getSingleHoldingTrain() return Train end

function GridUnit:wait(trainInstance, enterDirection) end

function GridUnit:resume(trainInstance) end

---reset this grid unit status
function GridUnit:reset() end

function GridUnit:isFixed() end

function GridUnit:isFault() end

function GridUnit:setFault() end

function GridUnit:mirror() end

function GridUnit:launch() end

function GridUnit:update()

end

function GridUnit:setLevelManager(levelManager)

end

return GridUnit
