local addon, PT = ...
_G.PatchTools = PT
PT.version = "@project-version@"
PT.defaults = {
    optionsTransparency = 0,
    barDecoration = "native", barDecorationLayer = "default", silverFoxUnlocked = false, modernActionBar = false,
    autoQuestAccept = false, autoQuestTurnIn = false, pawnQuestRewards = false,
    autoSell = true, autoRepair = true, extendedZoom = true,
    ghostColor = false, messages = true, cooldownNumbers = false,
    autoLoot = false, fastLoot = false, minimapIcon = true, minimapAngle = 225,
    boeRollConfirm = "off", confirmLootBind = false, confirmEquipBind = false,
    phaseInitial = false, phaseSoon = false, phaseSound = true, phaseLead = 60,
    phaseDuration = 10, phaseChat = true,
    simpleDelete = false, sellWhitelist = true, sellProfessionBag = true, tooltipIDs = false, tooltipPrices = false,
}
PT.modules = {}
function PT:Print(message)
    print("|cff80d6ffPatchTools:|r " .. message)
end
function PT:RegisterModule(name, module)
    self.modules[name] = module
end
local function ReadCVar(name)
    local fn = C_CVar and C_CVar.GetCVar or GetCVar
    if not fn then return nil end
    local ok, value = pcall(fn, name)
    if ok then return value end
end
local function WriteCVar(name, value)
    local fn = C_CVar and C_CVar.SetCVar or SetCVar
    if not fn then return false end
    local ok = pcall(fn, name, tostring(value))
    return ok
end
function PT:ApplyCVar(name, enabled, value)
    local db = self.db
    -- Autoloot und Cooldown-Zahlen separat pro Charakter sichern.
    -- Ein neuer Charakter darf nicht den früheren Wert eines anderen übernehmen.
    if name == "autoLootDefault" or name == "countdownForCooldowns" then
        local player = UnitName("player")
        if not player then return end
        local key = player .. "-" .. GetRealmName()
        db.characterCVars = db.characterCVars or {}
        db.characterCVars[key] = db.characterCVars[key] or {cvarBackup = {}, cvarApplied = {}}
        db = db.characterCVars[key]
    end
    local current = ReadCVar(name)
    if current == nil then
        if enabled and not self.warned[name] then
            self.warned[name] = true
            self:Print(self:T("CVAR_UNAVAILABLE", name))
        end
        return
    end
    if enabled then
        if not db.cvarBackup[name] then db.cvarBackup[name] = current end
        if WriteCVar(name, value) then
            db.cvarApplied[name] = ReadCVar(name)
        end
    elseif db.cvarBackup[name] then
        -- Nicht die zwischenzeitlichen Einstellungen eines anderen Addons überschreiben.
        local applied = db.cvarApplied[name]
        if applied and tonumber(current) == tonumber(applied) then
            WriteCVar(name, db.cvarBackup[name])
        end
        db.cvarBackup[name], db.cvarApplied[name] = nil, nil
    end
end
function PT:ApplyZoom(resetToDefault)
    local name = "cameraDistanceMaxZoomFactor"
    if self.db.extendedZoom then
        self:ApplyCVar(name, true, 4)
    elseif resetToDefault or self.db.cvarApplied[name] or self.db.cvarBackup[name] then
        local fn = C_CVar and C_CVar.GetCVarDefault or GetCVarDefault
        local ok, default
        if fn then ok, default = pcall(fn, name) end
        if ok and default ~= nil then
            WriteCVar(name, default)
            self.db.cvarBackup[name], self.db.cvarApplied[name] = nil, nil
        elseif not self.warned.zoomDefault then
            self.warned.zoomDefault = true
            self:Print(self:T("ZOOM_DEFAULT_ERROR"))
        end
    end
end
function PT:ApplySettings()
    self:ApplyZoom(false)
    self:ApplyCVar("ffxDeath", self.db.ghostColor, 0)
    self:ApplyCVar("countdownForCooldowns", self.db.cooldownNumbers, 1)
    self:ApplyCVar("autoLootDefault", self.db.autoLoot, 1)
end
function PT:SetOption(key, value)
    if self.defaults[key] == nil then return end
    self.db[key] = value
    if key == "optionsTransparency" and self.ApplyOptionsAppearance then self:ApplyOptionsAppearance() end
    if (key == "barDecoration" or key == "barDecorationLayer" or key == "modernActionBar") and self.modules.ActionBars then
        self.modules.ActionBars:Apply()
    end
    if key:match("^phase") and self.modules.Phasing then self.modules.Phasing:SettingsChanged() end
    if key == "extendedZoom" then
        self:ApplyZoom(not value)
    elseif key == "ghostColor" then
        self:ApplyCVar("ffxDeath", value, 0)
    elseif key == "cooldownNumbers" then
        self:ApplyCVar("countdownForCooldowns", value, 1)
    elseif key == "autoLoot" then
        self:ApplyCVar("autoLootDefault", value, 1)
    elseif key == "minimapIcon" then
        local module = self.modules.Minimap
        if module then module:Update() end
    end
end
function PT:OpenOptions()
    local phasing = self.modules.Phasing
    if phasing and phasing.options and not self.optionPages then phasing.options:Hide() end
    if self.options then self.options:Show() end
end
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" then
        if name ~= addon then return end
        if type(PatchToolsDB) ~= "table" then PatchToolsDB = {} end
        PT.db = PatchToolsDB
        if type(PatchToolsCharacterDB) ~= "table" then
            PatchToolsCharacterDB = {optionsScale = PT.db.optionsScale}
        end
        PT.windowDB = PatchToolsCharacterDB
        -- Preserve the previous checkbox/style combination when moving to a
        -- separate decoration selector. Never overwrite an existing choice.
        if type(PT.db.barDecoration) ~= "string" then
            PT.db.barDecoration = PT.db.hideBarEndCaps == true and "none"
                or PT.db.modernActionBar == true and "dragon" or "native"
        end
        for key, default in pairs(PT.defaults) do
            if type(PT.db[key]) ~= type(default) then PT.db[key] = default end
        end
        -- v1-Schalter bleiben erhalten; der fehlerhafte 2,6-Regler entfällt.
        PT.db.zoomFactor = nil
        PT.db.schemaVersion = 4
        for _, key in ipairs({"sellBlocklist", "sellAllowlist"}) do
            if type(PT.db[key]) ~= "table" then PT.db[key] = {} end
            for id, enabled in pairs(PT.db[key]) do
                if type(id) ~= "number" or id < 1 or id % 1 ~= 0 or enabled ~= true then PT.db[key][id] = nil end
            end
        end
        PT.db.minimapAngle = PT.db.minimapAngle % 360
        if type(PT.db.cvarBackup) ~= "table" then PT.db.cvarBackup = {} end
        if type(PT.db.cvarApplied) ~= "table" then PT.db.cvarApplied = {} end
        PT.warned = {}
        PT:CreateOptions()
        for _, module in pairs(PT.modules) do
            if module.Initialize then module:Initialize(PT) end
        end
    elseif PT.db then
        PT:ApplySettings()
    end
end)
SLASH_PATCHTOOLS1 = "/patchtools"
SLASH_PATCHTOOLS2 = "/ptools"
SlashCmdList.PATCHTOOLS = function(message)
    if not PT.db then return end
    if message == "reset" then
        PT:ResetOptionsWindow()
        PT:OpenOptions()
    elseif message == "status" then
        local version, build, _, interface = GetBuildInfo()
        PT:Print("v" .. PT.version .. "; Client " .. version .. " / " .. build .. "; Interface " .. interface)
        PT:Print("Client locale: " .. PT.clientLocale .. "; UI language: " .. PT.locale)
        for _, key in ipairs({"autoSell", "autoRepair", "extendedZoom", "ghostColor", "cooldownNumbers", "autoLoot", "fastLoot", "minimapIcon", "boeRollConfirm", "confirmLootBind", "confirmEquipBind", "simpleDelete", "phaseInitial", "phaseSoon", "phaseSound", "phaseLead", "phaseDuration", "phaseChat"}) do
            PT:Print(key .. ": " .. tostring(PT.db[key]))
        end
        PT:Print("Zoom-CVar: " .. tostring(ReadCVar("cameraDistanceMaxZoomFactor")))
        PT:Print("Ghost-CVar: " .. tostring(ReadCVar("ffxDeath")))
        PT:Print("Cooldown-CVar: " .. tostring(ReadCVar("countdownForCooldowns")))
        PT:Print("Autoloot-CVar: " .. tostring(ReadCVar("autoLootDefault")))
    else
        PT:OpenOptions()
    end
end
