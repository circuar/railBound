local api               = require "api"
local Event             = require "common.Event"
local CameraManager     = require "component.CameraManager"
local Global            = require "common.Global"
local GameUI            = require "component.GameUI"
local DispatchableScene = require "game.interface.DispatchableScene"
local GameLoader        = require "game.core.GameLoader"
local Logger            = require "logger.Logger"
local Vector            = require "util.Vector"
local LevelMetaDataManager = require "game.level.LevelMetaDataManager"
local ArchiveManager       = require "game.core.ArchiveManager"


---@class LevelSelectScene:DispatchableScene
---@field private currentPage integer
---@field private maxPage integer
local LevelSelectScene = {}
LevelSelectScene.__index = LevelSelectScene
setmetatable(LevelSelectScene, DispatchableScene)

local logger = Logger.new("LevelSelectScene")


local instance = nil

---private constructor
local function constructor()
    local self = setmetatable({
        currentPage = 1,
        maxPage = Global.LEVEL_PAGE_COUNT,
    }, LevelSelectScene)

    self:registerLevelSelectListener()

    api.base.registerEventListener(Event.EVENT_LEVEL_SELECT_PAGE_UP, function()
        self:pageUp()
    end)
    api.base.registerEventListener(Event.EVENT_LEVEL_SELECT_PAGE_DOWN, function()
        self:pageDown()
    end)

    return self
end


function LevelSelectScene.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
end

function LevelSelectScene:pageUp()
    logger:debug("page up, self.currentPage = " .. self.currentPage)
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
    logger:debug("page down, self.currentPage = " .. self.currentPage)
    if self.currentPage <= 1 then
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
        ---@type Vector3
        local clickPosition = data.position
        clickPosition.z = 0
        -- get gameLoader instance
        -- this is gameScene entry.

        local levelMetaDataManager = LevelMetaDataManager.instance()
        local levelMetaDataList = levelMetaDataManager:getLevelMetaDataList()

        for index, levelMetaData in ipairs(levelMetaDataList) do
            if Vector.distanceBetween(clickPosition, math.Vector3(levelMetaData.buttonXYPosition[1], levelMetaData.buttonXYPosition[2], 0)) <= 5 then
                if levelMetaDataManager:checkLevelUnlock(levelMetaData.levelIndex, ArchiveManager.instance():getMainLineProgress()) == false then
                    api.base.showTips("请先通过之前的关卡", 3.0)
                    return
                end

                local gameLoader = GameLoader.instance()
                gameLoader:initGame(levelMetaData.levelIndex)
            end
        end
    end)
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
