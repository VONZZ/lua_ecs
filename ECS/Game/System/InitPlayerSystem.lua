local _Base = require("ECS.Framework.System")
local InitPlayerSystem = class("InitPlayerSystem", _Base)

function InitPlayerSystem:Initialize(contexts)
    local entity = contexts.game:CreateEntity()
    entity:AddAsset("playerPrefabPath")
    print("create player entity!!!!!")
end

return InitPlayerSystem