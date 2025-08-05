local api = require "api"
local Global = require "common.Global"
local GameUI = require "component.GameUI"

---@class GlobalDispatcher
local GlobalDispatcher = {}
GlobalDispatcher.__index = GlobalDispatcher

function GlobalDispatcher.dispatcher(from, to)
    GameUI.showLoadUI(1.0, from ~= nil, to ~= nil)

    api.setTimeout(function()
        if from then
            from.exit()
        end

        if from then
            to:enter()
        end
    end, Global.LOAD_UI_FADE_IN_OUT_TIME + 0.5)
end

function GlobalDispatcher:enter()
end

function GlobalDispatcher:exit()
end

return GlobalDispatcher
