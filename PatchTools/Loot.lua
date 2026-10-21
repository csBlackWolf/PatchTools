local _, PT = ...
local Loot = {}
PT:RegisterModule("Loot", Loot)

-- Event-Boolean hat Vorrang: der Client hat Modifikatortasten bereits ausgewertet.
function Loot:AutoLootRequested(eventValue)
    if type(eventValue) == "boolean" then return eventValue end
    local fn = C_CVar and C_CVar.GetCVar or GetCVar
    local enabled = fn and fn("autoLootDefault") == "1"
    local modifier = IsModifiedClick and IsModifiedClick("AUTOLOOTTOGGLE")
    if modifier then return not enabled end
    return enabled == true
end

function Loot:Sweep(generation)
    if not self.open or self.generation ~= generation or not self.allowed
        or not self.owner.db.fastLoot then return end
    if not (GetNumLootItems and GetLootSlotInfo and LootSlot) then return end
    -- Rückwärts abarbeiten, damit entfernte Einträge nachfolgende Slots nicht verschieben.
    for slot = GetNumLootItems(), 1, -1 do
        if not self.open or self.generation ~= generation or not self.allowed then return end
        local slotType = GetLootSlotType and GetLootSlotType(slot)
        local _, name, _, _, _, locked = GetLootSlotInfo(slot)
        if slotType ~= 0 and name and not locked and not self.requested[slot] then
            self.requested[slot] = true
            -- Keine Bindungsbestätigungen, Gruppenbeutevergabe oder erzwungenes Schließen.
            LootSlot(slot)
        end
    end
end

function Loot:Initialize(owner)
    self.owner, self.generation = owner, 0
    local frame = CreateFrame("Frame")
    for _, event in ipairs({"LOOT_READY", "LOOT_OPENED", "LOOT_CLOSED", "LOOT_BIND_CONFIRM"}) do
        frame:RegisterEvent(event)
    end
    frame:SetScript("OnEvent", function(_, event, autoLoot)
        if event == "LOOT_CLOSED" then
            self.open, self.allowed = false, false
            self.generation = self.generation + 1
        elseif event == "LOOT_BIND_CONFIRM" then
            self.allowed = false -- Native Bestätigung und Lootfenster bleiben benutzbar.
        elseif event == "LOOT_READY" then
            self.generation = self.generation + 1
            self.open, self.requested = true, {}
            self.allowed = self:AutoLootRequested(autoLoot)
            self:Sweep(self.generation)
        elseif event == "LOOT_OPENED" then
            if not self.open then
                self.generation = self.generation + 1
                self.open, self.requested = true, {}
                self.allowed = self:AutoLootRequested(autoLoot)
            elseif type(autoLoot) == "boolean" and not autoLoot then
                self.allowed = false
            end
            local generation = self.generation
            -- Fallback nach dem nativen Öffnen, ohne dessen Handler zu ersetzen.
            C_Timer.After(0, function() self:Sweep(generation) end)
        end
    end)
end
