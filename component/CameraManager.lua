local Logger = require "logger.Logger"
local GameResource = require "common.GameResource"
local api = require "api"
local Global = require "common.Global"

---singleton
---@class CameraManager
---@field private cameraBindEntity Unit
local CameraManager = {}
CameraManager.__index = CameraManager

local logger = Logger.new("CameraManager")
local instance = nil

-- private constructor
local function constructor()
    local cameraBindEntity = api.base.getEntityById(GameResource.CAMERA_BIND_ENTITY_ID)
    logger:info("camera bind entity: " .. tostring(cameraBindEntity))
    local self = setmetatable({
        cameraBindEntity = cameraBindEntity
    }, CameraManager)

    local player = api.getSinglePlayer()

    api.base.setCameraFollowEntity(player, cameraBindEntity, false)
    api.base.setCameraBindMode(player, Enums.CameraBindMode.BIND)
    api.base.setCameraProjectionMode(player, Enums.CameraProjectionType.ORTHOGRAPHIC)
    api.base.setCameraDraggable(player, false)

    return self
end


function CameraManager.instance()
    if instance == nil then
        logger:info("the camera manager is not created, constructing a new instance")
        -- create object
        instance = constructor()
    end

    return instance
end

function CameraManager:gameMode()
end

function CameraManager:levelSelectMode()
    -- set camera position
    api.base.setEntityPosition(self.cameraBindEntity, Global.LEVEL_SELECTOR_PAGE_REFERENCE_POINT)

    local player = api.getSinglePlayer()
    api.base.setCameraProperty(player, Enums.CameraPropertyType.YAW, 180.0)
    api.base.setCameraProperty(player, Enums.CameraPropertyType.PITCH, 0.0)
end

function CameraManager:cameraMove(towards, duration)
    api.base.addLinearMotor(CameraManager.cameraBindEntity, towards, duration, false)
end

function CameraManager:getCameraBindEntity()
    return CameraManager.cameraBindEntity
end

return CameraManager
