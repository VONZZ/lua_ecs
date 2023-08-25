local _Base = require("ECS.Framework.Feature")
local FeatureUpdate = class("FeatureUpdate", _Base)

local Contexts = require("ECS.Generated.Contexts")

function FeatureUpdate:ctor()
    self.super:ctor()

    local contexts = Contexts.Instance()
    contexts:SetAllContexts()
    
    self:Add(require("ECS.Game.System.AddViewSystem"), contexts)
    self:Add(require("ECS.Game.System.InitPlayerSystem"), contexts)
    self:Add(require("ECS.Game.System.InputSystem"), contexts)

    -- contexts.game:Reset()
end

return FeatureUpdate