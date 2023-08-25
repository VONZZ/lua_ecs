------------------------------------------------------------------------
---收集器
------------------------------------------------------------------------
local Collector = class("Collector")

function Collector:ctor(groups, groupEvents)
    self.mGroups = groups

    self.mCollectedEntities = {}
    self.mIndexer = {}

    self.mGroupInsterestEvent = {}
    self:_initInsterestChangeEvent(groups, groupEvents)

    ---过滤组变化回调方法
    local this = self
    self.onGroupChange = function (group, e, changeEvent)
        this:_entityChange(group, e, changeEvent)
    end
end

---初始化过滤组和变化类型映射关系
---@param groups Group
---@param groupEvents GroupChangeEvent
function Collector:_initInsterestChangeEvent(groups, groupEvents)
    for i = 1, #groups do
        local group = groups[i]
        self.mGroupInsterestEvent[group.mID] = groupEvents[i]
    end
end

---注册过滤组变化监听
function Collector:_registerGroupChange()
    for i = 1, #self.mGroups do
        local group =  self.mGroups[i]
        group.mGroupChangeEventList = group.mGroupChangeEventList + self.onGroupChange
    end
end

---反注册过滤组变化监听
function Collector:_unregisterGroupChange()
    for i = 1, #self.mGroups do
        local group =  self.mGroups[i]
        group.mGroupChangeEventList = group.mGroupChangeEventList - self.onGroupChange
    end
end

---过滤组变更回调函数
---@param group Group
---@param entity Entity
---@param changeEvent GroupChangeEvent
function Collector:_entityChange(group, entity, changeEvent)
    local groupInsterestEvent = self.mGroupInsterestEvent[group.mID] 
    if groupInsterestEvent & changeEvent > 0 then
        if not self.mIndexer[entity.mUID] then
            self.mCollectedEntities[#self.mCollectedEntities + 1] = entity
            self.mIndexer[entity.mUID] = #self.mGroupInsterestEvent
            -- print("entityChange   ======>", "group.mID:",group.mID, 
            -- "entity.mUID: ",entity.mUID, 
            -- "changeEvent: ",changeEvent == 1 and "Added" or changeEvent == 2 and "Updated" or changeEvent == 3 and "Removed")
        end
    end
end

---激活收集器
function Collector:Activate()
    self:_registerGroupChange()
end

---取消激活收集器
function Collector:Deactivate()
    self:_unregisterGroupChange()
    self:ClearCollectedEntities()
end

---获取当前收集到的entity列表
---@return table Entity[]
function Collector:GetCollectedEntities()
    return self.mCollectedEntities
end

---清空entity列表
function Collector:ClearCollectedEntities()
    self.mCollectedEntities = {}
    self.mIndexer = {}
end

function Collector:HasCollectedEntities()
    return #self.mCollectedEntities > 0
end

---打印收集到的entityId
function Collector:PrintCollectedEntitiesId()
    local idList = {}
    for i = 1, #self.mCollectedEntities do
        table.insert(idList, self.mCollectedEntities[i].mUID)
    end
    print("CollectedEntities  :",table.concat(idList, ","))
end

return Collector