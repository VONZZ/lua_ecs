-------------------------------------------------------------------------------------------------
-- 自动生成，请勿改动
-------------------------------------------------------------------------------------------------
local GameContext = require("ECS.Generated.Game.GameContext")
local InputContext = require("ECS.Generated.Input.InputContext")

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
    self.game = nil
    self.input = nil
end

function Contexts:SetAllContexts()
    self.game = GameContext.new()
    self.input = InputContext.new()
end

return Contexts
