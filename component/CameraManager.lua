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

---set the camera parameters for the game state
function CameraManager:gameMode()
    local player = api.getSinglePlayer()

    -- set camera param

    api.base.setCameraProperty(player, Enums.CameraPropertyType.DIST, 50.0)
    api.base.setCameraProperty(player, Enums.CameraPropertyType.FOV, 35.0)
    api.base.setCameraProperty(player, Enums.CameraPropertyType.BIND_MODE_PITCH, 55.0)
    api.base.setCameraProperty(player, Enums.CameraPropertyType.BIND_MODE_YAW, 30.0)
    api.base.setCameraProperty(player, Enums.CameraPropertyType.OBSERVER_HEIGHT, 0.0)
end

function CameraManager:levelSelectMode(currentPage)
    -- set camera position
    local cameraPos = Global.LEVEL_SELECTOR_PAGE_REFERENCE_POINT + math.Vector3(
        Global.LEVEL_SELECTOR_PAGE_SPACING * (currentPage - 1),
        0,
        0
    )
    api.base.setEntityPosition(self.cameraBindEntity, cameraPos)

    local player = api.getSinglePlayer()

    -- set camera param

    api.base.setCameraProperty(player, Enums.CameraPropertyType.DIST, 50.0)
    api.base.setCameraProperty(player, Enums.CameraPropertyType.FOV, 20.0)
    api.base.setCameraProperty(player, Enums.CameraPropertyType.BIND_MODE_PITCH, 0.0)
    api.base.setCameraProperty(player, Enums.CameraPropertyType.BIND_MODE_YAW, 180.0)
    api.base.setCameraProperty(player, Enums.CameraPropertyType.OBSERVER_HEIGHT, 0.0)
end

function CameraManager:cameraMove(towards, duration)
    api.base.addLinearMotor(self.cameraBindEntity, towards, duration, false)
end

function CameraManager:getCameraBindEntity()
    return self.cameraBindEntity
end

function CameraManager:setCameraPosition(position)
    api.base.setEntityPosition(self.cameraBindEntity, position)
end

function CameraManager:setCameraDistance(distance)
    api.base.setCameraProperty(
        api.getSinglePlayer(),
        Enums.CameraPropertyType.DIST,
        distance
    )
end

return CameraManager
