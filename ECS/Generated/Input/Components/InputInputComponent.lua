local _Base = require('ECS.Framework.Component')
local InputComponent = class('InputComponent', _Base)

function InputComponent:Init(attack)
     self.attack = attack == nil and false or false
end

function InputComponent:SetData(attack)
     self.attack = attack == nil and self.attack or attack
end

return InputComponent
        