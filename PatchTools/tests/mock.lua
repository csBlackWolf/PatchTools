local frames, timers, cvars = {}, {}, {cameraDistanceMaxZoomFactor="1.9", ffxDeath="1", countdownForCooldowns="0", autoLootDefault="0"}
local player="Azaad"
function GetLocale() return os.getenv("PATCHTOOLS_TEST_LOCALE") or "enUS" end
function UnitName() return player end
function GetRealmName() return "Beta" end
local function Widget()
    local w = {scripts={}, events={}, value=1}
    local methods = {}
    function methods:SetScript(event, fn) self.scripts[event]=fn end
    function methods:RegisterEvent(event) self.events[event]=true end
    function methods:CreateFontString() return Widget() end
    function methods:SetText(text) self.text=text end
    function methods:SetChecked(value) self.checked=value end
    function methods:GetChecked() return self.checked end
    function methods:GetParent() return self.parent end
    function methods:SetPoint(...) self.pointCalls=(rawget(self,"pointCalls") or 0)+1 end
    function methods:CreateTexture() return Widget() end
    function methods:GetWidth() return 140 end
    function methods:GetHeight() return 140 end
    function methods:GetFrameLevel() return 2 end
    function methods:GetEffectiveScale() return 1 end
    function methods:GetCenter() return 100, 100 end
    function methods:SetShown(value) self.shown=value end
    function methods:IsShown() return self.shown end
    function methods:SetValue(value)
        self.value=value
        if self.scripts.OnValueChanged then self.scripts.OnValueChanged(self,value) end
    end
    function methods:Show() self.shown=true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
    function methods:Hide() self.shown=false; if self.scripts.OnHide then self.scripts.OnHide(self) end end
    return setmetatable(w,{__index=function(_,k) return methods[k] or function() end end})
end
function CreateFrame(_, name, parent, template)
    local w=Widget(); w.parent=parent; w.TitleText=Widget(); frames[#frames+1]=w
    if name then _G[name]=w end
    if template=="OptionsSliderTemplate" then
        for _,suffix in ipairs({"Low","High","Text"}) do _G[name..suffix]=Widget() end
    end
    return w
end
UIParent=Widget(); UISpecialFrames={}; tinsert=table.insert; SlashCmdList={}
Minimap=Widget(); GameTooltip=Widget()
function GetCursorPosition() return 100, 178 end
C_CVar={GetCVar=function(k) return cvars[k] end, SetCVar=function(k,v) cvars[k]=v end,
    GetCVarDefault=function(k) if k=="cameraDistanceMaxZoomFactor" then return "1.9" end end}
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
local shift=false
function IsShiftKeyDown() return shift end
function GetBuildInfo() return "1.60.1","70124","Sep 29 2026",16001 end
local function Event(event, arg)
    for _,f in ipairs(frames) do if f.events[event] then f.scripts.OnEvent(f,event,arg) end end
end
local function Flush()
    local guard=0
    while #timers>0 do guard=guard+1; assert(guard<250); table.remove(timers,1)() end
end
local bag, wallet, repairCost, repaired, requested = {}, 100, 0, 0, 0
C_Container={
    GetContainerNumSlots=function(b) return b==0 and 4 or 0 end,
    GetContainerItemInfo=function(_,s) return bag[s] end,
    GetContainerItemQuestInfo=function(_,s) return {isQuestItem=bag[s] and bag[s].quest} end,
    UseContainerItem=function(_,s) requested=requested+1; wallet=wallet+10; bag[s]=nil end,
}
C_Item={GetItemInfo=function() return 'item',nil,nil,nil,nil,nil,nil,nil,nil,nil,10 end}
function CanMerchantRepair() return true end
function GetRepairAllCost() return repairCost,repairCost>0 end
function GetMoney() return wallet end
function RepairAllItems(guild) assert(guild==false); repaired=repaired+1; wallet=wallet-repairCost; repairCost=0 end
local pt={}
for _,file in ipairs({"Locales.lua","Core.lua","Vendor.lua","Loot.lua","Minimap.lua","Options.lua"}) do assert(loadfile(file))("PatchTools",pt) end
assert(pt.locale==(GetLocale()=="deDE" and "deDE" or "enUS"))
for key, text in pairs(pt.locales.enUS) do
    assert(type(pt.locales.deDE[key])=="string", "Missing German translation: "..key)
    local function Signature(s)
        local result={}
        for spec in s:gmatch("%%[sd]") do result[#result+1]=spec end
        return table.concat(result,",")
    end
    assert(Signature(text)==Signature(pt.locales.deDE[key]), "Format mismatch: "..key)
end
assert(pt:T("SALES_REQUESTED",2):find("2"))
assert(pt:T("UNKNOWN_KEY")=="UNKNOWN_KEY")
Event("ADDON_LOADED","PatchTools"); Event("PLAYER_LOGIN")
assert(not pt.db.autoSell and not pt.db.autoRepair)
assert(cvars.ffxDeath=="1" and cvars.cameraDistanceMaxZoomFactor=="1.9")
SlashCmdList.PATCHTOOLS("")
pt:SetOption("ghostColor",true); assert(cvars.ffxDeath=="0")
pt:SetOption("ghostColor",false); assert(cvars.ffxDeath=="1")
pt:SetOption("extendedZoom",true); assert(cvars.cameraDistanceMaxZoomFactor=="4")
pt:SetOption("extendedZoom",false); assert(cvars.cameraDistanceMaxZoomFactor=="1.9")
pt:SetOption("extendedZoom",true); cvars.cameraDistanceMaxZoomFactor="2.1"
pt:SetOption("extendedZoom",false); assert(cvars.cameraDistanceMaxZoomFactor=="1.9")
pt:SetOption("cooldownNumbers",true); assert(cvars.countdownForCooldowns=="1")
pt:SetOption("cooldownNumbers",false); assert(cvars.countdownForCooldowns=="0")
pt:SetOption("autoLoot",true); assert(cvars.autoLootDefault=="1")
cvars.autoLootDefault="0"; Event("PLAYER_LOGIN"); assert(cvars.autoLootDefault=="1")
player="Preis Wert"; cvars.autoLootDefault="1"
Event("PLAYER_LOGIN"); pt:SetOption("autoLoot",false); assert(cvars.autoLootDefault=="1")
player="Azaad"; cvars.autoLootDefault="1"
Event("PLAYER_LOGIN"); assert(cvars.autoLootDefault=="0")
pt:SetOption("ghostColor",true); cvars.ffxDeath="0.5"
pt:SetOption("ghostColor",false); assert(cvars.ffxDeath=="0.5")
pt:SetOption("autoSell",true); pt:SetOption("autoRepair",true)
bag={{quality=0,itemID=1},{quality=1,itemID=2},{quality=0,itemID=3,quest=true},{quality=0,itemID=4,isLocked=true}}
repairCost=110
Event("MERCHANT_SHOW"); Flush()
assert(requested==1 and bag[2] and bag[3] and bag[4])
assert(repaired==1 and wallet==0) -- sell first, repair becomes affordable
Event("MERCHANT_CLOSED")
bag[1]={quality=0,itemID=1}; shift=true
Event("MERCHANT_SHOW"); Flush(); assert(bag[1] and requested==1)
shift=false; Event("MERCHANT_CLOSED")
Event("MERCHANT_SHOW"); Event("MERCHANT_CLOSED"); Flush(); assert(bag[1])
pt:SetOption("autoSell",false); repairCost=10
Event("MERCHANT_SHOW"); Flush(); assert(repaired==1 and bag[1]) -- no money
Event("MERCHANT_CLOSED")
pt:SetOption("autoSell",true)
C_Container.UseContainerItem=function() requested=requested+1 end -- server declines
Event("MERCHANT_SHOW"); Flush(); assert(requested==4) -- bounded retries
Event("MERCHANT_CLOSED")
-- Minimap visibility, slash-command escape hatch, click and saved drag position.
local icon=pt.modules.Minimap.button
assert(icon:IsShown() and not pt.db.fastLoot)
pt.options:Hide(); icon.scripts.OnClick(icon); assert(pt.options:IsShown())
pt:SetOption("minimapIcon",false); assert(not icon:IsShown())
pt.options:Hide(); SlashCmdList.PATCHTOOLS(""); assert(pt.options:IsShown())
pt:SetOption("minimapIcon",true); assert(icon:IsShown())
icon.scripts.OnDragStart(icon); icon.scripts.OnUpdate(icon)
assert(math.abs(pt.db.minimapAngle-90)<0.001)
icon.scripts.OnDragStop(icon); Flush()
-- Ein Buttonsammel-Addon übernimmt Parent und Position; PatchTools greift nicht ein.
local collection=Widget(); icon.parent=collection
local previousPointCalls=icon.pointCalls
pt.modules.Minimap:Update(); pt.modules.Minimap:Drag()
assert(icon.pointCalls==previousPointCalls and pt.db.minimapAngle==90)
pt:SetOption("minimapIcon",false); assert(not icon:IsShown())
pt:SetOption("minimapIcon",true); assert(icon:IsShown())
local ctrl=true
function IsControlKeyDown() return ctrl end
pt.options:Hide(); icon.scripts.OnClick(icon,"RightButton"); assert(not pt.options:IsShown())
ctrl=false; icon.scripts.OnClick(icon,"LeftButton"); assert(pt.options:IsShown())
icon.parent=Minimap
-- Fast loot respects event mode/modifiers, locked slots and confirmations.
local lootItems, lootCalls, modifier, closeOnLoot, confirmOnLoot = {}, {}, false, false, false
function IsModifiedClick(key) assert(key=="AUTOLOOTTOGGLE"); return modifier end
function GetNumLootItems() return #lootItems end
function GetLootSlotType(s) return lootItems[s].slotType or 1 end
function GetLootSlotInfo(s) return nil,lootItems[s].name,1,nil,0,lootItems[s].locked end
function LootSlot(s)
    lootCalls[#lootCalls+1]=s
    if confirmOnLoot then Event("LOOT_BIND_CONFIRM",s) end
    if closeOnLoot then Event("LOOT_CLOSED") end
end
lootItems={{name="white"},{name="locked",locked=true},{name="grey"}}
Event("LOOT_READY",true); Event("LOOT_OPENED",true); Flush(); assert(#lootCalls==0)
Event("LOOT_CLOSED"); pt:SetOption("fastLoot",true)
Event("LOOT_READY",true); Event("LOOT_OPENED",true); Flush()
assert(#lootCalls==2 and lootCalls[1]==3 and lootCalls[2]==1) -- reverse and no duplicates
Event("LOOT_CLOSED"); lootCalls={}; cvars.autoLootDefault="1"
Event("LOOT_READY",false); Event("LOOT_OPENED",false); Flush(); assert(#lootCalls==0)
Event("LOOT_CLOSED"); modifier=true
Event("LOOT_READY"); Event("LOOT_OPENED"); Flush(); assert(#lootCalls==0)
Event("LOOT_CLOSED"); cvars.autoLootDefault="0"
Event("LOOT_OPENED"); Flush(); assert(#lootCalls==2) -- modifier enables loot when native default is OFF
Event("LOOT_CLOSED"); lootCalls={}; modifier=false
Event("LOOT_OPENED",true); Event("LOOT_CLOSED"); Flush(); assert(#lootCalls==0)
confirmOnLoot=true
Event("LOOT_READY",true); Event("LOOT_OPENED",true); Flush(); assert(#lootCalls==1)
Event("LOOT_CLOSED"); lootCalls={}; confirmOnLoot=false; closeOnLoot=true
Event("LOOT_READY",true); Flush(); assert(#lootCalls==1) -- synchronous close stops iteration
closeOnLoot=false; lootCalls={}
Event("LOOT_OPENED",true); pt:SetOption("fastLoot",false); Flush(); assert(#lootCalls==0)
Event("LOOT_CLOSED")
local saved=PatchToolsDB
saved.zoomFactor=2.6; saved.extendedZoom=true
saved.cvarApplied.cameraDistanceMaxZoomFactor="2.6"
saved.cvarBackup.cameraDistanceMaxZoomFactor="1.9"
Event("ADDON_LOADED","PatchTools"); Event("PLAYER_LOGIN")
assert(pt.db==saved and pt.db.autoSell and pt.db.zoomFactor==nil)
assert(pt.db.schemaVersion==3 and pt.db.minimapAngle==90)
assert(cvars.cameraDistanceMaxZoomFactor=="4")
pt:SetOption("extendedZoom",false); assert(cvars.cameraDistanceMaxZoomFactor=="1.9")
print("PASS: defaults, options, CVar restoration, conflict preservation, junk safety,")
print("sale-before-repair, insufficient funds, Shift bypass, merchant-close cancellation,")
print("bounded retries, v1 migration, cooldown numbers, login autoloot and per-character restore.")
print("PASS: minimap toggle/click/drag, fast-loot defaults, manual-loot bypass, modifier XOR,")
print("locked slots, reverse order, no duplicate calls, pending cancellation and confirmation preservation.")
