local _Base = require("ECS.Framework.System")
local InputSystem = class("InputSystem", _Base)

function InputSystem:Initialize(contexts)
    local entity = contexts.input:CreateEntity()
    entity:AddAsset("playerPrefabPath")
    print("create input entity!!!!!")
end

return InputSystem