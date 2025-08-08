local api               = require "api"
local Event             = require "common.Event"
local CameraManager     = require "component.CameraManager"
local Global            = require "common.Global"
local GameUI            = require "component.GameUI"
local DispatchableScene = require "game.interface.DispatchableScene"
local GameLoader        = require "game.core.GameLoader"
local SceneDispatcher   = require "game.core.SceneDispatcher"


---@class LevelSelectScene:DispatchableScene
---@field private currentPage integer
---@field private maxPage integer
local LevelSelectScene = {}
LevelSelectScene.__index = LevelSelectScene
setmetatable(LevelSelectScene, DispatchableScene)

local instance = nil

function LevelSelectScene:pageUp()
    if self.currentPage >= self.maxPage then
        return
    end

    self.currentPage = self.currentPage + 1

    GameUI.setLevelSelectProgress(self.currentPage)

    local cameraManager = CameraManager.instance()
    cameraManager:cameraMove(
        math.Vector3(-Global.LEVEL_SELECTOR_PAGE_SPACING, 0, 0) /
        Global.LEVEL_SELECTOR_PAGE_SWITCH_DURATION,
        Global.LEVEL_SELECTOR_PAGE_SWITCH_DURATION
    )
end

function LevelSelectScene:pageDown()
    if LevelSelectScene.currentPage <= 0 then
        return
    end

    self.currentPage = self.currentPage - 1

    GameUI.setLevelSelectProgress(self.currentPage)

    local cameraManager = CameraManager.instance()
    cameraManager:cameraMove(
        math.Vector3(Global.LEVEL_SELECTOR_PAGE_SPACING, 0, 0) /
        Global.LEVEL_SELECTOR_PAGE_SWITCH_DURATION,
        Global.LEVEL_SELECTOR_PAGE_SWITCH_DURATION
    )
end

---register level select event listener
---when player click level button, this function will be called.
function LevelSelectScene:registerLevelSelectListener()
    api.base.registerEventListener(Event.GLOBAL_LEVEL_SELECT, function(data)
        local selectLevelId = data.levelId
        local gameLoader = GameLoader.instance()
        gameLoader:initGame(selectLevelId)
    end)
end

---private constructor
local function constructor()
    local levelData = require "resource.levelData"

    local self = setmetatable({
        currentPage = 1,
        maxPage = levelData.levelCount,
    }, LevelSelectScene)
    self:registerLevelSelectListener()

    api.base.registerEventListener(Event.EVENT_LEVEL_SELECT_PAGE_UP,self.pageUp)
    api.base.registerEventListener(Event.EVENT_LEVEL_SELECT_PAGE_DOWN, self.pageDown)

    return self
end

function LevelSelectScene.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
end

-- override
function LevelSelectScene:onLoad()
    -- get cameraManager instance
    local cameraManager = CameraManager.instance()
    cameraManager:levelSelectMode(self.currentPage)
    GameUI.showLevelSelectUI()
end

-- override
function LevelSelectScene:onExit()
    GameUI.hideLevelSelectUI()
end

return LevelSelectScene
