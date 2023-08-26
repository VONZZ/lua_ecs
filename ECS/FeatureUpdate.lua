local _Base = require("ECS.Framework.Feature")
local FeatureUpdate = class("FeatureUpdate", _Base)

local Contexts = require("ECS.Generated.Contexts")

function FeatureUpdate:ctor()
    self.super:ctor()

    local contexts = Contexts.Instance()
    contexts:SetAllContexts()
    
    self:createSystems(contexts)

    self:Initialize()

    -- contexts.game:Reset()
end

function FeatureUpdate:createSystems(contexts)
    self:Add(require("ECS.Game.System.InitPlayerSystem"), contexts)
    self:Add(require("ECS.Game.System.InputSystem"), contexts)
    self:Add(require("ECS.Game.System.AddViewSystem"), contexts)
end

return FeatureUpdate