local _, PT = ...
local Vendor = {}
PT:RegisterModule("Vendor", Vendor)
function Vendor:Initialize(owner)
    self.owner = owner
    self.generation = 0
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("MERCHANT_SHOW")
    frame:RegisterEvent("MERCHANT_CLOSED")
    frame:SetScript("OnEvent", function(_, event)
        self.generation = self.generation + 1
        self.open = event == "MERCHANT_SHOW"
        if self.open and not IsShiftKeyDown() then self:Start(self.generation) end
    end)
end
function Vendor:Repair()
    local db = self.owner.db
    if not db.autoRepair or not CanMerchantRepair() then return end
    local cost, canRepair = GetRepairAllCost()
    if not canRepair or not cost or cost <= 0 then return end
    if GetMoney() < cost then
        if db.messages then self.owner:Print(self.owner:T("NO_REPAIR_FUNDS")) end
        return
    end
    -- Ausschließlich eigenes Geld, kein ungefragter Zugriff auf die Gildenbank.
    RepairAllItems(false)
    if db.messages then
        local money = GetCoinTextureString and GetCoinTextureString(cost) or self.owner:T("COPPER", tostring(cost))
        self.owner:Print(self.owner:T("REPAIR_REQUESTED", money))
    end
end
function Vendor:Start(generation)
    local attempts, sold, passes = {}, 0, 0
    local containers = C_Container
    -- Forever uses the extra reagent slot for profession bags as well.
    local reagentBag = Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag or 5
    local function Active()
        return self.open and self.generation == generation and not IsShiftKeyDown()
    end
    local function Finish()
        if not Active() then return end
        if sold > 0 and self.owner.db.messages then
            self.owner:Print(self.owner:T("SALES_REQUESTED", sold))
        end
        self:Repair()
    end
    local function Step()
        if not Active() then return end
        passes = passes + 1
        if not (self.owner.db.autoSell or self.owner.db.sellWhitelist) or passes > 200 or not containers then Finish(); return end
        -- Only carried containers, including the profession bag; never bank/equipment.
        local bags = {0, 1, 2, 3, 4}
        if self.owner.hasProfessionBag ~= false and self.owner.db.sellProfessionBag then bags[#bags + 1] = reagentBag end
        for _, bag in ipairs(bags) do
            for slot = 1, containers.GetContainerNumSlots(bag) do
                local info = containers.GetContainerItemInfo(bag, slot)
                local key = bag .. ":" .. slot
                if info and self.owner:ShouldSellItem(info) and not info.isLocked
                    and (attempts[key] or 0) < 3 then
                    local isQuest = containers.GetContainerItemQuestInfo
                        and containers.GetContainerItemQuestInfo(bag, slot)
                    local questItem = isQuest and (isQuest.isQuestItem or isQuest.questID)
                    local itemInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
                    local price = itemInfo and select(11, itemInfo(info.hyperlink or info.itemID))
                    if not questItem and price and price > 0 then
                        -- Slot-Inhalt direkt vor dem Verkauf prüfen, nicht mit einer alten Liste arbeiten.
                        containers.UseContainerItem(bag, slot)
                        attempts[key] = (attempts[key] or 0) + 1
                        sold = sold + 1
                        C_Timer.After(0.25, Step)
                        return
                    end
                end
            end
        end
        Finish()
    end
    -- Händler und Gegenstandsdaten erst kurz laden lassen.
    C_Timer.After(0.35, Step)
end
