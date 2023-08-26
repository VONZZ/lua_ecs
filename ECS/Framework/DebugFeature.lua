local _Base = require("ECS.Framework.Feature")
local DebugFeature = class("DebugFeature", _Base)

function DebugFeature:ctor()
    self.super.ctor(self)

end

function DebugFeature:Execute(dt)
    _Base.Execute(self, dt)
    self:_debugLog()
end

function DebugFeature:_debugLog()
    print("__initializeSystems  count :", #self.__initializeSystems)
    print("__executeSystems  count :", #self.__executeSystems)
    print("__reactiveSystems  count :", #self.__reactiveSystems)
end

return DebugFeature