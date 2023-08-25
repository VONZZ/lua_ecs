-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 过滤组
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
---@type EventList
local EventList = require("ECS.Framework.EventList")
local GroupChangeEvent = GroupChangeEvent
local Group = class("Group")

function Group:ctor(id, matcher)
    self:Reset()
    self.mIsDirty = true
    self.mAnyMode = matcher.mAnyMode
    self.mGroupChangeEventList = EventList.new()

    for _, value in pairs(matcher.mAllOfContent) do
        self.mAllOfIndexer[value] = true
        table.insert(self.mAllOfContent, value)
    end
    for _, value in pairs(matcher.mNoneOfContent) do
        self.mNoneOfIndexer[value] = true
        table.insert(self.mNoneOfContent, value)
    end
    self.mID = id
    --- 实体对象缓存
    self.__entities = {}
    --[[
        self.__entities = {
            [uid] = entity,
            [uid] = entity,
            ...
        }
    ]]
end

function Group:registerGroupChangeEvent(callback)
    self.mGroupChangeEventList:registerCallBack(callback)
end

function Group:OnDispose()
    self.mGroupChangeEventList:unregisterAll()
end

function Group:Reset()
    self.mAllOfContent = {}
    self.mNoneOfContent = {}

    self.mAllOfIndexer = {}
    self.mNoneOfIndexer = {}

    self.mAnyMode = false

    self.mEntityIndexer = {}
    --- 实体对象缓存
    self.__entities = {}
end

function Group:ClearEntity()
    self.__entities = {}
end

---获取实体列表
function Group:GetEntities()
    return self.__entities
end

function Group:Test_GetEntities()
    for key, value in pairs(self:GetEntities()) do
        print(self.mID, key)
    end
end

-----------------------------------------------------------------------------------------------------------------------
-- Group 私有方法
-----------------------------------------------------------------------------------------------------------------------

function Group:_OnDestroyEntity(e)
    if self.__entities[e.mUID] then
        self.__entities[e.mUID] = nil
        self.mGroupChangeEventList:invoke(self, e, GroupChangeEvent.Removed)
    end
end

---添加组件
---@param e Entity
---@param comp_id integer
function Group:_OnAddComponent(e, comp_id)
    if self:_MatchEntity(e) then
        self.__entities[e.mUID] = e
        self.mGroupChangeEventList:invoke(self, e, GroupChangeEvent.Added)
    end
end

---移除组件
---@param e Entity
---@param comp_id integer
function Group:_OnRemoveComponent(e, comp_id)
    if self:_MatchEntity(e) then
        self.__entities[e.mUID] = nil
        self.mGroupChangeEventList:invoke(self, e, GroupChangeEvent.Removed)
    end
end

---更新组件
---@param e Entity
---@param comp_id integer
function Group:_OnUpdateComponent(e, comp_id)
    if self:_MatchEntity(e) then
        self.mGroupChangeEventList:invoke(self, e, comp_id, GroupChangeEvent.Updated)
    end
end

---匹配匹配器
---@param matcher Matcher
---@return boolean
function Group:_Match(matcher)
    if #matcher.mAllOfContent ~= #self.mAllOfContent or #matcher.mNoneOfContent ~= #self.mNoneOfContent then
        return false
    end
    for _, value in pairs(matcher.mAllOfContent) do
        if not self.mAllOfIndexer[value] then
            return false
        end
    end
    for _, value in pairs(matcher.mNoneOfContent) do
        if not self.mNoneOfIndexer[value] then
            return false
        end
    end
    return true
end

---匹配实体
---@param e Entity
---@return boolean
function Group:_MatchEntity(e)
    local pass_all = self.mAnyMode
    for _, id in pairs(self.mAllOfContent) do
        if self.mAnyMode then
            if e:HasComponent(id) then
                pass_all = true
                break
            end
        else
            if not e:HasComponent(id) then
                return false
            end
        end
    end
    for _, id in pairs(self.mNoneOfContent) do
        if e:HasComponent(id) then
            return false
        end
    end
    return pass_all
end

return Group
