---@class LevelData
---@field levelGridXSize integer
---@field levelGridZSize integer
---@field gridArray table<integer, table<integer, Chunk>>
local LevelData = {}
LevelData.__index = LevelData

return LevelData
