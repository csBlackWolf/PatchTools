local pt = PatchTools
local originalAPI = C_AddOns
local entries = {
    {name="Zulu", version="3.2", loaded=true, enabled=2},
    {name="PatchToolsBags", version="0.1.2", loaded=true, enabled=2},
    {name="Alpha", version="|cffffffff1.0|r", loaded=true, enabled=2},
    {name="Demand", version="2.0", enabled=2},
    {name="Disabled", enabled=0},
}
local function entry(name)
    for _, value in ipairs(entries) do if value.name == name then return value end end
    error("Unknown addon " .. tostring(name))
end
C_AddOns = {
    GetNumAddOns=function() return #entries end,
    GetAddOnInfo=function(index) return entries[index].name, "Title", "notes" end,
    GetAddOnMetadata=function(name, field) assert(field=="Version"); return entry(name).version end,
    IsAddOnLoaded=function(name) return entry(name).loaded, false end,
    GetAddOnEnableState=function(name, character) assert(character==UnitName("player")); return entry(name).enabled end,
}
local report = pt:BuildDebugReport()
assert(report:find("Loaded addons (3):",1,true))
assert(report:find("Enabled, not loaded (including load-on-demand) (1):",1,true))
assert(report:find("Disabled addons (1):",1,true))
assert(report:find("Alpha — 1.0",1,true) < report:find("Zulu — 3.2",1,true))
assert(report:find("PatchToolsBags — 0.1.2",1,true))
assert(report:find("Disabled — unknown",1,true))
assert(not report:find(UnitName("player"),1,true) and not report:find(GetRealmName(),1,true),'no character or realm names in report')
assert(not report:find("|c",1,true))
SlashCmdList.PATCHTOOLS(" DEBUG ")
assert(pt.debugWindow:IsShown() and pt.debugWindow.edit:GetText()==report)
entries[1].version="3.3"
SlashCmdList.PATCHTOOLS("debug")
assert(pt.debugWindow.edit:GetText():find("Zulu — 3.3",1,true),'each invocation refreshes the report')
pt.debugWindow.edit.scripts.OnEscapePressed()
assert(not pt.debugWindow:IsShown())
local legacy = C_AddOns
C_AddOns=nil
GetNumAddOns=legacy.GetNumAddOns; GetAddOnInfo=legacy.GetAddOnInfo
GetAddOnMetadata=legacy.GetAddOnMetadata; IsAddOnLoaded=legacy.IsAddOnLoaded
GetAddOnEnableState=function(character,index) assert(character==UnitName("player")); return entries[index].enabled end
assert(pt:BuildDebugReport():find("Disabled addons (1):",1,true),'legacy API fallback')
GetNumAddOns=nil; GetAddOnInfo=nil
assert(pt:BuildDebugReport():find("Addon list unavailable.",1,true))
C_AddOns=originalAPI
GetAddOnMetadata=nil; IsAddOnLoaded=nil; GetAddOnEnableState=nil
print("PASS: debug report with versions, load states, copy window, refresh, legacy APIs and no character names.")
