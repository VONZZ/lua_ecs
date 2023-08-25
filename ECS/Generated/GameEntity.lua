local GameEntity = class("GameEntity")

function GameEntity:ctor(context)
    self.context = context
    self.onAddedComponent = nil
    self.onUpdatedComponent = nil
    self.onRemovedComponent = nil
end

function GameEntity:OnDispose()
    self.Asset = nil
    self.View = nil
    self.onAddedComponent = nil
    self.onUpdatedComponent = nil
    self.onRemovedComponent = nil
end


--========= AssetComponent ========================================================================
function GameEntity:AddAsset(path)
    if self:HasComponent(GameComponentLookUp.AssetComponent) then
        self:UpdateAsset(path)
        return
    end
    self.Asset = self.context:_GetComponent(GameComponentLookUp.AssetComponent)
    self.Asset:Init(path)
    self:_OnAddComponent(self.Asset)
    if self.onAddedComponent then
        self.onAddedComponent(self.context, self, self.Asset)
    end
end

function GameEntity:UpdateAsset(path)
    if not self:HasComponent(GameComponentLookUp.AssetComponent) then
        self:AddAsset(path)
        return
    end
    self.Asset:SetData(path)
    if self.onUpdatedComponent then
        self.onUpdatedComponent(self.context, self, self.Asset)
    end
end

function GameEntity:RemoveAsset()
    if not self:HasComponent(GameComponentLookUp.AssetComponent) then 
        return 
    end
    self:_OnRemoveComponent(self.Asset)
    self.Asset = nil
    if self.onRemovedComponent then
        self.onRemovedComponent(self.context, self, self.Asset)
    end
end

function GameEntity:HasAsset()
    return self:HasComponent(GameComponentLookUp.AssetComponent)
end

--========= ViewComponent ========================================================================
function GameEntity:AddView(gameObject)
    if self:HasComponent(GameComponentLookUp.ViewComponent) then
        self:UpdateView(gameObject)
        return
    end
    self.View = self.context:_GetComponent(GameComponentLookUp.ViewComponent)
    self.View:Init(gameObject)
    self:_OnAddComponent(self.View)
    if self.onAddedComponent then
        self.onAddedComponent(self.context, self, self.View)
    end
end

function GameEntity:UpdateView(gameObject)
    if not self:HasComponent(GameComponentLookUp.ViewComponent) then
        self:AddView(gameObject)
        return
    end
    self.View:SetData(gameObject)
    if self.onUpdatedComponent then
        self.onUpdatedComponent(self.context, self, self.View)
    end
end

function GameEntity:RemoveView()
    if not self:HasComponent(GameComponentLookUp.ViewComponent) then 
        return 
    end
    self:_OnRemoveComponent(self.View)
    self.View = nil
    if self.onRemovedComponent then
        self.onRemovedComponent(self.context, self, self.View)
    end
end

function GameEntity:HasView()
    return self:HasComponent(GameComponentLookUp.ViewComponent)
end

return GameEntity
