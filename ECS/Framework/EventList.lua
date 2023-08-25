-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 事件列表
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

---@class EventList
local EventList = class("EventList")

function EventList:ctor()
    self.subscribers = {}
    ---拓展类的+-操作添加/移除事件
    local meta = getmetatable(self)
    meta.__add = function (a, callback)
        a:registerCallBack(callback)
        return a
    end
    meta.__sub = function (a, callback)
        a:unregisterCallBack(callback)
        return a
    end
end

function EventList:append(event)
    for _, subscriber in pairs(event.subscribers) do
        self:registerCallBack(subscriber)
    end
end

function EventList:registerCallBack(callback)
    if not callback then
        return
    end
    table.insert(self.subscribers, callback)
end

function EventList:unregisterCallBack(callback)
    for pos, subscriber in pairs(self.subscribers) do
        if subscriber == callback then
            table.remove(self.subscribers, pos)
            break
        end
    end
end

function EventList:unregisterAll()
    self.subscribers = {}
end

function EventList:invoke(...)
    if #self.subscribers == 0 then
        return true
    end
    local ret, intercept = true, nil
    for _, subscriber in pairs(self.subscribers) do
        ret, intercept = subscriber(...)
        ret = ret or false
        if intercept then
            break
        end
    end
    return ret
end

function EventList:hasSubscriber()
    return #self.subscribers > 0
end

return EventList