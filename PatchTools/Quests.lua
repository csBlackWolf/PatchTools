local _, PT = ...
local Quests = {}
PT:RegisterModule("Quests", Quests)

local function CharacterKey()
    if UnitGUID and UnitGUID("player") then return UnitGUID("player") end
    return (UnitName("player") or "player") .. "-" .. (GetRealmName() or "")
end

function Quests:GetScales()
    local result = {}
    -- PawnIsInitialized is private to Pawn.lua, not an exported global.
    -- Its public character identity and scale API become available on login.
    if not PawnPlayerFullName or not PawnGetAllScalesEx or not PawnCommon
        or (IsLoggedIn and not IsLoggedIn()) then return result end
    local _, _, classID = UnitClass("player")
    local ok, scales = pcall(PawnGetAllScalesEx)
    if not ok or type(scales) ~= "table" then return result end
    for _, entry in ipairs(scales) do
        local scale = PawnCommon.Scales and PawnCommon.Scales[entry.Name]
        if entry.IsVisible and scale and (not scale.ClassID or scale.ClassID == classID) then
            result[#result + 1] = {name=entry.Name, label=entry.LocalizedName or entry.Name}
        end
    end
    return result
end

function Quests:GetSelectedScale()
    local saved = PT.db.questScales
    return type(saved) == "table" and saved[CharacterKey()] or nil
end

function Quests:SetSelectedScale(name)
    if type(PT.db.questScales) ~= "table" then PT.db.questScales = {} end
    PT.db.questScales[CharacterKey()] = name
end

function Quests:ResolveScale()
    local scales, selected = self:GetScales(), self:GetSelectedScale()
    for _, scale in ipairs(scales) do
        if scale.name == selected then return selected end
    end
    -- A saved but unavailable scale must never silently choose another spec.
    if not selected and #scales == 1 then return scales[1].name end
end

function Quests:ChooseReward(count)
    if not PT.db.pawnQuestRewards or not PawnGetItemData or not PawnIsItemAnUpgrade
        or not PawnCanItemHaveStats or not GetQuestItemLink then return end
    local scale = self:ResolveScale()
    if not scale then return end
    local candidate
    for index = 1, count do
        local link = GetQuestItemLink("choice", index)
        if not link then return end -- Wait for all rewards, including competing choices.
        local info = C_Item and C_Item.GetItemInfo or GetItemInfo
        if not info then return end
        local name, _, _, _, level = info(link)
        if not name or not level or level > UnitLevel("player") then return end
        if PawnCanItemHaveStats(link) then
            local ok, item = pcall(PawnGetItemData, link)
            if not ok or not item or not item.Link or not item.Stats then return end
            local success, upgrades, _, _, _, needsEnhancements = pcall(PawnIsItemAnUpgrade, item, true)
            if not success or needsEnhancements then return end
            for _, upgrade in ipairs(upgrades or {}) do
                if upgrade[1] == scale and type(upgrade[3]) == "number"
                    and upgrade[3] > 0 and upgrade[3] < math.huge then
                    if candidate and candidate ~= index then return end
                    candidate = index
                end
            end
        end
    end
    return candidate
end

function Quests:RunOnce(stage, id, fn, ...)
    local key = stage .. ":" .. tostring(id)
    if self.lastAction == key then return end
    self.lastAction = key
    fn(...)
end

function Quests:Handle(event)
    if event == "QUEST_FINISHED" or event == "GOSSIP_CLOSED" then
        self.lastAction, self.rewardQuest = nil, nil
        return
    end
    if not PT.db or (IsShiftKeyDown and IsShiftKeyDown())
        or (InCombatLockdown and InCombatLockdown()) then return end
    if event == "GOSSIP_SHOW" then
        self.rewardQuest = nil
        if PT.db.autoQuestTurnIn and C_GossipInfo and C_GossipInfo.GetActiveQuests then
            for _, quest in ipairs(C_GossipInfo.GetActiveQuests() or {}) do
                if quest.isComplete and quest.questID and C_GossipInfo.SelectActiveQuest then
                    self:RunOnce("active", quest.questID, C_GossipInfo.SelectActiveQuest, quest.questID)
                    return
                end
            end
        end
        if PT.db.autoQuestAccept and C_GossipInfo and C_GossipInfo.GetAvailableQuests then
            local quest = (C_GossipInfo.GetAvailableQuests() or {})[1]
            if quest and quest.questID and C_GossipInfo.SelectAvailableQuest then
                self:RunOnce("available", quest.questID, C_GossipInfo.SelectAvailableQuest, quest.questID)
            end
        end
    elseif event == "QUEST_GREETING" then
        self.rewardQuest = nil
        if PT.db.autoQuestTurnIn and GetNumActiveQuests and GetActiveTitle and SelectActiveQuest then
            for index = 1, GetNumActiveQuests() do
                local title, complete = GetActiveTitle(index)
                if complete then self:RunOnce("greeting-active", title, SelectActiveQuest, index); return end
            end
        end
        if PT.db.autoQuestAccept and GetNumAvailableQuests and GetNumAvailableQuests() > 0 and SelectAvailableQuest then
            self:RunOnce("greeting-available", 1, SelectAvailableQuest, 1)
        end
    elseif event == "QUEST_DETAIL" then
        self.rewardQuest = nil
        local id = GetQuestID and GetQuestID()
        if PT.db.autoQuestAccept and id and id > 0 and AcceptQuest then
            self:RunOnce("accept", id, AcceptQuest)
        end
    elseif event == "QUEST_PROGRESS" then
        self.rewardQuest = nil
        local id = GetQuestID and GetQuestID()
        if PT.db.autoQuestTurnIn and id and id > 0 and IsQuestCompletable and IsQuestCompletable() and CompleteQuest then
            self:RunOnce("complete", id, CompleteQuest)
        end
    elseif event == "QUEST_COMPLETE" or event == "QUEST_ITEM_UPDATE" then
        local id = GetQuestID and GetQuestID()
        if event == "QUEST_ITEM_UPDATE" and (not self.rewardQuest or id ~= self.rewardQuest) then return end
        if not PT.db.autoQuestTurnIn or not id or id <= 0 or not GetNumQuestChoices or not GetQuestReward then return end
        self.rewardQuest = id
        local count = GetNumQuestChoices()
        if type(count) ~= "number" or count < 0 then return end
        local choice = count <= 1 and 1 or self:ChooseReward(count)
        if choice then self:RunOnce("reward", id, GetQuestReward, choice) end
    end
end

function Quests:Initialize()
    if self.events then return end
    self.events = CreateFrame("Frame")
    for _, event in ipairs({"GOSSIP_SHOW", "QUEST_GREETING", "QUEST_DETAIL", "QUEST_PROGRESS",
        "QUEST_COMPLETE", "QUEST_ITEM_UPDATE", "QUEST_FINISHED", "GOSSIP_CLOSED"}) do
        self.events:RegisterEvent(event)
    end
    self.events:SetScript("OnEvent", function(_, event) self:Handle(event) end)
end
