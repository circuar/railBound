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

function ArchiveManager:getMainLineProgress()

end

function ArchiveManager:getSideLineProgress()

end

function ArchiveManager:setMainLineProgress(levelIndex)
    
end

function ArchiveManager:setSideLineProgress(sideLineProgress)
    
end

return ArchiveManager