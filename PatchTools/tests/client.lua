local savedBuild, savedProject, savedClassic = GetBuildInfo, WOW_PROJECT_ID, WOW_PROJECT_CLASSIC
local cases = {
    {11509, 2, true, false},
    {11510, 2, true, false},
    {16001, 2, false, true},
    {16002, 2, false, true},
    {120105, 1, false, false},
    {50504, 19, false, false},
}
for _, case in ipairs(cases) do
    GetBuildInfo = function() return "test", "1", "", case[1] end
    WOW_PROJECT_ID, WOW_PROJECT_CLASSIC = case[2], 2
    local pt = {}
    assert(loadfile("Client.lua"))("PatchTools", pt)
    assert(pt.isClassicEra == case[3] and pt.isForever == case[4])
    assert(pt.supportsPhasing == case[4] and pt.hasProfessionBag == case[4])
end
GetBuildInfo, WOW_PROJECT_ID, WOW_PROJECT_CLASSIC = savedBuild, savedProject, savedClassic
print("PASS: interface-family detection distinguishes Era and Forever with shared project IDs, tolerates patch increments and excludes Retail/Mists.")
