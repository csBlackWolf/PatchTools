local PT={db={autoQuestAccept=false,autoQuestTurnIn=false,pawnQuestRewards=false},modules={}}
function PT:RegisterModule(name,module) self.modules[name]=module end
assert(loadfile("Quests.lua"))("PatchTools",PT)
local Q=PT.modules.Quests
local shift,combat,id,choices,player=false,false,101,0,"Hunter"
local actions={}
function UnitName() return player end
function UnitGUID() return player end
function GetRealmName() return "Test" end
function UnitClass() return "Hunter","HUNTER",3 end
function UnitLevel() return 60 end
function IsShiftKeyDown() return shift end
function InCombatLockdown() return combat end
function GetQuestID() return id end
function GetNumQuestChoices() return choices end
function AcceptQuest() actions[#actions+1]="accept" end
function CompleteQuest() actions[#actions+1]="complete" end
function GetQuestReward(index) actions[#actions+1]="reward"..index end
function IsQuestCompletable() return true end
local function Reset() Q:Handle("QUEST_FINISHED"); actions={} end
Q:Handle("QUEST_DETAIL"); Q:Handle("QUEST_COMPLETE"); assert(#actions==0)
PT.db.autoQuestAccept=true; PT.db.autoQuestTurnIn=true
Q:Handle("QUEST_DETAIL"); Q:Handle("QUEST_DETAIL"); assert(#actions==1 and actions[1]=="accept")
Q:Handle("QUEST_PROGRESS"); assert(actions[2]=="complete")
Q:Handle("QUEST_COMPLETE"); Q:Handle("QUEST_ITEM_UPDATE"); assert(#actions==3 and actions[3]=="reward1")
Reset(); choices=3; Q:Handle("QUEST_COMPLETE"); assert(#actions==0,"multiple rewards stay manual without Pawn")
Reset(); shift=true; Q:Handle("QUEST_DETAIL"); Q:Handle("QUEST_COMPLETE"); assert(#actions==0)
shift=false; combat=true; Q:Handle("QUEST_DETAIL"); assert(#actions==0); combat=false
local selected
C_GossipInfo={GetActiveQuests=function() return {{questID=201,isComplete=false},{questID=202,isComplete=true}} end,
    GetAvailableQuests=function() return {{questID=203}} end,
    SelectActiveQuest=function(quest) selected=quest end,
    SelectAvailableQuest=function(quest) selected=quest end}
Q:Handle("GOSSIP_SHOW"); assert(selected==202,"completed quest has priority")
Reset(); PT.db.autoQuestTurnIn=false; Q:Handle("GOSSIP_SHOW"); assert(selected==203)
PT.db.autoQuestTurnIn=true
C_GossipInfo=nil
function GetNumActiveQuests() return 1 end
function GetActiveTitle() return "Legacy",true end
function SelectActiveQuest(index) selected="legacy"..index end
Q:Handle("QUEST_GREETING"); assert(selected=="legacy1")
print("PASS: quest events, defaults off, duplicate guard, legacy greeting, Shift and combat bypass.")

PT.db.pawnQuestRewards=true; PawnPlayerFullName="Hunter-Test"
assert(PawnIsInitialized==nil,"Pawn readiness is private, not a global API")
PawnCommon={Scales={BM={ClassID=3},MM={ClassID=3},Warrior={ClassID=1}}}
local scales={{Name="BM",LocalizedName="Beast Mastery",IsVisible=true},{Name="Warrior",IsVisible=true}}
function PawnGetAllScalesEx() return scales end
assert(#Q:GetScales()==1 and Q:ResolveScale()=="BM")
Q:SetSelectedScale("BM"); player="Other"; assert(Q:GetSelectedScale()==nil); player="Hunter"
scales[#scales+1]={Name="MM",IsVisible=true}
Q:SetSelectedScale(nil); assert(Q:ResolveScale()==nil,"ambiguous auto scale remains manual")
Q:SetSelectedScale("BM"); assert(Q:ResolveScale()=="BM")
Q:SetSelectedScale("Removed"); assert(Q:ResolveScale()==nil,"missing saved scale must not fall back")
Q:SetSelectedScale("BM")
local links={"one","two","three"}
function GetQuestItemLink(_,index) return links[index] end
local pending,tooHigh,fail,missingStats,enhancements
C_Item={GetItemInfo=function(link) if link==pending then return end; return link,nil,nil,nil,link==tooHigh and 61 or 1 end}
function PawnCanItemHaveStats(link) return link~="three" end
function PawnGetItemData(link) return {Link=link,Stats=not missingStats and {} or nil} end
local upgrades={one={{"BM","Beast Mastery",.2}},two={{"MM","Marksmanship",.4}}}
function PawnIsItemAnUpgrade(item,noRescan)
    assert(noRescan==true)
    if fail then error("Pawn unavailable") end
    return upgrades[item.Link],nil,nil,nil,enhancements
end
Reset(); Q:Handle("QUEST_COMPLETE"); assert(actions[1]=="reward1")
Q:Handle("QUEST_ITEM_UPDATE"); assert(#actions==1,"reward only once")
upgrades.two={{"BM","Beast Mastery",.1}}
Reset(); Q:Handle("QUEST_COMPLETE"); assert(#actions==0,"two upgrades require manual selection even if one scores higher")
upgrades.two=nil; links[2]=nil
Reset(); Q:Handle("QUEST_COMPLETE"); assert(#actions==0,"missing reward link must not guess")
links[2]="two"; pending="two"; Q:Handle("QUEST_ITEM_UPDATE"); assert(#actions==0)
pending=nil; Q:Handle("QUEST_ITEM_UPDATE"); assert(actions[1]=="reward1","retry item updates only in current reward dialogue")
Reset(); Q:Handle("QUEST_ITEM_UPDATE"); assert(#actions==0,"no automation after closing dialogue")
for _,case in ipairs({"level","stats","enhancements","pawn-error","not-ready"}) do
    Reset()
    tooHigh=case=="level" and "two" or nil
    missingStats=case=="stats"; enhancements=case=="enhancements"; fail=case=="pawn-error"
    PawnPlayerFullName=case~="not-ready" and "Hunter-Test" or nil
    Q:Handle("QUEST_COMPLETE"); assert(#actions==0,case.." must remain manual")
end
print("PASS: per-character Pawn scale, unique upgrade only, complete item data, API failure and pending-item recovery.")
