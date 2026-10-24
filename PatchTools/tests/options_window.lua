local parentScale=.8
UIParent={GetWidth=function() return 1200 end,GetHeight=function() return 900 end,
    GetEffectiveScale=function() return parentScale end}
local cursorX,cursorY,mouse=800,200,true
function GetCursorPosition() return cursorX,cursorY end
function IsMouseButtonDown() return mouse end
local function Frame()
    local f={scripts={},scale=1,left=200,top=850}
    function f:SetScript(key,fn) self.scripts[key]=fn end
    function f:HookScript(key,fn)
        local previous=self.scripts[key]
        self.scripts[key]=function(...) if previous then previous(...) end; fn(...) end
    end
    function f:SetScale(value) self.scale=value end
    function f:GetEffectiveScale() return self.scale*parentScale end
    function f:GetLeft() return self.left/self.scale end
    function f:GetTop() return self.top/self.scale end
    function f:SetPoint(point,_,_,x,y)
        if point=="CENTER" then self.left,self.top=300,700
        elseif point=="TOPLEFT" then self.left,self.top=x*self.scale,y*self.scale end
    end
    function f:GetFrameLevel() return 1 end
    function f:ClearAllPoints() end
    function f:StopMovingOrSizing() end
    setmetatable(f,{__index=function() return function() end end})
    return f
end
function CreateFrame() return Frame() end
GameTooltip=Frame()
local closed=0
function CloseDropDownMenus() closed=closed+1 end
local PT={options=Frame(),db={optionsScale=.75}}
function PT:T(key) return key end
assert(loadfile("OptionsWindow.lua"))("PatchTools",PT)
local saved=0
PT.options:SetScript("OnHide",function() saved=saved+1 end)
PT:InstallOptionsScaling(PT.options)
assert(PT.options.scale==.75,'restore the saved window scale')
local grip=PT.optionsScaleGrip
grip.scripts.OnMouseDown(grip,"LeftButton")
assert(closed==1 and grip.scripts.OnUpdate)
cursorX=cursorX+820*parentScale*.2; cursorY=cursorY-650*parentScale*.2
grip.scripts.OnUpdate()
assert(math.abs(PT.options.scale-.95)<.000001)
assert(math.abs(PT.options.left-200)<.000001 and math.abs(PT.options.top-850)<.000001,
    'top-left position must stay fixed at non-default UI scale')
assert(PT.db.optionsScale==PT.options.scale)
grip.scripts.OnMouseUp(); assert(grip.scripts.OnUpdate==nil)
PT:SetOptionsWindowScale(100); assert(PT.db.optionsScale<1.5,'cap to screen dimensions')
PT:SetOptionsWindowScale(-100); assert(PT.db.optionsScale==.6)
for _,value in ipairs({0/0,math.huge,"bad"}) do PT:SetOptionsWindowScale(value); assert(PT.db.optionsScale==1) end
grip.scripts.OnMouseDown(grip,"LeftButton"); mouse=false; grip.scripts.OnUpdate()
assert(grip.scripts.OnUpdate==nil,'release outside the grip stops scaling')
mouse=true; grip.scripts.OnMouseDown(grip,"LeftButton")
PT.options.scripts.OnHide()
assert(saved==1 and grip.scripts.OnUpdate==nil,'keep original hide/save handler and stop scaling')
PT:SetOptionsWindowScale(.7); grip.scripts.OnMouseDown(grip,"RightButton")
assert(PT.db.optionsScale==.7,'right-click does not reset the window')
PT:ResetOptionsWindow()
assert(PT.options.scale==1 and PT.db.optionsScale==1 and PT.options.left==300)
print("PASS: settings scale persistence, proportional dragging, UI scale coordinates, screen bounds, invalid values, release/hide cleanup and reset.")
