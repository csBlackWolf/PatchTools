local _, PT = ...
local Bars = {hidden = {}, panels = {}, hooked = {}, dragons = {}, layerFrames = {}, nativeCopies = {}}
PT:RegisterModule("ActionBars", Bars)

function Bars:GetDecoration(db)
    db = db or self.pt.db
    local choice = db.barDecoration
    if choice == nil then -- Older saved settings and earlier module clients.
        return db.hideBarEndCaps and "none" or db.modernActionBar and "dragon" or "native"
    end
    if choice == "none" or choice == "dragon" or choice == "native" then return choice end
    if choice == "fox" and db.silverFoxUnlocked == true then return choice end
    return "native"
end

local strata = {background="BACKGROUND",low="LOW",medium="MEDIUM",high="HIGH",dialog="DIALOG"}
function Bars:GetDecorationLayer(db)
    local value = (db or self.pt.db).barDecorationLayer
    return strata[value] and value or "default"
end

function Bars:LayerParent(parent)
    local layer = self:GetDecorationLayer()
    if layer == "default" then return parent end
    local frame = self.layerFrames[parent]
    if not frame then
        frame = CreateFrame("Frame",nil,parent)
        frame:SetAllPoints(parent); frame:EnableMouse(false)
        self.layerFrames[parent] = frame
    end
    frame:SetFrameStrata(strata[layer])
    frame:SetFrameLevel((layer == "high" or layer == "dialog") and 100 or layer == "medium" and parent:GetFrameLevel() or 0)
    return frame
end

-- A visual copy lets native figures use another strata without moving secure
-- Blizzard frames or changing their anchors. Default restores the original.
function Bars:NativeCap(source, shown)
    if not source then return end
    local copy = self.nativeCopies[source]
    if shown then
        local parent = self:LayerParent(source:GetParent())
        if not copy then
            copy = parent:CreateTexture(nil,"OVERLAY",nil,6)
            copy:SetAllPoints(source)
            self.nativeCopies[source] = copy
        end
        copy:SetParent(parent)
        copy:SetTexture(source:GetTexture())
        copy:SetTexCoord(source:GetTexCoord())
        if source.GetVertexColor then copy:SetVertexColor(source:GetVertexColor()) end
        copy:SetAlpha(self.hidden[source] or 1)
        copy:SetShown(source:IsShown())
    elseif copy then copy:Hide() end
end

-- Only decoration textures are touched. Secure buttons, bar containers, page
-- controls, anchors and Blizzard's visibility logic remain owned by Blizzard.
function Bars:Mask(texture, wanted)
    if not texture or not texture.GetAlpha or not texture.SetAlpha then return end
    if wanted then
        if self.hidden[texture] == nil then self.hidden[texture] = texture:GetAlpha() end
        texture:SetAlpha(0)
    elseif self.hidden[texture] ~= nil then
        if texture:GetAlpha() == 0 then texture:SetAlpha(self.hidden[texture]) end
        self.hidden[texture] = nil
    end
end

function Bars:Panel(parent, compact, shown)
    if not parent then return end
    local panel = self.panels[parent]
    if not panel and shown then
        panel = {}
        local function Texture(r,g,b)
            local texture = parent:CreateTexture(nil,"BACKGROUND",nil,1)
            texture:SetColorTexture(r,g,b,1)
            panel[#panel+1] = texture
            return texture
        end
        local bg = Texture(.055,.045,.035)
        bg:SetPoint("BOTTOMLEFT",parent,"BOTTOMLEFT",compact and -5 or 0,compact and -5 or 0)
        bg:SetPoint("BOTTOMRIGHT",parent,"BOTTOMRIGHT",compact and 5 or 0,compact and -5 or 0)
        if compact then bg:SetPoint("TOP",parent,"TOP",0,5) else bg:SetHeight(43) end
        for _,side in ipairs({"TOP","BOTTOM","LEFT","RIGHT"}) do
            local edge = Texture(.48,.37,.23)
            if side == "TOP" or side == "BOTTOM" then
                edge:SetPoint(side.."LEFT",bg,side.."LEFT")
                edge:SetPoint(side.."RIGHT",bg,side.."RIGHT")
                edge:SetHeight(1)
            else
                edge:SetPoint("TOP"..side,bg,"TOP"..side)
                edge:SetPoint("BOTTOM"..side,bg,"BOTTOM"..side)
                edge:SetWidth(1)
            end
        end
        self.panels[parent] = panel
    end
    for _,texture in ipairs(panel or {}) do texture:SetShown(shown) end
end

function Bars:Dragons(parent, shown, rightAnchor, decoration)
    if not parent then return end
    local pair = self.dragons[parent]
    local layerParent = (shown or pair) and self:LayerParent(parent)
    if not pair and shown then
        pair = {}
        for i=1,2 do
            local dragon = layerParent:CreateTexture(nil,"OVERLAY",nil,6)
            dragon:SetSize(76,76)
            if i==2 then dragon:SetTexCoord(1,0,0,1) end
            pair[i] = dragon
        end
        self.dragons[parent] = pair
    end
    if pair then
        local asset = decoration == "fox" and "SilverFox" or "SilverDragonSeated"
        for _,texture in ipairs(pair) do
            texture:SetParent(layerParent)
            texture:SetTexture("Interface\\AddOns\\PatchTools\\Media\\"..asset)
        end
        pair[1]:ClearAllPoints()
        pair[1]:SetPoint("BOTTOMRIGHT",parent,"BOTTOMLEFT",10,-2)
        pair[2]:ClearAllPoints()
        pair[2]:SetPoint("BOTTOMLEFT",rightAnchor or parent,"BOTTOMRIGHT",-10,-2)
        for _,dragon in ipairs(pair) do dragon:SetShown(shown) end
    end
end

function Bars:Apply()
    if InCombatLockdown and InCombatLockdown() then self.pending = true; return end
    if not self.pt or not self.pt.db then return end
    self.pending = nil
    local db = self.pt.db
    local bar, art = _G.MainActionBar, _G.MainMenuBarArtFrame
    for _,frame in pairs({_G.MainMenuBar,bar}) do
        if not self.hooked[frame] then
            self.hooked[frame] = true
            frame:HookScript("OnShow",function() self:Apply() end)
            frame:HookScript("OnHide",function() self:Apply() end)
        end
    end
    -- Era uses both legacy end caps and compact end caps after editing the bar.
    local decoration = self:GetDecoration(db)
    local nativeOverride = decoration == "native" and self:GetDecorationLayer(db) ~= "default"
    local maskCaps = decoration ~= "native" or nativeOverride
    local function Cap(texture)
        self:Mask(texture,maskCaps)
        self:NativeCap(texture,nativeOverride)
    end
    Cap(_G.MainMenuBarLeftEndCap)
    Cap(_G.MainMenuBarRightEndCap)
    if bar and bar.EndCaps then
        Cap(bar.EndCaps.LeftEndCap)
        Cap(bar.EndCaps.RightEndCap)
    end
    for _,name in ipairs({"MainMenuBarTexture0","MainMenuBarTexture1","MainMenuBarTexture2",
        "MainMenuBarTexture3","MainMenuBarTextureExtender"}) do
        self:Mask(_G[name],db.modernActionBar)
    end
    self:Panel(art,false,db.modernActionBar)
    local legacyVisible = _G.MainMenuBar and _G.MainMenuBar:IsShown()
    self:Panel(bar,true,bar and db.modernActionBar and not legacyVisible and not bar.hideBarArt)
    local showDragons = decoration == "dragon" or decoration == "fox"
    self:Dragons(art,showDragons,nil,decoration)
    if bar and bar.EndCaps then
        -- Native EndCaps owns compact-bar visibility, including combat/layout
        -- transitions. Leave space for Blizzard's page arrows on the right.
        local page = bar.ActionBarPageNumber
        self:Dragons(bar.EndCaps,showDragons,page and page:IsShown() and page or bar.EndCaps,decoration)
    end
end

function Bars:Initialize(pt)
    self.pt = pt
    local events = CreateFrame("Frame")
    for _,event in ipairs({"PLAYER_LOGIN","PLAYER_ENTERING_WORLD","ADDON_LOADED","PLAYER_REGEN_ENABLED"}) do
        events:RegisterEvent(event)
    end
    events:SetScript("OnEvent",function() self:Apply() end)
    self:Apply()
end
