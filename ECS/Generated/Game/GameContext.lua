    -------------------------------------------------------------------------------------------------
    -- 自动生成，请勿改动
    -------------------------------------------------------------------------------------------------
    local _Base = require("ECS.Framework.Context")
    local Entity = require("ECS.Generated.Game.GameEntity")
    ---@class GameContext
    local GameContext = class("GameContext", _Base)
    
    function GameContext:_GetEntityClass()
        return Entity
    end
    
    return GameContext
    