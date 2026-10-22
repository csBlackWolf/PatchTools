local now, seconds, sounds = 0, nil, 0
function GetTime() return now end
function GetEvictionTimeRemaining() return seconds end
function PlaySound() sounds = sounds + 1 end
local function Widget()
    return setmetatable({scripts = {}}, {__index = function(_, key)
        if key == "SetScript" then return function(self, event, fn) self.scripts[event] = fn end end
        if key == "CreateFontString" then return Widget end
        if key == "Show" then return function(self) self.shown = true; if self.scripts.OnShow then self.scripts.OnShow() end end end
        if key == "Hide" then return function(self) self.shown = false end end
        return function() end
    end})
end
function CreateFrame() return Widget() end
UIParent = Widget()
local pt = {db = {phaseInitial = true, phaseSoon = true, phaseSound = true, phaseLead = 10}, messages = {}}
function pt:RegisterModule(_, module) self.module = module end
function pt:T(key, value) return key .. (value and tostring(value) or "") end
function pt:Print(message) table.insert(self.messages, message) end
assert(loadfile("Phasing.lua"))("PatchTools", pt)
local m = pt.module
m:Initialize()
local function Event(event) m.frame.scripts.OnEvent(m.frame, event) end
local function Tick(value) seconds = value; now = now + 0.2; m.frame.scripts.OnUpdate(m.frame, 0.2) end
seconds = 40; Event("SHARD_TRANSFER_IMMINENT")
assert(#pt.messages == 1 and sounds == 1)
Event("SHARD_TRANSFER_IMMINENT"); Tick(30)
assert(#pt.messages == 1)
Tick(10); Tick(9); Event("SHARD_TRANSFER_IMMINENT")
assert(#pt.messages == 2 and sounds == 2)
Tick(0); Tick(-1); assert(#pt.messages == 2 and m.active)
Event("SHARD_TRANSFER_CANCELLED"); assert(not m.active and not m.display.shown)
Tick(5); assert(#pt.messages == 2)
seconds = 5; Event("SHARD_TRANSFER_IMMINENT")
assert(#pt.messages == 3 and pt.messages[3] == "PHASE_ALERT_SOON5")
Event("SHARD_TRANSFER"); assert(not m.active)
seconds = 30; Event("SHARD_TRANSFER_IMMINENT"); Tick(50); Tick(11)
assert(#pt.messages == 4); Tick(8); assert(#pt.messages == 5)
Event("SHARD_TRANSFER_CANCELLED")
pt.db.phaseInitial = false; pt.db.phaseSoon = false
seconds = 30; Event("SHARD_TRANSFER_IMMINENT"); Tick(5); assert(#pt.messages == 5)
pt.db.phaseSoon = true; Tick(4); assert(#pt.messages == 6)
Event("SHARD_TRANSFER_CANCELLED")
pt.db.phaseSound = false
seconds = 8; Event("PLAYER_ENTERING_WORLD"); assert(#pt.messages == 7 and sounds == 6)
seconds = nil; Event("PLAYER_ENTERING_WORLD"); assert(not m.active)
pt.db.phaseInitial = true; Event("SHARD_TRANSFER_IMMINENT")
assert(#pt.messages == 8); Tick(nil); assert(#pt.messages == 8)
Tick(0); assert(#pt.messages == 9)
Event("SHARD_TRANSFER_CANCELLED")
seconds = 0; Event("PLAYER_ENTERING_WORLD"); assert(not m.active)
pt.db.phaseLead = 999; m:SettingsChanged(); assert(pt.db.phaseLead == 600)
pt.db.phaseLead = -9; m:SettingsChanged(); assert(pt.db.phaseLead == 1)
pt.db.phaseLead = 0/0; m:SettingsChanged(); assert(pt.db.phaseLead == 60)
m:Alert(10, true, true); assert(not m.active and m.display.shown)
now = now + 6; Tick(nil); assert(m.display.shown)
now = now + 5; Tick(nil); assert(not m.display.shown)
pt.db.phaseDuration = 30; pt.db.phaseChat = false
local beforeMessages = #pt.messages
m:Alert(40, false)
assert(m.hideAt == now + 30 and #pt.messages == beforeMessages)
now = now + 15; Tick(nil); assert(m.display.shown)
now = now + 16; Tick(nil); assert(not m.display.shown)
pt.db.phaseChat = true; m:Alert(40, false)
assert(#pt.messages == beforeMessages + 1)
pt.db.phaseDuration = 999; m:SettingsChanged(); assert(pt.db.phaseDuration == 60)
pt.db.phaseDuration = 0/0; m:SettingsChanged(); assert(pt.db.phaseDuration == 10)
print("PASS: phasing deadlines, deduplication, cancellation, completion, rescheduling, late announcements, toggles, reload recovery, unavailable time, bounds and preview expiry.")
