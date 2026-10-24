local _, PT = ...
local WIDTH, HEIGHT = 820, 650

function PT:ApplyOptionsAppearance()
    local value=tonumber(self.db.optionsTransparency) or 0
    if value~=value or math.abs(value)==math.huge then value=0 end
    value=math.max(0,math.min(.8,value))
    self.db.optionsTransparency=value
    if self.options then
        self.options:SetBackdropColor(.055,.045,.035,1-value)
        self.options:SetBackdropBorderColor(.48,.37,.23,1)
    end
end

function PT:SetOptionsWindowScale(value, left, top)
    local frame = self.options
    if not frame then return end
    value = tonumber(value)
    if not value or value ~= value or math.abs(value) == math.huge then value = 1 end
    local maximum = math.max(.6, math.min(1.5,
        (UIParent:GetWidth() - 24) / WIDTH, (UIParent:GetHeight() - 24) / HEIGHT))
    value = math.max(.6, math.min(maximum, value))
    frame:SetScale(value)
    self.db.optionsScale = value
    if left and top then
        -- Keep the top-left corner fixed in UIParent coordinates while scaling.
        local ratio = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left / ratio, top / ratio)
    end
end

function PT:ResetOptionsWindow()
    if not self.options then return end
    if self.optionsScaleGrip then self.optionsScaleGrip:SetScript("OnUpdate", nil) end
    self.options:StopMovingOrSizing()
    self:SetOptionsWindowScale(1)
    self.options:ClearAllPoints()
    self.options:SetPoint("CENTER")
end

function PT:InstallOptionsScaling(frame)
    self:SetOptionsWindowScale(self.db.optionsScale)
    local grip = CreateFrame("Button", nil, frame)
    self.optionsScaleGrip = grip
    grip:SetPoint("BOTTOMRIGHT", -3, 3)
    grip:SetSize(20, 20)
    grip:SetFrameLevel(frame:GetFrameLevel() + 10)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    local function Stop() grip:SetScript("OnUpdate", nil) end
    grip:SetScript("OnMouseDown", function(_, button)
        Stop()
        if button ~= "LeftButton" then return end
        if CloseDropDownMenus then CloseDropDownMenus() end
        GameTooltip:Hide()
        frame:StopMovingOrSizing()
        local parentScale = UIParent:GetEffectiveScale()
        local ratio = frame:GetEffectiveScale() / parentScale
        local left, top = frame:GetLeft() * ratio, frame:GetTop() * ratio
        local x, y = GetCursorPosition()
        local startScale = self.db.optionsScale
        grip:SetScript("OnUpdate", function()
            if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then Stop(); return end
            local cx, cy = GetCursorPosition()
            local change = ((cx - x) * WIDTH + (y - cy) * HEIGHT)
                / parentScale / (WIDTH * WIDTH + HEIGHT * HEIGHT)
            self:SetOptionsWindowScale(startScale + change, left, top)
        end)
    end)
    grip:SetScript("OnMouseUp", Stop)
    grip:SetScript("OnEnter", function()
        GameTooltip:SetOwner(grip, "ANCHOR_LEFT")
        GameTooltip:SetText(self:T("OPTIONS_SCALE_HINT"))
        GameTooltip:Show()
    end)
    grip:SetScript("OnLeave", function() GameTooltip:Hide() end)
    -- Preserve the settings page's save/refresh handlers installed by Options.lua.
    frame:HookScript("OnHide", Stop)
end
