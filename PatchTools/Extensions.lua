local _, PT = ...

-- Versioned, deliberately small interface for independently installed addons.
PT.extensionAPI = 1
PT.extraOptionsPages = {}
local reserved = {general=true, quests=true, vendor=true, tooltips=true, appearance=true, actionbars=true, phase=true, about=true}

function PT:RegisterOptionsPage(id, title, build)
    if type(id) ~= "string" or not id:match("^[%w_]+$") or reserved[id]
        or type(title) ~= "string" or type(build) ~= "function" then return false end
    for _, entry in ipairs(self.extraOptionsPages) do
        if entry.id == id then return false end
    end
    -- Up to eight built-in entries include the optional Maps page; two others fit.
    local additional=0
    for _,entry in ipairs(self.extraOptionsPages) do if entry.id~="maps" then additional=additional+1 end end
    if id~="maps" and additional>=2 then return false end
    local entry = {id=id, title=title, build=build}
    self.extraOptionsPages[#self.extraOptionsPages+1] = entry
    if self.mountOptionsPage then return self.mountOptionsPage(entry) end
    return true
end
