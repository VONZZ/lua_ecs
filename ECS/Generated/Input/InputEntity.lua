    local _Base = require("ECS.Framework.Entity")
    local InputEntity = class("InputEntity", _Base)
    
    function InputEntity:ctor(context)
        _Base.ctor(self, context)
        self.onAddedComponent = nil
        self.onUpdatedComponent = nil
        self.onRemovedComponent = nil
    end
    
    function InputEntity:OnDispose()
        self.Input = nil
        self.onAddedComponent = nil
        self.onUpdatedComponent = nil
        self.onRemovedComponent = nil
    end
    
        
    --========= InputComponent ========================================================================
    function InputEntity:AddInput(attack)
        if self:HasComponent(InputComponentLookUp.InputComponent) then
            self:UpdateInput(attack)
            return
        end
        self.Input = self.context:_GetComponent(InputComponentLookUp.InputComponent)
        self.Input:Init(attack)
        self:_OnAddComponent(self.Input)
        if self.onAddedComponent then
            self.onAddedComponent(self.context, self, self.Input)
        end
    end
    
    function InputEntity:UpdateInput(attack)
        if not self:HasComponent(InputComponentLookUp.InputComponent) then
            self:AddInput(attack)
            return
        end
        self.Input:SetData(attack)
        if self.onUpdatedComponent then
            self.onUpdatedComponent(self.context, self, self.Input)
        end
    end
    
    function InputEntity:RemoveInput()
        if not self:HasComponent(InputComponentLookUp.InputComponent) then 
            return 
        end
        self:_OnRemoveComponent(self.Input)
        self.Input = nil
        if self.onRemovedComponent then
            self.onRemovedComponent(self.context, self, self.Input)
        end
    end
    
    function InputEntity:HasInput()
        return self:HasComponent(InputComponentLookUp.InputComponent)
    end
        
    return InputEntity
    