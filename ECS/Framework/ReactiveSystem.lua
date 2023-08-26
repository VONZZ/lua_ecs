-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 响应性系统
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
local _Base = require("ECS.Framework.System")
---@class ReactiveSystem
local ReactiveSystem = class("ReactiveSystem", _Base)

function ReactiveSystem:ctor(contexts)
    ---@type Collector
    self.mCollector = self:GetCollector(contexts)
    self.mBuffer = {}
end

---获取收集器,子类需要重写
---@param contexts Contexts
function ReactiveSystem:GetCollector(contexts)
    
end

---过滤后的entitas变化回调,子类需要重写
---@param entities Entity[]
function ReactiveSystem:ChangeExecute(entities)
    
end

---entity过滤条件
---@param entity Entity
---@return boolean
function ReactiveSystem:Filter(entity)
    return true
end

---每帧处理收集的entity
function ReactiveSystem:Execute()
    if(self.mCollector:HasCollectedEntities()) then
        for i = 1, #self.mCollector.mCollectedEntities do
            local entity = self.mCollector.mCollectedEntities[i]
            if self:Filter(entity) then
                self.mBuffer[#self.mBuffer + 1] = entity
            end
        end
    end
    ---过滤完收集到的entity就清空收集器的entity数组
    self.mCollector:ClearCollectedEntities()

    ---执行entitas变更方法，子类自行处理这些entitas
    if #self.mBuffer > 0 then
        self:ChangeExecute(self.mBuffer)
        self.mBuffer = {}
    end
end

---激活
function ReactiveSystem:Activate()
    self.mCollector:Activate()
end

---取消激活
function ReactiveSystem:Deactivate()
    self.mCollector:Deactivate()
end

---释放
function ReactiveSystem:OnDispose()
    self:Deactivate()
end

return ReactiveSystem