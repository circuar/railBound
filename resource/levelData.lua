local GridUnitTypeEnum = require "common.enum.GridUnitTypeEnum"
return {
    [1] = {
        levelIndex = 1,
        levelLabel = "1-1",
        filterParam = {

        },
        backgroundSceneIndex = 1,
        pageIndex = 1,
        isExtraLevel = false,
        preLevelIndex = nil,
        postMainLevelIndex = 2,
        postLevelIndexArray = {},
        levelData = {
            remainRailCount = 3,

            gridSize = { row = 1, col = 5 },
            grid = {
                [1] = {
                    { gridUnitType = GridUnitTypeEnum.RAIL_STRAIGHT_FIXED, directionMask = { 0, 1, 0, 1 }, chiralityMask = nil },
                    { gridUnitType = GridUnitTypeEnum.EMPTY,               directionMask = nil,            chiralityMask = nil },
                    { gridUnitType = GridUnitTypeEnum.EMPTY,               directionMask = nil,            chiralityMask = nil },
                    { gridUnitType = GridUnitTypeEnum.EMPTY,               directionMask = nil,            chiralityMask = nil },
                    { gridUnitType = GridUnitTypeEnum.RAIL_STRAIGHT_FIXED, directionMask = { 0, 1, 0, 1 }, chiralityMask = nil },
                }
            },

            trainData = {
                {
                    sequenceId = 1,
                    trainType = "normal",
                    position = { row = 1, col = 1 },
                    directionMask = { 0, 1, 0, 0 }
                }
            },
            finalLinkedPosition = { row = 1, col = 5 }
        }
    }
}
