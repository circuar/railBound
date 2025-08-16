local api = require "api"
local ArchiveIndex = require "common.ArchiveIndex"



local ArchiveManager = {}
ArchiveManager.__index = ArchiveManager

local instance = nil

local function constructor()
    local self = setmetatable({}, ArchiveManager)
    return self
end

function ArchiveManager.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
end

---Get level main line progress.
---@return integer
function ArchiveManager:getMainLineProgress()
    local player = api.getSinglePlayer()
    return api.base.getArchiveData(player, ArchiveIndex.MAIN_LINE_PROGRESS_INDEX, Enums.ArchiveType.Int)
end

---Set level main line progress.
---@param levelIndex integer
function ArchiveManager:setMainLineProgress(levelIndex)
    local player = api.getSinglePlayer()
    api.base.setArchiveData(player, ArchiveIndex.MAIN_LINE_PROGRESS_INDEX, levelIndex, Enums.ArchiveType.Int)
end

return ArchiveManager
