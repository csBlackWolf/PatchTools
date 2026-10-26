
local dropdownItems={}
function UIDropDownMenu_SetWidth(frame,width) frame.dropdownWidth=width end
function UIDropDownMenu_Initialize(frame,fn) frame.dropdownInitialize=fn end
function UIDropDownMenu_CreateInfo() return {} end
function UIDropDownMenu_AddButton(info) dropdownItems[#dropdownItems+1]=info end
function UIDropDownMenu_SetText(frame,text) frame.dropdownText=text end
local function OpenDropdown(frame)
    dropdownItems={}; frame.dropdownInitialize(frame,1); return dropdownItems
end
local frames, timers, cvars = {}, {}, {cameraDistanceMaxZoomFactor="1.9", ffxDeath="1", countdownForCooldowns="0", autoLootDefault="0"}
local player="Azaad"
function GetLocale() return os.getenv("PATCHTOOLS_TEST_LOCALE") or "enUS" end
function UnitName() return player end
function GetRealmName() return "Beta" end
local function Widget()
    local w = {scripts={}, events={}, value=1}
    local methods = {}
    function methods:SetScript(event, fn) self.scripts[event]=fn end
    function methods:RegisterEvent(event)
        assert(not (os.getenv("PATCHTOOLS_TEST_CLIENT") == "era" and event:match("^SHARD_TRANSFER")))
        self.events[event]=true
    end
    function methods:CreateFontString() return Widget() end
    function methods:SetText(text) self.text=text end
    function methods:SetBackdropColor(r,g,b,a) self.backdropColor={r,g,b,a} end
    function methods:GetText() return self.text end
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
local era = os.getenv("PATCHTOOLS_TEST_CLIENT") == "era"
function GetBuildInfo()
    if era then return "1.15.9","70003","",11509 end
    return "1.60.1","70124","Sep 29 2026",16001
end
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
function GetTime() return 100 end
function GetEvictionTimeRemaining() return nil end
local pt={}
for _,file in ipairs({"Client.lua","Locales.lua","Core.lua","Extensions.lua","ItemRules.lua","Vendor.lua","Tooltips.lua","Loot.lua","LootConfirmations.lua","DeleteConfirmation.lua","Minimap.lua","Phasing.lua","Quests.lua","ActionBars.lua","OptionsWindow.lua","Options.lua"}) do assert(loadfile(file))("PatchTools",pt) end
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
assert(pt.db.autoSell and pt.db.autoRepair and pt.db.extendedZoom and pt.db.sellWhitelist)
assert(pt.db.autoQuestAccept==false and pt.db.autoQuestTurnIn==false and pt.db.pawnQuestRewards==false)
assert(pt.optionPages.quests and pt.optionNavigation.quests)
assert(next(pt.db.sellAllowlist) == nil)
assert(cvars.ffxDeath=="1" and cvars.cameraDistanceMaxZoomFactor=="4")
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
assert(pt.db.schemaVersion==4 and pt.db.minimapAngle==90)
assert(cvars.cameraDistanceMaxZoomFactor=="4")
pt:SetOption("extendedZoom",false); assert(cvars.cameraDistanceMaxZoomFactor=="1.9")
print("PASS: defaults, options, CVar restoration, conflict preservation, junk safety,")
print("sale-before-repair, insufficient funds, Shift bypass, merchant-close cancellation,")
print("bounded retries, v1 migration, cooldown numbers, login autoloot and per-character restore.")
print("PASS: minimap toggle/click/drag, fast-loot defaults, manual-loot bypass, modifier XOR,")
print("locked slots, reverse order, no duplicate calls, pending cancellation and confirmation preservation.")

if era then
    assert(pt.isClassicEra and not pt.isForever and not pt.hasProfessionBag)
    assert(not pt.optionPages.phase and not pt.optionNavigation.phase)
    assert(not pt.modules.Phasing.frame and not pt.modules.Phasing.display)
    assert(pt.modules.Phasing.supported == false)
    assert(pt.options.TitleText.text:find("Classic Era",1,true))
    pt:SetOption("phaseSoon",true); pt:SetOption("phaseSoon",false)
    assert(pt:SelectOptionsPage("phase") == false)
    assert(not pt.optionNavigation.maps and pt.optionNavigation.about)
    print("PASS: Era client identity, hidden phasing page/navigation and no phasing events or alert frame.")
else
    assert(pt.isForever and pt.hasProfessionBag and pt.supportsPhasing)
    pt.modules.Phasing:OpenOptions()
    assert(pt.modules.Phasing.options.shown)
end
assert(not pt.db.phaseInitial and not pt.db.phaseSoon and pt.db.phaseLead == 60)
if not era then print("PASS: integrated phasing initialization, settings panel and safe defaults.") end

-- Sale rules: blacklist wins; whitelist is explicit opt-in and independent of grey sale.
pt.db.autoSell=true; pt.db.sellWhitelist=false
assert(not pt:ItemID("0") and not pt:ItemID("-1") and not pt:ItemID("1.5"))
assert(not pt:ItemID("nan") and not pt:ItemID("2147483648"))
assert(pt:ItemID("|cff00ff00|Hitem:123:0|h[Test]|h|r")==123)
assert(pt:SetItemRule("sellBlocklist",1,true))
assert(not pt:ShouldSellItem({itemID=1,quality=0}))
assert(pt:SetItemRule("sellAllowlist",1,true))
pt.db.sellWhitelist=true
assert(not pt:ShouldSellItem({itemID=1,quality=0}))
pt:SetItemRule("sellBlocklist",1,false)
pt.db.autoSell=false
assert(pt:ShouldSellItem({itemID=1,quality=4}))
pt.db.sellWhitelist=false
assert(not pt:ShouldSellItem({itemID=1,quality=4}))
assert(not pt:ShouldSellItem({quality=0}))
assert(not pt:SetItemRule("other",1,true))
-- Exercise a real sale pass with listed rare items, a conflict, quest/locked/zero-value items.
pt.db.sellWhitelist=true
pt.db.sellBlocklist={ [2]=true }
pt.db.sellAllowlist={ [1]=true,[2]=true,[3]=true,[4]=true,[5]=true }
bag={{itemID=1,quality=4},{itemID=2,quality=0},{itemID=3,quality=4,quest=true},{itemID=4,quality=4,isLocked=true},{itemID=5,quality=4}}
C_Container.GetContainerNumSlots=function(b) return b==0 and #bag or 0 end
local sales={}
C_Container.UseContainerItem=function(_,slot) sales[#sales+1]=bag[slot].itemID; bag[slot]={} end
C_Item.GetItemInfo=function(id) return "Test",nil,nil,nil,nil,nil,nil,nil,nil,nil,id==5 and 0 or 10 end
Event("MERCHANT_CLOSED"); Event("MERCHANT_SHOW"); Flush()
assert(#sales==1 and sales[1]==1)
Event("MERCHANT_CLOSED")
-- Shift and closed merchant also protect whitelist sales.
bag[1]={itemID=1,quality=4}; shift=true
Event("MERCHANT_SHOW"); Flush(); assert(#sales==1)
shift=false; Event("MERCHANT_CLOSED")
Event("MERCHANT_SHOW"); Event("MERCHANT_CLOSED"); Flush(); assert(#sales==1)
-- List UI accepts IDs, de-duplicates, removes, and accepts item cursors only.
local list=pt.itemListUI.sellBlocklist
assert(list.add("42")); assert(pt.db.sellBlocklist[42])
assert(list.add("42")); assert(not list.add("invalid"))
GetCursorInfo=function() return "spell",99 end
local cleared=false; ClearCursor=function() cleared=true end
list.drop(); assert(not cleared and not pt.db.sellBlocklist[99])
GetCursorInfo=function() return "item",99 end
list.drop(); assert(cleared and pt.db.sellBlocklist[99])
pt:SetItemRule("sellBlocklist",99,false); assert(not pt.db.sellBlocklist[99])
-- Tooltips handle uncached prices, repeated callbacks and reset without duplicate lines.
local tip={lines={},GetItem=function() return "Test","item:42" end}
function tip:AddDoubleLine(a,b) self.lines[#self.lines+1]={a,b} end
pt.db.tooltipIDs=true; pt.db.tooltipPrices=true
local price=nil
C_Item.GetItemInfo=function() return "Test",nil,nil,nil,nil,nil,nil,nil,nil,nil,price end
pt.modules.Tooltips:Decorate(tip); assert(#tip.lines==1 and tip.lines[1][2]=="42")
pt.modules.Tooltips:Decorate(tip); assert(#tip.lines==1)
price=20; pt.modules.Tooltips:Decorate(tip); assert(#tip.lines==2)
pt.modules.Tooltips:Decorate(tip); assert(#tip.lines==2)
tip.patchToolsLines=nil; tip.lines={}; price=0
pt.modules.Tooltips:Decorate(tip); assert(#tip.lines==2 and tip.lines[2][2]==pt:T("TIP_NO_VALUE"))
pt.db.tooltipIDs=false; pt.db.tooltipPrices=false
tip.patchToolsLines=nil; tip.lines={}; pt.modules.Tooltips:Decorate(tip); assert(#tip.lines==0)
print("PASS: list precedence, explicit whitelist opt-in, rare-item sale, quest/locked/zero-price protection, Shift/close cancellation, drag validation and tooltip cache/deduplication.")

-- Saved rules survive reinitialization and keep protection precedence.
pt.db.sellBlocklist[123]=true; pt.db.sellAllowlist[123]=true
Event("ADDON_LOADED","PatchTools")
assert(pt.db.sellBlocklist[123] and pt.db.sellAllowlist[123])
assert(not pt:ShouldSellItem({itemID=123,quality=0}))
print("PASS: saved item lists survive initialization.")

-- Forever's extra profession/reagent bag is container 5, not a bank bag.
local containersByBag = {
    [0]={{itemID=2934,quality=1}},
    [5]={{itemID=2934,quality=1},{itemID=2934,quality=1},
        {itemID=2672,quality=1},{itemID=2934,quality=1,quest=true},
        {itemID=2934,quality=1,isLocked=true},{itemID=1372,quality=0}},
    [6]={{itemID=2934,quality=1}},
    [-1]={{itemID=2934,quality=1}},
}
pt.db.autoSell=true; pt.db.sellWhitelist=true; pt.db.autoRepair=false
pt.db.sellAllowlist={[2934]=true,[2672]=true}
pt.db.sellBlocklist={[2672]=true}
local visited, professionSales = {}, {}
C_Container.GetContainerNumSlots=function(b)
    visited[b]=true
    return containersByBag[b] and #containersByBag[b] or 0
end
C_Container.GetContainerItemInfo=function(b,s) return containersByBag[b][s] end
C_Container.GetContainerItemQuestInfo=function(b,s) return {isQuestItem=containersByBag[b][s].quest} end
C_Container.UseContainerItem=function(b,s)
    professionSales[#professionSales+1]={bag=b,slot=s,id=containersByBag[b][s].itemID}
    containersByBag[b][s]={}
end
C_Item.GetItemInfo=function() return "Test",nil,nil,nil,nil,nil,nil,nil,nil,nil,7 end
Event("MERCHANT_CLOSED"); Event("MERCHANT_SHOW"); Flush()
if era then
    assert(#professionSales == 1 and professionSales[1].bag == 0)
    assert(not visited[5] and not visited[6] and not visited[-1])
    assert(containersByBag[5][1].itemID == 2934 and containersByBag[5][6].quality == 0)
    Event("MERCHANT_CLOSED")
    -- Even enabling the saved Forever switch cannot expose Era bank slots.
    pt:SetOption("sellProfessionBag", true)
    visited = {}; Event("MERCHANT_SHOW"); Flush(); Event("MERCHANT_CLOSED")
    assert(not visited[5] and #professionSales == 1)
    print("PASS: Era bank slots stay untouched for both whitelist and grey sales, regardless of the profession-bag setting.")
else
assert(#professionSales==4, "Profession bag: expected main-bag item, two listed stacks and grey junk")
assert(professionSales[1].bag==0 and professionSales[2].bag==5)
assert(containersByBag[5][3].itemID==2672 and containersByBag[5][4].quest and containersByBag[5][5].isLocked)
assert(visited[5] and not visited[6] and not visited[-1], "Only carried bags may be visited")
Event("MERCHANT_CLOSED")
containersByBag[5]={}
Event("MERCHANT_SHOW"); Flush(); Event("MERCHANT_CLOSED")
assert(#professionSales==4, "Empty profession bag must be harmless")
print("PASS: profession bag whitelist stacks and grey sale; blacklist/quest/locked protection; bank exclusion; empty profession bag.")

-- Turning the extra bag off affects both grey and whitelist sales, even mid-session.
containersByBag[0]={{itemID=2934,quality=1}}
containersByBag[5]={{itemID=2934,quality=1},{itemID=1372,quality=0}}
pt:SetOption("sellProfessionBag", false)
visited={}; professionSales={}
Event("MERCHANT_SHOW"); Flush(); Event("MERCHANT_CLOSED")
assert(#professionSales==1 and professionSales[1].bag==0)
assert(not visited[5] and containersByBag[5][1].itemID==2934 and containersByBag[5][2].itemID==1372)
pt:SetOption("sellProfessionBag", true)
Event("MERCHANT_SHOW"); Flush(); Event("MERCHANT_CLOSED")
assert(#professionSales==3 and professionSales[2].bag==5 and professionSales[3].bag==5)
print("PASS: profession bag toggle skips whitelist and grey items while regular bags still sell; re-enable restores extra-bag sales.")
end
-- New defaults must never override explicit saved choices. Missing keys inherit them.
for _,key in ipairs({"autoSell","autoRepair","extendedZoom","sellWhitelist"}) do pt.db[key] = false end
Event("ADDON_LOADED","PatchTools")
for _,key in ipairs({"autoSell","autoRepair","extendedZoom","sellWhitelist"}) do assert(pt.db[key] == false) end
pt.db.autoRepair = nil
Event("ADDON_LOADED","PatchTools")
assert(pt.db.autoRepair and not pt.db.autoSell and not pt.db.extendedZoom and not pt.db.sellWhitelist)
print("PASS: new vendor/zoom defaults preserve saved false values and populate only missing settings.")

dofile("tests/delete_confirmation.lua")
dofile("tests/client.lua")

-- Open-time population must work when Pawn loads after the settings panel.
local menu=OpenDropdown(pt.questOptionsUI.scale)
assert(#menu==2 and menu[2].disabled and menu[1].checked)
PawnPlayerFullName="Hunter-Test"
PawnCommon={Scales={BM={ClassID=3},MM={ClassID=3}}}
function UnitClass() return "Hunter","HUNTER",3 end
local pawnScales={{Name="BM",LocalizedName="Beast Mastery",IsVisible=true},
    {Name="MM",LocalizedName="Marksmanship",IsVisible=true}}
function PawnGetAllScalesEx() return pawnScales end
assert(PawnIsInitialized==nil)
menu=OpenDropdown(pt.questOptionsUI.scale)
assert(#menu==3 and menu[2].text=="Beast Mastery" and menu[3].text=="Marksmanship")
menu[2].func()
assert(pt.modules.Quests:ResolveScale()=="BM" and pt.questOptionsUI.scale.dropdownText=="Beast Mastery")
assert(pawnScales[1].IsVisible and pawnScales[2].IsVisible,'reward selection must not change Pawn tooltip scales')
menu=OpenDropdown(pt.questOptionsUI.scale); assert(menu[2].checked and not menu[3].checked)
menu[3].func(); assert(pt.modules.Quests:ResolveScale()=="MM")
menu[1].func(); assert(pt.modules.Quests:ResolveScale()==nil,'multiple scales keep automatic mode undecided')
print("PASS: real dropdown selects a single Pawn reward scale with multiple tooltip scales, supports late availability and marks the current choice.")
local resets, resetWindow=0, pt.ResetOptionsWindow
pt.ResetOptionsWindow=function(self) resets=resets+1; resetWindow(self) end
SlashCmdList.PATCHTOOLS("reset")
assert(resets==1 and pt.options:IsShown(),'chat reset must recover and open the settings window')
pt.ResetOptionsWindow=resetWindow

assert(pt.optionPages.appearance and not pt.optionPages.actionbars and pt.appearanceUI.slider:GetParent()==pt.optionPages.appearance)
pt.appearanceUI.slider:SetValue(55)
assert(pt.db.optionsTransparency==.55 and math.abs(pt.options.backdropColor[4]-.45)<.000001)
pt:SetOption("optionsTransparency",math.huge); assert(pt.db.optionsTransparency==0)
pt:SetOption("optionsTransparency",.4); pt:CreateOptions()
assert(pt.db.optionsTransparency==.4 and pt.options.backdropColor[4]==.6)
print("PASS: settings background transparency applies live, survives window creation, bounds invalid values and keeps control opacity independent.")

-- The secret expands the real dropdown only after explicit discovery.
pt.db.silverFoxUnlocked=false; pt.db.barDecoration="dragon"; pt:CreateOptions()
local entries=OpenDropdown(pt.barDecorationUI.dropdown)
assert(#entries==3 and entries[3].value=="dragon")
pt.foxSecretButton.scripts.OnClick()
assert(pt.db.silverFoxUnlocked and pt.db.barDecoration=="fox")
entries=OpenDropdown(pt.barDecorationUI.dropdown)
assert(#entries==4 and entries[4].value=="fox" and entries[4].checked)
entries[1].func(); assert(pt.db.barDecoration=="none")
pt:CreateOptions(); entries=OpenDropdown(pt.barDecorationUI.dropdown)
assert(#entries==4 and entries[1].checked)
-- Migrate each earlier checkbox combination without reinstalling native hooks.
local previousModules=pt.modules; pt.modules={}
for _,case in ipairs({{hideBarEndCaps=true,modernActionBar=true,expected="none"},
    {hideBarEndCaps=false,modernActionBar=true,expected="dragon"},
    {hideBarEndCaps=false,modernActionBar=false,expected="native"},
    {hideBarEndCaps=true,modernActionBar=true,barDecoration="fox",silverFoxUnlocked=true,expected="fox"}}) do
    PatchToolsDB=case; Event("ADDON_LOADED","PatchTools")
    assert(pt.db.barDecoration==case.expected)
end
pt.modules=previousModules
print("PASS: hidden fox discovery, saved unlock, dropdown selection and legacy decoration migration.")

-- Only a loaded Maps extension can add map controls to the navigation.
pt:CreateOptions()
assert(not pt.optionPages.maps and not pt.optionNavigation.maps)
assert(pt:SelectOptionsPage("maps")==false)
local layers=OpenDropdown(pt.barDecorationUI.layer)
assert(#layers==6 and layers[1].checked)
layers[5].func(); assert(pt.db.barDecorationLayer=="high")
pt:CreateOptions(); layers=OpenDropdown(pt.barDecorationUI.layer)
assert(layers[5].checked)
print("PASS: ornament layer dropdown and hidden Maps page without the module.")

layers[6].func(); assert(pt.db.barDecorationLayer=="dialog")
pt:CreateOptions(); layers=OpenDropdown(pt.barDecorationUI.layer)
assert(layers[6].checked)

assert(pt.optionPages.confirmations and pt.optionNavigation.confirmations)
assert(pt.db.boeRollConfirm=="off" and not pt.db.confirmLootBind and not pt.db.confirmEquipBind)
local rollChoices=OpenDropdown(pt.boeRollDropdown)
assert(#rollChoices==3 and rollChoices[1].checked)
rollChoices[2].func(); assert(pt.db.boeRollConfirm=="greed")
pt:CreateOptions(); rollChoices=OpenDropdown(pt.boeRollDropdown)
assert(rollChoices[2].checked)
rollChoices[3].func(); assert(pt.db.boeRollConfirm=="all")
print("PASS: confirmations category, defaults off and saved BoE roll dropdown selection.")
-- Simulate separate character SavedVariables files against one account table.
local account=PatchToolsDB
local modules=pt.modules; pt.modules={}
local width,height=UIParent.GetWidth,UIParent.GetHeight
UIParent.GetWidth=function() return 1200 end
UIParent.GetHeight=function() return 900 end
account.optionsScale=.85; account.optionsTransparency=.37
PatchToolsCharacterDB=nil; Event("ADDON_LOADED","PatchTools")
local first=pt.windowDB
assert(first.optionsScale==.85 and first~=account,'import legacy scale into the first character')
first.optionsScale=.7; first.x=.2; first.y=.8
PatchToolsCharacterDB=nil; Event("ADDON_LOADED","PatchTools")
assert(pt.windowDB~=first and pt.windowDB.optionsScale==.85 and pt.windowDB.x==nil)
pt.windowDB.optionsScale=1.1
PatchToolsCharacterDB=first; Event("ADDON_LOADED","PatchTools")
assert(pt.windowDB.optionsScale==.7 and pt.windowDB.x==.2 and pt.db==account)
pt:ResetOptionsWindow(); Event("ADDON_LOADED","PatchTools")
assert(pt.windowDB.optionsScale==1 and pt.windowDB.x==nil,'reset does not reimport old geometry')
assert(account.optionsScale==.85 and account.optionsTransparency==.37)
print('PASS: settings character migration, isolation, restored selection, reset and shared transparency.')
pt.modules=modules
UIParent.GetWidth,UIParent.GetHeight=width,height

dofile("tests/loot_confirmations.lua")
