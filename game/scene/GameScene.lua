local DispatchableScene = require "game.abstract.DispatchableScene"
local GameUI            = require "component.GameUI"

---@class GameScene:DispatchableScene
local GameScene         = {}
GameScene.__index       = GameScene
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
function GameScene:onLoad()
    -- Game UI
    GameUI.showGameSceneUI()
end

function GameScene:onExit()
    -- hide game UI
end

return GameScene
