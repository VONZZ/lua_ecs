-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 系统基类
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

local System = class("System")

function System:ctor(contexts)
    self:Initialize(contexts)
end

---初始化函数
function System:Initialize(contexts)

end

---每帧执行函数
function System:Execute(dt)

end

---释放函数
function System:OnDispose()

end

return System
