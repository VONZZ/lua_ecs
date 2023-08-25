-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 匹配器
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

local Matcher = class("Matcher")

function Matcher:ctor()
    self:Reset()
end

function Matcher:OnDispose()

end

function Matcher:Reset()
    self.mAllOfContent = {}
    self.mNoneOfContent = {}
    self.mAnyMode = false
    return self
end

---必须拥有组件
---@param ... EMatcher
---@return table
function Matcher:AllOf(...)
    self.mAllOfContent = { ... }
    return self
end

---不包含组件
---@param ... EMatcher
---@return table
function Matcher:NoneOf(...)
    self.mNoneOfContent = { ... }
    return self
end

---包含任意组件 只要有其中一个就符合，和AllOf规则互斥
---@param ... EMatcher
---@return table
function Matcher:AnyOf(...)
    self.mAllOfContent = { ... }
    self.mAnyMode = true
    return self
end

return Matcher
