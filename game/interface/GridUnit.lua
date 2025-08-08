---@class GridUnit
local GridUnit = {}
GridUnit.__index = GridUnit

---if the train will enter this unit, you can call this method to know which
---output channel will be next used.
---
---enterChannelMask is a array with four elements.
---
---           top
---       -----------
--- left |    unit   | right
---       -----------
---          bottom
--- 
--- enterChannelMask = { top, right, bottom, left }
---
---@param enterChannelMask integer[]
function GridUnit:forward(enterChannelMask) end

---when a train enter this grid unit, you can call this method to proxy action
---of the train.
---
---this function can change grid unit status.
---@param trainInstance any
function GridUnit:onEnter(trainInstance) end

---reset this grid unit status
function GridUnit:reset() end

return GridUnit
