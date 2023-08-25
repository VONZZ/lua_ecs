-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 系统集基类
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
local Feature = class('Feature')

function Feature:ctor()
    self.__systems = {}
end

function Feature:Add(sys, contexts)
    table.insert(self.__systems, sys.new(contexts))
end

function Feature:Execute(dt)
    for _, system in ipairs(self.__systems) do
        system:Execute(dt)
    end
end

function Feature:OnDispose()
    for key, system in ipairs(self.__systems) do
        system:OnDispose()
        self.__systems[key] = nil
    end
    self.__systems = {}
end

return Feature