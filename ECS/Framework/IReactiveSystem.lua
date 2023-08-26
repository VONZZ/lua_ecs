-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 系统基类（监听entity组件变化的system）
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
local _Base = require("ECS.Framework.IExecuteSystem")
local IReactiveSystem = class("IReactiveSystem", _Base)
---@class IReactiveSystem
function IReactiveSystem:ctor(contexts)
    _Base.ctor(self, contexts)
    self.__systemType = self.__systemType | ISystemType.IReactive
end

---激活
function IReactiveSystem:Activate() end

---取消激活
function IReactiveSystem:Deactivate() end

---释放
function IReactiveSystem:OnDispose() end

return IReactiveSystem