
function class(className, super) -- className 是类名,super 为父类(可为空)
    -- 构建类
    local clazz = { __cname = className, super = super }
    if super then
        -- 设置类的元表，此类中没有的，可以查找父类是否含有
        setmetatable(clazz, { __index = super })
    end
    -- new 方法创建类对象
    clazz.new = function(...)
        -- 构造一个对象
        local instance = {}
        -- 设置对象的元表为当前类，这样，对象就可以调用当前类生命的方法了
        setmetatable(instance, { __index = clazz })
        if clazz.ctor then
            clazz.ctor(instance, ...)
        end
        return instance
    end
    return clazz
end

function split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == "") then return false end
    local pos, arr = 0, {}
    for st, sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

---table是否为{}
---@param t any
---@return boolean
function table_is_empty(t)
    return _G.next( t ) == nil
  end
  