local pt = {db = {simpleDelete = false}}
function pt:RegisterModule(_, module) self.module = module end
local hook, dialog, combat, calls = nil, nil, false, 0
function hooksecurefunc(name, callback)
    assert(name == "StaticPopup_Show" and hook == nil)
    hook = callback
end
function StaticPopup_Show() end
function StaticPopup_FindVisible(which)
    return dialog and dialog.which == which and dialog or nil
end
function InCombatLockdown() return combat end
DELETE_ITEM = "Destroy %s?"
DELETE_QUEST_ITEM = "Destroy quest item %s? This affects a quest."
function DeleteCursorItem() error("A hook must never delete an item") end
C_Item = {DeleteItem = DeleteCursorItem}
local definitions = {DELETE_GOOD_ITEM = {hasEditBox = true}}
StaticPopupDialogs = definitions
local function Popup(which)
    local edit = {visible = true, focus = true}
    function edit:ClearFocus() self.focus = false end
    function edit:Hide() self.visible = false end
    local button = {enabled = false}
    function button:Enable() self.enabled = true end
    local value = {which = which, data = {itemGUID = "original-guid"}, text = "Type DELETE"}
    function value:GetEditBox() return edit end
    function value:GetButton1() return button end
    function value:SetText(text) self.text = text end
    function value:Resize() self.resized = true end
    value.OnAccept = function() calls = calls + 1 end
    value.OnCancel = function() calls = calls - 1 end
    return value, edit, button
end
assert(loadfile("DeleteConfirmation.lua"))("PatchTools", pt)
pt.module:Initialize(); pt.module:Initialize()
dialog = Popup("DELETE_GOOD_ITEM")
hook("DELETE_GOOD_ITEM", "Example")
assert(dialog.text == "Type DELETE")
pt.db.simpleDelete = true
local edit, button
dialog, edit, button = Popup("DELETE_GOOD_ITEM")
local accept, cancel, data = dialog.OnAccept, dialog.OnCancel, dialog.data
hook("DELETE_GOOD_ITEM", "|cff00ff00[Example]|r")
assert(button.enabled and not edit.visible and not edit.focus and dialog.resized)
assert(dialog.text == "Destroy |cff00ff00[Example]|r?")
assert(dialog.OnAccept == accept and dialog.OnCancel == cancel and dialog.data == data)
assert(calls == 0 and definitions.DELETE_GOOD_ITEM.hasEditBox)
dialog:OnAccept(); assert(calls == 1)
dialog:OnCancel(); assert(calls == 0)
dialog = Popup("DELETE_GOOD_QUEST_ITEM")
hook("DELETE_GOOD_QUEST_ITEM", "Quest item")
assert(dialog.text:find("This affects a quest", 1, true))
for _, which in ipairs({"DELETE_GOOD_ITEM_GAMEPAD", "DELETE_ITEM", "UNRELATED"}) do
    dialog = Popup(which); hook(which, "Example")
    assert(dialog.text == "Type DELETE")
end
combat = true
dialog = Popup("DELETE_GOOD_ITEM"); hook("DELETE_GOOD_ITEM", "Example")
assert(dialog.text == "Type DELETE")
combat = false; pt.db.simpleDelete = false
dialog = Popup("DELETE_GOOD_ITEM"); hook("DELETE_GOOD_ITEM", "Example")
assert(dialog.text == "Type DELETE")
pt.db.simpleDelete = true
dialog = nil; hook("DELETE_GOOD_ITEM", "Example")
dialog = {which = "DELETE_GOOD_ITEM"}; hook("DELETE_GOOD_ITEM", "Example")
print("PASS: optional delete confirmation preserves native actions, quest warning and GUID; disabled, combat, gamepad and missing-dialog paths stay untouched.")
