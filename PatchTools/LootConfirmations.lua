local _, PT = ...
local Confirmations = {}
PT:RegisterModule("LootConfirmations", Confirmations)

local prompts = {
    CONFIRM_LOOT_ROLL = "CONFIRM_LOOT_ROLL",
    LOOT_BIND_CONFIRM = "LOOT_BIND",
    EQUIP_BIND_CONFIRM = "EQUIP_BIND",
}

function Confirmations:Allowed(event, id, rollType)
    local db = self.owner.db
    if not db or (IsShiftKeyDown and IsShiftKeyDown())
        or (InCombatLockdown and InCombatLockdown()) then return false end
    if event == "LOOT_BIND_CONFIRM" then return db.confirmLootBind == true end
    if event == "EQUIP_BIND_CONFIRM" then return db.confirmEquipBind == true end
    if event ~= "CONFIRM_LOOT_ROLL" then return false end
    local mode = db.boeRollConfirm
    if mode ~= "greed" and mode ~= "all" then return false end
    -- Never choose a roll. Only confirm Need/Greed already requested by the player.
    -- Disenchant, pass and unknown roll types always retain their native warning.
    if rollType ~= 2 and not (mode == "all" and rollType == 1) then return false end
    if type(GetLootRollItemInfo) ~= "function" or type(GetLootRollItemLink) ~= "function" then return false end
    local _, name, _, _, bindOnPickup = GetLootRollItemInfo(id)
    if not name or bindOnPickup then return false end
    local link = GetLootRollItemLink(id)
    local info = C_Item and C_Item.GetItemInfo or GetItemInfo
    if not link or type(info) ~= "function" then return false end
    -- A non-BoP roll is not necessarily BoE. Require positive cached bind-type data.
    local bindType = select(14, info(link))
    return bindType == 2 -- Enum.ItemBind.OnEquip, including clients without Enum.
end

function Confirmations:Accept(event, id, rollType)
    if not self:Allowed(event, id, rollType) or type(StaticPopup_FindVisible) ~= "function" then return end
    local which = prompts[event]
    local dialog = StaticPopup_FindVisible(which)
    if not dialog or dialog.which ~= which or dialog.data ~= id then return end
    if event == "CONFIRM_LOOT_ROLL" and dialog.data2 ~= rollType then return end
    local definition = StaticPopupDialogs and StaticPopupDialogs[which]
    if not definition or type(definition.OnAccept) ~= "function" or type(dialog.Hide) ~= "function" then return end
    -- Use precisely the native accept action, with the native data. Do not alter
    -- dialog definitions, replace UIParent handlers, or touch refund/trade warnings.
    local ok = pcall(definition.OnAccept, dialog, dialog.data, dialog.data2)
    if ok and dialog.which == which and dialog.data == id then dialog:Hide() end
end

function Confirmations:Initialize(owner)
    self.owner = owner
    if self.frame or not (C_Timer and C_Timer.After) then return end
    local frame = CreateFrame("Frame")
    self.frame = frame
    for event in pairs(prompts) do frame:RegisterEvent(event) end
    frame:SetScript("OnEvent", function(_, event, id, rollType)
        if type(id) ~= "number" or id < 1 or id % 1 ~= 0 then return end
        if not self:Allowed(event, id, rollType) then return end
        -- UIParent fills the roll dialog's data after StaticPopup_Show returns.
        -- Wait one tick, then recheck settings, modifier keys and dialog identity.
        C_Timer.After(0, function() self:Accept(event, id, rollType) end)
    end)
end
