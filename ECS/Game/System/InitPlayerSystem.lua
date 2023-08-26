local _Base = require("ECS.Framework.System")
local InitPlayerSystem = class("InitPlayerSystem", _Base)

function InitPlayerSystem:ctor(contexts)
    self.context = contexts.game
end

function InitPlayerSystem:Initialize()
    local entity = self.context:CreateEntity()
    print("create player entity!!!!!")
    entity:AddAsset("playerPrefabPath")
end

return InitPlayerSystem