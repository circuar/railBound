local api                    = require "api"
local Event                  = require "common.Event"
local Global                 = require "common.Global"
local Logger                 = require "logger.Logger"
local GameUIRunBtnStatusEnum = require "common.enum.GameUIRunBtnStatusEnum"
local UI                     = require "common.UIResource"
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
    api.base.sendUIEvent(api.getSinglePlayer(), Event.UI_HIDE_LEVEL_SELECT_UI)
end

function GameUI.setLevelSelectProgress(progress)
    if progress > Global.LEVEL_PAGE_COUNT or progress < 1 then
        logger:error("invalid level page progress.")
    end

    local BEFORE_BLANK_PERCENTAGE = 0.05
    local AFTER_BLANK_PERCENTAGE = 0.05


    local levelProgressPercentage = progress /
        (Global.LEVEL_PAGE_COUNT * (1 - BEFORE_BLANK_PERCENTAGE -
            AFTER_BLANK_PERCENTAGE)) + BEFORE_BLANK_PERCENTAGE
    -- set progress
    local player = api.getSinglePlayer()
    api.base.setUIProgressBarProperties(player, UIResource.LEVEL_SELECT_PROGRESS_BAR,
        BEFORE_BLANK_PERCENTAGE, 100)
    api.base.setUIProgressBarCurrent(player, UIResource.LEVEL_SELECT_PROGRESS_BAR, levelProgressPercentage,
        Global.LEVEL_SELECTOR_PAGE_SWITCH_DURATION)
end

function GameUI.showGameSceneUI()
    api.base.sendUIEvent(api.getSinglePlayer(), Event.UI_SHOW_GAME_UI)
end

function GameUI.hideGameSceneUI()
    api.base.sendUIEvent(api.getSinglePlayer(), Event.UI_HIDE_GAME_UI)
end

function GameUI.setGameUILevelName(levelName)

end

function GameUI.setGameUIRailCount(num)

end

function GameUI.setGameUIRunBtnStatus(status)
    if status == GameUIRunBtnStatusEnum.NORMAL then

    end
end

---play level switch animation
---@deprecated
function GameUI.showLevelSwitchAnim()
    local player = api.getSinglePlayer()
    api.base.sendUIEvent(player, Event.UI_PLAY_LEVEL_SWITCH_OUT_ANIM)

    api.setTimeout(function()
        api.base.sendUIEvent(player, Event.UI_PLAY_LEVEL_SWITCH_IN_ANIM)
    end, Global.LEVEL_SWITCH_ANIM_IN_OUT_DURATION)
end

function GameUI.showLevelSwitchOutAnim()
    api.base.sendUIEvent(api.getSinglePlayer(), Event.UI_PLAY_LEVEL_SWITCH_OUT_ANIM)
end
function GameUI.showLevelSwitchInAnim()
    api.base.sendUIEvent(api.getSinglePlayer(), Event.UI_PLAY_LEVEL_SWITCH_IN_ANIM)
end


return GameUI
