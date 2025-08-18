
---@class GameOperation
---@field operationType GameOperationTypeEnum
---@field gridUnitData table
---@field operationRow integer
---@field operationCol integer
local GameOperation = {}
GameOperation.__index = GameOperation

function GameOperation.new(operationType, gridUnitData, operationRow, operationCol)
    local self = setmetatable({
        operationType = operationType,
        gridUnitData = gridUnitData,
        operationRow = operationRow,
        operationCol = operationCol
    })
end

function GameOperation:undo(grid)
    if self.gridUnitData == nil then
        
    end
end

return GameOperation