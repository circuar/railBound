---@class Level
---@field initialGrid table<integer, table<integer, table>>
local Level = {}
Level.__index = Level

function Level.new(grid)
    local self = setmetatable({
        initialGrid = grid,
    }, Level)
    return self
end

function Level:setInitialGrid(grid)
    self.initialGrid = grid
end

function Level:getInitialGrid()
    return self.initialGrid
end

function Level:renderGridLine()
    
end

function Level:renderGrid()

end

function Level:destroy()
    
end

function Level:resetLevel()
    
end

return Level