local DispatchableScene = require "game.interface.DispatchableScene"
local GameLoader        = require "game.core.GameLoader"
local GameUI            = require "component.GameUI"

---@class GameScene:DispatchableScene
local GameScene = {}
GameScene.__index = GameScene
setmetatable(GameScene, DispatchableScene)

local instance = nil

local function constructor()
    local self = setmetatable({}, GameScene)
    return self
end

function GameScene.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
end
-- override
function GameScene:enter()
    -- Game UI

end

function GameScene:exit()
    -- hide game UI
end

return GameScene