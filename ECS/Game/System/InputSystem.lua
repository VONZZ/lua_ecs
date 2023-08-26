local _Base = require("ECS.Framework.IExecuteSystem")
local InputSystem = class("InputSystem", _Base)

function InputSystem:ctor(contexts)
    _Base.ctor(self, contexts)
    self.context = contexts.input
end

function InputSystem:Execute()
    print("input system execute!!!!!")
end

return InputSystem