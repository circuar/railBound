---@module "api"

local runtime = {
    singlePlayer = nil
}

-- api package provide some enhanced interfaces of original interfaces.
local api = {}

---when the game is in single-player mode, get that player and cache it.
---@return Role
function api.getSinglePlayer()
    if runtime.singlePlayer == nil then
        local playerList = GameAPI.get_all_roles()
        if #playerList > 1 then
            error("[ ERROR ] currently in non-single-player mode, you cannot" ..
                " use this function to acquire players")
        end
        runtime.singlePlayer = playerList[1]
    end

    return runtime.singlePlayer
end

---call the callback function at a delayed time.
---
---you can specify whether frames are used instead of seconds.
---@param callback fun()
---@param delay number
---@param useFrameCount boolean?
function api.setTimeout(callback, delay, useFrameCount)
    if useFrameCount then
        LuaAPI.call_delay_frame(delay, callback)
    else
        LuaAPI.call_delay_time(delay, callback)
    end
end





-- base package provides the package of the original api.
local base = {}

---make player win the game
---@param player Role
function base.win(player)
    player.win()
end

---end the game
function base.endGame()
    GameAPI.game_end()
end

---get entity by id
---@param id integer
---@return Unit
function base.getEntityById(id)
    return GameAPI.get_unit(id)
end

---send an event to the specified player's UI
---@param player Role
---@param event string
---@param data table?
function base.sendUIEvent(player, event, data)
    ---@diagnostic disable-next-line: param-type-mismatch
    player.send_ui_custom_event(event, data)
end

---register custom event listener
---@param event string
---@param callback fun(data:table):nil
function base.registerEventListener(event, callback)
    LuaAPI.global_register_custom_event(event, callback)
end

---add linear motor to unit
---@param entity Unit
---@param velocity Vector3
---@param duration number
---@param localCoordinate boolean?
function base.addLinearMotor(entity, velocity, duration, localCoordinate)
    entity.add_linear_motor(velocity, duration, localCoordinate)
end

---set entity position
---@param entity Unit
---@param position Vector3
function base.setEntityPosition(entity, position)
    entity.set_position(position)
end

---set player camera properties
---@param player Role
---@param property Enums.CameraPropertyType
---@param value number
function base.setCameraProperty(player, property, value)
    player.set_camera_property(property, value)
end

---set player camera draggable
---@param player Role
---@param draggable boolean
function base.setCameraDraggable(player, draggable)
    player.set_camera_draggable(draggable)
end

--- set camera follow entity
--- @param player Role
--- @param entity Unit
--- @param followRotation boolean 是否跟随旋转
function base.setCameraFollowEntity(player, entity, followRotation)
    ---@diagnostic disable-next-line: undefined-field
    GlobalAPI.set_camera_follow_unit(player, entity, followRotation)
end

---set player camera projection mode
---@param player Role
---@param projectionMode Enums.CameraProjectionType
function base.setCameraProjectionMode(player, projectionMode)
    player.set_camera_projection_type(projectionMode)
end

---set player camera bind mode
---@param player Role
---@param bindMode Enums.CameraBindMode
function  base.setCameraBindMode(player, bindMode)
    player.set_camera_bind_mode(bindMode)
end

---@param player Role
---@param uiNode string
---@param current integer
---@param duration number
function base.setUIProgressBarCurrent(player, uiNode, current, duration)
    player.set_progressbar_transition(uiNode, current, duration)
end

--- set UI progress bar min and max value
---@param player Role
---@param uiNode string
---@param min integer?
---@param max integer?
function base.setUIProgressBarProperties(player, uiNode, min, max)
    if min then
        player.set_progressbar_min(uiNode, min)
    end
    if max then
        player.set_progressbar_max(uiNode, max)
    end
end

api.base = base
return api
