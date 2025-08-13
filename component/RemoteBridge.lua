local Logger = require("component.Logger")
local api = require("api")

local RemoteBridge = {}
RemoteBridge.__index = RemoteBridge

RemoteBridge.bridgeEvent = {
    SET_CAMERA_PROJECTION_FOV = "BRI_SET_CAMERA_PROJECTION_FOV",
}


local logger = Logger.new("RemoteBridge")



return RemoteBridge
