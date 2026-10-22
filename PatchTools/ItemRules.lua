local _, PT = ...
function PT:ItemID(value)
    if type(value) == "string" then value = value:match("item:(%d+)") or value:match("^%s*(%d+)%s*$") end
    local id = tonumber(value)
    if id and id == id and id > 0 and id <= 2147483647 and id % 1 == 0 then return id end
end
function PT:SetItemRule(list, value, enabled)
    if list ~= "sellBlocklist" and list ~= "sellAllowlist" then return false end
    local id = self:ItemID(value)
    if not id then return false end
    self.db[list][id] = enabled and true or nil
    return true
end
function PT:ShouldSellItem(info)
    local id = self:ItemID(info.itemID or info.hyperlink)
    -- Unidentified items are never eligible. Protection always wins.
    if not id or self.db.sellBlocklist[id] then return false end
    return (self.db.autoSell and info.quality == 0)
        or (self.db.sellWhitelist and self.db.sellAllowlist[id] == true)
end
