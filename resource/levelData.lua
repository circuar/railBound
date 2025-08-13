local GridUnitTypeEnum = require "common.enum.GridUnitClassEnum"
return {
    [1] = {
        levelIndex = 1,
        filterParam = {

        },
        backgroundSceneIndex = 1,
        cameraDistance = 150.0,
        levelData = {
            remainRailCount = 3,

            gridSize = { row = 1, col = 5 },
            gridData = {
                [1] = {
                    { gridUnitType = GridUnitTypeEnum.RAIL_NORMAL_FIXED, directionMask = { 0, 1, 0, 1 }, chiralityMask = nil },
                    { gridUnitType = GridUnitTypeEnum.EMPTY,             directionMask = nil,            chiralityMask = nil },
                    { gridUnitType = GridUnitTypeEnum.EMPTY,             directionMask = nil,            chiralityMask = nil },
                    { gridUnitType = GridUnitTypeEnum.EMPTY,             directionMask = nil,            chiralityMask = nil },
                    { gridUnitType = GridUnitTypeEnum.RAIL_NORMAL_FIXED, directionMask = { 0, 1, 0, 1 }, chiralityMask = nil },
                }
            },

            trainData = {
                {
                    trainId = 1,
                    sequenceId = 1,
                    trainType = "normal",
                    trainGroup = 1,
                    position = { row = 1, col = 1 },
                    directionMask = { 0, 1, 0, 0 }
                }
            },
            finalLinkedGridUnitData = {
                { group = 1, row = 1, col = 5 }
            }

        }
    }
}
