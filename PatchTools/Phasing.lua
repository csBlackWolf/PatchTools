local _, PT = ...
local module = {}
PT:RegisterModule("Phasing", module)

-- Verified against the Forever branch of Blizzard_SocialToast/SocialToast.lua.
-- SHARD_TRANSFER_IMMINENT has no documented time payload; use the native query.
local function Remaining()
    if type(GetEvictionTimeRemaining) ~= "function" then return nil end
    local ok, seconds = pcall(GetEvictionTimeRemaining)
    if ok and type(seconds) == "number" and seconds == seconds and math.abs(seconds) < math.huge then
        return seconds
    end
end
function module:Lead()
    local value = tonumber(PT.db.phaseLead) or 60
    if value ~= value then value = 60 end
    return math.max(1, math.min(600, math.floor(value)))
end
function module:Duration()
    local value = tonumber(PT.db.phaseDuration) or 10
    if value ~= value then value = 10 end
    return math.max(1, math.min(60, math.floor(value)))
end
function module:Alert(seconds, soon, test)
    local message
    if seconds and seconds > 0 then
        message = PT:T(soon and "PHASE_ALERT_SOON" or "PHASE_ALERT_INITIAL", math.ceil(seconds))
    else
        message = PT:T("PHASE_ALERT_PENDING")
    end
    if test then message = PT:T("PHASE_TEST_PREFIX") .. message end
    self.label:SetText(message)
    self.label:SetTextColor(1, soon and 0.25 or 0.8, 0.1)
    self.display:Show()
    self.hideAt = GetTime() + self:Duration()
    if PT.db.phaseChat ~= false then PT:Print(message) end
    if PT.db.phaseSound and PlaySound then
        PlaySound(SOUNDKIT and SOUNDKIT.RAID_WARNING or 8959, "Master")
    end
end
function module:Reset()
    self.active, self.initialSent, self.soonSent = false, false, false
    self.display:Hide()
    self.hideAt = nil
end
function module:Evaluate(seconds)
    if not self.active then return end
    local urgent = seconds ~= nil and seconds <= self:Lead()
    -- A late announcement produces one urgent alert, not two overlapping sounds.
    if urgent and PT.db.phaseSoon and not self.soonSent then
        self.soonSent, self.initialSent = true, true
        self:Alert(seconds, true)
    elseif PT.db.phaseInitial and not self.initialSent then
        self.initialSent = true
        self:Alert(seconds, false)
    end
end
function module:SettingsChanged()
    PT.db.phaseLead = self:Lead()
    PT.db.phaseDuration = self:Duration()
    if not PT.db.phaseInitial and not PT.db.phaseSoon then
        self.display:Hide()
        self.hideAt = nil
    end
    -- Do not replay an already delivered alert when changing its settings.
end
function module:Initialize()
    PT.db.phaseLead = self:Lead()
    PT.db.phaseDuration = self:Duration()
    self.display = CreateFrame("Frame", "PatchToolsPhaseAlert", UIParent)
    self.display:SetSize(700, 90)
    self.display:SetPoint("TOP", UIParent, "TOP", 0, -180)
    self.display:SetFrameStrata("HIGH")
    self.display:EnableMouse(false)
    self.label = self.display:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    self.label:SetAllPoints()
    self.label:SetJustifyH("CENTER")
    self.display:Hide()
    self.frame = CreateFrame("Frame")
    self.supported = type(GetEvictionTimeRemaining) == "function"
    for _, event in ipairs({"SHARD_TRANSFER_IMMINENT", "SHARD_TRANSFER_CANCELLED", "SHARD_TRANSFER"}) do
        local ok = pcall(self.frame.RegisterEvent, self.frame, event)
        if not ok then self.supported = false end
    end
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.frame:SetScript("OnEvent", function(_, event)
        if event == "SHARD_TRANSFER_IMMINENT" then
            if not self.active then self.initialSent, self.soonSent = false, false end
            self.active = true
            self:Evaluate(Remaining())
        elseif event == "PLAYER_ENTERING_WORLD" then
            self:Reset()
            local seconds = Remaining()
            if seconds and seconds > 0 then
                self.active = true
                self:Evaluate(seconds)
            end
        else
            self:Reset()
        end
    end)
    local elapsedTotal = 0
    self.frame:SetScript("OnUpdate", function(_, elapsed)
        if self.hideAt and GetTime() >= self.hideAt then
            self.display:Hide()
            self.hideAt = nil
        end
        elapsedTotal = elapsedTotal + elapsed
        if elapsedTotal < 0.1 then return end
        elapsedTotal = 0
        -- Query the server-managed countdown, never infer completion from zero.
        if self.active then self:Evaluate(Remaining()) end
    end)
end

function module:OpenOptions()
    if self.options then self.options:Show(); return end
    local frame = CreateFrame("Frame", "PatchToolsPhasingOptions", UIParent, "BasicFrameTemplateWithInset")
    frame:Hide()
    self.options = frame
    frame:SetSize(560, 510)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame.TitleText:SetText(PT:T("PHASE_OPTIONS"))
    tinsert(UISpecialFrames, "PatchToolsPhasingOptions")
    local function Text(text, y)
        local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("TOPLEFT", 24, y)
        label:SetWidth(510)
        label:SetJustifyH("LEFT")
        label:SetText(text)
        return label
    end
    Text(PT:T("PHASE_DESC"), -40)
    local checks = {}
    for index, entry in ipairs({{"phaseInitial", "PHASE_INITIAL"}, {"phaseSoon", "PHASE_SOON"}, {"phaseSound", "PHASE_SOUND"}, {"phaseChat", "PHASE_CHAT"}}) do
        local key = entry[1]
        local box = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
        box:SetPoint("TOPLEFT", 20, -75 - (index - 1) * 37)
        local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", box, "RIGHT", 4, 0)
        label:SetText(PT:T(entry[2]))
        box:SetScript("OnClick", function(button) PT:SetOption(key, button:GetChecked() == true) end)
        checks[key] = box
    end
    local fields = {}
    local function NumberField(key, title, hint, name, y, read)
        Text(PT:T(title), y)
        local input = CreateFrame("EditBox", name, frame, "InputBoxTemplate")
        input:SetPoint("TOPLEFT", 32, y - 22)
        input:SetSize(100, 28)
        input:SetAutoFocus(false)
        input:SetNumeric(true)
        input:SetMaxLetters(6)
        local function Restore()
            input:SetText(tostring(read(self)))
        end
        local function Save()
            local text = input:GetText() or ""
            if text:match("^%d+$") then PT:SetOption(key, tonumber(text)) end
            Restore()
        end
        input:SetScript("OnEnterPressed", function() Save(); input:ClearFocus() end)
        input:SetScript("OnEditFocusLost", Save)
        input:SetScript("OnEscapePressed", function() Restore(); input:ClearFocus() end)
        Text(PT:T(hint), y - 57)
        Restore()
        fields[#fields + 1] = {input = input, restore = Restore, save = Save}
    end
    NumberField("phaseLead", "PHASE_LEAD", "PHASE_INPUT_HINT", "PatchToolsPhaseLeadInput", -233, self.Lead)
    NumberField("phaseDuration", "PHASE_DURATION", "PHASE_DURATION_HINT", "PatchToolsPhaseDurationInput", -323, self.Duration)
    local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button:SetSize(230, 28)
    button:SetPoint("TOPLEFT", 24, -414)
    button:SetText(PT:T("PHASE_TEST"))
    button:SetScript("OnClick", function() self:Alert(self:Lead(), true, true) end)
    Text(PT:T(self.supported and "PHASE_READY" or "PHASE_UNAVAILABLE"), -463)
    frame:SetScript("OnShow", function()
        if PT.options then PT.options:Hide() end
        for key, box in pairs(checks) do box:SetChecked(PT.db[key]) end
        for _, field in ipairs(fields) do field.restore() end
    end)
    frame:SetScript("OnHide", function()
        for _, field in ipairs(fields) do field.save(); field.input:ClearFocus() end
        if PT.options then PT.options:Show() end
    end)
    frame:Show()
end
