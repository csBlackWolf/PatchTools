local combat = false
function InCombatLockdown() return combat end
local frames = {}
local function Widget(alpha)
    local w = {alpha=alpha or 1,shown=true,hooks={},textures={}}
    function w:GetAlpha() return self.alpha end
    function w:SetAlpha(value) assert(not combat); self.alpha=value end
    function w:SetColorTexture(...) self.color={...} end
    function w:SetPoint(...) end
    function w:SetHeight(...) end
    function w:SetWidth(...) end
    function w:SetTexture(value) self.texture=value end
    function w:SetSize(w,h) self.size={w,h} end
    function w:SetTexCoord(...) self.coords={...} end
    function w:ClearAllPoints() end
    function w:SetShown(value) assert(not combat); self.shown=value end
    function w:IsShown() return self.shown end
    function w:CreateTexture() local t=Widget(); self.textures[#self.textures+1]=t; return t end
    function w:HookScript(event,fn) self.hooks[event]=fn end
    function w:RegisterEvent(event) end
    function w:SetScript(event,fn) self[event]=fn end
    return w
end
function CreateFrame() local f=Widget(); frames[#frames+1]=f; return f end
local pt={db={hideBarEndCaps=false,modernActionBar=false},modules={}}
function pt:RegisterModule(key,value) self.modules[key]=value end
assert(loadfile("ActionBars.lua"))("PatchTools",pt)
local bars=pt.modules.ActionBars
-- Loading before Blizzard's frames exists is harmless; late loading works.
bars:Initialize(pt)
MainMenuBar=Widget(); MainMenuBarArtFrame=Widget()
MainMenuBarLeftEndCap=Widget(.75); MainMenuBarRightEndCap=Widget()
for i=0,3 do _G["MainMenuBarTexture"..i]=Widget(.8) end
MainMenuBarTextureExtender=Widget()
MainActionBar=Widget(); MainActionBar.EndCaps=Widget(); MainActionBar.EndCaps.LeftEndCap=Widget(); MainActionBar.EndCaps.RightEndCap=Widget()
local pageControl=Widget(); MainActionBar.ActionBarPageNumber=pageControl
bars:Apply()
assert(MainMenuBarLeftEndCap.alpha==.75 and #MainMenuBarArtFrame.textures==0)
pt.db.hideBarEndCaps=true; bars:Apply()
assert(MainMenuBarLeftEndCap.alpha==0 and MainActionBar.EndCaps.LeftEndCap.alpha==0)
assert(MainMenuBarTexture0.alpha==.8 and MainMenuBar.shown)
pt.db.modernActionBar=true; bars:Apply()
assert(MainMenuBarTexture0.alpha==0 and MainMenuBarTextureExtender.alpha==0)
assert(#MainMenuBarArtFrame.textures==5 and MainMenuBarArtFrame.textures[1].shown)
assert(not MainActionBar.textures[1]) -- compact background is unnecessary in default layout
MainMenuBar.shown=false; MainMenuBar.hooks.OnHide()
assert(MainActionBar.textures[1].shown)
MainMenuBar.shown=true; MainMenuBar.hooks.OnShow()
assert(not MainActionBar.textures[1].shown)
assert(MainActionBar.ActionBarPageNumber==pageControl)
-- No cosmetic mutation is attempted while combat lockdown is active.
combat=true; pt.db.hideBarEndCaps=false; pt.db.modernActionBar=false
bars:Apply(); assert(bars.pending and MainMenuBarLeftEndCap.alpha==0)
combat=false; frames[1].OnEvent(nil,"PLAYER_REGEN_ENABLED")
assert(not bars.pending and MainMenuBarLeftEndCap.alpha==.75)
assert(MainMenuBarTexture0.alpha==.8 and not MainMenuBarArtFrame.textures[1].shown)
-- The old layout without MainActionBar also supports the separate options.
MainActionBar=nil; pt.db.modernActionBar=true; bars:Apply()
assert(MainMenuBarTexture0.alpha==0 and MainMenuBarLeftEndCap.alpha==0)
local dragons=bars.dragons[MainMenuBarArtFrame]
assert(dragons and dragons[1].shown and dragons[2].shown)
assert(dragons[1].size[1]==44 and dragons[2].coords[1]==1)
pt.db.hideBarEndCaps=true; bars:Apply()
assert(not dragons[1].shown and MainMenuBarLeftEndCap.alpha==0)
pt.db.modernActionBar=false; bars:Apply()
assert(not dragons[1].shown and MainMenuBarLeftEndCap.alpha==0)
pt.db.hideBarEndCaps=false; bars:Apply()
assert(not dragons[1].shown and MainMenuBarLeftEndCap.alpha==.75)
-- Recreate the compact layout and verify it gets the same pair.
MainActionBar=Widget(); MainActionBar.EndCaps=Widget()
pt.db.modernActionBar=true; bars:Apply()
assert(bars.dragons[MainActionBar.EndCaps][1].shown)
combat=true; pt.db.hideBarEndCaps=true; bars:Apply()
assert(bars.dragons[MainActionBar.EndCaps][1].shown)
combat=false; frames[1].OnEvent(nil,"PLAYER_REGEN_ENABLED")
assert(not bars.dragons[MainActionBar.EndCaps][1].shown)
pt.db.modernActionBar=false; bars:Apply(); assert(MainMenuBarTexture0.alpha==.8)
print("PASS: action bar variants, independent options, restoration and combat deferral.")
