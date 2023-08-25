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
    self.input = nil
    self.game = nil
end

function Contexts:SetAllContexts()
    self.input = Context.new()
    self.game = Context.new()
end


return Contexts
