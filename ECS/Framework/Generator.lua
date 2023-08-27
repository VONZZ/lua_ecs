--============================================================================================
-- ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓

local contextType = {
    "Game",
    "Input",
}

local compMap = {
    Game = {
        "ECS\\Game\\Component\\AssetComponent.lua",
        "ECS\\Game\\Component\\ViewComponent.lua",
    },
    Input = {
        "ECS\\Input\\Component\\InputComponent.lua",
    }
}


-- ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑
--============================================================================================

require("Core.functions")
local entity_extention = {}
--[[
    entity_extention = {
        [contextName] = {
            {
                name = componentName
                parma = 'id, list, bol'
            }
        }
        ...
    }
]]

---------------------------------------------------------------------------------------
-- 生成Component代码
---------------------------------------------------------------------------------------
print("----------- 生成Component代码 -----------------------------------------------")

for _, contextName in pairs(contextType) do
    local compList = compMap[contextName] or {}
    local generate_path = string.format('ECS\\Generated\\%s\\Components\\', contextName)
    for name, path in pairs(compList) do
        local code_comp = [[
local _Base = require('ECS.Framework.Component')
local [Name] = class('[Name]', _Base)

function [Name]:Init([Param])
[Prop]
end

function [Name]:SetData([Param])
[SetData]
end

return [Name]
        ]]
        local name = string.match(path, "[^%\\]+%w$")
        name = name:gsub('.lua', '')
        local comp = path:gsub('\\', '.')
        comp = comp:gsub('.lua', '')
        local script = require(comp)
    
        local file = io.open(path, "r")
        assert(file, "read file is nil")
        if not entity_extention[contextName] then
            entity_extention[contextName] = {}
        end
    
        ---------------- 处理属性字段 ----------------
        local content = ''
        local set_content = ''
        local index = 0
        local line = ''
        local param = ''
    
        for r in file:lines() do
            if table_is_empty(script) then
                break
            end
            index = index + 1
            if index >= 2 then
                if r == '}' then
                    break
                end
                line = r
                line = line:gsub(' ', '')
                line = line:gsub('\n', '')
                if line == '' then -- 处理空行
                    goto continue
                end
                if line:sub(#line) == ',' then
                    line = line:sub(1, #line - 1)
                end
                -- 分割行，1 = 属性名，2 = 属性默认值
                local sp_pos = line:find('=')
                local prop_name = line
                local prop_value = ''
                if sp_pos then
                    prop_name = line:sub(1, sp_pos - 1)
                    prop_value = line:sub(sp_pos + 1)
                end
    
    
                if nil == sp_pos then
                    content = string.format("%s     self.%s = %s\n", content, prop_name, prop_name)
                else
                    -- 需要处理布尔值，不能直接用or，否则不能正确赋值
                    if type(script[prop_name]) == 'boolean' then
                        content = string.format("%s     self.%s = %s == nil and false or %s\n", content, prop_name,
                            prop_name,
                            prop_value)
                    else
                        content = string.format("%s     self.%s = %s or %s\n", content, prop_name, prop_name, prop_value)
                    end
                end
    
    
                -- 需要处理布尔值，不能直接用or，否则不能正确赋值
                if type(script[prop_name]) == 'boolean' then
                    set_content = string.format("%s     self.%s = %s == nil and self.%s or %s\n", set_content, prop_name,
                        prop_name,
                        prop_name, prop_name)
                else
                    set_content = string.format("%s     self.%s = %s or self.%s\n", set_content, prop_name, prop_name,
                        prop_name)
                end
    
                ---------------- 处理参数 ----------------
                param = string.format('%s, %s', param, prop_name)
            end
            ::continue::
        end
        param = string.sub(param, 3, #param)
    
        file:close()
    
        content = content:gsub("\n[^\n]*$", "")
        set_content = set_content:gsub("\n[^\n]*$", "")
    
        code_comp = code_comp:gsub('%[Name]', name)
        code_comp = code_comp:gsub('%[Param]', param)
        code_comp = code_comp:gsub('%[Prop]', content)
        code_comp = code_comp:gsub('%[SetData]', set_content)
    
    
        -- 缓存到Entity扩展列表
        table.insert(entity_extention[contextName], {
            name = name, 
            param = param
        })
        os.execute("mkdir ".. generate_path)
        file = io.open(generate_path.. contextName .. name .. '.lua', 'w+')
    
        assert(file, "create file is nil")
        file:write(code_comp)
        file:close()
    end
end

---------------------------------------------------------------------------------------
-- 生成Entity代码
---------------------------------------------------------------------------------------
print("----------- 生成Entity代码 -----------------------------------------------")


for _, contextName in pairs(contextType) do
    local entity_path = "ECS\\Generated\\[T]\\[T]Entity.lua"

    local code_head = [[
    local _Base = require("ECS.Framework.Entity")
    local [T]Entity = class("[T]Entity", _Base)
    
    function [T]Entity:ctor(context)
        _Base.ctor(self, context)
        self.onAddedComponent = nil
        self.onUpdatedComponent = nil
        self.onRemovedComponent = nil
    end
    
    function [T]Entity:OnDispose()
    [ClearCode]
        self.onAddedComponent = nil
        self.onUpdatedComponent = nil
        self.onRemovedComponent = nil
    end
    
    ]]
    
    
    local code_body = [[
    
    --========= [Name] ========================================================================
    function [T]Entity:Add[PName]([Param])
        if self:HasComponent([T]ComponentLookUp.[Name]) then
            self:Update[PName]([Param])
            return
        end
        self.[PName] = self.context:_GetComponent([T]ComponentLookUp.[Name])
        self.[PName]:Init([Param])
        self:_OnAddComponent(self.[PName])
        if self.onAddedComponent then
            self.onAddedComponent(self.context, self, self.[PName])
        end
    end
    
    function [T]Entity:Update[PName]([Param])
        if not self:HasComponent([T]ComponentLookUp.[Name]) then
            self:Add[PName]([Param])
            return
        end
        self.[PName]:SetData([Param])
        if self.onUpdatedComponent then
            self.onUpdatedComponent(self.context, self, self.[PName])
        end
    end
    
    function [T]Entity:Remove[PName]()
        if not self:HasComponent([T]ComponentLookUp.[Name]) then 
            return 
        end
        self:_OnRemoveComponent(self.[PName])
        self.[PName] = nil
        if self.onRemovedComponent then
            self.onRemovedComponent(self.context, self, self.[PName])
        end
    end
    
    function [T]Entity:Has[PName]()
        return self:HasComponent([T]ComponentLookUp.[Name])
    end
    ]]
    
    local clear_builder = ''
    if entity_extention[contextName] then
        for _, list in pairs(entity_extention[contextName]) do
            local key = list.name
            local propery_name = key:gsub("Component", '')
            local code = code_body
            code = code:gsub('%[Param]', list.param)
            code = code:gsub('%[PName]', propery_name)
            code = code:gsub('%[Name]', key)
            code_head = code_head .. code
        
            clear_builder = clear_builder .. string.format("    self.%s = nil\n", propery_name)
        end
    end
    clear_builder = clear_builder:gsub("\n[^\n]*$", "")
    
    code_head = code_head:gsub('%[ClearCode]', clear_builder)
    code_head = code_head .. [[
    
    return [T]Entity
    ]]
    
    code_head = code_head:gsub('%[T]', contextName)
    code_body = code_body:gsub('%[T]', contextName)
    entity_path = entity_path:gsub('%[T]', contextName)

    os.execute("mkdir ECS\\Generated\\"..contextName)

    local entity_file = io.open(entity_path, "w+")
    assert(entity_file, "entity_file file is nil")
    entity_file:write(code_head)
    entity_file:close()
end

---------------------------------------------------------------------------------------
-- 生成ComponentDefine代码
---------------------------------------------------------------------------------------
print("----------- 生成ComponentDefine代码 -----------------------------------------------")

local path_context = "ECS\\Generated\\ComponentDefine.lua"
local code_context = [[
-------------------------------------------------------------------------------------------------
-- 自动生成，请勿改动
-------------------------------------------------------------------------------------------------

]]

local str = ""
for _, contextName in pairs(contextType) do
    local extention = entity_extention[contextName]
    local reqM = [[
[T]ComponentScript = {
[REQ]
}

]]
    local lokM = [[
[T]ComponentLookUp = {
[LOK]
}

]]
    local macM = [[
[T]EMatcher = {
[MAC]
}

]]
    local req = ''
    local lok = ''
    local mac = ''
    local index = 1
    for _, list in pairs(extention) do
        local key = list.name
        req = req .. string.format("    [%d] = require('ECS.Generated.%s.Components.%s%s'),\n", index,contextName, contextName, key)
        lok = lok .. string.format("    %s = %d,\n", key, index)
        mac = mac .. string.format("    %s = %d,\n", key:gsub('Component', ''), index)
        index = index + 1
    end
    req = req:gsub("\n[^\n]*$", "")
    lok = lok:gsub("\n[^\n]*$", "")
    mac = mac:gsub("\n[^\n]*$", "")

    reqM = reqM:gsub('%[REQ]', req)
    lokM = lokM:gsub('%[LOK]', lok)
    macM = macM:gsub('%[MAC]', mac)

    reqM = reqM:gsub('%[T]', contextName)
    lokM = lokM:gsub('%[T]', contextName)
    macM = macM:gsub('%[T]', contextName)
    str = str..reqM..lokM..macM
end

code_context = code_context..str

local context_file = io.open(path_context, "w+")
assert(context_file, "context_file file is nil")
context_file:write(code_context)
context_file:close()

---------------------------------------------------------------------------------------
-- 生成Contexts代码
---------------------------------------------------------------------------------------
print("----------- 生成Contexts代码 -----------------------------------------------")

local path_context = "ECS\\Generated\\Contexts.lua"
local code_context = [[
-------------------------------------------------------------------------------------------------
-- 自动生成，请勿改动
-------------------------------------------------------------------------------------------------
[RCT]
---@class Contexts
local Contexts = class("Contexts")

local _instance = nil

function Contexts.Instance()
    if not _instance then
        _instance = Contexts.new()
    end
    return _instance
end

function Contexts:ctor()
[CT]
end

function Contexts:SetAllContexts()
[NC]
end

return Contexts
]]

local ct = ''
local nc = ''
local rct = ''
for _, contextName in pairs(contextType) do
    ct = ct .. string.format("    self.%s = nil\n", string.lower(contextName))
    nc = nc .. string.format("    self.%s = %sContext.new()\n", string.lower(contextName), contextName)
    rct = rct .. string.format("local %sContext = require(\"ECS.Generated.%s.%sContext\")\n", contextName, contextName, contextName)
end
ct = ct:gsub("\n[^\n]*$", "")
nc = nc:gsub("\n[^\n]*$", "")

code_context = code_context:gsub('%[CT]', ct)
code_context = code_context:gsub('%[NC]', nc)
code_context = code_context:gsub('%[RCT]', rct)

local context_file = io.open(path_context, "w+")
assert(context_file, "context_file file is nil")
context_file:write(code_context)
context_file:close()

---------------------------------------------------------------------------------------
-- 生成Context<T>代码
---------------------------------------------------------------------------------------
print("----------- 生成TContext<T>代码 -----------------------------------------------")


for _, contextName in pairs(contextType) do
    local path_context = "ECS\\Generated\\[T]\\[T]Context.lua"
    local code_context = [[
    -------------------------------------------------------------------------------------------------
    -- 自动生成，请勿改动
    -------------------------------------------------------------------------------------------------
    local _Base = require("ECS.Framework.Context")
    local Entity = require("ECS.Generated.[T].[T]Entity")
    ---@class [T]Context
    local [T]Context = class("[T]Context", _Base)
    
    function [T]Context:_GetEntityClass()
        return Entity
    end
    
    return [T]Context
    ]]
    
    code_context = code_context:gsub('%[T]', contextName)
    path_context = path_context:gsub('%[T]', contextName)
    
    local context_file = io.open(path_context, "w+")
    assert(context_file, "context_file file is nil")
    context_file:write(code_context)
    context_file:close()
end

print("----------- 代码生成完毕 ------------------------------------------------------")
