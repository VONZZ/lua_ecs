-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 实体基类
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
---@class Entity
local Entity = class("Entity")

function Entity:ctor(context)
    self.context = context
    self.__component_indexer = {}
    self.mUID = 0
end

---销毁实体
function Entity:Destroy()
    self.context:_OnDestroyEntity(self)
end

---添加组件事件
---@param comp Component 组件实例
function Entity:_OnAddComponent(comp)
    if not self.__component_indexer[comp.__id] then
        self.__component_indexer[comp.__id] = comp
    end
end

---移除组件事件
---@param comp Component 组件实例
function Entity:_OnRemoveComponent(comp)
    if self.__component_indexer[comp.__id] then
        self.__component_indexer[comp.__id] = nil
    end
end

---检查实体是否有指定id的组件
---@param id integer
---@return boolean
function Entity:HasComponent(id)
    if self.__component_indexer[id] then
        return true
    end
    return false
end


---@param id integer
---@return Component
function Entity:GetComponent(id)
    return self.__component_indexer[id]
end

return Entity
