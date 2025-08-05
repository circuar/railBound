local api = require "api"
local Event = require "common.Event"
local Global = require "common.Global"
local GameUI = {}
GameUI.__index = GameUI

---show load UI
---
---you can specify whether to include a fade-in and fade-out effect,
---enabled by default.
---
---the specified time does not include the time of fading.
---@param duration number
---@param fadeIn boolean?
---@param fadeOut boolean?
function GameUI.showLoadUI(duration, fadeIn, fadeOut)
    local player = api.getSinglePlayer()
    local delay = duration

    if fadeIn then
        delay = delay + Global.LOAD_UI_FADE_IN_OUT_TIME
        api.base.sendUIEvent(player, Event.UI_LOAD_UI_FADE_IN)
    end

    api.base.sendUIEvent(player, Event.UI_SHOW_LOAD_UI)

    if fadeOut then
        api.setTimeout(function()
            api.base.sendUIEvent(player, Event.UI_LOAD_UI_FADE_OUT)
        end, delay)
        delay = delay + Global.LOAD_UI_FADE_IN_OUT_TIME
    end

    api.setTimeout(function()
        api.base.sendUIEvent(player, Event.UI_HIDE_LOAD_UI)
    end, delay)
end

function GameUI.showLevelSelectUI()
    api.base.sendUIEvent(api.getSinglePlayer(), Event.UI_SHOW_LEVEL_SELECT_UI)
end


function GameUI.hideLevelSelectUI()
    api.base.sendUIEvent(api.getSinglePlayer(), Event.UI_HIDE_LEVEL_SELECT_UI)
end

return GameUI
