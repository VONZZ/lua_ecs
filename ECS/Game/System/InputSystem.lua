local _Base = require("ECS.Framework.System")
local InputSystem = class("InputSystem", _Base)

function InputSystem:ctor(contexts)
    self.context = contexts.input
end

function InputSystem:Initialize()
    local entity = self.context:CreateEntity()
    entity:AddAsset("playerPrefabPath")
    print("create input entity!!!!!")
end

return InputSystem