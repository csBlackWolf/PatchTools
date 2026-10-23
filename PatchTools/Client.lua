local _, PT = ...

function PT:DetectClient()
    local version, build, _, interface = GetBuildInfo()
    interface = tonumber(interface) or 0
    -- Era and Forever can share a project ID. The interface family separates
    -- Era 1.15.x from Forever 1.60.x without depending on install folder names.
    local classicProject = WOW_PROJECT_ID == nil or WOW_PROJECT_CLASSIC == nil
        or WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
    self.isClassicEra = classicProject and interface >= 10000 and interface < 16000
    self.isForever = interface >= 16000 and interface < 17000
    self.supportsPhasing = self.isForever
    self.hasProfessionBag = self.isForever
    self.gameLabel = self.isClassicEra and "WoW Classic Era"
        or (self.isForever and "WoW Forever" or "World of Warcraft")
    self.clientVersion, self.clientBuild, self.clientInterface = version, build, interface
end
PT:DetectClient()
