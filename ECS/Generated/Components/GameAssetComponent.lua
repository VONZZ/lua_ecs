local _Base = require('ECS.Framework.Component')
local AssetComponent = class('AssetComponent', _Base)

function AssetComponent:Init(path)
     self.path = path or ""
end

function AssetComponent:SetData(path)
     self.path = path or self.path
end

return AssetComponent
