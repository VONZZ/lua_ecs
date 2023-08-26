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

function Feature:Initialize()
    for i = 1, #self.__systems do
        self.__systems[i]:Initialize()
    end
end

function Feature:Execute(dt)
    for i = 1, #self.__systems do
        self.__systems[i]:Execute(dt)
    end
end

function Feature:OnDispose()
    for i = #self.__systems , 1, -1 do
        self.__systems[i]:OnDispose()
    end
    self.__systems = {}
end

return Feature