-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 系统集基类
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
local Feature = class('Feature')

function Feature:ctor()
    self.__initializeSystems = {}
    self.__executeSystems = {}
    self.__reactiveSystems = {}
end

function Feature:Add(sys, contexts)
    local system = sys.new(contexts)
    if system.__systemType & ISystemType.IInitialize > 0 then
        table.insert(self.__initializeSystems, system)
    end
    if system.__systemType & ISystemType.IExecute > 0 then
        table.insert(self.__executeSystems, system)
    end
    if system.__systemType & ISystemType.IReactive > 0 then
        table.insert(self.__reactiveSystems, system)
    end
end

function Feature:Initialize()
    for i = 1, #self.__initializeSystems do
        self.__initializeSystems[i]:Initialize()
    end
end

function Feature:Execute(dt)
    for i = 1, #self.__executeSystems do
        self.__executeSystems[i]:Execute(dt)
    end
end

function Feature:ActiveReactiveSystems()
    for i = #self.__reactiveSystems , 1, -1 do
        self.__reactiveSystems[i]:Activate()
    end
end

function Feature:DeactiveReactiveSystems()
    for i = #self.__reactiveSystems , 1, -1 do
        self.__reactiveSystems[i]:Deactivate()
    end
end

function Feature:OnDispose()
    for i = #self.__reactiveSystems , 1, -1 do
        self.__reactiveSystems[i]:OnDispose()
    end
    self.__reactiveSystems = {}
end

return Feature