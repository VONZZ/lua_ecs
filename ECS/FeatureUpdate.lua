local debug  = true

local _Base 
if debug then
    _Base = require("ECS.Framework.DebugFeature")
else
    _Base = require("ECS.Framework.Feature")
end

local FeatureUpdate = class("FeatureUpdate", _Base)

local Contexts = require("ECS.Generated.Contexts")

function FeatureUpdate:ctor()
    _Base:ctor()

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