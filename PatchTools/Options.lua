local _, PT = ...
function PT:CreateOptions()
    local frame = CreateFrame("Frame", "PatchToolsOptions", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(560, 620)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame.TitleText:SetText("PatchTools " .. self.version .. " — WoW Forever")
    frame:Hide()
    self.options = frame
    tinsert(UISpecialFrames, "PatchToolsOptions")
    local function Text(text, y)
        local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("TOPLEFT", 24, y)
        label:SetWidth(510)
        label:SetJustifyH("LEFT")
        label:SetText(text)
        return label
    end
    Text(self:T("INTRO"), -38)
    local checks = {}
    local function Check(key, title, detail, y)
        local box = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
        box:SetPoint("TOPLEFT", 20, y)
        local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", box, "RIGHT", 4, 0)
        label:SetText(title)
        Text(detail, y - 30)
        box:SetScript("OnClick", function(button)
            self:SetOption(key, button:GetChecked() == true)
        end)
        checks[key] = box
    end
    Check("autoSell", self:T("SELL"), self:T("SELL_DESC"), -68)
    Check("autoRepair", self:T("REPAIR"), self:T("REPAIR_DESC"), -125)
    Check("extendedZoom", self:T("ZOOM"), self:T("ZOOM_DESC"), -182)
    Check("ghostColor", self:T("GHOST"), self:T("GHOST_DESC"), -239)
    Check("cooldownNumbers", self:T("COOLDOWN"), self:T("COOLDOWN_DESC"), -296)
    Check("autoLoot", self:T("AUTOLOOT"), self:T("AUTOLOOT_DESC"), -353)
    Check("messages", self:T("MESSAGES"), self:T("MESSAGES_DESC"), -410)
    Check("fastLoot", self:T("FASTLOOT"), self:T("FASTLOOT_DESC"), -467)
    Check("minimapIcon", self:T("MINIMAP"), self:T("MINIMAP_DESC"), -524)
    frame:SetScript("OnShow", function()
        for key, box in pairs(checks) do box:SetChecked(self.db[key]) end
    end)
    -- Native Kategorie, wenn der Betaclient diese Settings-API anbietet.
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local panel = CreateFrame("Frame")
        panel.name = "PatchTools"
        local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        label:SetPoint("TOPLEFT", 16, -16)
        label:SetText(self:T("CATEGORY"))
        local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        button:SetSize(220, 28)
        button:SetPoint("TOPLEFT", 16, -58)
        button:SetText(self:T("OPEN"))
        button:SetScript("OnClick", function() self:OpenOptions() end)
        local ok, category = pcall(Settings.RegisterCanvasLayoutCategory, panel, panel.name)
        if ok and category then pcall(Settings.RegisterAddOnCategory, category) end
    end
end
