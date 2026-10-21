local _, PT = ...
local Icon = {}
PT:RegisterModule("Minimap", Icon)

function Icon:Update()
    if not self.button then return end
    -- Buttonsammel-Addons dürfen den Button umhängen und selbst positionieren.
    if self.button:GetParent() == Minimap then
        local angle = math.rad(self.owner.db.minimapAngle)
        self.button:ClearAllPoints()
        self.button:SetPoint("CENTER", Minimap, "CENTER",
            math.cos(angle) * (Minimap:GetWidth() / 2 + 8),
            math.sin(angle) * (Minimap:GetHeight() / 2 + 8))
    end
    self.button:SetShown(self.owner.db.minimapIcon)
end

function Icon:Drag()
    if self.button:GetParent() ~= Minimap then return end
    local x, y = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    local cx, cy = Minimap:GetCenter()
    if not cx or not cy or not scale or scale == 0 then return end
    local dx = (x / scale - cx) / (Minimap:GetWidth() / 2 + 8)
    local dy = (y / scale - cy) / (Minimap:GetHeight() / 2 + 8)
    local atan2 = math.atan2 or math.atan
    self.owner.db.minimapAngle = math.deg(atan2(dy, dx)) % 360
    self:Update()
end

function Icon:Initialize(owner)
    self.owner = owner
    if not Minimap then return end
    local button = CreateFrame("Button", "PatchToolsMinimapButton", Minimap)
    self.button = button
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local texture = button:CreateTexture(nil, "BACKGROUND")
    texture:SetTexture("Interface\\Icons\\Ability_Hunter_Pet_Cat")
    texture:SetPoint("TOPLEFT", 5, -5)
    texture:SetPoint("BOTTOMRIGHT", -5, 5)
    button.icon = texture
    button:SetNormalTexture(texture)
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT")
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(button, "ANCHOR_LEFT")
        GameTooltip:SetText("PatchTools " .. owner.version)
        GameTooltip:AddLine(owner:T("ICON_CLICK"), 1, 1, 1)
        GameTooltip:AddLine(owner:T("ICON_DRAG"), 1, 1, 1)
        GameTooltip:AddLine(owner:T("ICON_HIDE"), 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnClick", function(_, mouseButton)
        if self.dragged then self.dragged = false; return end
        -- Strg-Rechtsklick wird u.a. von MBB zum Herauslösen/Einordnen verwendet.
        if mouseButton == "RightButton" and IsControlKeyDown and IsControlKeyDown() then return end
        owner:OpenOptions()
    end)
    button:SetScript("OnDragStart", function()
        if button:GetParent() ~= Minimap then return end
        self.dragged = true
        GameTooltip:Hide()
        button:SetScript("OnUpdate", function() self:Drag() end)
    end)
    button:SetScript("OnDragStop", function()
        button:SetScript("OnUpdate", nil)
        self:Drag()
        C_Timer.After(0, function() self.dragged = false end)
    end)
    button:SetScript("OnHide", function() button:SetScript("OnUpdate", nil) end)
    self:Update()
end
