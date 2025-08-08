local api = require "api"
local GameUI = require "component.GameUI"
local Global = require "common.Global"
local Logger = require "logger.Logger"

---@class SceneDispatcher
---@field private currentSceneName string
---@field private currentScene DispatchableScene
---@field private scenes DispatchableScene[]
---@field private sceneCount integer
local SceneDispatcher = {}
SceneDispatcher.__index = SceneDispatcher



local logger = Logger.new("SceneDispatcher")

local instance = nil

local function constructor()
    local self = setmetatable({
        currentSceneName = nil,
        currentScene = nil,
        scenes = {},
        sceneCount = 0
    }, SceneDispatcher)
    return self
end

function SceneDispatcher.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
end

---switch scene
---@param sceneName string
---@param disableTransitionAnim boolean?
function SceneDispatcher:dispatch(sceneName, disableTransitionAnim)
    logger:info("scene dispatch from: " .. tostring(self.currentSceneName) .. ", to: " .. tostring(sceneName))

    local doDispatch = function()
        if self.currentScene then
            self.currentScene:onExit()
        end

        if self.scenes[sceneName] then
            self.scenes[sceneName]:onLoad()
            self.currentScene = self.scenes[sceneName]
            self.currentSceneName = sceneName
        else
            logger:error("invalid scene name: " .. sceneName)
        end
    end

    if disableTransitionAnim then
        doDispatch()
    else
        GameUI.showLoadUI(1.0)
        api.setTimeout(doDispatch, Global.LOAD_UI_FADE_IN_OUT_TIME + 0.5)
    end
end

---@param sceneName string
---@param sceneInstance DispatchableScene
---@return integer sceneId
function SceneDispatcher:registerScene(sceneName, sceneInstance)
    if self.scenes[sceneName] ~= nil then
        logger:warn("scene name are duplicated: " .. sceneName .. ", covered.")
    end
    table.insert(self, sceneInstance)
    self.sceneCount = self.sceneCount + 1
    return self.sceneCount
end

return SceneDispatcher
