--============================================================================================
-- ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓

local process = {
    AssetComponent = "ECS\\Game\\Component\\AssetComponent.lua",
    ViewComponent = "ECS\\Game\\Component\\ViewComponent.lua",
}

local contextType = {
    game = "game",
    input = "input"
}


-- ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑
--============================================================================================

require("Core.functions")
local generate_path = 'ECS\\Generated\\Components\\Game'

local entity_extention = {}
--[[
    entity_extention = {
        [TestComponent] = 'id, list, bol'
    }
]]
---------------------------------------------------------------------------------------
-- 生成GameComponent代码
---------------------------------------------------------------------------------------
print("----------- 生成GameComponent代码 -----------------------------------------------")

for name, path in pairs(process) do
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

    local comp = path:gsub('\\', '.')
    comp = comp:gsub('.lua', '')
    local script = require(comp)

    local file = io.open(path, "r")
    assert(file, "read file is nil")

    entity_extention[name] = {}

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


    -- 缓存到GameEntity扩展列表
    entity_extention[name] = param

    file = io.open(generate_path .. name .. '.lua', 'w+')

    assert(file, "create file is nil")
    file:write(code_comp)
    file:close()
end

---------------------------------------------------------------------------------------
-- 生成GameEntity代码
---------------------------------------------------------------------------------------
print("----------- 生成GameEntity代码 -----------------------------------------------")

local entity_path = "ECS\\Generated\\GameEntity.lua"

local code_head = [[
local GameEntity = class("GameEntity")

function GameEntity:ctor(context)
    self.context = context
    self.onAddedComponent = nil
    self.onUpdatedComponent = nil
    self.onRemovedComponent = nil
end

function GameEntity:OnDispose()
[ClearCode]
    self.onAddedComponent = nil
    self.onUpdatedComponent = nil
    self.onRemovedComponent = nil
end

]]


local code_body = [[

--========= [Name] ========================================================================
function GameEntity:Add[PName]([Param])
    if self:HasComponent(GameComponentLookUp.[Name]) then
        self:Update[PName]([Param])
        return
    end
    self.[PName] = self.context:_GetComponent(GameComponentLookUp.[Name])
    self.[PName]:Init([Param])
    self:_OnAddComponent(self.[PName])
    if self.onAddedComponent then
        self.onAddedComponent(self.context, self, self.[PName])
    end
end

function GameEntity:Update[PName]([Param])
    if not self:HasComponent(GameComponentLookUp.[Name]) then
        self:Add[PName]([Param])
        return
    end
    self.[PName]:SetData([Param])
    if self.onUpdatedComponent then
        self.onUpdatedComponent(self.context, self, self.[PName])
    end
end

function GameEntity:Remove[PName]()
    if not self:HasComponent(GameComponentLookUp.[Name]) then 
        return 
    end
    self:_OnRemoveComponent(self.[PName])
    self.[PName] = nil
    if self.onRemovedComponent then
        self.onRemovedComponent(self.context, self, self.[PName])
    end
end

function GameEntity:Has[PName]()
    return self:HasComponent(GameComponentLookUp.[Name])
end
]]

local clear_builder = ''

for key, value in pairs(entity_extention) do
    local propery_name = key:gsub("Component", '')
    local code = code_body
    code = code:gsub('%[Param]', value)
    code = code:gsub('%[PName]', propery_name)
    code = code:gsub('%[Name]', key)
    code_head = code_head .. code

    clear_builder = clear_builder .. string.format("    self.%s = nil\n", propery_name)
end

clear_builder = clear_builder:gsub("\n[^\n]*$", "")

code_head = code_head:gsub('%[ClearCode]', clear_builder)
code_head = code_head .. [[

return GameEntity
]]


local entity_file = io.open(entity_path, "w+")
assert(entity_file, "entity_file file is nil")
entity_file:write(code_head)
entity_file:close()

---------------------------------------------------------------------------------------
-- 生成ComponentDefine代码
---------------------------------------------------------------------------------------
print("----------- 生成ComponentDefine代码 -----------------------------------------------")

local path_context = "ECS\\Generated\\ComponentDefine.lua"
local code_context = [[
-------------------------------------------------------------------------------------------------
-- 自动生成，请勿改动
-------------------------------------------------------------------------------------------------

GameComponentScript = {
[REQ]
}

GameComponentLookUp = {
[LOK]
}

--- 组件匹配id，和GameComponentLookUp保持一致，主要是为了书写简洁
EMatcher = {
[MAC]
}
]]

local req = ''
local lok = ''
local mac = ''
local index = 1
for key, value in pairs(entity_extention) do
    req = req .. string.format("    [%d] = require('ECS.Generated.Components.Game%s'),\n", index, key)
    lok = lok .. string.format("    %s = %d,\n", key, index)
    mac = mac .. string.format("    %s = %d,\n", key:gsub('Component', ''), index)
    index = index + 1
end

lok = lok:gsub("\n[^\n]*$", "")
mac = mac:gsub("\n[^\n]*$", "")

code_context = code_context:gsub('%[REQ]', req)
code_context = code_context:gsub('%[LOK]', lok)
code_context = code_context:gsub('%[MAC]', mac)

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
local Context = require("ECS.Framework.Context")
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
for key, value in pairs(contextType) do
    ct = ct .. string.format("    self.%s = nil\n", key)
    nc = nc .. string.format("    self.%s = Context.new()\n", key)
end
ct = ct:gsub("\n[^\n]*$", "")
nc = nc:gsub("\n[^\n]*$", "")

code_context = code_context:gsub('%[CT]', ct)
code_context = code_context:gsub('%[NC]', nc)

local context_file = io.open(path_context, "w+")
assert(context_file, "context_file file is nil")
context_file:write(code_context)
context_file:close()

print("----------- 代码生成完毕 ------------------------------------------------------")
