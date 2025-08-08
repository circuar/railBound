-- Level.lua

-- This class should be used as a carrier for the data loaded by LevelLoader and
-- managed by LevelManager.

---@class Level
---@field initialGrid table<integer, table<integer, table>>
local Level = {}
Level.__index = Level

function Level.new(levelData)
    local self = {}
    self.levelIndex = levelData.levelIndex
    self.nextLevelIndex = levelData.postMainLevelIndex
    self.grid = {}

    

    setmetatable(self, Level)
    return self
end

function Level:getInitialGrid()
    return self.initialGrid
end

function Level:renderGridLine()
    
end

function Level:renderGridUnit()

end

function Level:renderFilter()
    
end

function Level:destroy()
    
end

return Level