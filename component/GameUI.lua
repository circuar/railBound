local api                    = require "api"
local Event                  = require "common.Event"
local Global                 = require "common.Global"
local Logger                 = require "logger.Logger"
local GameUIRunBtnStatusEnum = require "common.enum.GameUIRunBtnStatusEnum"
local UIResource             = require "common.UIResource"

local GameUI                 = {}
GameUI.__index               = GameUI

local logger                 = Logger.new("GameUI")

---show load UI
---
---the specified time does not include the time of fading.
---@param duration number
function GameUI.showLoadUI(duration)
    logger:info("show load ui, duration: " .. duration)
    local player = api.getSinglePlayer()

    api.base.sendUIEvent(player, Event.UI_SHOW_LOAD_UI)

    api.setTimeout(function()
        api.base.sendUIEvent(player, Event.UI_HIDE_LOAD_UI)
    end, duration + Global.LOAD_UI_FADE_IN_OUT_TIME)
end

function GameUI.showLevelSelectUI()
    api.base.sendUIEvent(api.getSinglePlayer(), Event.UI_SHOW_LEVEL_SELECT_UI)
end

function GameUI.hideLevelSelectUI()
    logger:debug("Send hide level select ui event")
    api.base.sendUIEvent(api.getSinglePlayer(), Event.UI_HIDE_LEVEL_SELECT_UI)
end

function GameUI.setLevelSelectProgress(progress)
    if progress > Global.LEVEL_PAGE_COUNT or progress < 1 then
        logger:error("invalid level page progress.")
    end

    local BEFORE_BLANK_PERCENTAGE = 0.02
    local AFTER_BLANK_PERCENTAGE = 0.03


    local levelProgressPercentage = progress * 100 / Global.LEVEL_PAGE_COUNT *
        (1 - BEFORE_BLANK_PERCENTAGE - AFTER_BLANK_PERCENTAGE) + BEFORE_BLANK_PERCENTAGE * 100
    -- set progress
    local player = api.getSinglePlayer()
    -- api.base.setUIProgressBarProperties(player, UIResource.LEVEL_SELECT_PROGRESS_BAR,
    --     BEFORE_BLANK_PERCENTAGE, 100)
    logger:info("set level select top progress bar: " .. levelProgressPercentage)
    api.base.setUIProgressBarCurrent(player, UIResource.LEVEL_SELECT_PROGRESS_BAR,
        ---@diagnostic disable-next-line: param-type-mismatch
        math.tointeger(levelProgressPercentage),
        Global.LEVEL_SELECTOR_PAGE_SWITCH_DURATION)
end

function GameUI.showGameSceneUI()
    api.base.sendUIEvent(api.getSinglePlayer(), Event.UI_SHOW_GAME_UI)
end

function GameUI.hideGameSceneUI()
    api.base.sendUIEvent(api.getSinglePlayer(), Event.UI_HIDE_GAME_UI)
end

function GameUI.setGameUILevelName(levelName)
    local player = api.getSinglePlayer()
    logger:debug("Set level name label text. Level name: " .. levelName)
    api.base.setUIText(player, UIResource.GAME_LEVEL_NAME_LABEL, levelName)
end

function GameUI.setGameUIRailCount(num)
    local player = api.getSinglePlayer()
    logger:debug("Set rail count text. Rail count: " .. num)
    api.base.setUIText(player, UIResource.GAME_RAIL_COUNT, tostring(num))
end

function GameUI.setGameUIRunBtnStatus(status)
    if status == GameUIRunBtnStatusEnum.NORMAL then

    end
end

---play level switch animation
function GameUI.showLevelSwitchAnim(loadInterval)
    GameUI.showLevelSwitchAnimIn()

    api.setTimeout(function()
        GameUI.showLevelSwitchAnimOut()
    end, Global.LEVEL_SWITCH_ANIM_IN_OUT_DURATION + loadInterval)
end

function GameUI.showLevelSwitchAnimIn()
    local player = api.getSinglePlayer()
    api.base.sendUIEvent(player, Event.UI_SHOW_LEVEL_SWITCH_SCENE)
    api.base.sendUIEvent(player, Event.UI_PLAY_LEVEL_SWITCH_ANIM_IN)
end

function GameUI.showLevelSwitchAnimOut()
    local player = api.getSinglePlayer()
    api.base.sendUIEvent(player, Event.UI_PLAY_LEVEL_SWITCH_ANIM_OUT)
    api.setTimeout(function()
        api.base.sendUIEvent(player, Event.UI_HIDE_LEVEL_SWITCH_SCENE)
    end, Global.LEVEL_SWITCH_ANIM_IN_OUT_DURATION)
end

function GameUI.enableGameDeleteMode()
    api.base.sendUIEvent(
        api.getSinglePlayer(),
        Event.UI_GAME_SHOW_DELETE_MODE,
        {}
    )
    api.base.setUINodeOpacity(api.getSinglePlayer(), "1519736575|2098868386", 1.0)
    api.base.setUINodeOpacity(api.getSinglePlayer(), "1519736575|1385281103", 0.0)
end

function GameUI.disableGameDeleteMode()
    api.base.sendUIEvent(
        api.getSinglePlayer(),
        Event.UI_GAME_HIDE_DELETE_MODE,
        {}
    )
    api.base.setUINodeOpacity(api.getSinglePlayer(), "1519736575|2098868386", 0.0)
    api.base.setUINodeOpacity(api.getSinglePlayer(), "1519736575|1385281103", 1.0)
end

return GameUI
