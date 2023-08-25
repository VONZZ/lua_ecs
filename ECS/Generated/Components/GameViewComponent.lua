local _Base = require('ECS.Framework.Component')
local ViewComponent = class('ViewComponent', _Base)

function ViewComponent:Init(gameObject)
     self.gameObject = gameObject or ""
end

function ViewComponent:SetData(gameObject)
     self.gameObject = gameObject or self.gameObject
end

return ViewComponent
