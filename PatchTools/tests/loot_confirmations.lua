local pt = {db={boeRollConfirm="off",confirmLootBind=false,confirmEquipBind=false}}
function pt:RegisterModule(_, module) self.module=module end
local queue, frame, dialog = {}, nil, nil
local shift, combat, bindType, bop = false, false, 2, nil
local accepts, lastAction = 0, nil
function IsShiftKeyDown() return shift end
function InCombatLockdown() return combat end
function CreateFrame()
    frame={events={}}
    function frame:RegisterEvent(event) self.events[event]=true end
    function frame:SetScript(_, callback) self.callback=callback end
    return frame
end
C_Timer={After=function(_, callback) queue[#queue+1]=callback end}
function GetLootRollItemInfo() return 1,"Example",1,3,bop end
function GetLootRollItemLink() return "item:100" end
C_Item={GetItemInfo=function() return "Example",nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,bindType end}
function StaticPopup_FindVisible(which)
    return dialog and dialog.shown and dialog.which==which and dialog or nil
end
function RollOnLoot() error("Never select a roll automatically") end
function LootSlot() error("Never select loot automatically") end
StaticPopupDialogs={}
for _, which in ipairs({"CONFIRM_LOOT_ROLL","LOOT_BIND","EQUIP_BIND"}) do
    StaticPopupDialogs[which]={OnAccept=function(d,id,roll)
        accepts=accepts+1; lastAction={d.which,id,roll}
    end}
end
assert(loadfile("LootConfirmations.lua"))("PatchTools",pt)
pt.module:Initialize(pt)
local function Flush()
    local pending=queue; queue={}
    for _, callback in ipairs(pending) do callback() end
end
local function Popup(which,id,roll)
    dialog={which=which,data=id,data2=roll,shown=true}
    function dialog:Hide() self.shown=false end
end
local function Event(event,id,roll)
    assert(frame.events[event]); frame.callback(frame,event,id,roll)
end
local function Roll(mode, roll, kind, isBop)
    pt.db.boeRollConfirm=mode; bindType=kind; bop=isBop
    Popup("CONFIRM_LOOT_ROLL",10,roll)
    Event("CONFIRM_LOOT_ROLL",10,roll); Flush()
end
Roll("off",2,2); assert(accepts==0 and dialog.shown)
Roll("greed",2,2); assert(accepts==1 and not dialog.shown and lastAction[3]==2)
for _, case in ipairs({{"greed",1,2},{"all",3,2},{"all",0,2},{"all",99,2},
                        {"greed",2,1},{"greed",2,0},{"greed",2,4},{"invalid",2,2}}) do
    local before=accepts; Roll(table.unpack(case)); assert(accepts==before and dialog.shown)
end
Roll("all",1,2); assert(accepts==2 and lastAction[3]==1)
Roll("all",2,nil); assert(accepts==2 and dialog.shown) -- uncached data
Roll("all",2,2,true); assert(accepts==2 and dialog.shown) -- contradictory BoP flag wins
local saved=C_Item.GetItemInfo; C_Item.GetItemInfo=nil
Roll("greed",2,2); assert(accepts==2 and dialog.shown); C_Item.GetItemInfo=saved
bop=nil; bindType=2

-- Popup handlers may run after our event listener; confirm only on the next tick.
pt.db.boeRollConfirm="greed"; dialog=nil
Event("CONFIRM_LOOT_ROLL",10,2); Popup("CONFIRM_LOOT_ROLL",10,2); Flush()
assert(accepts==3 and not dialog.shown)
for _, change in ipairs({"differentId","differentRoll","dismissed","shift","combat","disabled"}) do
    Popup("CONFIRM_LOOT_ROLL",10,2); Event("CONFIRM_LOOT_ROLL",10,2)
    if change=="differentId" then dialog.data=11
    elseif change=="differentRoll" then dialog.data2=1
    elseif change=="dismissed" then dialog:Hide()
    elseif change=="shift" then shift=true
    elseif change=="combat" then combat=true
    else pt.db.boeRollConfirm="off" end
    Flush(); assert(accepts==3)
    shift=false; combat=false; pt.db.boeRollConfirm="greed"
end

for _, case in ipairs({{"LOOT_BIND_CONFIRM","LOOT_BIND","confirmLootBind"},
                        {"EQUIP_BIND_CONFIRM","EQUIP_BIND","confirmEquipBind"}}) do
    local event,which,option=table.unpack(case)
    local before=accepts
    Popup(which,4); Event(event,4); Flush(); assert(accepts==before and dialog.shown)
    pt.db[option]=true
    Popup(which,4); Event(event,4); Flush(); assert(accepts==before+1 and not dialog.shown)
    Popup(which,4); shift=true; Event(event,4); shift=false; Flush(); assert(dialog.shown)
    Popup(which,4); combat=true; Event(event,4); combat=false; Flush(); assert(dialog.shown)
    Event(event,4); pt.db[option]=false; Flush(); assert(dialog.shown)
end
assert(not frame.events.EQUIP_BIND_REFUNDABLE_CONFIRM and not frame.events.EQUIP_BIND_TRADEABLE_CONFIRM)
assert(not frame.events.CONFIRM_DISENCHANT_ROLL)

-- Missing/failed native handlers leave the original warning for manual action.
pt.db.confirmEquipBind=true
StaticPopupDialogs.EQUIP_BIND.OnAccept=function() error("native action unavailable") end
Popup("EQUIP_BIND",4); Event("EQUIP_BIND_CONFIRM",4); Flush(); assert(dialog.shown)
StaticPopupDialogs.EQUIP_BIND=nil
Event("EQUIP_BIND_CONFIRM",4); Flush(); assert(dialog.shown)
print("PASS: optional BoE Greed/Need confirmations, cached bind-type checks, separate loot/equip settings, native actions, Shift/combat, stale-dialog cancellation and manual fallback.")
