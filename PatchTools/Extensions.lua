local _, PT = ...

-- Versioned, deliberately small interface for independently installed addons.
PT.extensionAPI = 1
PT.extraOptionsPages = {}
local reserved = {general=true, vendor=true, tooltips=true, phase=true, about=true}

function PT:RegisterOptionsPage(id, title, build)
    if type(id) ~= "string" or not id:match("^[%w_]+$") or reserved[id]
        or type(title) ~= "string" or type(build) ~= "function" then return false end
    for _, entry in ipairs(self.extraOptionsPages) do
        if entry.id == id then return false end
    end
    -- Current sidebar has room for three extensions, in addition to five built-in pages.
    if #self.extraOptionsPages >= 3 then return false end
    local entry = {id=id, title=title, build=build}
    self.extraOptionsPages[#self.extraOptionsPages+1] = entry
    if self.mountOptionsPage then return self.mountOptionsPage(entry) end
    return true
end
