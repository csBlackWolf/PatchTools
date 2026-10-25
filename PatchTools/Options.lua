local _, PT = ...
local function Label(parent, text, x, y, width, font)
    local label = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    label:SetPoint("TOPLEFT", x, y)
    label:SetWidth(width)
    label:SetJustifyH("LEFT")
    label:SetText(text)
    return label
end
local function Button(parent, text, x, y, width, callback)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetPoint("TOPLEFT", x, y)
    button:SetSize(width, 26)
    button:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=8,insets={left=2,right=2,top=2,bottom=2}})
    button:SetBackdropColor(.075,.06,.045,1)
    button:SetBackdropBorderColor(.48,.37,.23,1)
    local caption=button:CreateFontString(nil,"OVERLAY","GameFontNormal")
    caption:SetPoint("CENTER"); button:SetFontString(caption)
    button:SetNormalFontObject("GameFontNormal")
    button:SetDisabledFontObject("GameFontDisable")
    local highlight=button:CreateTexture(nil,"HIGHLIGHT")
    highlight:SetAllPoints(); highlight:SetColorTexture(.48,.37,.23,.18)
    button:SetText(text)
    button:SetScript("OnDisable",function(b) b:SetBackdropBorderColor(.8,.62,.32,1) end)
    button:SetScript("OnEnable",function(b) b:SetBackdropBorderColor(.48,.37,.23,1) end)
    button:SetScript("OnClick", callback)
    return button
end
local function Dropdown(parent, name, x, y, width, entries, selected, choose)
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", x - 16, y)
    UIDropDownMenu_SetWidth(dropdown, width)
    UIDropDownMenu_Initialize(dropdown, function(_, level)
        for _, entry in ipairs(entries()) do
            local value = entry.value
            local info = UIDropDownMenu_CreateInfo()
            info.text, info.value = entry.label, value
            info.checked = selected() == value
            info.disabled = entry.disabled
            info.func = function() choose(value) end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    return dropdown
end
function PT:CreateOptions()
    local frame = CreateFrame("Frame", "PatchToolsOptions", UIParent, "BackdropTemplate")
    frame:SetSize(820, 650)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=10,insets={left=2,right=2,top=2,bottom=2}})
    frame.TitleText=Label(frame,"PatchTools " .. self.version .. " — " .. (self.gameLabel or "WoW Forever"),12,-10,750,"GameFontNormal")
    local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton")
    close:SetPoint("TOPRIGHT",-1,-1); close:SetSize(30,30)
    close:SetScript("OnClick",function() frame:Hide() end)
    frame:Hide()
    self.options = frame
    if self.ApplyOptionsAppearance then self:ApplyOptionsAppearance() end
    tinsert(UISpecialFrames, "PatchToolsOptions")
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(.48, .37, .23, .65)
    accent:SetPoint("TOPLEFT", 184, -42)
    accent:SetSize(2, 562)
    Label(frame, "PATCHTOOLS", 22, -48, 150, "GameFontNormalLarge")
    Label(frame, self:T("BUILD_LABEL"), 22, -82, 148)
    Label(frame, "Patch & Zen", 22, -596, 150)
    local pages, checks, refresh = {}, {}, {}
    self.optionPages = pages
    local function Page(key)
        local page = CreateFrame("Frame", nil, frame)
        page:SetPoint("TOPLEFT", 204, -44)
        page:SetSize(590, 570)
        page:Hide(); pages[key] = page
        return page
    end
    local function Check(page, key, title, detail, y, x)
        x = x or 0
        local box = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
        box:SetPoint("TOPLEFT", x, y)
        local label = Label(page, self:T(title), x + 36, y - 8, 544 - x, "GameFontNormal")
        if detail then Label(page, self:T(detail), 36, y - 34, 530) end
        box:SetScript("OnClick", function(b) self:SetOption(key, b:GetChecked() == true) end)
        checks[key] = box
        return box
    end
    local general = Page("general")
    Label(general, self:T("INTRO"), 0, 0, 580)
    for i, entry in ipairs({{"extendedZoom","ZOOM","ZOOM_DESC"},{"ghostColor","GHOST","GHOST_DESC"},
        {"cooldownNumbers","COOLDOWN","COOLDOWN_DESC"},{"autoLoot","AUTOLOOT","AUTOLOOT_DESC"},
        {"fastLoot","FASTLOOT","FASTLOOT_DESC"},{"minimapIcon","MINIMAP","MINIMAP_DESC"},
        {"messages","MESSAGES","MESSAGES_DESC"},{"simpleDelete","SIMPLE_DELETE","SIMPLE_DELETE_DESC"}}) do
        Check(general, entry[1], entry[2], entry[3], -35 - (i-1)*56)
    end
    local appearance
    if self.ApplyOptionsAppearance or self.modules.ActionBars then
        appearance = Page("appearance")
        Label(appearance,self:T("APPEARANCE_INTRO"),0,0,580)
    end
    if self.ApplyOptionsAppearance then
        local opacityText=Label(appearance,"",0,-52,580,"GameFontNormal")
        local slider=CreateFrame("Slider","PatchToolsOptionsOpacitySlider",appearance,"OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT",4,-81); slider:SetWidth(350)
        slider:SetMinMaxValues(0,80); slider:SetValueStep(1); slider:SetObeyStepOnDrag(true)
        PatchToolsOptionsOpacitySliderLow:SetText("0%"); PatchToolsOptionsOpacitySliderHigh:SetText("80%")
        local updating=false
        local function RefreshOpacity()
            updating=true
            self:ApplyOptionsAppearance()
            local value=math.floor(self.db.optionsTransparency*100+.5)
            slider:SetValue(value); opacityText:SetText(self:T("OPTIONS_TRANSPARENCY",value))
            updating=false
        end
        slider:SetScript("OnValueChanged",function(_,value)
            if updating then return end
            self:SetOption("optionsTransparency",math.floor(value+.5)/100); RefreshOpacity()
        end)
        slider:SetScript("OnEnter",function()
            GameTooltip:SetOwner(slider,"ANCHOR_TOP")
            GameTooltip:SetText(self:T("OPTIONS_TRANSPARENCY_HINT"),1,1,1,1,true); GameTooltip:Show()
        end)
        slider:SetScript("OnLeave",function() GameTooltip:Hide() end)
        refresh[#refresh+1]=RefreshOpacity
        self.appearanceUI={slider=slider,refresh=RefreshOpacity}
    end
    if appearance then
        Label(appearance,self:T("APPEARANCE_SCALE_HINT"),0,-132,580)
    end
    local questsModule = self.modules.Quests
    if questsModule then
        local quests = Page("quests")
        Label(quests,self:T("QUEST_INTRO"),0,0,580)
        Check(quests,"autoQuestAccept","QUEST_ACCEPT","QUEST_ACCEPT_DESC",-60)
        Check(quests,"autoQuestTurnIn","QUEST_TURNIN","QUEST_TURNIN_DESC",-145)
        Check(quests,"pawnQuestRewards","QUEST_PAWN","QUEST_PAWN_DESC",-230)
        Label(quests,self:T("QUEST_SCALE"),0,-337,580,"GameFontNormal")
        local selection
        local function RefreshScale()
            local selected = questsModule:GetSelectedScale()
            local text = self:T("QUEST_SCALE_AUTO")
            if selected then
                text = selected
                for _,scale in ipairs(questsModule:GetScales()) do
                    if scale.name == selected then text = scale.label; break end
                end
            end
            UIDropDownMenu_SetText(selection,text)
        end
        selection = Dropdown(quests,"PatchToolsQuestScaleDropdown",0,-368,500,function()
            local entries={{value="",label=self:T("QUEST_SCALE_AUTO")}}
            for _,scale in ipairs(questsModule:GetScales()) do
                entries[#entries+1]={value=scale.name,label=scale.label}
            end
            if #entries==1 then entries[#entries+1]={label=self:T("QUEST_SCALE_EMPTY"),disabled=true} end
            return entries
        end,function() return questsModule:GetSelectedScale() or "" end,function(value)
            questsModule:SetSelectedScale(value~="" and value or nil)
            RefreshScale()
        end)
        Label(quests,self:T("QUEST_SCALE_DESC"),0,-420,580)
        refresh[#refresh+1] = RefreshScale
        self.questOptionsUI={checks=checks,refresh=RefreshScale,scale=selection}
    end
    if self.modules.ActionBars then
        local bars = appearance
        Label(bars,self:T("NAV_ACTIONBARS"),0,-208,580,"GameFontNormal")
        Check(bars,"hideBarEndCaps","BARS_ENDCAPS","BARS_ENDCAPS_DESC",-238)
        Check(bars,"modernActionBar","BARS_STYLE","BARS_STYLE_DESC",-343)
        Label(bars,self:T("BARS_NOTE"),0,-465,580)
    end
    local vendor = Page("vendor")
    Label(vendor, self:T("VENDOR_INTRO"), 0, 0, 580)
    Check(vendor, "autoSell", "SELL", nil, -28)
    Check(vendor, "autoRepair", "REPAIR", nil, -62)
    if self.hasProfessionBag ~= false then
        Check(vendor, "sellProfessionBag", "SELL_PROFESSION", nil, -62, 300)
    end
    Check(vendor, "sellWhitelist", "ALLOW_ENABLE", "ALLOW_DESC", -96)
    Label(vendor, self:T("RULE_HINT"), 0, -160, 580)
    Label(vendor, self:T("RULE_PRIORITY"), 0, -198, 580)
    self.itemListUI = {}
    local function ItemList(key, title, x)
        local panel = CreateFrame("Frame", nil, vendor)
        panel:SetPoint("TOPLEFT", x, -242); panel:SetSize(280, 322)
        Label(panel, self:T(title), 0, 0, 280, "GameFontNormal")
        local input = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
        input:SetPoint("TOPLEFT", 8, -30); input:SetSize(172, 26)
        input:SetAutoFocus(false); input:SetMaxLetters(255)
        local status = Label(panel, "", 0, -302, 280)
        local rows, pageNumber = {}, 1
        local pageLabel = Label(panel, "", 65, -273, 155)
        local function Refresh()
            local ids = {}
            for id in pairs(self.db[key]) do ids[#ids+1] = id end
            table.sort(ids)
            local count = math.max(1, math.ceil(#ids/6))
            pageNumber = math.max(1, math.min(count, pageNumber))
            pageLabel:SetText(self:T("PAGE", pageNumber, count))
            for i, row in ipairs(rows) do
                local id = ids[(pageNumber-1)*6+i]; row.id = id
                if id then
                    local fn = C_Item and C_Item.GetItemInfo or GetItemInfo
                    local name, link, _, _, _, _, _, _, _, icon
                    if fn then name, link, _, _, _, _, _, _, _, icon = fn(id) end
                    row.icon:SetTexture(icon or 134400)
                    row.text:SetText((name or self:T("UNKNOWN_ITEM", id)) .. "\n|cff9c9c9cID " .. id .. "|r")
                    row.button:Show()
                else row.button:Hide() end
            end
            if #ids == 0 then status:SetText(self:T("EMPTY_LIST")) else status:SetText("") end
        end
        local function Add(value)
            if not self:SetItemRule(key, value, true) then status:SetText(self:T("INVALID_ID")); return false end
            input:SetText(""); input:ClearFocus(); Refresh(); return true
        end
        local function Drop()
            if not GetCursorInfo then return end
            local kind, id, link = GetCursorInfo()
            if kind == "item" and Add(id or link) and ClearCursor then ClearCursor() end
        end
        input:SetScript("OnReceiveDrag", Drop)
        input:SetScript("OnMouseUp", function() if GetCursorInfo and GetCursorInfo() == "item" then Drop() end end)
        input:SetScript("OnEnterPressed", function() Add(input:GetText()) end)
        input:SetScript("OnEscapePressed", function() input:SetText(""); input:ClearFocus() end)
        Button(panel, "+", 190, -29, 76, function() Add(input:GetText()) end)
        for i=1,6 do
            local row = {}
            row.button = CreateFrame("Button", nil, panel)
            row.button:SetPoint("TOPLEFT", 0, -66-(i-1)*33); row.button:SetSize(230, 32)
            row.icon = row.button:CreateTexture(nil, "ARTWORK")
            row.icon:SetPoint("LEFT", 0, 0); row.icon:SetSize(27,27)
            row.text = Label(row.button, "", 34, -1, 186)
            row.button:SetScript("OnEnter", function(b)
                if row.id then GameTooltip:SetOwner(b,"ANCHOR_RIGHT"); GameTooltip:SetHyperlink("item:"..row.id); GameTooltip:Show() end
            end)
            row.button:SetScript("OnLeave", function() GameTooltip:Hide() end)
            row.remove = Button(row.button, "×", 240, -2, 28, function()
                if row.id then self:SetItemRule(key,row.id,false); Refresh() end
            end)
            rows[i] = row
        end
        Button(panel, "<", 0, -267, 44, function() pageNumber=pageNumber-1; Refresh() end)
        Button(panel, ">", 230, -267, 44, function() pageNumber=pageNumber+1; Refresh() end)
        self.itemListUI[key] = {input=input, add=Add, drop=Drop, refresh=Refresh, rows=rows}
        refresh[#refresh+1] = Refresh
    end
    ItemList("sellBlocklist", "BLOCK_TITLE", 0)
    ItemList("sellAllowlist", "ALLOW_TITLE", 300)
    local tips = Page("tooltips")
    Check(tips, "tooltipIDs", "TIP_IDS", "TIP_IDS_DESC", -20)
    Check(tips, "tooltipPrices", "TIP_PRICES", "TIP_PRICES_DESC", -108)
    local fields = {}
    if self.supportsPhasing ~= false then
        local phase = Page("phase")
        Label(phase, self:T("PHASE_DESC"), 0, 0, 580)
        for i, entry in ipairs({{"phaseInitial","PHASE_INITIAL"},{"phaseSoon","PHASE_SOON"},
            {"phaseSound","PHASE_SOUND"},{"phaseChat","PHASE_CHAT"}}) do
            Check(phase, entry[1], entry[2], nil, -35-(i-1)*38)
        end
        local function Number(key, title, hint, y)
            Label(phase, self:T(title), 0, y, 580, "GameFontNormal")
            local input = CreateFrame("EditBox", nil, phase, "InputBoxTemplate")
            input:SetPoint("TOPLEFT", 8, y-26); input:SetSize(100,28)
            input:SetAutoFocus(false); input:SetNumeric(true); input:SetMaxLetters(6)
            local function Restore() input:SetText(tostring(self.db[key])) end
            local function Save()
                local value=input:GetText() or ""
                if value:match("^%d+$") then self:SetOption(key,tonumber(value)) end
                Restore()
            end
            input:SetScript("OnEnterPressed",function() Save(); input:ClearFocus() end)
            input:SetScript("OnEditFocusLost",Save)
            input:SetScript("OnEscapePressed",function() Restore(); input:ClearFocus() end)
            Label(phase,self:T(hint),0,y-65,580)
            fields[#fields+1] = {input=input,save=Save,restore=Restore}
            refresh[#refresh+1] = Restore
        end
        Number("phaseLead","PHASE_LEAD","PHASE_INPUT_HINT",-215)
        Number("phaseDuration","PHASE_DURATION","PHASE_DURATION_HINT",-315)
        Button(phase,self:T("PHASE_TEST"),0,-422,270,function()
            local module=self.modules.Phasing; module:Alert(module:Lead(),true,true)
        end)
        Label(phase,self:T("PHASE_READY"),0,-472,580)
    end
    local maps = Page("maps")
    self.mapsPlaceholder=maps
    Label(maps,"PatchToolsMaps",0,-8,560,"GameFontNormalHuge")
    Label(maps,self:T("MAPS_INSTALL"),0,-66,560)
    Label(maps,self:T("MAPS_FEATURES"),0,-150,560)
    Label(maps,self:T("MAPS_VISUAL"),0,-302,560)
    local mapsLink=CreateFrame("EditBox",nil,maps,"InputBoxTemplate")
    mapsLink:SetPoint("TOPLEFT",8,-372); mapsLink:SetSize(540,28); mapsLink:SetAutoFocus(false)
    local mapsURL="https://www.curseforge.com/wow/addons/patchtoolsmaps"
    mapsLink:SetText(mapsURL)
    mapsLink:SetScript("OnEditFocusGained",function(b) b:HighlightText() end)
    mapsLink:SetScript("OnTextChanged",function(b) if b:GetText()~=mapsURL then b:SetText(mapsURL) end end)
    mapsLink:SetScript("OnEscapePressed",function(b) b:ClearFocus() end)
    local about = Page("about")
    Label(about,"PatchTools",0,-8,560,"GameFontNormalHuge")
    Label(about,self:T("ABOUT_TEXT"),0,-62,560)
    local link=CreateFrame("EditBox",nil,about,"InputBoxTemplate")
    link:SetPoint("TOPLEFT",8,-280); link:SetSize(540,28); link:SetAutoFocus(false)
    local url="https://github.com/csBlackWolf/PatchTools"
    link:SetText(url)
    link:SetScript("OnEditFocusGained",function(b) b:HighlightText() end)
    link:SetScript("OnTextChanged",function(b) if b:GetText()~=url then b:SetText(url) end end)
    link:SetScript("OnEscapePressed",function(b) b:ClearFocus() end)
    Label(about,self:T("IDEAS_INVITE"),0,-352,560)
    local ideas=CreateFrame("EditBox",nil,about,"InputBoxTemplate")
    ideas:SetPoint("TOPLEFT",8,-410); ideas:SetSize(540,28); ideas:SetAutoFocus(false)
    local issuesURL="https://github.com/csBlackWolf/PatchTools/issues/new/choose"
    ideas:SetText(issuesURL)
    ideas:SetScript("OnEditFocusGained",function(b) b:HighlightText() end)
    ideas:SetScript("OnTextChanged",function(b) if b:GetText()~=issuesURL then b:SetText(issuesURL) end end)
    ideas:SetScript("OnEscapePressed",function(b) b:ClearFocus() end)
    Label(about,self.version,0,-470,560)
    Label(about,"Twitch · zenlynxley",0,-504,560,"GameFontNormal")
    local twitch=CreateFrame("EditBox",nil,about,"InputBoxTemplate")
    twitch:SetPoint("TOPLEFT",8,-526); twitch:SetSize(540,28); twitch:SetAutoFocus(false)
    local twitchURL="https://www.twitch.tv/zenlynxley"
    twitch:SetText(twitchURL)
    twitch:SetScript("OnEditFocusGained",function(b) b:HighlightText() end)
    twitch:SetScript("OnTextChanged",function(b) if b:GetText()~=twitchURL then b:SetText(twitchURL) end end)
    twitch:SetScript("OnEscapePressed",function(b) b:ClearFocus() end)
    local navigation={}
    self.optionNavigation=navigation
    local navigationOrder={"general","appearance","quests","vendor","tooltips","phase","maps","about"}
    local function ArrangeNavigation()
        local index = 0
        for _,key in ipairs(navigationOrder) do
            if navigation[key] then
                navigation[key]:ClearAllPoints()
                navigation[key]:SetPoint("TOPLEFT",20,-135-index*45)
                index = index + 1
            end
        end
    end
    function self:SelectOptionsPage(key)
        if not pages[key] then return false end
        for name,page in pairs(pages) do page:SetShown(name==key) end
        for name,button in pairs(navigation) do
            if name==key then button:Disable() else button:Enable() end
        end
        for _, fn in ipairs(refresh) do fn() end
        for name,box in pairs(checks) do box:SetChecked(self.db[name]) end
    end
    for i,entry in ipairs({{"general","NAV_GENERAL"},{"appearance","NAV_APPEARANCE"},{"quests","NAV_QUESTS"},{"vendor","NAV_VENDOR"},{"tooltips","NAV_TOOLTIPS"},
        {"phase","NAV_PHASE"},{"maps","NAV_MAPS"},{"about","NAV_ABOUT"}}) do
        local key=entry[1]
        if pages[key] then
            navigation[key]=Button(frame,self:T(entry[2]),20,-135-(i-1)*45,150,function() self:SelectOptionsPage(key) end)
        end
    end
    ArrangeNavigation()
    self.mountOptionsPage = function(entry)
        local previous=pages[entry.id]
        if previous and previous~=self.mapsPlaceholder then return true end
        local selected=previous and previous:IsShown()
        local page = Page(entry.id)
        local ok, err = pcall(entry.build, page, self)
        if not ok then
            page:Hide(); pages[entry.id] = previous
            self:Print(self:T("EXTENSION_ERROR", entry.title))
            if geterrorhandler then geterrorhandler()(err) end
            return false
        end
        if previous then previous:Hide(); self.mapsPlaceholder=nil end
        if navigation[entry.id] then navigation[entry.id]:SetText(entry.title)
        else
            navigation[entry.id] = Button(frame,entry.title,20,0,150,
                function() self:SelectOptionsPage(entry.id) end)
            table.insert(navigationOrder,#navigationOrder,entry.id)
        end
        ArrangeNavigation()
        if selected then self:SelectOptionsPage(entry.id) end
        return true
    end
    for _, entry in ipairs(self.extraOptionsPages or {}) do self.mountOptionsPage(entry) end
    frame:SetScript("OnShow",function()
        for name,box in pairs(checks) do box:SetChecked(self.db[name]) end
        for _,fn in ipairs(refresh) do fn() end
    end)
    frame:SetScript("OnHide",function() for _,field in ipairs(fields) do field.save(); field.input:ClearFocus() end end)
    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:SetScript("OnEvent", function()
        if frame:IsShown() then
            for _, list in pairs(self.itemListUI) do list.refresh() end
        end
    end)
    self:SelectOptionsPage("general")
    if self.InstallOptionsScaling then self:InstallOptionsScaling(frame) end
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local panel=CreateFrame("Frame"); panel.name="PatchTools"
        Label(panel,self:T("CATEGORY"),16,-16,600,"GameFontNormalLarge")
        Button(panel,self:T("OPEN"),16,-58,250,function() self:OpenOptions() end)
        local ok,category=pcall(Settings.RegisterCanvasLayoutCategory,panel,panel.name)
        if ok and category then pcall(Settings.RegisterAddOnCategory,category) end
    end
end
