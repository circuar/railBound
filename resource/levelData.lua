local GridUnitTypeEnum = require "common.enum.GridUnitClassEnum"
return {
    --- debug level
    [0] = {
        levelIndex = 0,
        filterParam = {

        },
        backgroundSceneIndex = 1,
        cameraDistance = 150.0,
        levelData = {
            remainRailCount = 999,

            gridSize = { row = 10, col = 10 },
            gridData = {
                [1] = {},
                [2] = {},
                [3] = {},
                [4] = {},
                [5] = {
                    [1] = { gridUnitType = GridUnitTypeEnum.EMPTY },
                    [2] = { gridUnitType = GridUnitTypeEnum.EMPTY },
                    [3] = { gridUnitType = GridUnitTypeEnum.RAIL_NORMAL_FIXED, directionMask = { 0, 1, 0, 1 }, chiralityMask = nil, extraData = {} },
                    [4] = { gridUnitType = GridUnitTypeEnum.RAIL_NORMAL_FIXED, directionMask = { 0, 1, 0, 1 }, chiralityMask = nil, extraData = {} }
                },
                [6] = {},
                [7] = {},
                [8] = {},
                [9] = {},
                [10] = {}
            },

            trainData = {
                {
                    trainId = 1,
                    sequenceId = 1,
                    trainType = "NORMAL",
                    trainGroup = 1,
                    gridPosition = { row = 5, col = 3 },
                    directionMask = { 0, 0, 0, 1 }
                },
                {
                    trainId = 2,
                    sequenceId = 2,
                    trainType = "NORMAL",
                    trainGroup = 1,
                    gridPosition = { row = 5, col = 4 },
                    directionMask = { 0, 1, 0, 0 }
                }
            },
            groupChannelCount = 1
        }
    },



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
                    { gridUnitType = GridUnitTypeEnum.RAIL_NORMAL_FIXED, directionMask = { 0, 1, 0, 1 }, chiralityMask = nil, extraData = {} },
                    -- test
                    { gridUnitType = GridUnitTypeEnum.RAIL_NORMAL_FIXED, directionMask = { 1, 1, 0, 1 }, chiralityMask = 1,   extraData = {} },
                    { gridUnitType = GridUnitTypeEnum.RAIL_NORMAL_FIXED, directionMask = { 1, 1, 0, 1 }, chiralityMask = 0,   extraData = {} },
                    { gridUnitType = GridUnitTypeEnum.RAIL_NORMAL_FIXED, directionMask = { 0, 1, 1, 1 }, chiralityMask = 1,   extraData = {} },
                    { gridUnitType = GridUnitTypeEnum.RAIL_NORMAL_FIXED, directionMask = { 1, 1, 1, 0 }, chiralityMask = 0,   extraData = {} },

                    -- { gridUnitType = GridUnitTypeEnum.EMPTY,             directionMask = nil,            chiralityMask = nil, extraData = {} },
                    -- { gridUnitType = GridUnitTypeEnum.EMPTY,             directionMask = nil,            chiralityMask = nil, extraData = {} },
                    -- { gridUnitType = GridUnitTypeEnum.EMPTY,             directionMask = nil,            chiralityMask = nil, extraData = {} },
                    -- { gridUnitType = GridUnitTypeEnum.EMPTY,             directionMask = nil,            chiralityMask = nil, extraData = {} },
                    -- { gridUnitType = GridUnitTypeEnum.RAIL_FINAL,        directionMask = { 0, 1, 0, 1 }, chiralityMask = nil, extraData = { group = 1, trainSpaceLength = 10.0 } },
                }
            },

            trainData = {
                {
                    trainId = 1,
                    sequenceId = 1,
                    trainType = "NORMAL",
                    trainGroup = 1,
                    gridPosition = { row = 1, col = 1 },
                    directionMask = { 0, 1, 0, 0 }
                }
            },
            groupChannelCount = 1
        }
    }
}
