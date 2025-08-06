local api = require "api"
local GameUI = require "component.GameUI"
local Global = require "common.Global"
local Logger = require "logger.Logger"


---@class SceneDispatcher
local SceneDispatcher = {}
SceneDispatcher.__index = SceneDispatcher

local logger = Logger.new("SceneDispatcher")

function SceneDispatcher.dispatcher(from, to)
    logger:info("scene dispatch from: " .. tostring(from) .. ", to: " .. tostring(to))
    GameUI.showLoadUI(1.0, from ~= nil, to ~= nil)

    api.setTimeout(function()
        if from then
            from:exit()
        end

        if from then
            to:enter()
        end
    end, Global.LOAD_UI_FADE_IN_OUT_TIME + 0.5)
end


return SceneDispatcher
