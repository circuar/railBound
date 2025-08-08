local api = require "api"
local Event = require "common.Event"
local Global = require "common.Global"
local Logger = require "logger.Logger"

local GameUI = {}
GameUI.__index = GameUI

local logger = Logger.new("GameUI")

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

return GameUI
