-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- ECS Context ECS运行环境
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
local Collector = require("ECS.Framework.Collector")
local Entity = require("ECS.Framework.Entity")
local Matcher = require("ECS.Framework.Matcher")
local Group = require("ECS.Framework.Group")

local Context = class("Context")

-----------------------------------------------------------------------------------------------------------------------
-- Context API
-----------------------------------------------------------------------------------------------------------------------

---初始化
function Context:ctor()
    --- 实体对象回收池
    self.mEntityList_Recycle = {}
    --- 组件对象回收池
    self.mComponentList_Recycle = {}
    --- 实体列表
    self.mEntityList = {}
    --- 过滤组列表
    self.mGroupList = {}     -- 由group id索引
    self.mGroupMap_Comp = {} -- 由组件id索引，有重复
    --[[
        mGroupMap_Comp = {
            [1] = {...},
            [10] = {...}
        }
    ]]
    -- self.mGroupMap_Act = {} -- 由Added、Removed动作和数字id索引，有重复
    --[[
        mGroupMap_Act = {
            OnAdd = {
                [5612] = { ... }
            },
            OnRemoved = {},
            OnUpdate = {}
        }
    ]]
    --- 实体UID，自增
    self.mEntityUID = 0
    --- 匹配器实例，只需要一个
    self.mMatcher = Matcher.new()

    self:_InitGroupData()
end

function Context:Reset()
    self:ClearGroup()
    self:DestroyAllEntities()
    self.mEntityUID = 0
end

function Context:ClearGroup()
    for _, set in pairs(self.mGroupList) do
        for _, group in pairs(set) do
            group:ClearEntity()
        end
    end
    self.mGroupList = {}
    self:_InitGroupData()
end

function Context:DestroyAllEntities()
    for _, entity in pairs(self.mEntityList) do
        self:_OnDestroyEntity(entity)
    end
end

-----------------------------------------------------------------------------------------------------------------------
-- Context 私有方法
-----------------------------------------------------------------------------------------------------------------------

---获取实体uid
---@return integer UID
function Context:_GetEntityUID()
    self.mEntityUID = self.mEntityUID + 1
    return self.mEntityUID
end

function Context:_InitGroupData()
    for key, value in pairs(GameComponentLookUp) do
        self.mGroupMap_Comp[value] = {}
    end
end

-----------------------------------------------------------------------------------------------------------------------
-- Entity 实体相关
-----------------------------------------------------------------------------------------------------------------------

--- 创建Entity
---@return Entity 实体
function Context:CreateEntity()
    local entity = nil
    if #self.mEntityList_Recycle > 0 then
        entity = table.remove(self.mEntityList_Recycle, #self.mEntityList_Recycle)
    else
        entity = Entity.new(self)
    end
    entity.mUID = self:_GetEntityUID()
    entity.onAddedComponent = self._OnAddComponent
    entity.onUpdatedComponent = self._OnUpdateComponent
    entity.onRemovedComponent = self._OnRemoveComponent
    self.mEntityList[entity.mUID] = entity
    return entity
end

---根据uid获取实体
---@param uid integer
---@return Entity entity对象
function Context:GetEntity(uid)
    if self.mEntityList[uid] then
        return self.mEntityList[uid]
    end
    return nil
end

function Context:_OnDestroyEntity(entity)
    if not entity then
        return
    end
    for comp_id, comp in pairs(entity.__component_indexer) do
        -- 先处理group
        for key, group in pairs(self.mGroupMap_Comp[comp_id]) do
            group:_OnDestroyEntity(entity)
        end
        -- 回收entity组件
        if not self.mComponentList_Recycle[comp_id] then
            self.mComponentList_Recycle[comp_id] = {}
        end
        table.insert(self.mComponentList_Recycle[comp_id], comp)
        entity:_OnRemoveComponent(comp)
    end
    -- 清理组件数据
    entity:OnDispose()
    -- 回收entity
    table.insert(self.mEntityList_Recycle, entity)
    if self.mEntityList[entity.mUID] then
        self.mEntityList[entity.mUID] = nil
    end
end

-----------------------------------------------------------------------------------------------------------------------
-- Component 组件相关
-----------------------------------------------------------------------------------------------------------------------

---获取组件实例，优先取回收的组件，不够时创建新的
---@param component_id integer 组件id
---@return Component 组件实例
function Context:_GetComponent(component_id)
    if self.mComponentList_Recycle[component_id] and
        #self.mComponentList_Recycle[component_id] > 0 then
        return table.remove(self.mComponentList_Recycle[component_id], 1)
    end
    local comp = GameComponentScript[component_id].new()
    comp.__id = component_id
    return comp
end

---实体添加组件
---@param e Entity 实体对象
---@param component Component 组件对象
function Context:_OnAddComponent(e, component)
    local id = component.__id
    for _, group in pairs(self.mGroupMap_Comp[id]) do
        group:_OnAddComponent(e, id)
    end
end

---实体移除组件
---@param e Entity 实体对象
---@param component Component 组件对象
function Context:_OnRemoveComponent(e, component)
    local id = component.__id
    for _, group in pairs(self.mGroupMap_Comp[id]) do
        group:_OnRemoveComponent(e, id)
    end
end

function Context:_OnUpdateComponent(e, component)
    local id = component.__id
    for _, group in pairs(self.mGroupMap_Comp[id]) do
        group:_OnUpdateComponent(e, id)
    end
end

-----------------------------------------------------------------------------------------------------------------------
-- System 系统相关
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Group 过滤组相关
-----------------------------------------------------------------------------------------------------------------------

---获取匹配器
---@return Matcher 匹配器实例
function Context:GetMatcher()
    return self.mMatcher:Reset()
end

---获取过滤组
---@param matcher Matcher 匹配器
---@return Group 过滤组实例
function Context:GetGroup(matcher)
    if not matcher then 
        return nil 
    end
    local group = nil
    local id = self:_GenerateGroupID(matcher)

    -- 找出已有的group
    if self.mGroupList[id] then
        for _, g in pairs(self.mGroupList[id]) do
            if g:_Match(matcher) then
                group = g
                break
            end
        end
    end

    -- 创建新的group
    if not group then
        group = Group.new(id, matcher)
        -- 加入id索引列表
        if not self.mGroupList[id] then
            self.mGroupList[id] = {}
        end
        table.insert(self.mGroupList[id], group)

        -- 加入组件索引列表
        for _, comp_id in pairs(matcher.mAllOfContent) do
            table.insert(self.mGroupMap_Comp[comp_id], group)
        end
        for _, comp_id in pairs(matcher.mNoneOfContent) do
            table.insert(self.mGroupMap_Comp[comp_id], group)
        end
    end

    return group
end

---生成过滤组id，组件id简单求和做id有碰撞概率，所以不是唯一id，但是可以大幅减少无用的遍历
---@param matcher Matcher 匹配器实例
---@return integer id
function Context:_GenerateGroupID(matcher)
    local id = 0
    for _, value in ipairs(matcher.mAllOfContent) do
        id = id + value
    end
    for _, value in ipairs(matcher.mNoneOfContent) do
        id = id + value
    end

    return id
end

-----------------------------------------------------------------------------------------------------------------------
-- Collector 收集器相关
-----------------------------------------------------------------------------------------------------------------------
---@param groups Group[]                        过滤组数组
---@param groupEvents GroupChangeEvent[]        过滤组变化事件数组
---@return Collector collector                  收集器对象
function Context:GetCollector(groups, groupEvents)
    local collector = Collector.new(groups, groupEvents)
    return collector
end


-----------------------------------------------------------------------------------------------------------------------
-- DebugLog debug相关
-----------------------------------------------------------------------------------------------------------------------
function Context:PrintEntitasId()
    local idList = {}
    for i = 1, #self.mEntityList do
        table.insert(idList, self.mEntityList[i].mUID)
    end
    print("ContextEntitasId  :",table.concat(idList, ","))
end

return Context