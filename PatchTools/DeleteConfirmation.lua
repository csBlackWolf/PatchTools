local _, PT = ...
local module = {}
PT:RegisterModule("DeleteConfirmation", module)

-- Keep Blizzard's accept/cancel handlers and item GUID. Only the visible
-- keyboard confirmation is simplified; never delete from an event or hook.
local prompts = {
    DELETE_GOOD_ITEM = "DELETE_ITEM",
    DELETE_GOOD_QUEST_ITEM = "DELETE_QUEST_ITEM",
}
function module:Initialize()
    if self.hooked or type(hooksecurefunc) ~= "function"
        or type(StaticPopup_Show) ~= "function" then return end
    self.hooked = true
    hooksecurefunc("StaticPopup_Show", function(which, itemName)
        local textKey = prompts[which]
        if not textKey or not PT.db or not PT.db.simpleDelete then return end
        -- Leave protected UI alone during combat.
        if InCombatLockdown and InCombatLockdown() then return end
        if type(itemName) ~= "string" or type(_G[textKey]) ~= "string"
            or type(StaticPopup_FindVisible) ~= "function" then return end
        local dialog = StaticPopup_FindVisible(which)
        if not dialog or dialog.which ~= which then return end
        local editBox = dialog.GetEditBox and dialog:GetEditBox()
        local accept = dialog.GetButton1 and dialog:GetButton1()
        if not editBox or not accept or not dialog.SetText then return end
        editBox:ClearFocus()
        editBox:Hide()
        dialog:SetText(string.format(_G[textKey], itemName))
        accept:Enable()
        if dialog.Resize then dialog:Resize() end
    end)
end
