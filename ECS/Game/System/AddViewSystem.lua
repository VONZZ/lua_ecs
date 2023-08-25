local _Base = require("ECS.Framework.ReactiveSystem")
local AddViewSystem = class("AddViewSystem", _Base)


function AddViewSystem:GetCollector(contexts)
    local context = contexts.game
    local collector = context:GetCollector({
        context:GetGroup(context:GetMatcher():AllOf(EMatcher.Asset))
    },{
        GroupChangeEvent.Added
    })
    return collector
end

function AddViewSystem:ChangeExecute(entities)
    for i = 1, #entities do
        local entity = entities[i]
        local path = entity:GetComponent(GameComponentLookUp.AssetComponent).path
        entity:AddView("a prefab")
        print("add view create a prefab : ", path)
    end
end

return AddViewSystem
