local _Base = require("ECS.Framework.System")
local InitPlayerSystem = class("InitPlayerSystem", _Base)

function InitPlayerSystem:Initialize(contexts)
    local entity = contexts.game:CreateEntity()
    print("create player entity!!!!!")
    entity:AddAsset("playerPrefabPath")
end

return InitPlayerSystem