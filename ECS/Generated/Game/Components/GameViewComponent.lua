local _Base = require('ECS.Framework.Component')
local ViewComponent = class('ViewComponent', _Base)

function ViewComponent:Init(gameObject, id)
     self.gameObject = gameObject or ""
     self.id = id or 0
end

function ViewComponent:SetData(gameObject, id)
     self.gameObject = gameObject or self.gameObject
     self.id = id or self.id
end

return ViewComponent
        