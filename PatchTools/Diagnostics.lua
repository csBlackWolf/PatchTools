local _, PT = ...

local function Plain(value)
    return tostring(value or "unknown"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("[%c]", " ")
end

function PT:BuildDebugReport()
    local api = C_AddOns or {}
    local count = api.GetNumAddOns or GetNumAddOns
    local info = api.GetAddOnInfo or GetAddOnInfo
    local metadata = api.GetAddOnMetadata or GetAddOnMetadata
    local loaded = api.IsAddOnLoaded or IsAddOnLoaded
    local version, build, _, interface = GetBuildInfo()
    local lines = {"PatchTools diagnostic report", "PatchTools: " .. Plain(self.version),
        "Game: " .. Plain(self.gameLabel) .. " / " .. Plain(version) .. " / build " .. Plain(build) .. " / interface " .. Plain(interface),
        "Locale: " .. Plain(GetLocale()), "Combat: " .. tostring(InCombatLockdown and InCombatLockdown() or false),
        "UI scale: " .. Plain(UIParent:GetEffectiveScale())}
    local groups = {loaded = {}, enabled = {}, disabled = {}, unknown = {}}
    if count and info then
        for index = 1, count() do
            local name = info(index)
            if name then
                local state
                if api.GetAddOnEnableState then state = api.GetAddOnEnableState(name, UnitName("player"))
                elseif GetAddOnEnableState then state = GetAddOnEnableState(UnitName("player"), index) end
                local group = loaded and loaded(name) and "loaded" or
                    (state == nil and "unknown" or (state == 0 and "disabled" or "enabled"))
                local entry = Plain(name) .. " — " .. Plain(metadata and metadata(name, "Version"))
                groups[group][#groups[group] + 1] = entry
            end
        end
        for _, key in ipairs({"loaded", "enabled", "disabled", "unknown"}) do
            local entries = groups[key]
            table.sort(entries, function(a, b) return a:lower() < b:lower() end)
            lines[#lines + 1] = ""
            local label = ({loaded="Loaded addons", enabled="Enabled, not loaded (including load-on-demand)",
                disabled="Disabled addons", unknown="Not loaded, enable state unavailable"})[key]
            lines[#lines + 1] = label .. " (" .. #entries .. "):"
            for _, entry in ipairs(entries) do lines[#lines + 1] = entry end
        end
    else
        lines[#lines + 1] = "Addon list unavailable."
    end
    return table.concat(lines, "\n")
end

function PT:OpenDebugReport()
    local frame = self.debugWindow
    if not frame then
        frame = CreateFrame("Frame", "PatchToolsDebugReport", UIParent, "BackdropTemplate")
        self.debugWindow = frame
        frame:SetSize(600, 440); frame:SetPoint("CENTER"); frame:SetFrameStrata("DIALOG")
        frame:SetClampedToScreen(true); frame:EnableMouse(true); frame:SetMovable(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=8})
        frame:SetBackdropColor(.055, .045, .035, 1); frame:SetBackdropBorderColor(.48, .37, .23, 1)
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", 14, -12); title:SetText(self:T("DEBUG_TITLE"))
        local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT", 14, -40); hint:SetWidth(550); hint:SetJustifyH("LEFT")
        hint:SetText(self:T("DEBUG_COPY"))
        local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -2, -2)
        local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 14, -76); scroll:SetPoint("BOTTOMRIGHT", -34, 14)
        local edit = CreateFrame("EditBox", nil, scroll)
        edit:SetMultiLine(true); edit:SetFontObject("ChatFontNormal"); edit:SetAutoFocus(false)
        edit:SetWidth(550); edit:SetHeight(1); edit:SetMaxLetters(0)
        edit:SetScript("OnEscapePressed", function() frame:Hide() end)
        edit:SetScript("OnTextChanged", function() scroll:UpdateScrollChildRect() end)
        scroll:SetScrollChild(edit)
        frame.edit, frame.scroll = edit, scroll
        frame:SetScript("OnHide", function() edit:ClearFocus() end)
        UISpecialFrames[#UISpecialFrames + 1] = "PatchToolsDebugReport"
    end
    local scale = math.max(.5, math.min(1, (UIParent:GetWidth()-24)/600, (UIParent:GetHeight()-24)/440))
    frame:SetScale(scale); frame:Show()
    frame.edit:SetText(self:BuildDebugReport()); frame.scroll:SetVerticalScroll(0)
    frame.edit:SetFocus(); frame.edit:HighlightText()
end
