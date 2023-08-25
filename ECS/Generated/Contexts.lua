-------------------------------------------------------------------------------------------------
-- 自动生成，请勿改动
-------------------------------------------------------------------------------------------------
local Context = require("ECS.Framework.Context")
local Contexts = class("Contexts")

local _instance = nil

function Contexts.Instance()
    if not _instance then
        _instance = Contexts.new()
    end
    return _instance
end

function Contexts:ctor()
    self.game = nil
    self.input = nil
end

function Contexts:SetAllContexts()
    self.game = Context.new()
    self.input = Context.new()
end


return Contexts
