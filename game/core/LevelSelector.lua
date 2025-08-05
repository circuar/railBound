local api              = require "api"
local Event            = require "common.Event"
local CameraManager    = require "component.CameraManager"
local Global           = require "common.Global"
local GameUI           = require "component.GameUI"
local GlobalDispatcher = require "game.GlobalDispatcher"


---@class LevelSelector:GlobalDispatcher
---@field private currentPage integer
---@field private maxPage integer
local LevelSelector = {}
LevelSelector.__index = LevelSelector
setmetatable(LevelSelector, { __index = GlobalDispatcher })

local instance = nil

local function pageUp()
    if LevelSelector.currentPage >= LevelSelector.maxPage then
        return
    end

    local cameraManager = CameraManager.instance()
    cameraManager:cameraMove(
        math.Vector3(-Global.LEVEL_SELECTOR_PAGE_SPACING, 0, 0) /
        Global.LEVEL_SELECTOR_PAGE_SWITCH_DURATION,
        Global.LEVEL_SELECTOR_PAGE_SWITCH_DURATION
    )
end

local function pageDown()
    if LevelSelector.currentPage <= 0 then
        return
    end

    local cameraManager = CameraManager.instance()
    cameraManager:cameraMove(
        math.Vector3(Global.LEVEL_SELECTOR_PAGE_SPACING, 0, 0) /
        Global.LEVEL_SELECTOR_PAGE_SWITCH_DURATION,
        Global.LEVEL_SELECTOR_PAGE_SWITCH_DURATION
    )
end


---private constructor
local function constructor()
    api.base.registerEventListener(Event.EVENT_LEVEL_SELECT_PAGE_UP, pageUp)
    api.base.registerEventListener(Event.EVENT_LEVEL_SELECT_PAGE_DOWN, pageDown)

    local levelData = require "resource.levelData"


    return setmetatable({
        currentPage = 1,
        maxPage = levelData.levelCount
    }, LevelSelector)
end

function LevelSelector.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
end

function LevelSelector:enter()
    local cameraManager = CameraManager.instance()
    cameraManager:levelSelectMode()
end

function LevelSelector:exit()
    GameUI.hideLevelSelectUI()
end

return LevelSelector
