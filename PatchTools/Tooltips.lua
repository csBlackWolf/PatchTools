local _, PT = ...
local module = {}
PT:RegisterModule("Tooltips", module)
function module:Decorate(tooltip)
    if not PT.db or not (PT.db.tooltipIDs or PT.db.tooltipPrices) then return end
    if not tooltip.GetItem or not tooltip.AddDoubleLine then return end
    local _, link = tooltip:GetItem()
    local id = PT:ItemID(link)
    if not id then return end
    local getInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
    local price = getInfo and select(11, getInfo(link))
    local lines = tooltip.patchToolsLines
    if not lines or lines.id ~= id then lines = {id=id}; tooltip.patchToolsLines = lines end
    if PT.db.tooltipIDs and not lines.itemID then
        tooltip:AddDoubleLine("PatchTools · Item ID", tostring(id), .5,.84,1, 1,1,1)
        lines.itemID = true
    end
    if PT.db.tooltipPrices and price ~= nil and not lines.price then
        local money = GetCoinTextureString and GetCoinTextureString(price) or PT:T("COPPER", tostring(price))
        tooltip:AddDoubleLine(PT:T("TIP_PRICE"), price > 0 and money or PT:T("TIP_NO_VALUE"), .5,.84,1, 1,1,1)
        lines.price = true
    end
end
function module:Initialize()
    local function Add(tooltip) self:Decorate(tooltip) end
    for _, tooltip in ipairs({GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2}) do
        if tooltip and tooltip.HookScript then
            tooltip:HookScript("OnTooltipCleared", function(t) t.patchToolsLines = nil end)
            -- Older clients provide this script; modern ones use the processor below.
            if not (TooltipDataProcessor and Enum and Enum.TooltipDataType) then
                pcall(tooltip.HookScript, tooltip, "OnTooltipSetItem", Add)
            end
        end
    end
    if TooltipDataProcessor and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, Add)
    end
end
