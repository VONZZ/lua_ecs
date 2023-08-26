    -------------------------------------------------------------------------------------------------
    -- 自动生成，请勿改动
    -------------------------------------------------------------------------------------------------
    local _Base = require("ECS.Framework.Context")
    local Entity = require("ECS.Generated.Input.InputEntity")
    ---@class InputContext
    local InputContext = class("InputContext", _Base)
    
    function InputContext:_GetEntityClass()
        return Entity
    end
    
    return InputContext
    