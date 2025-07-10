--origally from https://pastebin.com/raw/Pje1QRBd

----------------------script start-------------------------------

--some functions--

function Notify(tt, tx, dur)
    dur = dur or 4
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = tt,
        Text = tx,
        Duration = dur
    })
end
function getcurrentgun(plr)
    local char = plr.Character
    if not char then return nil, nil end
    local invchar = game.ReplicatedStorage.Players:FindFirstChild(game.Players.LocalPlayer.Name).Inventory
    if not invchar then return nil, nil end

    local gun = nil
    local gunname = nil
    local guninv = nil

    for _, desc in ipairs(char:GetChildren()) do
        if desc:IsA("Model") and desc:FindFirstChild("ItemRoot") and desc:FindFirstChild("Attachments") then
            gun = desc
            gunname = desc.Name
            guninv = invchar:FindFirstChild(gunname)
            break
        end
    end

    return gunname, gun, guninv
end
function getcurrentammo(gun)
    if not gun then return nil end
    local loadedfold = gun:FindFirstChild("LoadedAmmo", true)
    if not loadedfold then return nil end

    local loadedtable = loadedfold:GetChildren()
    local lastammo = loadedtable[#loadedtable]
    if not lastammo then return nil end
    
    local ammotype = lastammo:GetAttribute("AmmoType")
    if not ammotype then return nil end
    
    return game.ReplicatedStorage.AmmoTypes:FindFirstChild(ammotype)
end
function fetchgui(url)
    local attempts = 0
    while attempts < 5 do
        attempts = attempts + 1
        local success, result = nil, nil
        success, result = pcall(function()
            local str = nil
            task.spawn(function()
                str = tostring(game:HttpGet(url))
            end)
            task.wait(1)
            return str
        end)
        if success and result ~= nil then
            return result
        end
        wait(1)
    end
    return nil
end
function safesetvalue(value, toggle)
    pcall(function()
        toggle.Value = value;
        toggle:Display();
        for _, Addon in next, toggle.Addons do
            if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
                Addon.Toggled = value
                Addon:Update()
            end
        end
    end)
end

--startup--

print("Loading start")


if _G.Ardour then
    _G.Ardour:Unload()
    _G.Ardour = nil
end

local exec = identifyexecutor()
if string.match(exec, "Synapse") == nil 
    and string.match(exec, "Macsploit") == nil 
    and string.match(exec, "Seliware") == nil 
    and string.match(exec, "Velocity") == nil 
    and string.match(exec, "AWP") == nil then

    local reqtest = pcall(function()
        require(game.ReplicatedStorage.Modules.FPS)
    end)
    local filetest = pcall(function()
        isfile("Ardour1runCheck.mp3")
    end)
    local connecttest = pcall(function()
        getconnections(game.ChildAdded)
    end)
    if reqtest == true and filetest == true and connecttest == true then else
        Notify("Ardour", "Sorry, your executor cant run this script")
        return
    end

    local libtest = pcall(function()
        local drawing1 = Drawing.new("Square")
        drawing1.Visible = false
        drawing1:Destroy()
    end)
    if libtest == false then
        Notify("Ardour", "Wait while we install drawing lib for you")
        local lib = game:HttpGet("https://raw.githubusercontent.com/Tr4nter/ProjectDeltaScript/refs/heads/main/espfix.lua")
        loadstring(lib)()
        Notify("Ardour", "Drawing lib installed!, Script is loading")
    else
        Notify("Ardour", "Loading. Using " .. exec .. " (Half supported)", 4)
    end

    Notify("WARNING", "We do not guarantee that the script will work on your injector!")
else
    Notify("Ardour", "Loading. Using " .. exec .. " (Full supported)", 4)
end

if game.Players.LocalPlayer.Character == nil or not game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
    Notify("Ardour", "It looks like the game has not loaded yet, the script is waiting for the game to load")

    while game.Players.LocalPlayer.Character == nil or not game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") do
        wait(0.2)
    end
end
wait(0.5)

print("loading variables ")

--variables--

local wcamera = workspace.CurrentCamera
local localplayer = game.Players.LocalPlayer
local runs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local tweens = game:GetService("TweenService")
local scriptloading = true
local ACBYPASS_SYNC = false
local keybindlist = false
local keylist_gui 
local keylist_items = {}
local a1table
local cfgloading = false
local characterspawned = tick()

local configname = nil
allvars = {}

allvars.aimbool = false
allvars.shootAtPredicted = false
local fakemodels = {}
allvars.aimbots = false
allvars.aimvischeck = false
allvars.aimdistcheck = false
allvars.aimbang = true
allvars.aimtrigger = false
local aimtarget = nil
local aimtargetpart = nil
local aimpretarget = nil
allvars.showfov = false
allvars.aimfovcolor = Color3.fromRGB(255,255,255)
allvars.showname = false
allvars.showhp = false
local showkdr = false
local showdist = false
local targetinfoskip = false
allvars.aimdynamicfov = false
allvars.peekblink = false
allvars.aimpart = "Head"
allvars.aimfov = 150
local aimsnapline = Drawing.new("Line") 
allvars.snaplinebool = false
allvars.snaplinethick = 1
allvars.snaplinecolor = Color3.fromRGB(255,255,255)
allvars.aimdistance = 800 -- meters
allvars.aimchance = 100
allvars.aimfakewait = false
allvars.triggerbotdelay = 100
local aimresolver = false
local modelmanip = false
local undergroundusers = {}
local aimresolvertime = tick()
local aimresolverhh = false
allvars.resolvertimeout = 2
local aimresolverpos = localplayer.Character.HumanoidRootPart.CFrame
local aimfovcircle = Drawing.new("Circle")
local aimtargetname = Drawing.new("Text")
local aimtargetshots = Drawing.new("Text")
local aimtargetvis = Drawing.new("Text")
local targetvisred = Color3.fromRGB(255, 41, 41)
local targetvisgreen = Color3.fromRGB(105, 255, 41)
local aimogfunc = require(game.ReplicatedStorage.Modules.FPS.Bullet).CreateBullet
local aimmodfunc -- will change later in script
local aimignoreparts = {}
for i,v in ipairs(workspace:GetDescendants()) do
    if v:GetAttribute("PassThrough") then
        table.insert(aimignoreparts, v)
    end
end

allvars.hitmarkbool = false
allvars.hitmarkcolor = Color3.fromRGB(255,255,255)
allvars.hitmarkfade = 2
allvars.hitsoundbool = false
allvars.hitsoundhead = "Ding"
allvars.hitsoundbody = "Blackout"
local hitsoundlib = {
    ["TF2"]       = "rbxassetid://8255306220",
    ["Gamesense"] = "rbxassetid://4817809188",
    ["Rust"]      = "rbxassetid://1255040462",
    ["Neverlose"] = "rbxassetid://8726881116",
    ["Bubble"]    = "rbxassetid://198598793",
    ["Quake"]     = "rbxassetid://1455817260",
    ["Among-Us"]  = "rbxassetid://7227567562",
    ["Ding"]      = "rbxassetid://2868331684",
    ["Minecraft"] = "rbxassetid://6361963422",
    ["Blackout"]  = "rbxassetid://3748776946",
    ["Osu!"]      = "rbxassetid://7151989073",
}
local hitsoundlibUI = {}
for i,v in hitsoundlib do
    table.insert(hitsoundlibUI, i)
end

local skyboxtable = {
    ["Standard"] = {
        SkyboxBk = "http://www.roblox.com/asset/?id=91458024",  
        SkyboxDn = "http://www.roblox.com/asset/?id=91457980",
        SkyboxFt = "http://www.roblox.com/asset/?id=91458024",
        SkyboxLf = "http://www.roblox.com/asset/?id=91458024",
        SkyboxRt = "http://www.roblox.com/asset/?id=91458024",
        SkyboxUp = "http://www.roblox.com/asset/?id=91458002"
    },
    ["Minecraft"] = {
        SkyboxBk = "rbxassetid://8735166756",
        SkyboxDn = "http://www.roblox.com/asset/?id=8735166707",
        SkyboxFt = "http://www.roblox.com/asset/?id=8735231668",
        SkyboxLf = "http://www.roblox.com/asset/?id=8735166755",
        SkyboxRt = "http://www.roblox.com/asset/?id=8735166751",
        SkyboxUp = "http://www.roblox.com/asset/?id=8735166729"
    },
    ["Spongebob"] = {
        SkyboxBk = "rbxassetid://277099484",
        SkyboxDn = "rbxassetid://277099500",
        SkyboxFt = "rbxassetid://277099554",
        SkyboxLf = "rbxassetid://277099531",
        SkyboxRt = "rbxassetid://277099589",
        SkyboxUp = "rbxassetid://277101591"
    },
    ["Deep Space"] = {
        SkyboxBk = "rbxassetid://159248188",
        SkyboxDn = "rbxassetid://159248183",
        SkyboxFt = "rbxassetid://159248187",
        SkyboxLf = "rbxassetid://159248173",
        SkyboxRt = "rbxassetid://159248192",
        SkyboxUp = "rbxassetid://159248176"
    },
    ["Clouded Sky"] = {
        SkyboxBk = "rbxassetid://252760981",
        SkyboxDn = "rbxassetid://252763035",
        SkyboxFt = "rbxassetid://252761439",
        SkyboxLf = "rbxassetid://252760980",
        SkyboxRt = "rbxassetid://252760986",
        SkyboxUp = "rbxassetid://252762652"
    },
    ["Retro"] = {
        SkyboxBk = "rbxasset://sky/null_plainsky512_bk.jpg",
        SkyboxDn = "rbxasset://sky/null_plainsky512_dn.jpg",
        SkyboxFt = "rbxasset://sky/null_plainsky512_ft.jpg",
        SkyboxLf = "rbxasset://sky/null_plainsky512_lf.jpg",
        SkyboxRt = "rbxasset://sky/null_plainsky512_rt.jpg",
        SkyboxUp = "rbxasset://sky/null_plainsky512_up.jpg"
    },
    ["City"] = {
        SkyboxBk = "rbxassetid://9134792889",
        SkyboxDn = "rbxassetid://9134791975",
        SkyboxFt = "rbxassetid://9134793457",
        SkyboxLf = "rbxassetid://9134791234",
        SkyboxRt = "rbxassetid://9134790419",
        SkyboxUp = "rbxassetid://9134791633"
    },
}

allvars.rapidfire = false
allvars.crapidfire = false
allvars.crapidfirenum = 0.001
allvars.unlockmodes = false
allvars.multitaps = 1
local instrelOGfunc = require(game.ReplicatedStorage.Modules.FPS).reload
local instrelMODfunc -- changed later
allvars.instaequip = false
allvars.instareload = false
allvars.noswaybool = false

local mforcehit = false
local mhitpart = "FaceHitBox"
local malwayspower = false

allvars.aimFRIENDLIST = {}
allvars.friendlistmode = "Blacklist"
allvars.friendlistbots = false

allvars.esptextcolor = Color3.fromRGB(255,255,255)
local esptable = {}
--[[ esptable template
    drawingobj = {
        primary = instance
        type = string --(highlight, name, hp, hotbar, distance, skelet, box)
        otype = string --(plr, bot, dead, extract, loot)
    }      
]] 
allvars.espbool = false
allvars.espname = false
allvars.esphp = false
allvars.esphpmax = Color3.fromRGB(0,255,0)
allvars.esphpmid = Color3.fromRGB(255,255,0)
allvars.esphpmin = Color3.fromRGB(255,0, 0)
allvars.espdistance = false
allvars.espdistmode = "Meters"
allvars.espbots = false
allvars.esphigh = false
allvars.espdead = false
allvars.esphotbar = false
allvars.esploot = false
allvars.espexit = false
allvars.esptextline = false
allvars.esprenderdist = 1000 -- meters
allvars.espchamsfill = 0.5
allvars.espchamsline = 0
allvars.esptextsize = 14
allvars.espboxcolor = Color3.fromRGB(255,255,255)
allvars.espfillcolor = Color3.fromRGB(255,0,0)
allvars.esplinecolor = Color3.fromRGB(255,255,255)

allvars.invcheck = false
local invchecktext = Drawing.new("Text")

allvars.tracbool = false
allvars.tracwait = 2
allvars.traccolor = Color3.fromRGB(255,255,255)
allvars.tractexture = nil
local tractextures = {
    ["None"] = nil,
    ["Lighting"] = "http://www.roblox.com/asset/?id=131326755401058",
}

allvars.crossbool = false
allvars.crosscolor = Color3.fromRGB(255,255,255)
local crosssizeog = UDim2.new(0.017, 0, 0.03, 0)
allvars.crosssizek = 2
allvars.crossrot = 0
allvars.crossimg = "rbxassetid://15574540229"
local crossgui = Instance.new("ScreenGui", localplayer.PlayerGui)
crossgui.ClipToDeviceSafeArea = false
crossgui.ResetOnSpawn = false
crossgui.ScreenInsets = 0
local crosshair = Instance.new("ImageLabel", crossgui)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshair.Size = UDim2.new(crosssizeog.X.Scale * allvars.crosssizek, 0, crosssizeog.Y.Scale * allvars.crosssizek, 0)
crosshair.Image = allvars.crossimg
crosshair.ImageColor3 = allvars.crosscolor
crosshair.BackgroundTransparency = 1
crosshair.Visible = false

allvars.camthirdp = false
local thirdpshow = false
allvars.camthirdpX = 2
allvars.camthirdpY = 2
allvars.camthirdpZ = 5
allvars.editzoom = false
local instazoom = false
local nojumptilt = false
allvars.basefov = 120
allvars.zoomfov = 5
allvars.antimaskbool = false
allvars.antiflashbool = false
local camzoomfunctionOG = require(game.ReplicatedStorage.Modules.CameraSystem).SetZoomTarget
local camzoomfunction --changed later

local viewmod_materials = {
    ["Forcefield"] = Enum.Material.ForceField,
    ["Neon"] = Enum.Material.Neon,
    ["Plastic"] = Enum.Material.SmoothPlastic
}
allvars.viewmodbool = false
allvars.viewmodhandmat = Enum.Material.Plastic
allvars.viewmodgunmat = Enum.Material.Plastic
allvars.viewmodhandcolor = Color3.fromRGB(255,255,255)
allvars.viewmodguncolor = Color3.fromRGB(255,255,255)
allvars.viewmodoffset = false
allvars.viewmodX = -2
allvars.viewmodY = -2
allvars.viewmodZ = 0

local scbool = false
local scgui = nil --later
local scselected = nil

allvars.doublejump = false
local candbjump = false
local dbjumplast = 0
local dbjumpdelay = 0.2

local invisanim = Instance.new("Animation")
invisanim.AnimationId = "rbxassetid://15609995579"
local invisnum = 2.35
local invistrack
local desynctable = {}
local desyncvis = nil
allvars.desyncbool = false
allvars.invisbool = false
allvars.desyncPos = false
allvars.desynXp = 0
allvars.desynYp = 0
allvars.desynZp = 0
allvars.desyncOr = false
allvars.desynXo = 0
allvars.desynYo = 0
allvars.desynZo = 0
local visdesync = false
local desynccolor = Color3.fromRGB(255,0,0)
local desynctrans = 0.5
local blinkbool = false
local blinktemp = false
local blinkstop = false
local blinknoclip = false
local blinktable = {}

allvars.upanglebool = false
allvars.upanglenum = 0
allvars.speedbool = false
allvars.speedboost = 1.2
allvars.nojumpcd = false
allvars.nofall = false
allvars.instafall = false
allvars.instalean = false
allvars.changerbool = false
allvars.changergrav = 95
allvars.changerspeed = 20
allvars.changerheight = 2
allvars.changerjump = 3
allvars.predict = false
local charsemifly = false
allvars.charsemiflydist = 6
allvars.charsemiflyspeed = 30
local semifly_bodyvel = nil
local semifly_pos = CFrame.new()
local semifly_posconnect = nil
local instantleanOGfunc --changed later
local instantleanMODfunc --changed later



allvars.worldleaves = false
allvars.worldgrass = false
allvars.worldcloud = false
local folcheck = workspace:FindFirstChild("SpawnerZones")
allvars.worldclock = 14
local clockbool = true
allvars.worldnomines = false
allvars.worldnoweather = false
local waterplatforms = Instance.new("Folder", workspace)
waterplatforms.Name = "ArdourWaterPlatforms"
allvars.worldjesus = false
local noswim = false
allvars.worldambient = Color3.fromRGB(255,255,255)
allvars.worldoutdoor = Color3.fromRGB(255,255,255)
allvars.worldexpo = 0
allvars.colorcorrectbool = false
allvars.colorcorrectbright = 0
allvars.colorcorrectcontrast = 0
allvars.colorcorrectsatur = 0
allvars.colorcorrecttint = Color3.fromRGB(255,255,255)

allvars.instantrespawn = false
local espmapactive = false
local handleESPMAP = function() do end end
local espmapmarkers = {}
local espmaptarget = nil
local detectedmods = {}
local mdetect = false
local city13unlock = false
allvars.detectmods = false
local joindetect = false
local leavedetect = false

local valcache = {
    ["6B45"] = 16,
    ["AS Val"] = 16,
    ["ATC Key"] = 6,
    ["Airfield Key"] = 6,
    ["Altyn"] = 16,
    ["Altyn Visor"] = 8,
    ["Maska Visor"] = 8,
    ["Attak-5 60L"] = 16,
    ["Bolts"] = 1,
    ["Crane Key"] = 6,
    ["DAGR"] = 12,
    ["Duct Tape"] = 1,
    ["Fast MT"] = 10,
    ["Flare Gun"] = 20,
    ["Fueling Station Key"] = 2,
    ["Garage Key"] = 4,
    ["Hammer"] = 1,
    ["JPC"] = 10,
    ["Lighthouse Key"] = 6,
    ["M4A1"] = 12,
    ["Nails"] = 1,
    ["Nuts"] = 1,
    ["Saiga 12"] = 8,
    ["Super Glue"] = 1,
    ["Village Key"] = 2,
    ["Wrench"] = 1,
    ["SPSh-44"] = 12,
    ["R700"] = 16,
    ["AKMN"] = 12,
    ["Mosin"] = 12,
    ["SVD"] = 12,
    ["7.62x39AP"] = 0.15,
    ["7.62x54AP"] = 0,15,
}
local terrainmats = {
    "Grass",
    "Sand",
    "Sandstone",
    "Mud",
    "Ground",
    "Rock",
    "Brick",
    "Cobblestone",
    "Concrete",
    "Glacier",
    "Asphalt",
    "Snow",
    "Basalt",
    "Salt",
    "Limestone",
    "Pavement",
    "LeafyGrass",
    "Ice",
    "Slate",
    "CrackedLava"
}
--drawing setup--

aimfovcircle.Visible = false
aimfovcircle.Radius = allvars.aimfov
aimfovcircle.Thickness = 2
aimfovcircle.Filled = false
aimfovcircle.Transparency = 1
aimfovcircle.Color = Color3.fromRGB(255, 255, 255)
aimfovcircle.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2)
aimtargetname.Text = "None"
aimtargetname.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2 + allvars.aimfov + 20) 
aimtargetname.Size = 24
aimtargetname.Font = Drawing.Fonts.Monospace
aimtargetname.Color = Color3.fromRGB(255,255,255)
aimtargetname.Visible = false
aimtargetname.Center = true
aimtargetname.Outline = true
aimtargetname.OutlineColor = Color3.new(0, 0, 0)
aimtargetshots.Text = " "
aimtargetshots.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2 + allvars.aimfov + 30) 
aimtargetshots.Size = 20
aimtargetshots.Font = Drawing.Fonts.Monospace
aimtargetshots.Color = Color3.fromRGB(255,255,255)
aimtargetshots.Visible = false
aimtargetshots.Center = true
aimtargetshots.Outline = true
aimtargetshots.OutlineColor = Color3.new(0, 0, 0)
aimtargetvis.Text = "NOT VISIBLE"
aimtargetvis.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2 + allvars.aimfov + 40) 
aimtargetvis.Size = 24
aimtargetvis.Font = Drawing.Fonts.Monospace
aimtargetvis.Color = Color3.fromRGB(255, 41, 41)
aimtargetvis.Visible = false
aimtargetvis.Center = true
aimtargetvis.Outline = true
aimtargetvis.OutlineColor = Color3.new(0, 0, 0)
invchecktext.Text = " "
invchecktext.Position = Vector2.new(100, wcamera.ViewportSize.Y / 2)
invchecktext.Size = 18
invchecktext.Font = Drawing.Fonts.Monospace
invchecktext.Color = Color3.fromRGB(255,255,255)
invchecktext.Visible = true
invchecktext.Center = false
invchecktext.Outline = true
invchecktext.OutlineColor = Color3.new(0, 0, 0)
aimsnapline.From = Vector2.new(20, 20)
aimsnapline.To = Vector2.new(50, 50)
aimsnapline.Color = Color3.fromRGB(255,255,255)
aimsnapline.Thickness = 1
aimsnapline.Visible = false



--ui load--
if _G.Ardour then return end

print('loading gui')
local loadstopped = false
local libstring, themestring, savestring
task.delay(8, function()
    if libstring == nil or themestring == nil or savestring == nil then
        loadstopped = true
        Notify("Ardour Error", "Gui load stopped (timeout), try again")
        _G.Ardour = false
    end
end)

libstring = fetchgui('https://raw.githubusercontent.com/Tr4nter/ProjectDeltaScript/refs/heads/main/Library.lua')
themestring = fetchgui('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua')
savestring = fetchgui('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua')

if libstring == nil or themestring == nil or savestring == nil then
    if loadstopped == false then 
        Notify("Ardour Error", "Gui load failed")
        _G.Ardour = false
        return
    end
end
if loadstopped then
    return
end

local Library = loadstring(libstring)()
_G.Ardour = Library
local ThemeManager = loadstring(themestring)()
local SaveManager = loadstring(savestring)()

print('gui loaded')
print('setting up gui')

local Window = Library:CreateWindow({
    Title = 'Ardour',
    Center = true,
    AutoShow = false,
    TabPadding = 2,
    MenuFadeTime = 0.1
})
local tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Other = Window:AddTab('Other'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}
local aim = tabs.Combat:AddLeftGroupbox('Aimbot')
local tarinfo = tabs.Combat:AddLeftGroupbox('Target')
local cvis = tabs.Combat:AddLeftGroupbox('Combat Visual')
local gunmods = tabs.Combat:AddRightGroupbox('Gunmods')
local uimelee = tabs.Combat:AddRightGroupbox('Melee')
local friendman = tabs.Combat:AddRightGroupbox('Friend Manager')
local wh = tabs.Visuals:AddLeftGroupbox('ESP')
local cross = tabs.Visuals:AddRightGroupbox('Crosshair')
local tracers = tabs.Visuals:AddRightGroupbox('Tracers')
local camer = tabs.Visuals:AddLeftGroupbox('Camera')
local viewmod = tabs.Visuals:AddRightGroupbox('Viewmodel')
local speedh = tabs.Other:AddLeftGroupbox('Character')
local worldh = tabs.Other:AddRightGroupbox('World')
local vmisc = tabs.Other:AddRightGroupbox('Misc')

aim:AddToggle('Silent Aim', {
    Text = 'Silent aim',
    Default = false,
    Tooltip = 'Enables silent aim',
    Callback = function(v)
        allvars.aimbool = v
        if v == true then
            require(game.ReplicatedStorage.Modules.FPS.Bullet).CreateBullet = aimmodfunc
        else
            require(game.ReplicatedStorage.Modules.FPS.Bullet).CreateBullet = aimogfunc
        end
    end
}):AddKeyPicker('Silent Aim', {
    Default = 'Y',
    SyncToggleState = true,
    Mode = 'Toggle', --Always, Toggle, Hold
    Text = 'Silent aim',
    NoUI = false, 
})
aim:AddToggle('TriggerBot', {
    Text = 'Trigger Bot',
    Default = false,
    Tooltip = 'Enables trigger bot',
    Callback = function(v)
        allvars.aimtrigger = v
    end
}):AddKeyPicker('TriggerBot', {
    Default = 'O',
    SyncToggleState = true,
    Mode = 'Toggle', --Always, Toggle, Hold
    Text = 'Trigger Bot',
    NoUI = false, 
})
aim:AddToggle('PredictMovement', {
    Text = 'Triggerbot Predict Movement',
    Default = false,
    Tooltip = 'Predict enemy movement and shoot at the exact same time the enemy is about to peek/you peeking into them',
    Callback = function(v)
        allvars.predict = v
    end
})
aim:AddToggle("Shoot At Predicted", {
    Text = 'Shoot At Predicted',
    Default = false,
    Tooltip = 'Shoots at predicted position of target instead of current position taking target velocity into account, recommended to be used with "Predict Movement" option',
    Callback = function(v)
        allvars.shootAtPredicted = v
        
    end
})
aim:AddSlider('TriggerBotDelay', {
    Text = 'Shoot Delay(ms)',
    Default = allvars.triggerbotdelay,
    Min = 0,
    Max = 10000,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.triggerbotdelay = c
    end
})

aim:AddToggle('Target AI', {
    Text = 'Target AI',
    Default = false,
    Tooltip = 'Also targets bots',
    Callback = function(v)
        allvars.aimbots = v
    end
})
aim:AddToggle('Visibility check', {
    Text = 'Visibility check',
    Default = false,
    Tooltip = 'Is target visible',
    Callback = function(v)
        allvars.aimvischeck = v
    end
})
aim:AddToggle('Ammo distance check', {
    Text = 'Ammo distance check',
    Default = false,
    Tooltip = 'Limits check distance to range of ammo',
    Callback = function(v)
        allvars.aimdistcheck = v
    end
})
aim:AddToggle('Slow bullet', {
    Text = 'Slow bullet',
    Default = false,
    Tooltip = 'Delays bullet hit [only instahit]',
    Callback = function(v)
        allvars.aimfakewait = v
    end
})
aim:AddDropdown('AimPartDropdown', {
    Values = {'Head', 'HeadTop', "Face", 'Torso', 'Scripted', "Random"},
    Default = 1,
    Multi = false,
    Text = 'Aim Part',
    Tooltip = 'Silent aim will hit choosen part',
    Callback = function(v)
        allvars.aimpart = v
    end
})
aim:AddDivider()
aim:AddSlider('HitChance', {
    Text = 'Hit Chance',
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.aimchance = c
    end
})
aim:AddSlider('AimDistance', {
    Text = 'Aim Distance [Meters]',
    Default = 800,
    Min = 0,
    Max = 1000,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.aimdistance = c
    end
})
aim:AddDivider()
aim:AddToggle('ShowFov', {
    Text = 'Show FOV',
    Default = false,
    Tooltip = 'Changes visibility of FOV Circle',
    Callback = function(v)
        allvars.showfov = v
        aimfovcircle.Visible = v
    end
})
aim:AddToggle('DynFov', {
    Text = 'Dynamic FOV',
    Default = false,
    Tooltip = 'Aim FOV depends on Cam FOV',
    Callback = function(v)
        allvars.aimdynamicfov = v
    end
})
aim:AddSlider('AimFov', {
    Text = 'Aim FOV',
    Default = 150,
    Min = 0,
    Max = 300,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.aimfov = c
    end
})
aim:AddLabel('FOV Circle Color'):AddColorPicker('FovColorPick', {
    Default = Color3.new(1, 1, 1),
    Title = 'FOV Circle',
    Callback = function(a)
        allvars.aimfovcolor = a
        aimfovcircle.Color = allvars.aimfovcolor
    end
})



cvis:AddToggle('Snapline', {
    Text = 'Snapline',
    Default = false,
    Tooltip = 'Enables snapline',
    Callback = function(v)
        allvars.snaplinebool = v
    end
})
cvis:AddSlider('SnaplineThick', {
    Text = 'Snapline Thickness',
    Default = 1,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.snaplinethick = c
        aimsnapline.Thickness = c
    end
})
cvis:AddLabel('Snapline Color'):AddColorPicker('SnaplineColorPick', {
    Default = Color3.new(1, 1, 1),
    Title = 'Snapline Color',
    Callback = function(a)
        allvars.snaplinecolor = a
        aimsnapline.Color = allvars.snaplinecolor
    end
})
cvis:AddDivider()
cvis:AddToggle('Hitsound', {
    Text = 'Hitsounds',
    Default = false,
    Tooltip = 'Enables hitsounds',
    Callback = function(v)
        allvars.hitsoundbool = v
    end
})
cvis:AddDropdown('HitsoundHead', {
    Values = hitsoundlibUI,
    Default = "Ding",
    Multi = false,
    Text = 'Head Sound',
    Tooltip = 'Plays choosen sound on head hit',
    Callback = function(a)
        if hitsoundlib == nil or a == nil then return end
        allvars.hitsoundhead = a

        if cfgloading then return end

        local preview = Instance.new("Sound", workspace)
        preview.SoundId = hitsoundlib[a]
        preview:Play()
        task.wait(1)
        preview:Destroy()
    end
})
cvis:AddDropdown('HitsoundBody', {
    Values = hitsoundlibUI,
    Default = "Blackout",
    Multi = false,
    Text = 'Body Sound',
    Tooltip = 'Plays choosen sound on body hit',
    Callback = function(a)
        if hitsoundlib == nil or a == nil then return end
        allvars.hitsoundbody = a

        if cfgloading then return end

        local preview = Instance.new("Sound", workspace)
        preview.SoundId = hitsoundlib[a]
        preview:Play()
        task.wait(1)
        preview:Destroy()
    end
})
cvis:AddDivider()
cvis:AddToggle('Hitmarker', {
    Text = 'Hitmarker',
    Default = false,
    Tooltip = 'Enables hitmarkers',
    Callback = function(v)
        allvars.hitmarkbool = v
    end
})
cvis:AddSlider('Hitmarker fade', {
    Text = 'Hitmarker Fade Time',
    Default = 2,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.hitmarkfade = c
    end
})
cvis:AddLabel('Hitmarker color'):AddColorPicker('HitmarkColorPick', {
    Default = Color3.new(1, 1, 1),
    Title = 'Hitmarker Color',
    Callback = function(a)
        allvars.hitmarkcolor = a
    end
})







gunmods:AddToggle('Rapid Fire', {
    Text = 'Rapid Fire',
    Default = false,
    Tooltip = 'Enables rapid fire (reequip gun if holding)',
    Callback = function(v)
        allvars.rapidfire = v
        if v == false then
            local inv = game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Inventory
            for i,v in pairs(inv:GetChildren()) do
                local sett = require(v.SettingsModule)
                local toset = 0.05
                toset = 60 / v.ItemProperties.Tool:GetAttribute("FireRate")
                sett.FireRate = toset
            end
        end
    end
})
gunmods:AddToggle('Custom Rapidfire', {
    Text = 'Custom rapidfire',
    Default = false,
    Tooltip = 'Enables custom rapidfire',
    Callback = function(v)
        allvars.crapidfire = v
    end
})
gunmods:AddInput('CustomRapidNum', {
    Default = '0.01',
    Numeric = true,
    Finished = false,
    Text = 'Custom RapidFire value',
    Tooltip = 'Then custom rapidfire on, changes firerate to this value',
    Placeholder = 'Put value',
    Callback = function(a)
        local num = tonumber(a)
        if num ~= nil then
            allvars.crapidfirenum = num
            Library:Notify("Set custom allvars.rapidfire delay", 2.5)
        end
    end
})
gunmods:AddToggle('Unlock Firemodes', {
    Text = 'Unlock firemodes',
    Default = false,
    Tooltip = 'Unlocks firemodes (reequip gun if holding)',
    Callback = function(v)
        allvars.unlockmodes = v
    end
})
gunmods:AddToggle('Instant Reload', {
    Text = 'Instant Reload',
    Default = false,
    Tooltip = 'Enables instant reload',
    Callback = function(v)
        allvars.instareload = v
        if v then 
            require(game.ReplicatedStorage.Modules.FPS).reload = instrelMODfunc
        else
            require(game.ReplicatedStorage.Modules.FPS).reload = instrelOGfunc
        end
    end
})
gunmods:AddToggle('Instant Equip', {
    Text = 'Instant Equip',
    Default = false,
    Tooltip = 'Enables instant equip',
    Callback = function(v)
        allvars.instaequip = v
    end
})
gunmods:AddToggle('No Sway', {
    Text = 'No sway',
    Default = false,
    Tooltip = 'Disables weapon sway',
    Callback = function(v)
        allvars.noswaybool = v
    end
})
gunmods:AddSlider('Multitaps', {
    Text = 'Multitaps',
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Compact = false,
    Callback = function(c)
        allvars.multitaps = c
    end
})



tarinfo:AddToggle('ShowName', {
    Text = 'Show Name',
    Default = false,
    Tooltip = 'Shows target name',
    Callback = function(v)
        allvars.showname = v
        aimtargetname.Visible = v
    end
})
tarinfo:AddToggle('ShowHP', {
    Text = 'Show HP',
    Default = false,
    Tooltip = 'Shows target HP',
    Callback = function(v)
        allvars.showhp = v
        aimtargetshots.Visible = v
    end
})
tarinfo:AddToggle('ShowKDR', {
    Text = 'Show KDR',
    Default = false,
    Tooltip = 'Shows target KDR',
    Callback = function(v)
        showkdr = v
    end
})
tarinfo:AddToggle('ShowDist', {
    Text = 'Show Distance',
    Default = false,
    Tooltip = 'Shows target distance',
    Callback = function(v)
        showdist = v
    end
})
tarinfo:AddToggle('SkipVisCheck', {
    Text = 'Skip Wall Check',
    Default = false,
    Tooltip = 'If target is not visible info will still show',
    Callback = function(v)
        targetinfoskip = v
        aimtargetvis.Visible = v
    end
})
tarinfo:AddToggle('InventoryChecker', {
    Text = 'Inventory Checker',
    Default = false,
    Tooltip = 'Enables inventory checker',
    Callback = function(v)
        allvars.invcheck = v
    end
})
tarinfo:AddLabel('Text Color'):AddColorPicker('InfoColor', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'Target info Color',
    Callback = function(a)
        aimtargetname.Color = a
        aimtargetshots.Color = a
    end
})




uimelee:AddToggle('Force Hit', {
    Text = 'Force hit',
    Default = false,
    Tooltip = 'Forces melee hit to choosen',
    Callback = function(v)
        mforcehit = v
    end
})
uimelee:AddToggle('Always Power Attack', {
    Text = 'Always power attack',
    Default = false,
    Tooltip = 'Always sets attack type to power',
    Callback = function(v)
        malwayspower = v
    end
})
uimelee:AddDropdown('Force Hit Target', {
    Values = {'FaceHitBox', 'HeadTopHitBox', 'Head', 'UpperTorso'},
    Default = 'FaceHitBox',
    Multi = false,
    Text = 'Force hit target',
    Tooltip = 'Selects target part for force hit',
    Callback = function(a)
        mhitpart = a
    end
})
uimelee:AddToggle('Kill Aura', {
    Text = 'Kill aura [later, not working]',
    Default = false,
    Tooltip = 'Enables kill aura (currently not working)',
    Callback = function(v)
    end
})
uimelee:AddToggle('Kill Aura Wallcheck', {
    Text = 'Kill aura wallcheck',
    Default = false,
    Tooltip = 'Enables wallcheck for kill aura',
    Callback = function(v)
    end
})
uimelee:AddSlider('Kill Aura Distance', {
    Text = 'Kill aura distance',
    Default = 3,
    Min = 1,
    Max = 6,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
    end
})



friendman:AddInput('FriendPlrName', {
    Default = '',
    Numeric = false,
    Finished = false,
    Text = 'Add player name',
    Tooltip = 'Add player name to friend list',
    Placeholder = 'Write name',
    Callback = function(a)
        if a == nil then return end

        local name = string.lower(a)
        local plrname = nil
        local matches = {}
        for _, plr in pairs(game.Players:GetPlayers()) do
            if string.find(string.lower(plr.Name), name, 1, true) then
                table.insert(matches, plr)
            end
        end
        if #matches == 1 then
            plrname = matches[1].Name
        end
        
        if plrname and game.Players:FindFirstChild(plrname) then 
            if table.find(allvars.aimFRIENDLIST, plrname) ~= nil then return end
            table.insert(allvars.aimFRIENDLIST, plrname)
            Library:Notify("Added "..plrname.." to friendlist", 3 )
        end
    end
})
friendman:AddInput('FriendBotName', {
    Default = '',
    Numeric = false,
    Finished = false,
    Text = 'Add bot name',
    Tooltip = 'Add bot name to friend list',
    Placeholder = 'Write name',
    Callback = function(plrname)
        if plrname == nil then return end

        if workspace.AiZones:FindFirstChild(plrname, true) then 
            if table.find(allvars.aimFRIENDLIST, plrname) ~= nil then return end
            table.insert(allvars.aimFRIENDLIST, plrname)
            Library:Notify("Added "..plrname.." to friendlist", 3 )
        end
    end
})
friendman:AddInput('FriendRemoveName', {
    Default = '',
    Numeric = false,
    Finished = false,
    Text = 'Remove name',
    Tooltip = 'Removes name from friendlist',
    Placeholder = 'Write name',
    Callback = function(plrname)
        if plrname == nil then return end

        local iter = table.find(allvars.aimFRIENDLIST, plrname)
        if iter ~= nil then 
            table.remove(allvars.aimFRIENDLIST, iter)
            Library:Notify("Removed "..plrname.." from friendlist", 3 )
        end
    end
})
friendman:AddToggle('Include Bots', {
    Text = 'Include bots',
    Default = false,
    Tooltip = 'Includes bots in friendlist',
    Callback = function(v)
        allvars.friendlistbots = v
    end
})
friendman:AddDropdown('Friendlist Mode', {
    Values = {'Blacklist', 'Whitelist'},
    Default = 1,
    Multi = false,
    Text = 'Friendlist mode',
    Tooltip = 'Selects friendlist mode',
    Callback = function(a)
        allvars.friendlistmode = a
    end
})
friendman:AddButton({
    Text = 'Print friendlist to console',
    DoubleClick = false,
    Tooltip = 'Prints current friendlist to console',
    Func = function()
        if #allvars.aimFRIENDLIST == 0 then 
            print("No one in friendlist")
            return
        end
        print("Ardour friendlist:")
        for i,v in allvars.aimFRIENDLIST do
            print("["..i.."] "..v)
        end
        print("Ardour friendlist end")
        Library:Notify("Check console", 2)
    end,
})
friendman:AddButton({
    Text = 'Clear friendlist',
    DoubleClick = false,
    Tooltip = 'Clears whole friendlist',
    Func = function()
        table.clear(allvars.aimFRIENDLIST)
        Library:Notify("Friendlist cleared", 2)
    end,
})



wh:AddToggle('ESP', {
    Text = 'ESP',
    Default = false,
    Tooltip = 'Enables ESP',
    Callback = function(v)
        allvars.espbool = v
    end
})
wh:AddToggle('Name', {
    Text = 'Name',
    Default = false,
    Tooltip = 'Shows names in ESP',
    Callback = function(v)
        allvars.espname = v
    end
})
wh:AddToggle('HP', {
    Text = 'HP',
    Default = false,
    Tooltip = 'Shows HP in ESP',
    Callback = function(v)
        allvars.esphp = v
    end
})
wh:AddToggle('Distance', {
    Text = 'Distance',
    Default = false,
    Tooltip = 'Shows distance in ESP',
    Callback = function(v)
        allvars.espdistance = v
    end
})
wh:AddToggle('Chams', {
    Text = 'Chams',
    Default = false,
    Tooltip = 'Enables chams in ESP',
    Callback = function(v)
        allvars.esphigh = v
    end
})
wh:AddToggle('Active Gun', {
    Text = 'Active Gun',
    Default = false,
    Tooltip = 'Shows active gun in ESP',
    Callback = function(v)
        allvars.esphotbar = v
    end
})
wh:AddToggle('Dead', {
    Text = 'Dead',
    Default = false,
    Tooltip = 'Shows dead bodies in ESP',
    Callback = function(v)
        allvars.espdead = v
    end
})
wh:AddToggle('Bots', {
    Text = 'Bots',
    Default = false,
    Tooltip = 'Shows bots in ESP',
    Callback = function(v)
        allvars.espbots = v
    end
})
wh:AddToggle('Loot', {
    Text = 'Loot',
    Default = false,
    Tooltip = 'Shows loot in ESP',
    Callback = function(v)
        allvars.esploot = v
    end
})
wh:AddToggle('Extract', {
    Text = 'Extract',
    Default = false,
    Tooltip = 'Shows extract points in ESP',
    Callback = function(v)
        allvars.espexit = v
    end
})
wh:AddDropdown('Distance Type', {
    Values = {'Meters', 'Studs'},
    Default = 1,
    Multi = false,
    Text = 'Distance type',
    Tooltip = 'Selects distance measurement type',
    Callback = function(a)
        allvars.espdistmode = a
    end
})
wh:AddSlider('Render Distance', {
    Text = 'Render Distance (Meters)',
    Default = 1000,
    Min = 50,
    Max = 1200,
    Rounding = 0,
    Compact = false,
    Callback = function(c)
        allvars.esprenderdist = c
    end
})
wh:AddSlider('Text Size', {
    Text = 'Text Size',
    Default = 14,
    Min = 1,
    Max = 35,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.esptextsize = c
    end
})
wh:AddToggle('Text Outline', {
    Text = 'Text outline',
    Default = false,
    Tooltip = 'Enables text outline in ESP',
    Callback = function(v)
        allvars.esptextline = v
    end
})
wh:AddSlider('Chams Outline Transparency', {
    Text = 'Chams Outline Transparency',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(c)
        allvars.espchamsline = c
    end
})
wh:AddSlider('Chams Fill Transparency', {
    Text = 'Chams Fill Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(c)
        allvars.espchamsfill = c
    end
})
wh:AddLabel('HP Max Color'):AddColorPicker('HP Max Color', {
    Default = Color3.fromRGB(0,255,0),
    Title = 'HP Max Color',
    Callback = function(a)
        allvars.esphpmax = a
    end
})
wh:AddLabel('HP Mid Color'):AddColorPicker('HP Mid Color', {
    Default = Color3.fromRGB(255,255,0),
    Title = 'HP Mid Color',
    Callback = function(a)
        allvars.esphpmid = a
    end
})
wh:AddLabel('HP Min Color'):AddColorPicker('HP Min Color', {
    Default = Color3.fromRGB(255,0,0),
    Title = 'HP Min Color',
    Callback = function(a)
        allvars.esphpmin = a
    end
})
wh:AddLabel('Text Color'):AddColorPicker('Text Color', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'Text Color',
    Callback = function(a)
        allvars.esptextcolor = a
    end
})
wh:AddLabel('Chams Outline Color'):AddColorPicker('Chams Outline Color', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'Chams Outline Color',
    Callback = function(a)
        allvars.esplinecolor = a
    end
})
wh:AddLabel('Chams Fill Color'):AddColorPicker('Chams Fill Color', {
    Default = Color3.fromRGB(255,0,0),
    Title = 'Chams Fill Color',
    Callback = function(a)
        allvars.espfillcolor = a
    end
})



cross:AddToggle('Crosshair', {
    Text = 'Crosshair',
    Default = false,
    Tooltip = 'Enables crosshair',
    Callback = function(v)
        allvars.crossbool = v
    end
})
cross:AddInput('CrossFile', {
    Default = '',
    Numeric = false,
    Finished = false,
    Text = 'File Name',
    Tooltip = 'Example: ArdourCross.png (from workspace folder)',
    Placeholder = 'Write name',
    Callback = function(a)
        if isfile(a) then
            if getcustomasset(a) ~= nil then
                allvars.crossimg = getcustomasset(a)
            else
                Library:Notify("File is not a image", 3)
                return
            end
        else
            Library:Notify("Cant find the image", 2)
            return
        end
    end
})
cross:AddInput('CrossId', {
    Default = "15574540229",
    Numeric = true,
    Finished = false,
    Text = 'Image id',
    Tooltip = 'Just roblox decal id',
    Placeholder = 'Put Id',
    Callback = function(a)
        allvars.crossimg = "rbxassetid://"..a
    end
})
cross:AddSlider('Size', {
    Text = 'Size',
    Default = 1,
    Min = 0.5,
    Max = 30,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.crosssizek = c
    end
})
cross:AddSlider('Rotation Speed', {
    Text = 'Rotation Speed',
    Default = 2,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.crossrot = c
    end
})
cross:AddLabel('Crosshair Color'):AddColorPicker('Crosshair Color', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'Crosshair Color',
    Callback = function(a)
        allvars.crosscolor = a
    end
})



tracers:AddToggle('Tracers Enabled', {
    Text = 'Tracers Enabled',
    Default = false,
    Tooltip = 'Enables tracers',
    Callback = function(v)
        allvars.tracbool = v
    end
})
tracers:AddSlider('Remove Time', {
    Text = 'Remove time',
    Default = 2,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.tracwait = c
    end
})
tracers:AddLabel('Tracers Color'):AddColorPicker('Tracers Color', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'Tracers Color',
    Callback = function(a)
        allvars.traccolor = a
    end
})
tracers:AddDropdown('Texture', {
    Values = {'None', 'Lighting'},
    Default = 1,
    Multi = false,
    Text = 'Texture',
    Tooltip = 'Selects tracer texture',
    Callback = function(a)
        allvars.tractexture = tractextures[a]
    end
})



camer:AddToggle('ThirdPerson', {
    Text = 'Third Person',
    Default = false,
    Tooltip = 'Enables third person',
    Callback = function(v)
        allvars.camthirdp = v
        if v and localplayer.Character then
            localplayer.Character.Humanoid.CameraOffset = Vector3.new(allvars.camthirdpX, allvars.camthirdpY, allvars.camthirdpZ)
            localplayer.CameraMaxZoomDistance = 5
            localplayer.CameraMinZoomDistance = 5
        else
            localplayer.Character.Humanoid.CameraOffset = Vector3.new(0,0,0)
            localplayer.CameraMaxZoomDistance = 0.5
            localplayer.CameraMinZoomDistance = 0.5
        end
    end
}):AddKeyPicker('ThirdPerson', {
    Default = 'KeypadSix',
    SyncToggleState = true,
    Mode = 'Toggle', --Always, Toggle, Hold
    Text = 'Third Person',
    NoUI = false, 
})
camer:AddToggle('ThirdPShow', {
    Text = 'Show character',
    Default = false,
    Tooltip = 'Shows character while third person',
    Callback = function(v)
        thirdpshow = v
    end
})
camer:AddSlider('Thirdp Offset X', {
    Text = 'Thirdp Offset X',
    Default = 2,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.camthirdpX = c
        if allvars.camthirdp and localplayer.Character then
            localplayer.Character.Humanoid.CameraOffset = Vector3.new(allvars.camthirdpX, allvars.camthirdpY, allvars.camthirdpZ)
        end
    end
})
camer:AddSlider('Thirdp Offset Y', {
    Text = 'Thirdp Offset Y',
    Default = 2,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.camthirdpY = c
        if allvars.camthirdp and localplayer.Character then
            localplayer.Character.Humanoid.CameraOffset = Vector3.new(allvars.camthirdpX, allvars.camthirdpY, allvars.camthirdpZ)
        end
    end
})
camer:AddSlider('Thirdp Offset Z', {
    Text = 'Thirdp Offset Z',
    Default = 2,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.camthirdpZ = c
        if allvars.camthirdp and localplayer.Character then
            localplayer.Character.Humanoid.CameraOffset = Vector3.new(allvars.camthirdpX, allvars.camthirdpY, allvars.camthirdpZ)
        end
    end
})
camer:AddDivider()
camer:AddToggle('Anti Mask', {
    Text = 'Anti mask',
    Default = false,
    Tooltip = 'Disables mask effects',
    Callback = function(v)
        allvars.antimaskbool = v
        if v == true then
            game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.HelmetMask.TitanShield.Size = UDim2.new(0,0,1,0)
            game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Mask.GP5.Size = UDim2.new(0,0,1,0)
            for i,v in pairs(game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Visor:GetChildren()) do
                v.Size = UDim2.new(0,0,1,0)
            end
        else
            game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.HelmetMask.TitanShield.Size = UDim2.new(1,0,1,0)
            game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Mask.GP5.Size = UDim2.new(1,0,1,0)
            for i,v in pairs(game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Visor:GetChildren()) do
                v.Size = UDim2.new(1,0,1,0)
            end
        end
    end
})
camer:AddToggle('Anti Flash', {
    Text = 'Anti flash',
    Default = false,
    Tooltip = 'Disables flash effects',
    Callback = function(v)
        allvars.antiflashbool = v
        if v == true then
            game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Flashbang.Size = UDim2.new(0,0,1,0)
        else
            game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Flashbang.Size = UDim2.new(1,0,1,0)
        end
    end
})
camer:AddToggle('Nojumptilt', {
    Text = 'No jump tilt',
    Default = false,
    Tooltip = 'Removes jump tilt',
    Callback = function(v)
        nojumptilt = v
    end
})
camer:AddDivider()
camer:AddToggle('Modify Zoom', {
    Text = 'Modify Zoom',
    Default = false,
    Tooltip = 'Enables custom zoom modification',
    Callback = function(v)
        allvars.editzoom = v
    
        if v == true then
            require(game.ReplicatedStorage.Modules.CameraSystem).SetZoomTarget = camzoomfunction
        else
            require(game.ReplicatedStorage.Modules.CameraSystem).SetZoomTarget = camzoomfunctionOG
        end
    end
})
camer:AddToggle('Instazoom', {
    Text = 'Instant Zoom',
    Default = false,
    Tooltip = 'Removes zoom animation',
    Callback = function(v)
        instazoom = v
    end
})
camer:AddSlider('Base FOV', {
    Text = 'Base FOV',
    Default = 100,
    Min = 10,
    Max = 120,
    Rounding = 0,
    Compact = false,
    Callback = function(c)
        allvars.basefov = c
    end
})
camer:AddSlider('Zoom FOV', {
    Text = 'Zoom FOV',
    Default = 15,
    Min = 0,
    Max = 50,
    Rounding = 0,
    Compact = false,
    Callback = function(c)
        allvars.zoomfov = c
    end
})



viewmod:AddToggle('SkinChanger Menu', {
    Text = 'SkinChanger menu',
    Default = false,
    Tooltip = 'Shows SkinChanger',
    Keybind = Enum.KeyCode.KeypadEight,
    Callback = function(v)
        scbool = v
        scgui.Visible = v
    end
})
viewmod:AddDivider()
viewmod:AddToggle('Texture Changer', {
    Text = 'Texture changer',
    Default = false,
    Tooltip = 'Enables texture changer',
    Callback = function(v)
        allvars.viewmodbool = v
    end
})
viewmod:AddDropdown('Hand Material', {
    Values = {'Neon', 'Forcefield', 'Plastic'},
    Default = 2,
    Multi = false,
    Text = 'Hand Material',
    Tooltip = 'Selects hand material',
    Callback = function(a)
        if viewmod_materials[a] then
            allvars.viewmodhandmat = viewmod_materials[a]
        else
            warn('no material in mat table : ' .. a)
        end
    end
})
viewmod:AddDropdown('Gun Material', {
    Values = {'Neon', 'Forcefield', 'Plastic'},
    Default = 2,
    Multi = false,
    Text = 'Gun Material',
    Tooltip = 'Selects gun material',
    Callback = function(a)
        if viewmod_materials[a] then
            allvars.viewmodgunmat = viewmod_materials[a]
        else
            warn('no material in mat table : ' .. a)
        end
    end
})
viewmod:AddLabel('Hand Color'):AddColorPicker('Hand Color', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'Hand Color',
    Callback = function(a)
        allvars.viewmodhandcolor = a
    end
})
viewmod:AddLabel('Gun Color'):AddColorPicker('Gun Color', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'Gun Color',
    Callback = function(a)
        allvars.viewmodguncolor = a
    end
})
viewmod:AddDivider()
viewmod:AddToggle('Offset Changer', {
    Text = 'Offset changer',
    Default = false,
    Tooltip = 'Enables offset changer',
    Callback = function(v)
        allvars.viewmodoffset = v
    end
})
viewmod:AddSlider('Offset X', {
    Text = 'Offset X',
    Default = 2,
    Min = -5,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.viewmodX = c
    end
})
viewmod:AddSlider('Offset Y', {
    Text = 'Offset Y',
    Default = 2,
    Min = -5,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.viewmodY = c
    end
})
viewmod:AddSlider('Offset Z', {
    Text = 'Offset Z',
    Default = 2,
    Min = -5,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.viewmodZ = c
    end
})



speedh:AddToggle('Desync', {
    Text = 'Desync',
    Default = false,
    Tooltip = 'Enables desync',
    Callback = function(v)
        allvars.desyncbool = v

        if v then
            desyncvis = Instance.new("Part", workspace)
            desyncvis.Name = "DesyncVisual"
            desyncvis.Anchored = true
            desyncvis.CanQuery = false
            desyncvis.CanCollide = false
            desyncvis.Size = Vector3.new(4,5,1)
            desyncvis.Color = desynccolor
            desyncvis.Material = Enum.Material.Neon
            desyncvis.Transparency = visdesync == true and 1 or desynctrans
            desyncvis.TopSurface = Enum.SurfaceType.Hinge
    
            while allvars.desyncbool do
                task.wait(0.01)
            end
    
            localplayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    
            desyncvis:Destroy()
            desyncvis = nil
        end
    end
}):AddKeyPicker('DesyncToggle', {
    Default = 'KeypadThree',
    SyncToggleState = true,
    Mode = 'Toggle', --Always, Toggle, Hold
    Text = 'Desync',
    NoUI = false, 
})
speedh:AddLabel('desync:to fix cam use third person')

speedh:AddToggle('Edit Position', {
    Text = 'Edit Position',
    Default = false,
    Tooltip = 'Enables position offset',
    Callback = function(v)
        allvars.desyncPos = v
    end
})
speedh:AddSlider('Position X', {
    Text = 'Position X',
    Default = 0,
    Min = -3,
    Max = 3,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.desynXp = c
    end
})
speedh:AddSlider('Position Y', {
    Text = 'Position Y',
    Default = 0,
    Min = -2.5,
    Max = 2.5,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.desynYp = c
    end
})
speedh:AddSlider('Position Z', {
    Text = 'Position Z',
    Default = 0,
    Min = -3,
    Max = 3,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.desynZp = c
    end
})
speedh:AddToggle('Edit Orientation', {
    Text = 'Edit Orientation',
    Default = false,
    Tooltip = 'Enables orientation editing for desync',
    Callback = function(v)
        allvars.desyncOr = v
    end
})
speedh:AddSlider('Orientation X', {
    Text = 'Orientation X',
    Default = 0,
    Min = -180,
    Max = 180,
    Rounding = 0,
    Compact = false,
    Callback = function(c)
        allvars.desynXo = c
    end
})
speedh:AddSlider('Orientation Y', {
    Text = 'Orientation Y',
    Default = 0,
    Min = -180,
    Max = 180,
    Rounding = 0,
    Compact = false,
    Callback = function(c)
        allvars.desynYo = c
    end
})
speedh:AddSlider('Orientation Z', {
    Text = 'Orientation Z',
    Default = 0,
    Min = -180,
    Max = 180,
    Rounding = 0,
    Compact = false,
    Callback = function(c)
        allvars.desynZo = c
    end
})
speedh:AddToggle('VisualizeDesync', {
    Text = 'Visualize',
    Default = false,
    Tooltip = 'Enables desync visual',
    Callback = function(v)
        visdesync = v
    end
})
speedh:AddSlider('DesyncTransparency', {
    Text = 'Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(c)
        desynctrans = c
    end
})
speedh:AddLabel('Color'):AddColorPicker('DesyncColor', {
    Default = Color3.fromRGB(255,0,0),
    Title = 'Desync Visual Color',
    Callback = function(a)
        desynccolor = a
    end
})
local _recordedBlinkPos = nil 
speedh:AddDivider()
speedh:AddToggle('Peek Blink' , {
    Text = 'Peek Blink',
    Default = false,
    Tooltip = 'Enables peek blink',
    Callback = function(v)
        allvars.peekblink = v

        if v then
          local beam = Instance.new("Beam")
            beam.Name = "LineBeam"
            beam.Parent = game.Workspace
            local startpart = Instance.new("Part")
            startpart.CanCollide = false
            startpart.CanQuery = false
            startpart.Transparency = 0
            startpart.Material = Enum.Material.ForceField
            startpart.Color = Color3.fromRGB(255,255,255)
            startpart.Size = localplayer.Character.HumanoidRootPart.Size
            startpart.CFrame = localplayer.Character.HumanoidRootPart.CFrame
            startpart.Parent = workspace
            startpart.Anchored = true
            local endpart = localplayer.Character.HumanoidRootPart
            beam.Attachment0 = Instance.new("Attachment", startpart)
            beam.Attachment1 = Instance.new("Attachment", endpart)
            beam.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))
            beam.Width0 = 0.1
            beam.Width1 = 0.1
            beam.FaceCamera = true
            beam.Transparency = NumberSequence.new(0)
            beam.LightEmission = 1
            local blinkhigh = Instance.new("Highlight", startpart)
            blinkhigh.Name = "ardour highlight solter dont delete PLS"
            blinkhigh.FillColor = Color3.fromRGB(255,255,255)
            blinkhigh.OutlineColor = blinkhigh.FillColor
            blinkhigh.FillTransparency = 0.5
            blinkhigh.OutlineTransparency = 1
            blinkhigh.Adornee = startpart
            blinkhigh.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            _recordedBlinkPos = localplayer.Character.HumanoidRootPart.CFrame
            while allvars.peekblink do
                task.wait()
                local posi = game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Status.UAC:GetAttribute("LastVerifiedPos")
                print(posi)
                startpart.CFrame = CFrame.new(posi, posi + localplayer.Character.HumanoidRootPart.CFrame.LookVector)
            end
                
            startpart:Destroy()
            beam:Destroy()
        end
    end
}):AddKeyPicker('Blink', {
    Default = 'U',
    SyncToggleState = true,
    Mode = 'Toggle', --Always, Toggle, Hold
    Text = 'Blink',
    NoUI = false, 
   
})

speedh:AddDivider()
speedh:AddToggle('Edit Upangle', {
    Text = 'Edit upangle',
    Default = false,
    Tooltip = 'Enables upangle editing',
    Callback = function(v)
        allvars.upanglebool = v
    end
})
speedh:AddSlider('Upangle Number', {
    Text = 'Upangle number',
    Default = 0,
    Min = -0.75,
    Max = 0.75,
    Rounding = 2,
    Compact = false,
    Callback = function(c)
        allvars.upanglenum = c
    end
})
speedh:AddDivider()
speedh:AddToggle('Auto Respawn', {
    Text = 'Auto Respawn',
    Default = false,
    Tooltip = 'Enables auto respawn',
    Callback = function(v)
        allvars.instantrespawn = v
    end
})
speedh:AddToggle('No Jump Cooldown', {
    Text = 'No Jump Cooldown',
    Default = false,
    Tooltip = 'Disables jump cooldown',
    Callback = function(v)
        allvars.nojumpcd = v
        startnojumpcd()
    end
})
speedh:AddToggle('NoFall', {
    Text = 'NoFall',
    Default = false,
    Tooltip = 'Prevents fall damage',
    Callback = function(v)
        allvars.nofall = v
    end
})
speedh:AddToggle('InstaFall', {
    Text = 'InstaFall',
    Default = false,
    Tooltip = 'Enables instant fall',
    Callback = function(v)
        allvars.instafall = v
    end
})
speedh:AddToggle('Double Jump', {
    Text = 'Double jump',
    Default = false,
    Tooltip = 'Enables double jump',
    Callback = function(v)
        allvars.doublejump = v
    end
})
speedh:AddToggle('Instant Lean', {
    Text = 'Instant Lean',
    Default = false,
    Tooltip = 'Enables instant lean',
    Callback = function(v)
        allvars.instalean = v
        if v then 
            require(game.ReplicatedStorage.Modules.FPS).changeLean = instantleanMODfunc
        else
            require(game.ReplicatedStorage.Modules.FPS).changeLean = instantleanOGfunc
        end
    end
})
speedh:AddDivider()
speedh:AddToggle('Stop Water Effect Update', {
    Text = 'Stop water effect update',
    Default = false,
    Tooltip = 'Disables water effect updates',
    Callback = function(v)
        if scriptloading then return end

        localplayer.PlayerGui.MainGui.Scripts.HealthLocal.Disabled = v
        localplayer.PlayerGui.MainGui.Scripts.HealthLocal.Enabled = not v
    end
})
speedh:AddToggle('Jesus', {
    Text = 'Jesus',
    Default = false,
    Tooltip = 'Enables water walking',
    Callback = function(v)
        allvars.worldjesus = v
        if v then
            while allvars.worldjesus do --original = https://devforum.roblox.com/t/how-do-i-make-water-walking-passive-like-this/1589924/10
                wait(0.01)
                if not localplayer.Character or not localplayer.Character:FindFirstChild("HumanoidRootPart") then continue end

                local hitPart = workspace:Raycast(localplayer.Character:FindFirstChild("HumanoidRootPart").Position, Vector3.new(0, -5, 0) + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 5, RaycastParams.new())
                if hitPart and hitPart.Material == Enum.Material.Water then
                    local clone = Instance.new("Part")
                    clone.Parent = waterplatforms
                    clone.Position = hitPart.Position
                    clone.Anchored = true
                    clone.CanCollide = true
                    clone.Size = Vector3.new(10,0.2,10)
                    clone.Transparency = 1
                end
            end
        else
            for i,v in pairs(waterplatforms:GetChildren()) do
                v:Destroy()
            end
        end
    end
})
speedh:AddToggle('Noswim', {
    Text = 'No swimming',
    Default = false,
    Tooltip = 'Stops swimming so you can walk underwater',
    Callback = function(v)
        noswim = v
    end
})
speedh:AddDivider()
speedh:AddToggle('Humanoid Changer', {
    Text = 'Humanoid changer',
    Default = false,
    Tooltip = 'Enables humanoid property changes',
    Callback = function(v)
        allvars.changerbool = v
    end
})
speedh:AddSlider('Humanoid Speed', {
    Text = 'Humanoid Speed',
    Default = 20,
    Min = 0,
    Max = 21,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.changerspeed = c
    end
})
speedh:AddSlider('Humanoid Jumpheight', {
    Text = 'Humanoid Jumpheight',
    Default = 3,
    Min = 0,
    Max = 8,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.changerjump = c
    end
})
speedh:AddSlider('Humanoid Height', {
    Text = 'Humanoid Height',
    Default = 2,
    Min = 0,
    Max = 6,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.changerheight = c
    end
})
speedh:AddSlider('Gravity', {
    Text = 'Gravity',
    Default = 75,
    Min = 0,
    Max = 150,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.changergrav = c
    end
})
speedh:AddDivider()
speedh:AddLabel('Semi-Fly'):AddKeyPicker('SemiFly', {
    Default = 'KeypadFive',
    SyncToggleState = false,
    Mode = 'Toggle', --Always, Toggle, Hold
    Text = 'Semi-Fly',
    NoUI = false, 
    Callback = function(v)
        if scriptloading then return end
    
        if localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart") then
            if ACBYPASS_SYNC == false then
                Library:Notify("Action in queue, wait for anticheat bypass update", 4)
    
                while ACBYPASS_SYNC == false do
                    wait(0.5)
                end
            end
    
            if v == false then
                semifly_bodyvel:Destroy()
    
                for i,v in pairs(localplayer.Character.HumanoidRootPart:GetChildren()) do
                    if v:IsA("BodyVelocity") then
                        v:Destroy()
                    end
                end
    
                localplayer.Character.Humanoid.PlatformStand = false
            elseif v == true then
                semifly_bodyvel = Instance.new("BodyVelocity", localplayer.Character.HumanoidRootPart)
                semifly_bodyvel.Velocity = Vector3.new(0,0,0)
                localplayer.Character.Humanoid.PlatformStand = true
            end
    
            charsemifly = v
        else
            charsemifly = false
        end
    end,
    ChangedCallback = function(New)
    end
})
speedh:AddSlider('Semi-Fly Distance', {
    Text = 'Semi-Fly Distance',
    Default = 6,
    Min = 0.1,
    Max = 6,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.charsemiflydist = c
    end
})
speedh:AddSlider('Semi-Fly Speed', {
    Text = 'Semi-Fly Speed',
    Default = 30,
    Min = 5,
    Max = 50,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.charsemiflyspeed = c
    end
})
speedh:AddDivider()
speedh:AddToggle('TP Speed', {
    Text = 'TP Speed',
    Default = false,
    Tooltip = 'Enables teleport speed boost',
    Callback = function(v)
        allvars.speedbool = v
        startspeedhack()
    end
})
speedh:AddSlider('TP Speed Boost', {
    Text = 'TP Speed Boost',
    Default = 1.2,
    Min = 0,
    Max = 1.5,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.speedboost = c
    end
})



vmisc:AddToggle('Mod Notify', {
    Text = 'Mod notify',
    Default = false,
    Tooltip = 'Notifies about mods on your server',
    Callback = function(v)
        allvars.detectmods = v
        if v == false then
            mdetect = false
            table.clear(detectedmods)
        end
    end
})
vmisc:AddToggle('Revive Boss', {
    Text = 'Revive boss',
    Default = false,
    Tooltip = 'Revives boss in lobby',
    Callback = function(v)
        if not workspace:FindFirstChild("Boss") then Library:Notify("Use this only in lobby", 2) return end

        if v then
            local boss = workspace.Boss
            boss:SetAttribute("Hidden", false)
            for _,v in boss:GetDescendants() do
                if v:IsA("BasePart") and v:GetAttribute("OriginalTransparency") then
                    v.Transparency = v:GetAttribute("OriginalTransparency")
                end
            end
        else
            local boss = workspace.Boss
            boss:SetAttribute("Hidden", true)
            for _,v in boss:GetDescendants() do
                if v:IsA("BasePart") and v:GetAttribute("OriginalTransparency") then
                    v.Transparency = 1
                end
            end
        end
    end
})
vmisc:AddLabel('ESP Map'):AddKeyPicker('ESPmap', {
    Default = 'KeypadSeven',
    SyncToggleState = false,
    Mode = 'Toggle', --Always, Toggle, Hold
    Text = 'ESP Map',
    NoUI = false, 
    Callback = function(v)
        if scriptloading then return end
        espmapactive = v
        handleESPMAP(v)
    end,
    ChangedCallback = function(New)
    end
})
vmisc:AddDivider()
vmisc:AddLabel("Logs")
vmisc:AddToggle('JoinDetect', {
    Text = 'Player join',
    Default = false,
    Tooltip = 'Notify on player join',
    Callback = function(v)
        joindetect = v
    end
})
vmisc:AddToggle('LeaveDetect', {
    Text = 'Player leave',
    Default = false,
    Tooltip = 'Notify on player leave',
    Callback = function(v)
        leavedetect = v
    end
})



worldh:AddToggle('Disable Grass', {
    Text = 'Disable Grass',
    Default = false,
    Tooltip = 'Disables grass rendering',
    Callback = function(v)
        allvars.worldgrass = v
        sethiddenproperty(workspace.Terrain, "Decoration", not v)
    end
})
worldh:AddToggle('Disable Leaves', {
    Text = 'Disable Leaves',
    Default = false,
    Tooltip = 'Disables leaves rendering',
    Callback = function(v)
        allvars.worldleaves = v
    end
})
worldh:AddToggle('No Clouds', {
    Text = 'No clouds',
    Default = false,
    Tooltip = 'Disables clouds',
    Callback = function(v)
        allvars.worldcloud = v
        if workspace.Terrain:FindFirstChild("Clouds") then
            workspace.Terrain.Clouds.Enabled = not v
        end
    end
})
worldh:AddToggle('No Mines', {
    Text = 'No mines',
    Default = false,
    Tooltip = 'Deletes mines every 10 secs',
    Callback = function(v)
        allvars.worldnomines = v
    end
})
worldh:AddDivider()
worldh:AddToggle('ClockTimeBool', {
    Text = 'Edit clock time',
    Default = true,
    Tooltip = 'Always sets clock time to selected',
    Callback = function(v)
        clockbool = v
        game.Lighting.ClockTime = allvars.worldclock
    end
})
worldh:AddSlider('Clock Time', {
    Text = 'Clock time',
    Default = 14,
    Min = 0,
    Max = 24,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.worldclock = c
        game.Lighting.ClockTime = c
    end
})
worldh:AddSlider('Exposure', {
    Text = 'Exposure',
    Default = 1,
    Min = -4,
    Max = 4,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.worldexpo = c
        game.Lighting.ExposureCompensation = c
    end
})
worldh:AddDropdown('ChangeSkybox', {
    Values = {'Standard', 'Minecraft', 'Spongebob', 'Deep Space', 'Clouded Sky', 'Retro', 'City'},
    Default = 1,
    Multi = false,
    Text = 'Change Skybox',
    Tooltip = 'Changes skybox texture',
    Callback = function(v)
        local Sky = game.Lighting:FindFirstChildOfClass("Sky")
        local selected = skyboxtable[v]
        if selected then
            Sky.SkyboxBk = selected.SkyboxBk
            Sky.SkyboxDn = selected.SkyboxDn
            Sky.SkyboxFt = selected.SkyboxFt
            Sky.SkyboxLf = selected.SkyboxLf
            Sky.SkyboxRt = selected.SkyboxRt
            Sky.SkyboxUp = selected.SkyboxUp
        end
    end
})
worldh:AddDivider()
worldh:AddToggle('Edit PostEffects', {
    Text = 'Edit PostEffects',
    Default = false,
    Tooltip = 'Enables post-processing effects editing',
    Callback = function(v)
        allvars.colorcorrectbool = v
        game.Lighting.GeographicLatitude += 0.1
        game.Lighting.GeographicLatitude -= 0.1
    end
})
worldh:AddSlider('Brightness', {
    Text = 'Brightness',
    Default = 0,
    Min = -3,
    Max = 3,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.colorcorrectbright = c
        game.Lighting.GeographicLatitude += 0.1
        game.Lighting.GeographicLatitude -= 0.1
    end
})
worldh:AddSlider('Saturation', {
    Text = 'Saturation',
    Default = 0,
    Min = -3,
    Max = 3,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.colorcorrectsatur = c
        game.Lighting.GeographicLatitude += 0.1
        game.Lighting.GeographicLatitude -= 0.1
    end
})
worldh:AddSlider('Contrast', {
    Text = 'Contrast',
    Default = 0,
    Min = -3,
    Max = 3,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        allvars.colorcorrectcontrast = c
        game.Lighting.GeographicLatitude += 0.1
        game.Lighting.GeographicLatitude -= 0.1
    end
})
worldh:AddLabel('Tint Color'):AddColorPicker('Tint Color', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'Tint Color',
    Callback = function(a)
        allvars.colorcorrecttint = a
        game.Lighting.GeographicLatitude += 0.1
        game.Lighting.GeographicLatitude -= 0.1
    end
})
worldh:AddLabel('Color Shift'):AddColorPicker('Colorshift', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'Color Shift',
    Callback = function(a)
        allvars.worldambient = a
        game.Lighting.ColorShift_Top = allvars.worldambient
    end
})



Library:SetWatermarkVisibility(true)
local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;
local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;
    Library:SetWatermark(('Ardour Hub | Whiskey-2 | %s fps '):format(
        math.floor(FPS)
    ))
end);

Library.KeybindFrame.Visible = true
local MenuGroup = tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind

function SaveManager:Load(nm)
    cfgloading = true
    task.delay(0.3, function() cfgloading = false end)

    local httpserv = game:GetService("HttpService")
    if (not nm) then
        return false, 'no config file is selected'
    end
    
    local file = SaveManager.Folder .. '/settings/' .. nm .. '.json'
    if not isfile(file) then return false, 'invalid file' end

    local success, decoded = pcall(httpserv.JSONDecode, httpserv, readfile(file))
    if not success then return false, 'decode error' end

    for _, option in next, decoded.objects do
        if SaveManager.Parser[option.type] then
            task.spawn(function() SaveManager.Parser[option.type].Load(option.idx, option) end)
        end
    end

    return true
end
function Library:Notify(Text, Time, NColor)
    local XSize, YSize = Library:GetTextBounds(Text, Library.Font, 14);

    YSize = YSize + 7

    local NotifyOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, 10);
        Size = UDim2.new(0, 0, 0, YSize);
        ClipsDescendants = true;
        ZIndex = 100;
        Parent = Library.NotificationArea;
    });

    local NotifyInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = NotifyOuter;
    });

    Library:AddToRegistry(NotifyInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 102;
        Parent = NotifyInner;
    });

    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    });

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
        end
    });

    local NotifyLabel = Library:CreateLabel({
        Position = UDim2.new(0, 4, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        Text = Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextSize = 14;
        ZIndex = 103;
        Parent = InnerFrame;
    });

    local LeftColor
    if NColor then
        LeftColor = Library:Create('Frame', {
            BackgroundColor3 = NColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, -1, 0, -1);
            Size = UDim2.new(0, 3, 1, 2);
            ZIndex = 104;
            Parent = NotifyOuter;
        })
    else
        LeftColor = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, -1, 0, -1);
            Size = UDim2.new(0, 3, 1, 2);
            ZIndex = 104;
            Parent = NotifyOuter;
        })
    end

    Library:AddToRegistry(LeftColor, {
        BackgroundColor3 = 'AccentColor';
    }, true);

    pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize + 8 + 4, 0, YSize), 'Out', 'Quad', 0.4, true);

    task.spawn(function()
        wait(Time or 5);

        pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true);

        wait(0.4);

        NotifyOuter:Destroy();
    end)
end
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('ArdourHub')
SaveManager:SetFolder('ArdourHub/projectdelta')
SaveManager:BuildConfigSection(tabs['UI Settings'])
ThemeManager:ApplyToTab(tabs['UI Settings'])

Library.BackgroundColor = Color3.fromRGB(29,29,29)
Library.MainColor = Color3.fromRGB(36,36,36)
Library.AccentColor = Color3.fromRGB(42,153,255)
Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);
Library:UpdateColorsUsingRegistry()

--ui loaded--
print('ui ready')
Library:Notify("UI Loaded", 2)

--tracers--
print("loading tracers")
local function runtracer(start, endp)
    local beam = Instance.new("Beam")
    beam.Name = "LineBeam"
    beam.Parent = game.Workspace
    local startpart = Instance.new("Part")
    startpart.CanCollide = false
    startpart.CanQuery = false
    startpart.Transparency = 1
    startpart.Position = start
    startpart.Parent = workspace
    startpart.Anchored = true
    startpart.Size = Vector3.new(0.01, 0.01, 0.01)
    local endpart = Instance.new("Part")
    endpart.CanCollide = false
    endpart.CanQuery = false
    endpart.Transparency = 1
    endpart.Position = endp
    endpart.Parent = workspace
    endpart.Anchored = true
    endpart.Size = Vector3.new(0.01, 0.01, 0.01)
    beam.Attachment0 = Instance.new("Attachment", startpart)
    beam.Attachment1 = Instance.new("Attachment", endpart)
    beam.Color = ColorSequence.new(allvars.traccolor,  allvars.traccolor)
    beam.Width0 = 0.05
    beam.Width1 = 0.05
    beam.FaceCamera = true
    beam.Transparency = NumberSequence.new(0)
    beam.LightEmission = 1

    if allvars.tractexture ~= nil then
        beam.Texture = allvars.tractexture
        if allvars.tractexture == "http://www.roblox.com/asset/?id=131326755401058" then
            beam.TextureSpeed = 3
            beam.TextureLength = (endp - start).Magnitude
            beam.Width0 = 0.3
            beam.Width1 = 0.3
        end
    end

    wait(allvars.tracwait)

    beam:Destroy()
    startpart:Destroy()
    endpart:Destroy()
end


--silent aim--
print("loading silent aim ")
function isonscreen(object)
    local _, bool = wcamera:WorldToScreenPoint(object.Position)
    return bool
end
v311 = require(game.ReplicatedStorage.Modules:WaitForChild("UniversalTables"))
globalist11 = v311.ReturnTable("GlobalIgnoreListProjectile")

local _chooseTargetDelta = 0
function isvisible(char, object, predict)
	local predict = predict or false
    if not localplayer.Character or not localplayer.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    if allvars.aimvischeck == false then
        return true
    end
	local origin 
	if predict then
		origin = localplayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0) + localplayer.Character.HumanoidRootPart.AssemblyLinearVelocity * _chooseTargetDelta
	else 
	    origin = localplayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)
	end
    if allvars.desyncbool and desynctable[3] then
        origin = desynctable[3].Position + Vector3.new(0, 1.5, 0)
    end
	local pos
	if typeof(object) == "Vector3"  then
		pos = object
	else

		pos = object.Position
	end
  
    local dir = pos - origin
    local dist = dir.Magnitude + 2500
    local penetrated = true
    dir = dir.Unit

    local params = RaycastParams.new()
    params.IgnoreWater = true
    params.CollisionGroup = "WeaponRay"
    params.FilterDescendantsInstances = {
        localplayer.Character,
        wcamera,
        globalist11,
        aimignoreparts,
    }

    local ray = workspace:Raycast(origin, dir * dist, params)
    if ray and ray.Instance:IsDescendantOf(char) then
        return true
    elseif ray and ray.Instance.Name ~= "Terrain" and not ray.Instance:GetAttribute("NoPen") then
        local armorpen4 = 10
        if globalammo then
            armorpen4 = globalammo:GetAttribute("ArmorPen")
        end

        local FunctionLibraryExtension = require(game.ReplicatedStorage.Modules.FunctionLibraryExtension)
        local armorpen1, newpos2 = FunctionLibraryExtension.Penetration(FunctionLibraryExtension, ray.Instance, ray.Position, dir, armorpen4)
        if armorpen1 == nil or newpos2 == nil then
            return false
        end

        local neworigin = ray.Position + dir * 0.01
        local newray = workspace:Raycast(neworigin, dir * (dist - (neworigin - origin).Magnitude), params)
        if newray and newray.Instance:IsDescendantOf(char) then
            return true
        end
    end

    return false
end
function choosetarget(delta)
    _chooseTargetDelta = delta
    local cent = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2)
    local cdist = math.huge
    local ctar = nil
    local cpart = nil
    local restar = nil
    local predist = math.huge

    local ammodistance = 999999999
    if allvars.aimdistcheck and globalammo then
        ammodistance = globalammo:GetAttribute("MuzzleVelocity")
    end

    local bparts = {
        "Head",
        "HeadTopHitBox",
        "FaceHitBox",
        "UpperTorso",
        "LowerTorso",
        "LeftUpperArm",
        "RightUpperArm",
        "LeftLowerArm",
        "RightLowerArm",
        "LeftHand",
        "RightHand",
        "LeftUpperLeg",
        "RightUpperLeg",
        "LeftLowerLeg",
        "RightLowerLeg",
        "LeftFoot",
        "RightFoot"
    }

    local function chooseTpart(charact)
        if allvars.aimpart == "Head" then
            return charact:FindFirstChild("Head")
        elseif allvars.aimpart == "HeadTop" then
            return charact:FindFirstChild("HeadTopHitBox")
        elseif allvars.aimpart == "Face" then
            return charact:FindFirstChild("FaceHitBox")
        elseif allvars.aimpart == "Torso" then
            return charact:FindFirstChild("UpperTorso")
        elseif allvars.aimpart == "Scripted" then
            local head = charact:FindFirstChild("Head")
            local upperTorso = charact:FindFirstChild("UpperTorso")
			local lowerTorso = charact:FindFirstChild("LowerTorso")	
			if isvisible(charact, lowerTorso) then return lowerTorso end
			if isvisible(charact, upperTorso) then return upperTorso end
			return head


           
        elseif allvars.aimpart == "Random" then
            return charact:FindFirstChild(bparts[math.random(1, #bparts)])
        end
    end

    if allvars.aimbots then --priority 2 (bots)
        for _, botfold in pairs(workspace.AiZones:GetChildren()) do
            for _, bot in pairs(botfold:GetChildren()) do
                if bot:IsA("Model") and bot:FindFirstChild("Humanoid") and bot.Humanoid.Health > 0 then
                    if allvars.friendlistbots then
                        if allvars.friendlistmode == "Blacklist" then 
                            if table.find(allvars.aimFRIENDLIST, bot.Name) ~= nil then
                                continue
                            end
                        elseif allvars.friendlistmode == "Whitelist" then 
                            if table.find(allvars.aimFRIENDLIST, bot.Name) == nil then
                                continue
                            end
                        end
                    end

                    local potroot = chooseTpart(bot)
                    if potroot and localplayer.Character then
                        local spoint = wcamera:WorldToViewportPoint(potroot.Position)
                        local optpoint = Vector2.new(spoint.X, spoint.Y)
                        local dist = (optpoint - cent).Magnitude
                        
                        local betweendist = (localplayer.Character.PrimaryPart.Position - potroot.Position).Magnitude * 0.3336
                        local betweendistSTUDS = (localplayer.Character.PrimaryPart.Position - potroot.Position).Magnitude
                        if dist <= aimfovcircle.Radius and dist < cdist and betweendist < allvars.aimdistance and betweendistSTUDS < ammodistance and isonscreen(potroot) then
                            local canvis = isvisible(bot, potroot)

                            if canvis then
                                cdist = dist
                                ctar = bot
                                cpart = potroot
                            end
                            if dist < predist then
                                predist = dist
                                restar = bot
                            end
                        end
                    end
                end
            end
        end
    end

    for _, pottar in pairs(game.Players:GetPlayers()) do --priority 1 (players)
        if pottar ~= localplayer and pottar.Character and localplayer.Character.PrimaryPart ~= nil then
            if allvars.friendlistmode == "Blacklist" then 
                if table.find(allvars.aimFRIENDLIST, pottar.Name) ~= nil then
                    continue
                end
            elseif allvars.friendlistmode == "Whitelist" then 
                if table.find(allvars.aimFRIENDLIST, pottar.Name) == nil then
                    continue
                end
            end

            local potroot = chooseTpart(pottar.Character)
            if potroot then
                local spoint = wcamera:WorldToViewportPoint(potroot.Position)
                local optpoint = Vector2.new(spoint.X, spoint.Y)
                local dist = (optpoint - cent).Magnitude
                
                local betweendist = (localplayer.Character.PrimaryPart.Position - potroot.Position).Magnitude * 0.3336
                local betweendistSTUDS = (localplayer.Character.PrimaryPart.Position - potroot.Position).Magnitude
                if dist <= aimfovcircle.Radius and dist < cdist and betweendist < allvars.aimdistance and betweendistSTUDS < ammodistance and isonscreen(potroot) then
                    local canvis = isvisible(pottar.Character, potroot)
					if not canvis and allvars.predict then canvis = isvisible(pottar.Character, potroot.Position + potroot.AssemblyLinearVelocity * delta) end
					if not canvis and allvars.predict then canvis = isvisible(pottar.Character, potroot.Position + potroot.AssemblyLinearVelocity * delta, true) end 
                    if canvis then
                        cdist = dist
                        ctar = pottar
                        cpart = potroot
                    end
                    if dist < predist then
                        predist = dist
                        restar = pottar
                    end
                end
            end
        end
    end

    if ctar == nil then
        aimtarget = nil
        aimtargetpart = nil
        if restar then
            aimpretarget = restar
        else
            aimpretarget = nil
        end
    else
        aimtarget = ctar
        aimtargetpart = cpart
        aimpretarget = restar
    end
end
function runhitmark(v140)
    if allvars.hitmarkbool then --some code by ds: meowya_1337
        local hitpart = Instance.new("Part", workspace)
        hitpart.Transparency = 1
        hitpart.CanCollide = false
        hitpart.CanQuery = false
        hitpart.Size = Vector3.new(0.01,0.01,0.01)
        hitpart.Anchored = true
        hitpart.Position = v140

        local hit = Instance.new("BillboardGui")
        hit.Name = "hit"
        hit.AlwaysOnTop = true
        hit.Parent = hitpart

        local hit_img = Instance.new("ImageLabel")
        hit_img.Name = "hit_img"
        hit_img.Image = "http://www.roblox.com/asset/?id=13298929624"
        hit_img.BackgroundTransparency = 1
        hit_img.Size = UDim2.new(0, 50, 0, 50)
        hit_img.Visible = true
        hit_img.ImageColor3 = allvars.hitmarkcolor
        hit_img.Rotation = 45
        hit_img.AnchorPoint = Vector2.new(0.5, 0.5)
        hit_img.Parent = hit

        task.spawn(function()
            local tweninfo = TweenInfo.new(allvars.hitmarkfade, Enum.EasingStyle.Sine)
            local tweninfo2 = TweenInfo.new(allvars.hitmarkfade, Enum.EasingStyle.Linear)
            tweens:Create(hit_img, tweninfo, {ImageTransparency = 1}):Play()
            tweens:Create(hit_img, tweninfo2, {Rotation = 180}):Play()
            task.wait(allvars.hitmarkfade)
            hit_img:Destroy()
            hit:Destroy()
        end)
    end
end
aimmodfunc = function(prikol, p49, p50, p_u_51, aimpart, _, p52, p53, p54)
    local v_u_6 = game.ReplicatedStorage.Remotes.VisualProjectile
    local v_u_108 = 1
    local v_u_106 = 0
    local v_u_7 = game.ReplicatedStorage.Remotes.FireProjectile
    local target = aimtarget
    local target_part
    local v_u_4 = require(game.ReplicatedStorage.Modules:WaitForChild("FunctionLibraryExtension"))
    local v_u_103
    local v_u_114
    local v_u_16 = game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name)
    local v_u_64 = v_u_16.Status.GameplayVariables:GetAttribute("EquipId")
    local v_u_13 = game.ReplicatedStorage:WaitForChild("VFX")
    local v_u_2 = require(game.ReplicatedStorage.Modules:WaitForChild("VFX"))
    local v3 = require(game.ReplicatedStorage.Modules:WaitForChild("UniversalTables"))
    local v_u_5 = game.ReplicatedStorage.Remotes.ProjectileInflict
    local v_u_10 = game:GetService("ReplicatedStorage")
    local v_u_12 = v_u_10:WaitForChild("RangedWeapons")
    local v_u_17 = game.ReplicatedStorage.Temp
    local v_u_56 = localplayer.Character
    local v135 = 500000
    local v_u_18 = v3.ReturnTable("GlobalIgnoreListProjectile")
    local v_u_115 = localplayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)
    if allvars.desyncbool and desynctable[3] then
        v_u_115 = desynctable[3].Position + Vector3.new(0, 1.5, 0)
    end
    local hittick = tick()
    local v65 = v_u_10.AmmoTypes:FindFirstChild(p52)
    local v_u_74 = v65:GetAttribute("Pellets")
    local v60 = p50.ItemRoot
    local v61 = p49.ItemProperties
    local v62 = v_u_12:FindFirstChild(p49.Name)
    local v63 = v61:FindFirstChild("SpecialProperties")
    local v_u_66 = v63 and v63:GetAttribute("TracerColor") or v62:GetAttribute("ProjectileColor")
    local itemprop = require(v_u_16.Inventory:FindFirstChild(p49.Name).SettingsModule)
    local bulletspeed = v65:GetAttribute("MuzzleVelocity")
    local armorpen4 = v65:GetAttribute("ArmorPen")
    local tracerendpos = Vector3.zero
    local v79 = {
        ["x"] = {
            ["Value"] = 0
        },
        ["y"] = {
            ["Value"] = 0
        }
    }

    if v_u_56:FindFirstChild(p49.Name) then
        local v83 = 0.001 
        local v82 = 0.001
        local v81 = v61.Tool:GetAttribute("MuzzleDevice") or "Default"
        v_u_108 = math.random(-100000, 100000)
        
        if v61.Tool:GetAttribute("MuzzleDevice") or "Default" == "Suppressor" then
            if tick() - p53 < 0.8 then
                v_u_4:PlaySoundV2(v60.Sounds.FireSoundSupressed, v60.Sounds.FireSoundSupressed.TimeLength, v_u_17)
            else
                v_u_4:PlaySoundV2(v60.Sounds.FireSoundSupressed, v60.Sounds.FireSoundSupressed.TimeLength, v_u_17)
            end
        elseif tick() - p53 < 0.8 then
            v_u_4:PlaySoundV2(v60.Sounds.FireSound, v60.Sounds.FireSound.TimeLength, v_u_17)
        else
            v_u_4:PlaySoundV2(v60.Sounds.FireSound, v60.Sounds.FireSound.TimeLength, v_u_17)
        end
        local v_u_59
        if p_u_51.Item.Attachments:FindFirstChild("Front") then
            v_u_59 = p_u_51.Item.Attachments.Front:GetChildren()[1].Barrel
        else
            v_u_59 = p_u_51.Item.Barrel
        end

        if target ~= nil and aimtargetpart ~= nil then
            target_part = aimtargetpart
            if not allvars.shootAtPredicted then
                v_u_103 = CFrame.new(v_u_115, target_part.Position).LookVector
            else
                v_u_103 = CFrame.new(v_u_115, target_part.Position + target_part.AssemblyLinearVelocity * _chooseTargetDelta).LookVector
            end
            if allvars.aimfakewait then
                local predictedPos = v_u_103
                for i =1, 3 do
                    local toTarget = predictedPos - v_u_115
                    local estTime = toTarget.Magnitude / bulletspeed    
                    predictedPos = target_part.Position + target_part.AssemblyLinearVelocity * estTime
                end
                v_u_103 = CFrame.new(v_u_115, predictedPos).LookVector

            end
            v_u_114 = v_u_103
        else
            target_part = aimpart
            v_u_103 = CFrame.new(v_u_115, localplayer:GetMouse().Hit.Position).LookVector
            v_u_114 = v_u_103
        end

        function v185()
            local v_u_110 = RaycastParams.new()
            v_u_110.FilterType = Enum.RaycastFilterType.Exclude
            local v_u_111 = { v_u_56, p_u_51, v_u_18, aimignoreparts}
            v_u_110.FilterDescendantsInstances = v_u_111
            v_u_110.CollisionGroup = "WeaponRay"
            v_u_110.IgnoreWater = true

            v_u_106 += 1

            local usethisvec = v_u_114

            if v_u_106 == 1 then
                task.spawn(function()
                    for i=1, allvars.multitaps do
                        if not v_u_7:InvokeServer(usethisvec, v_u_108, 0) then 
                            game.ReplicatedStorage.Modules.FPS.Binds.AdjustBullets:Fire(v_u_64, 1)
                        end
                    end
                end)
            elseif 1 < v_u_106 then
                for i=1, allvars.multitaps do
                    v_u_6:FireServer(usethisvec, v_u_108)
                end
            end

            local v_u_131 = nil
            local v_u_132 = 0
            local v_u_133 = 0

            if allvars.aimfakewait and target ~= nil then
                local tpart 
                if target:IsA("Model") then
                    tpart = target.HumanoidRootPart
                else
                    tpart = target.Character.HumanoidRootPart
                end
                local velocity = tpart.Velocity
                local distance = (wcamera.CFrame.Position - tpart.CFrame.Position).Magnitude
                local tth = (distance / bulletspeed)
                task.wait(tth + 0.01)
            end

            local penetrated = false

            function v184(p134)
                v_u_132 = v_u_132 + p134
                if true then
                    v_u_133 = v_u_133 + v_u_132
                    local v136 = workspace:Raycast(v_u_115, v_u_114 * v135, v_u_110)
                    local v137 = nil
                    local v138 = nil
                    local v139 = nil
                    local v140
                    if v136 then
                        v137 = v136.Instance
                        v140 = v136.Position
                        v138 = v136.Normal
                        v139 = v136.Material
                    else
                        v140 = v_u_115 + v_u_114 * v135
                    end

                    if v137 == nil then
                        v_u_131:Disconnect()
                        return
                    end


                    local v171 = v_u_4:FindDeepAncestor(v137, "Model")
                    if v171:FindFirstChild("Humanoid") then -- if hit target
                        allvars.peekblink = false
                        local ran = math.random(1, 100)
                        local ranbool = ran <= allvars.aimchance
                     
                        if ranbool then
							

                            
                            local v175 = v137.CFrame:ToObjectSpace(CFrame.new(v140))
							
                            if target_part and penetrated == false then
                                v_u_5:FireServer(target_part, v175, v_u_108, hittick)
                            else
                                v_u_5:FireServer(v137, v175, v_u_108, hittick)
                            end
                        else
                      
                            local offsetRange = 12.5


                            local randomOffset = Vector3.new(
                            math.random(-100, 100)/100 * offsetRange,
                            math.random(-100, 100)/100 * offsetRange,
                            math.random(-100, 100)/100 * offsetRange
                                     )

							
                            local v175 = v137.CFrame:ToObjectSpace(CFrame.new(v140+randomOffset)) 
                            
                            v_u_5:FireServer(aimpart, v175, v_u_108, hittick)
                        end
                        tracerendpos = v140
                        runs.RenderStepped:Wait()
                        task.spawn(function()
                            runhitmark(v140)
                        end)
                        localplayer.Character.HumanoidRootPart.CFrame = _recordedBlinkPos or localplayer.Character.HumanoidRootPart.CFrame
                        
                    elseif v137.Name == "Terrain" then -- if hit terrain
                        local v175 = v137.CFrame:ToObjectSpace(CFrame.new(v140))
                        v_u_5:FireServer(v137, v175, v_u_108, hittick)
	
                        v_u_2.Impact(v137, v140, v138, v139, v_u_114, "Ranged", true)

                        task.spawn(function()
                            runhitmark(v140)
                        end)
                    else -- if hit not target then try wallpen
                        v_u_2.Impact(v137, v140, v138, v139, v_u_114, "Ranged", true)

                        task.spawn(function()
                            runhitmark(v140)
                        end)

                        local arg1, arg2, arg3 = v_u_4.Penetration(v_u_4, v137, v140, v_u_114, armorpen4)
                        if arg1 == nil or arg2 == nil then
                            local v175 = v137.CFrame:ToObjectSpace(CFrame.new(v140))
                            v_u_5:FireServer(v137, v175, v_u_108, hittick)
                            v_u_131:Disconnect()
                            return
                        end

                        armorpen4 = arg1
                        if armorpen4 > 0 then
                            v_u_115 = arg2
                            v_u_2.Impact(unpack(arg3))
                            penetrated = true
                            return
                        end

                        v_u_131:Disconnect()
                        return
                    end
                end

                v_u_131:Disconnect()
                return
            end
            v_u_131 = game:GetService("RunService").RenderStepped:Connect(v184)
            return
        end

        if v_u_74 == nil then
            task.spawn(v185)
        else
            for i = 1, v_u_74 do
                task.spawn(v185)
            end
        end

        if allvars.tracbool then
            task.spawn(function()
                task.wait(0.05)
                if tracerendpos == Vector3.zero then return end
                runtracer(wcamera.ViewModel.Item.ItemRoot.Position, tracerendpos)
            end)
        end
        return v83, v82, v81, v79
    end
end

--esp--
print("loading ESP functions/connections")
function setupesp(obj, dtype, otype1)
    if not obj then return end

    local dobj
    local tableinfo
    if dtype == "Name" then
        dobj = Drawing.new("Text")
        dobj.Font = Drawing.Fonts.Monospace
        dobj.Visible = allvars.espbool
        dobj.Center = true
        dobj.Outline = true
        dobj.Size = allvars.esptextsize + 2
        dobj.Color = allvars.esptextcolor
        dobj.OutlineColor = Color3.new(0, 0, 0)
        tableinfo = {
            primary = obj,
            type = "Name",
            otype = otype1
        }
    elseif dtype == "HP" then
        dobj = Drawing.new("Text")
        dobj.Visible = allvars.espbool
        dobj.Font = Drawing.Fonts.Monospace
        dobj.Center = true
        dobj.Outline = true
        dobj.Size = allvars.esptextsize
        dobj.Color = allvars.esptextcolor
        dobj.OutlineColor = Color3.new(0, 0, 0)
        tableinfo = {
            primary = obj,
            type = "HP",
            otype = otype1
        }
    elseif dtype == "Distance" then
        dobj = Drawing.new("Text")
        dobj.Visible = allvars.espbool
        dobj.Font = Drawing.Fonts.Monospace
        dobj.Center = true
        dobj.Outline = true
        dobj.Size = allvars.esptextsize
        dobj.Color = allvars.esptextcolor
        dobj.OutlineColor = Color3.new(0, 0, 0)
        tableinfo = {
            primary = obj,
            type = "Distance",
            otype = otype1
        }
    elseif dtype == "Hotbar" then
        dobj = Drawing.new("Text")
        dobj.Visible = allvars.espbool
        dobj.Font = Drawing.Fonts.Monospace
        dobj.Center = true
        dobj.Outline = true
        dobj.Size = allvars.esptextsize + 1
        dobj.Color = allvars.esptextcolor
        dobj.OutlineColor = Color3.new(0, 0, 0)
        tableinfo = {
            primary = obj,
            type = "Hotbar",
            otype = otype1
        }
    elseif dtype == "Highlight" then
        dobj = Instance.new("Highlight")
        dobj.Name = "ardour highlight solter dont delete PLS"
        dobj.FillColor = allvars.espfillcolor
        dobj.OutlineColor = allvars.esplinecolor
        dobj.FillTransparency = allvars.espchamsfill
        dobj.OutlineTransparency = allvars.espchamsline
        if obj.Parent:IsA("Model") then
            dobj.Parent = obj.Parent
        else
            dobj:Destroy()
            return
        end

        dobj.Enabled = allvars.esphigh
        tableinfo = {
            primary = obj,
            type = "Highlight",
            otype = otype1
        }
    end

    if dobj == nil or tableinfo == nil then return end

    local function selfdestruct() --destroy esp object
        if dtype == "Highlight" then
            dobj.Enabled = false
            dobj:Destroy()
        else
            dobj.Visible = false
            dobj:Remove()
        end
        if removing then
            removing:Disconnect()
            removing = nil
        end
        return
    end

    if esptable[dobj] ~= nil then --if in table then cancel
        selfdestruct()
        return
    else
        esptable[dobj] = tableinfo
    end

    removing = workspace.DescendantRemoving:Connect(function(what)
        if what == obj then
            esptable[dobj] = nil
            selfdestruct()
        end
    end)
end
function startesp(v, otype) --start esp for model
    if not v then return end

    task.spawn(function()
        if otype == "Extract" then
            setupesp(v, "Name", otype)
            setupesp(v, "Distance", otype)
        elseif otype == "Loot" then
            local Amount
            local TotalPrice = 0
            local Value = 0

            if v.Parent and v.Parent:FindFirstChild("Inventory") then else
                return
            end

            for _, i in pairs(v.Parent.Inventory:GetChildren()) do
                Amount = i.ItemProperties:GetAttribute("Amount") or 1
                TotalPrice += i.ItemProperties:GetAttribute("Price") or 0
                Value += (valcache[i.ItemProperties:GetAttribute("CallSign")] or 0) * Amount
            end --original = https://rbxscript.com/post/ProjectDeltaLootEsp-P7xaS

            if Value >= 4 then
                setupesp(v, "Name", otype)
                setupesp(v, "Hotbar", otype)
                setupesp(v, "Distance", otype)
            end
        elseif otype == "Dead333" then
            local hd = v:WaitForChild("Head",1)
            if hd == nil then return end
            setupesp(hd, "Name", otype)
            setupesp(hd, "Distance", otype)
        else
            local hd = v:WaitForChild("Head",1)
            if hd == nil then return end
            setupesp(hd, "Name", otype)
            setupesp(hd, "HP", otype)
            setupesp(hd, "Distance", otype)
            setupesp(hd, "Hotbar", otype)
            setupesp(hd, "Highlight", otype) 
        end
    end)
end
for i,v in pairs(workspace:GetDescendants()) do
    if v:FindFirstChild("Humanoid") and v ~= localplayer.Character then
        if game.Players:FindFirstChild(v.Name) and not v:FindFirstAncestor("DroppedItems") then
            startesp(v, "Plr")
        elseif v:FindFirstAncestor("AiZones") then
            startesp(v, "Bot333")
        elseif v:FindFirstAncestor("DroppedItems") then
            startesp(v, "Dead333")
        end
    elseif v.Parent == workspace:FindFirstChild("NoCollision"):FindFirstChild("ExitLocations") then
        startesp(v, "Extract")
    elseif v:FindFirstAncestor("Containers") and v:IsA("MeshPart") then
        if v.Parent:IsA("Model") then
            startesp(v, "Loot")
        end
    end
end
workspace.DescendantAdded:Connect(function(v)
    if v.Name == "Head" and v:IsA("BasePart") then
        local hum = v.Parent:WaitForChild("Humanoid", 2)
        if hum and v.Parent ~= localplayer.Character then
            if game.Players:FindFirstChild(v.Parent.Name) and not v:FindFirstAncestor("DroppedItems") then
                startesp(v.Parent, "Plr")
            elseif v:FindFirstAncestor("AiZones") then
                startesp(v.Parent, "Bot333")
            elseif v:FindFirstAncestor("DroppedItems") then
                startesp(v.Parent, "Dead333")
            end
        end
    elseif v.Parent == workspace:FindFirstChild("NoCollision"):FindFirstChild("ExitLocations") then
        startesp(v, "Extract")
    elseif v:FindFirstAncestor("Containers") and v:IsA("MeshPart") then
        if v.Parent:IsA("Model") then
            startesp(v, "Loot")
        end
    end
end)

--speedhack--
print("loading speedhack function")
function startspeedhack() --paste2
    local chr = localplayer.Character
    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
    while allvars.speedbool and chr and hum and hum.Parent do
        local delta = runs.Heartbeat:Wait()
        if hum.MoveDirection.Magnitude > 0 then
            chr:TranslateBy(hum.MoveDirection * tonumber(allvars.speedboost) * delta * 10)
        else
            chr:TranslateBy(hum.MoveDirection * delta * 10)
        end
    end
end

--no jump cd--
print("loading bunnyhop function")
function startnojumpcd() --btw this not paste i found it myself
    while allvars.nojumpcd do
        task.wait(0.01)
        if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid:SetAttribute("JumpCooldown", tick())
        else
            wait(1)
        end
    end
end

--fullbright--
print("loading fullbright")
pcall(function() --paste1
    local lighting = game:GetService("Lighting");
    lighting.ColorShift_Top = allvars.worldambient
    lighting.OutdoorAmbient = allvars.worldoutdoor
    lighting.Brightness = 1;
    lighting.FogEnd = 100000
    lighting.GlobalShadows = false
	for i,v in pairs(lighting:GetChildren()) do
		if v:IsA("Atmosphere") then
			v:Destroy()
		end
	end
    for i, v in pairs(lighting:GetChildren()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false;
        end;
    end;
    lighting.Changed:Connect(function()
        lighting.ColorShift_Top = allvars.worldambient
        lighting.Brightness = 1;
        lighting.FogEnd = 100000
        lighting.OutdoorAmbient = allvars.worldoutdoor
        if clockbool then lighting.ClockTime = allvars.worldclock end
        lighting.ExposureCompensation = allvars.worldexpo

        if allvars.colorcorrectbool then
            lighting.PostEffects.Enabled = true
            lighting.PostEffects.Brightness = allvars.colorcorrectbright
            lighting.PostEffects.Saturation = allvars.colorcorrectsatur
            lighting.PostEffects.Contrast = allvars.colorcorrectcontrast
            lighting.PostEffects.TintColor = allvars.colorcorrecttint
        else
            lighting.PostEffects.Enabled = false
        end

        local atmo = lighting:FindFirstChildOfClass("Atmosphere")
        if atmo then
            atmo:Destroy()
        end
    end)
end)

--camera--
print("loading fov changer")
do --fov changer
    csys = require(game.ReplicatedStorage.Modules.CameraSystem)
    dop2 = require(game.ReplicatedStorage.Modules.spring).new(Vector3.new(), Vector3.new(), Vector3.new(), 15, 0.5)
    dop3 = game:GetService("TweenService")
    dop4 = workspace.Camera
    dop5 = false
    dop6 = 1
    dop7 = false
    dop8 = 1
    dop9 = 1
    dop10 = nil
    function FieldOfViewUpdate(p11, p12, p13) 
        local v14 = p12 or Enum.EasingStyle.Quad
        local v15 = p13 or Enum.EasingDirection.Out
        local targetfov
        if dop8 > 1 then
            targetfov = allvars.zoomfov
        else
            targetfov = allvars.basefov
        end
        local v16 = dop9 ~= 1 and dop9 or dop5 and dop6 or targetfov
        if instazoom then
            p11 = 0.01
        end
        dop3:Create(dop4, TweenInfo.new(p11, v14, v15), {
            ["FieldOfView"] = v16 > 1 and dop7 and v16 or v16
        }):Play()
        if dop10 then
            local v_u_17 = dop10
            task.spawn(function() 
                local v_u_18 = v_u_17:FindFirstChild("Head") or v_u_17.PrimaryPart
                dop2.p = v_u_18.Position
                local v_u_19 = nil
                v_u_19 = game:GetService("RunService").RenderStepped:Connect(function(p20)
                    dop4.CFrame = CFrame.lookAt(dop4.CFrame.Position, dop2.p)
                    dop2.target = v_u_18.Position
                    dop2:update(p20)
                    if dop10 ~= v_u_17 then
                        v_u_19:Disconnect()
                    end
                end)
            end)
        end
    end
    camzoomfunction = function(_, p21, p22, p23, p24, p25)
        dop7 = p22
        dop8 = p21
        FieldOfViewUpdate(p23, p24, p25)
    end
end


--insta equip 
print("loading insta equip")
workspace.Camera.ChildAdded:Connect(function(ch)
    if allvars.instaequip and ch:IsA("Model") then
        task.wait(0.015)
        for i,v in ch.Humanoid.Animator:GetPlayingAnimationTracks() do
            if v.Animation.Name == "Equip" then
                v:AdjustSpeed(15)
                v.TimePosition = v.Length - 0.01
            end
        end
    end
end)


-- third person --
print("changing thirdperson roblox script")
require(game.Players.LocalPlayer.PlayerScripts.PlayerModule.CameraModule.TransparencyController).Update = function(a1, a2) -- transparency = allvars.camthirdp and 1 or 0
    local v14_3_ = workspace
    local v14_2_ = v14_3_.CurrentCamera

    local setto = 0
    if allvars.camthirdp == false or thirdpshow == false then
        setto = 1
    end

    if v14_2_ then
        v14_3_ = a1.enabled
        if v14_3_ then
            local v14_6_ = v14_2_.Focus
            local v14_5_ = v14_6_.p
            local v14_7_ = v14_2_.CoordinateFrame
            v14_6_ = v14_7_.p
            local v14_4_ = v14_5_ - v14_6_
            v14_3_ = v14_4_.magnitude
            v14_5_ = 2
            v14_4_ = 0
            v14_5_ = 0.500000
            if v14_4_ < v14_5_ then
                v14_4_ = 0
            end
            v14_5_ = a1.lastTransparency
            if v14_5_ then
                v14_5_ = 1
                if v14_4_ < v14_5_ then
                    v14_5_ = a1.lastTransparency
                    v14_6_ = 0.950000
                    if v14_5_ < v14_6_ then
                        v14_6_ = a1.lastTransparency
                        v14_5_ = v14_4_ - v14_6_
                        v14_7_ = 2.800000
                        v14_6_ = v14_7_ * a2
                        local v14_9_ = -v14_6_
                        local v14_8_ = v14_5_
                        local v14_10_ = v14_6_
                        local clamp = math.clamp
                        v14_7_ = clamp(v14_8_, v14_9_, v14_10_)
                        v14_5_ = v14_7_
                        v14_7_ = a1.lastTransparency
                        v14_4_ = v14_7_ + v14_5_
                    else
                        v14_5_ = true
                        a1.transparencyDirty = v14_5_
                    end
                else
                    v14_5_ = true
                    a1.transparencyDirty = v14_5_
                end
            else
                v14_5_ = true
                a1.transparencyDirty = v14_5_
            end
            v14_7_ = v0_2_
            v14_7_ = v14_4_
            local v14_8_ = 2
            v14_7_ = 0
            v14_8_ = 1
            v14_4_ = v14_5_
            v14_5_ = a1.transparencyDirty
            if not v14_5_ then
                v14_5_ = a1.lastTransparency
                if v14_5_ ~= v14_4_ then
                    v14_5_ = pairs
                    v14_6_ = a1.cachedParts
                    v14_5_, v14_6_, v14_7_ = v14_5_(v14_6_)
                    for v14_8_, v14_9_ in v14_5_, v14_6_, v14_7_ do
                        local v14_11_ = v0_0_
                        local v14_10_ = false
                        if v14_10_ then
                            v14_11_ = v0_0_
                            v14_10_ = v14_11_.AvatarGestures
                            if v14_10_ then
                                v14_10_ = {}
                                local Hat = Enum.AccessoryType.Hat
                                local v14_12_ = true
                                v14_10_[Hat] = v14_12_
                                local Hair = Enum.AccessoryType.Hair
                                v14_12_ = true
                                v14_10_[Hair] = v14_12_
                                local Face = Enum.AccessoryType.Face
                                v14_12_ = true
                                v14_10_[Face] = v14_12_
                                local Eyebrow = Enum.AccessoryType.Eyebrow
                                v14_12_ = true
                                v14_10_[Eyebrow] = v14_12_
                                local Eyelash = Enum.AccessoryType.Eyelash
                                v14_12_ = true
                                v14_10_[Eyelash] = v14_12_
                                v14_11_ = v14_8_.Parent
                                local v14_13_ = "Accessory"
                                v14_11_ = v14_11_:IsA(v14_13_)
                                if v14_11_ then
                                    v14_13_ = v14_8_.Parent
                                    v14_12_ = v14_13_.AccessoryType
                                    v14_11_ = v14_10_[v14_12_]
                                    if not v14_11_ then
                                        v14_11_ = v14_8_.Name
                                        if v14_11_ == "Head" then
                                            v14_8_.LocalTransparencyModifier = setto
                                        else
                                            v14_11_ = 0
                                            v14_8_.LocalTransparencyModifier = setto
                                            v14_8_.LocalTransparencyModifier = setto
                                        end
                                    end
                                end
                                v14_11_ = v14_8_.Name
                                if v14_11_ == "Head" then
                                    v14_8_.LocalTransparencyModifier = setto
                                else
                                    v14_11_ = 0
                                    v14_8_.LocalTransparencyModifier = setto
                                    v14_8_.LocalTransparencyModifier = setto
                                end
                            else
                                v14_8_.LocalTransparencyModifier = setto
                            end
                        else
                            v14_8_.LocalTransparencyModifier = setto
                        end
                    end
                    v14_5_ = false
                    a1.transparencyDirty = v14_5_
                    a1.lastTransparency = setto
                end
            end
            v14_5_ = pairs
            v14_6_ = a1.cachedParts
            v14_5_, v14_6_, v14_7_ = v14_5_(v14_6_)
            for v14_8_, v14_9_ in v14_5_, v14_6_, v14_7_ do
                local v14_11_ = v0_0_
                local v14_10_ = false
                if v14_10_ then
                    v14_11_ = v0_0_
                    v14_10_ = v14_11_.AvatarGestures
                    if v14_10_ then
                        v14_10_ = {}
                        local Hat = Enum.AccessoryType.Hat
                        local v14_12_ = true
                        v14_10_[Hat] = v14_12_
                        local Hair = Enum.AccessoryType.Hair
                        v14_12_ = true
                        v14_10_[Hair] = v14_12_
                        local Face = Enum.AccessoryType.Face
                        v14_12_ = true
                        v14_10_[Face] = v14_12_
                        local Eyebrow = Enum.AccessoryType.Eyebrow
                        v14_12_ = true
                        v14_10_[Eyebrow] = v14_12_
                        local Eyelash = Enum.AccessoryType.Eyelash
                        v14_12_ = true
                        v14_10_[Eyelash] = v14_12_
                        v14_11_ = v14_8_.Parent
                        local v14_13_ = "Accessory"
                        v14_11_ = v14_11_:IsA(v14_13_)
                        if v14_11_ then
                            v14_13_ = v14_8_.Parent
                            v14_12_ = v14_13_.AccessoryType
                            v14_11_ = v14_10_[v14_12_]
                            if not v14_11_ then
                                v14_11_ = v14_8_.Name
                                if v14_11_ == "Head" then
                                    v14_8_.LocalTransparencyModifier = setto
                                else
                                    v14_11_ = 0
                                    v14_8_.LocalTransparencyModifier = setto
                                    v14_8_.LocalTransparencyModifier = setto
                                end
                            end
                        end
                        v14_11_ = v14_8_.Name
                        if v14_11_ == "Head" then
                            v14_8_.LocalTransparencyModifier = setto
                        else
                            v14_11_ = 0
                            v14_8_.LocalTransparencyModifier = setto
                            v14_8_.LocalTransparencyModifier = setto
                        end
                    else
                        v14_8_.LocalTransparencyModifier = setto
                    end
                else
                    v14_8_.LocalTransparencyModifier = setto
                end
            end
            v14_5_ = false
            a1.transparencyDirty = v14_5_
            a1.lastTransparency = setto
        end
    end
end


--instant reload--
print("loading instant reload function")
instrelMODfunc = function(a1,a2)
    local function aaa(a1)
        local v27_2_ = a1.weapon
        local v27_1_ = v27_2_.Attachments
        local v27_3_ = "Magazine"
        v27_1_ = v27_1_:FindFirstChild(v27_3_)
        if v27_1_ then
            local v27_4_ = a1.weapon
            v27_3_ = v27_4_.Attachments
            v27_2_ = v27_3_.Magazine
            v27_2_ = v27_2_:GetChildren()
            v27_1_ = v27_2_[-1]
            if v27_1_ then
                v27_2_ = v27_1_.ItemProperties
                v27_4_ = "LoadedAmmo"
                v27_2_ = v27_2_:GetAttribute(v27_4_)
                a1.Bullets = v27_2_
                v27_2_ = {}
                a1.BulletsList = v27_2_
                v27_3_ = v27_1_.ItemProperties
                v27_2_ = v27_3_.LoadedAmmo
                v27_3_ = v27_2_:GetChildren()
                local v27_6_ = 1
                v27_4_ = #v27_3_
                local v27_5_ = 1
                for v27_6_ = v27_6_, v27_4_, v27_5_ do
                    local v27_7_ = a1.BulletsList
                    local v27_10_ = v27_3_[v27_6_]
                    local v27_9_ = v27_10_.Name
                    local v27_8_ = tonumber
                    v27_8_ = v27_8_(v27_9_)
                    v27_9_ = {}
                    v27_10_ = v27_3_[v27_6_]
                    local v27_12_ = "AmmoType"
                    v27_10_ = v27_10_:GetAttribute(v27_12_)
                    v27_9_.AmmoType = v27_10_
                    v27_10_ = v27_3_[v27_6_]
                    v27_12_ = "Amount"
                    v27_10_ = v27_10_:GetAttribute(v27_12_)
                    v27_9_.Amount = v27_10_
                    v27_7_[v27_8_] = v27_9_
                end
            end
            v27_2_ = 0
            a1.movementModifier = v27_2_
            v27_2_ = a1.weapon
            if v27_2_ then
                v27_2_ = a1.movementModifier
                local v27_6_ = a1.weapon
                local v27_5_ = v27_6_.ItemProperties
                v27_4_ = v27_5_.Tool
                v27_6_ = "MovementModifer"
                v27_4_ = v27_4_:GetAttribute(v27_6_)
                v27_3_ = v27_4_ or 0.000000
                v27_2_ += v27_3_
                a1.movementModifier = v27_2_
                v27_2_ = a1.weapon
                v27_4_ = "Attachments"
                v27_2_ = v27_2_:FindFirstChild(v27_4_)
                if v27_2_ then
                    v27_3_ = a1.weapon
                    v27_2_ = v27_3_.Attachments
                    v27_2_ = v27_2_:GetChildren()
                    v27_5_ = 1
                    v27_3_ = #v27_2_
                    v27_4_ = 1
                    for v27_5_ = v27_5_, v27_3_, v27_4_ do
                        v27_6_ = v27_2_[v27_5_]
                        local v27_8_ = "StringValue"
                        v27_6_ = v27_6_:FindFirstChildOfClass(v27_8_)
                        if v27_6_ then
                            local v27_7_ = v27_6_.ItemProperties
                            local v27_9_ = "Attachment"
                            v27_7_ = v27_7_:FindFirstChild(v27_9_)
                            if v27_7_ then
                                v27_7_ = a1.movementModifier
                                local v27_10_ = v27_6_.ItemProperties
                                v27_9_ = v27_10_.Attachment
                                local v27_11_ = "MovementModifer"
                                v27_9_ = v27_9_:GetAttribute(v27_11_)
                                v27_8_ = v27_9_ or 0.000000
                                v27_7_ += v27_8_
                                a1.movementModifier = v27_7_
                            end
                        end
                        return
                    end
                end
            end
        end
        v27_2_ = a1.weapon
        v27_1_ = v27_2_.ItemProperties
        v27_3_ = "LoadedAmmo"
        v27_1_ = v27_1_:GetAttribute(v27_3_)
        a1.Bullets = v27_1_
        v27_1_ = {}
        a1.BulletsList = v27_1_
        v27_3_ = a1.weapon
        v27_2_ = v27_3_.ItemProperties
        v27_1_ = v27_2_.LoadedAmmo
        v27_2_ = v27_1_:GetChildren()
        local v27_5_ = 1
        v27_3_ = #v27_2_
        local v27_4_ = 1
        for v27_5_ = v27_5_, v27_3_, v27_4_ do
            local v27_6_ = a1.BulletsList
            local v27_9_ = v27_2_[v27_5_]
            local v27_8_ = v27_9_.Name
            local v27_7_ = tonumber
            v27_7_ = v27_7_(v27_8_)
            v27_8_ = {}
            v27_9_ = v27_2_[v27_5_]
            local v27_11_ = "AmmoType"
            v27_9_ = v27_9_:GetAttribute(v27_11_)
            v27_8_.AmmoType = v27_9_
            v27_9_ = v27_2_[v27_5_]
            v27_11_ = "Amount"
            v27_9_ = v27_9_:GetAttribute(v27_11_)
            v27_8_.Amount = v27_9_
            v27_6_[v27_7_] = v27_8_
        end
    end
    local v103_2_ = a1.viewModel
    if v103_2_ then
        local v103_3_ = a1.viewModel
        v103_2_ = v103_3_.Item
        local v103_4_ = "AmmoTypes"
        v103_2_ = v103_2_:FindFirstChild(v103_4_)
        if v103_2_ then
            local v103_5_ = a1.weapon
            v103_4_ = v103_5_.ItemProperties
            v103_3_ = v103_4_.AmmoType
            v103_2_ = v103_3_.Value
            v103_5_ = a1.viewModel
            v103_4_ = v103_5_.Item
            v103_3_ = v103_4_.AmmoTypes
            v103_3_ = v103_3_:GetChildren()
            local v103_6_ = 1
            v103_4_ = #v103_3_
            v103_5_ = 1
            for v103_6_ = v103_6_, v103_4_, v103_5_ do
                local v103_7_ = v103_3_[v103_6_]
                local v103_8_ = 1
                v103_7_.Transparency = v103_8_
            end
            v103_6_ = a1.viewModel
            v103_5_ = v103_6_.Item
            v103_4_ = v103_5_.AmmoTypes
            v103_6_ = v103_2_
            v103_4_ = v103_4_:FindFirstChild(v103_6_)
            v103_5_ = 0
            v103_4_.Transparency = v103_5_
            v103_5_ = a1.viewModel
            v103_4_ = v103_5_.Item
            v103_6_ = "AmmoTypes2"
            v103_4_ = v103_4_:FindFirstChild(v103_6_)
            if v103_4_ then
                v103_6_ = a1.viewModel
                v103_5_ = v103_6_.Item
                v103_4_ = v103_5_.AmmoTypes2
                v103_4_ = v103_4_:GetChildren()
                local v103_7_ = 1
                v103_5_ = #v103_4_
                v103_6_ = 1
                for v103_7_ = v103_7_, v103_5_, v103_6_ do
                    local v103_8_ = v103_4_[v103_7_]
                    local v103_9_ = 1
                    v103_8_.Transparency = v103_9_
                end
                v103_7_ = a1.viewModel
                v103_6_ = v103_7_.Item
                v103_5_ = v103_6_.AmmoTypes2
                v103_7_ = v103_2_
                v103_5_ = v103_5_:FindFirstChild(v103_7_)
                v103_6_ = 0
                v103_5_.Transparency = v103_6_
            end
        end
        v103_2_ = a1.reloading
        if v103_2_ == false then
            v103_2_ = a1.cancellingReload
            if v103_2_ == false then
                v103_2_ = a1.MaxAmmo
                v103_3_ = 0
                if v103_3_ < v103_2_ then
                    v103_3_ = true
                    local v103_6_ = 1
                    local v103_7_ = a1.CancelTables
                    v103_4_ = #v103_7_
                    local v103_5_ = 1
                    for v103_6_ = v103_6_, v103_4_, v103_5_ do
                        local v103_9_ = a1.CancelTables
                        local v103_8_ = v103_9_[v103_6_]
                        v103_7_ = v103_8_.Visible
                        if v103_7_ == true then
                            v103_3_ = false
                        else
                        end
                    end
                    v103_2_ = v103_3_
                    if v103_2_ then
                        v103_3_ = a1.clientAnimationTracks
                        v103_2_ = v103_3_.Inspect
                        if v103_2_ then
                            v103_3_ = a1.clientAnimationTracks
                            v103_2_ = v103_3_.Inspect
                            v103_2_:Stop()
                            v103_3_ = a1.serverAnimationTracks
                            v103_2_ = v103_3_.Inspect
                            v103_2_:Stop()
                            v103_4_ = a1.WeldedTool
                            v103_3_ = v103_4_.ItemRoot
                            v103_2_ = v103_3_.Sounds.Inspect
                            v103_2_:Stop()
                        end
                        v103_3_ = a1.settings
                        v103_2_ = v103_3_.AimWhileActing
                        if not v103_2_ then
                            v103_2_ = a1.isAiming
                            if v103_2_ then
                                v103_4_ = false
                                a1:aim(v103_4_)
                            end
                        end
                        
                        if a1.reloadType == "loadByHand" then
                            local count = a1.Bullets
                            local maxcount = a1.MaxAmmo

                            for i=count, maxcount do 
                                game.ReplicatedStorage.Remotes.Reload:InvokeServer(nil, 0.001, nil)
                            end

                            aaa(a1)
                        else
                            game.ReplicatedStorage.Remotes.Reload:InvokeServer(nil, 0.001, nil)

                            require(game.ReplicatedStorage.Modules.FPS).equip(a1, a1.weapon, nil)

                            aaa(a1)
                        end      
                    end
                end
            end
        end
    end
end

--instant lean--
print("loading instant lean functions")
instantleanMODfunc = function(a1,a2,a3)
    --a1 = player table 
    if a2 == 0 then 
        if a1.lean == 0 then return end
    end
    carv_9X7Z = a1.rs_Vehicle.CurrentSeat.Value
    if carv_9X7Z then 
        if a1.lean == 0 then return end
    end
    if a1.humanoid:GetState() == Enum.HumanoidStateType.Swimming then 
        if a1.lean == 0 then return end
    end
    if a1.sprinting == true then 
        if a1.lean == 0 then return end
    end
    
    if a2 == a1.lean then 
        a1.lean = 0
    else 
        a1.lean = a2
    end
    
    springs_R2D2 = a1.springs
    lalpha_C3PO = springs_R2D2.leanAlpha
    springs_R2D2.leanAlpha.Speed = 15
    currentlean_BB8 = a1.lean
    vectorposidk_VADER = Vector3.new(-currentlean_BB8, 0,0)
    lalpha_C3PO.Target = vectorposidk_VADER
    valuetoserver_YODA = nil
    
    if lalpha_C3PO.Target.X == 1 then 
        valuetoserver_YODA = true
    elseif lalpha_C3PO.Target.X == -1 then
        valuetoserver_YODA = false
    end

    game.ReplicatedStorage.Remotes.UpdateLeaning:FireServer(valuetoserver_YODA)
end
instantleanOGfunc = function(a1,a2,a3)
    --a1 = player table 
    if a2 == 0 then 
        if a1.lean == 0 then return end
    end
    carv_9X7Z = a1.rs_Vehicle.CurrentSeat.Value
    if carv_9X7Z then 
        if a1.lean == 0 then return end
    end
    if a1.humanoid:GetState() == Enum.HumanoidStateType.Swimming then 
        if a1.lean == 0 then return end
    end
    if a1.sprinting == true then 
        if a1.lean == 0 then return end
    end
    
    if a2 == a1.lean then 
        a1.lean = 0
    else 
        a1.lean = a2
    end
    
    springs_R2D2 = a1.springs
    lalpha_C3PO = springs_R2D2.leanAlpha
    springs_R2D2.leanAlpha.Speed = 5
    currentlean_BB8 = a1.lean
    vectorposidk_VADER = Vector3.new(-currentlean_BB8, 0,0)
    lalpha_C3PO.Target = vectorposidk_VADER
    valuetoserver_YODA = nil
    
    if lalpha_C3PO.Target.X == 1 then 
        valuetoserver_YODA = true
    elseif lalpha_C3PO.Target.X == -1 then
        valuetoserver_YODA = false
    end

    game.ReplicatedStorage.Remotes.UpdateLeaning:FireServer(valuetoserver_YODA)
end


--hitsound-- hitsound method by ds: _hai_hai
print("loading hitsound")
localplayer.CharacterAdded:Connect(function(lchar)
    if localplayer.PlayerGui:WaitForChild("MainGui") then
        localplayer.PlayerGui.MainGui.ChildAdded:Connect(function(Sound)
            if Sound:IsA("Sound") and allvars.hitsoundbool then
                if Sound.SoundId == "rbxassetid://4585351098" or Sound.SoundId == "rbxassetid://4585382589" then --headshot
                    Sound.SoundId = hitsoundlib[allvars.hitsoundhead]
                elseif Sound.SoundId == "rbxassetid://4585382046" or Sound.SoundId == "rbxassetid://4585364605" then --bodyshot
                    Sound.SoundId = hitsoundlib[allvars.hitsoundbody]
                end
            end
        end)
    end
end)
localplayer.PlayerGui.MainGui.ChildAdded:Connect(function(Sound)
    if Sound:IsA("Sound") and allvars.hitsoundbool then
        if Sound.SoundId == "rbxassetid://4585351098" or Sound.SoundId == "rbxassetid://4585382589" then --headshot
            Sound.SoundId = hitsoundlib[allvars.hitsoundhead]
        elseif Sound.SoundId == "rbxassetid://4585382046" or Sound.SoundId == "rbxassetid://4585364605" then --bodyshot
            Sound.SoundId = hitsoundlib[allvars.hitsoundbody]
        end
    end
end)


--esp map--
print("loading espmap function")
handleESPMAP = function(bool)
    if bool then
        map = game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.MainFrame.Maps.EstonianBorderMap
        mapFrame = game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.MainFrame
        mapFrame.Size = UDim2.fromScale(1, 1)
        mapFrame.Position = UDim2.new(0.5, 0, 0.49, 0)

        mapFrame.Parent.Visible = true
        game.UserInputService.MouseIconEnabled = true
        game.Players.LocalPlayer.PlayerGui.MainGui.ModalButton.Modal = true

        for _,v in pairs(mapFrame.Markers:GetChildren()) do
            v:Destroy()
        end

        selfMarker = game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.MainFrame.MarkerDotTemplate:Clone()
        selfMarker.Name = "SelfMarker"
        selfMarker.Visible = true
        selfMarker.Parent = game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.MainFrame.Markers
        selfMarker.TextLabel.Visible = true
        espmapmarkers.Me = {
            playerRef = game.Players.LocalPlayer,
            markerRef = selfMarker,
        }

        for _,v in pairs(game.Players:GetChildren()) do
            if v ~= localplayer then
                plrMarker = game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.MainFrame.MarkerDotTemplate:Clone()
                plrMarker.ImageColor3 = Color3.fromRGB(227, 36, 36)
                plrMarker.Name = "TeamMarker"
                plrMarker.Visible = true
                plrMarker.TextLabel.Text = v.Name
                plrMarker.TextLabel.Visible = true
                plrMarker.TextLabel.RichText = false
                plrMarker.TextLabel.Size = UDim2.fromScale(3, 0.5)
                plrMarker.TextLabel.Position = UDim2.fromScale(-1, 0)
                plrMarker.Parent = game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.MainFrame.Markers
                espmapmarkers[v.Name] = {
                    playerRef = v,
                    markerRef = plrMarker,
                }

                plrMarker.MouseMoved:Connect(function()
                    espmaptarget = v
                end)
                plrMarker.MouseLeave:Connect(function()
                    espmaptarget = nil
                end)
            end
        end
        
        task.spawn(function()
            while task.wait(0.1) do
                if espmapactive == false then return end

                for ind, markerData in espmapmarkers do
                    if markerData.markerRef == nil then
                        table.remove(espmapmarkers, ind)
                    else
                        local playerRef = markerData.playerRef
                        if playerRef then
                            local character = playerRef.Character
                            if character then
                                local chpos = game.ReplicatedStorage.Players:FindFirstChild(playerRef.Name).Status.UAC:GetAttribute("LastVerifiedPos")
                                local xPos = (chpos.X - 208) / map:GetAttribute("SizeReal")
                                local zPos = (chpos.Z + 203) / map:GetAttribute("SizeReal")
                                markerData.markerRef.Position = UDim2.new(0.5 + xPos, 0, 0.5 + zPos, 0)
                                markerData.markerRef.Visible = true
                                if markerData.playerRef ~= localplayer then 
                                    if table.find(allvars.aimFRIENDLIST, markerData.playerRef.Name) ~= nil then
                                        markerData.markerRef.ImageColor3 = Color3.fromRGB(102, 245, 66)
                                    else
                                        markerData.markerRef.ImageColor3 = Color3.fromRGB(227, 36, 36)
                                    end
                                end
                            else
                                markerData.markerRef.Visible = false
                            end
                        end
                    end
                end
            end
        end)

        mapFrame.Markers.Visible = true
    else
        if game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.Visible == true then
            game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.Visible = false
            game.Players.LocalPlayer.PlayerGui.MainGui.ModalButton.Modal = false
            game.UserInputService.MouseIconEnabled = false
        end
    end
end


-- semi fly --
print("loading semifly functions")
function fly_move(dir)
    local hrp = localplayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

	local newPos = hrp.CFrame + (dir * 1)
	hrp.CFrame = newPos
end
function fly_getclosestpoint()
    local hrp = localplayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

	local dirs = {
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 0),
        Vector3.new(0, 1, 0),
        Vector3.new(0, -1, 0),
        Vector3.new(0, 0, 1),
        Vector3.new(0, 0, -1),
        Vector3.new(1, 1, 0),
        Vector3.new(1, -1, 0),
        Vector3.new(-1, 1, 0),
        Vector3.new(-1, -1, 0),
        Vector3.new(1, 0, 1),
        Vector3.new(1, 0, -1),
        Vector3.new(-1, 0, 1),
        Vector3.new(-1, 0, -1),
        Vector3.new(0, 1, 1),
        Vector3.new(0, 1, -1),
        Vector3.new(0, -1, 1),
        Vector3.new(0, -1, -1),
        Vector3.new(1, 1, 1),
        Vector3.new(1, 1, -1),
        Vector3.new(1, -1, 1),
        Vector3.new(1, -1, -1),
        Vector3.new(-1, 1, 1),
        Vector3.new(-1, 1, -1),
        Vector3.new(-1, -1, 1),
        Vector3.new(-1, -1, -1)
    }

	local fcp = nil
	local cd = math.huge

    local ignorl = {localplayer.Character, wcamera}

    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            table.insert(ignorl, player.Character)
        end
    end

	for _, dir in pairs(dirs) do
		local ray = Ray.new(hrp.Position, dir * 200)
		local part, pos = workspace:FindPartOnRayWithIgnoreList(ray, ignorl)
		if part and pos then
			local d = (hrp.Position - pos).Magnitude
			if d < cd then
				cd = d
				fcp = pos
			end
		end
	end

	return fcp
end
function fly_getoffset(dir)
	local offset = Vector3.new(0.1, 0.1, 0.1)
	if dir.X > 0 then
		offset = Vector3.new(0.1, 0, 0)
	elseif dir.X < 0 then
		offset = Vector3.new(-0.1, 0, 0)
	elseif dir.Y > 0 then
		offset = Vector3.new(0, 0.1, 0)
	elseif dir.Y < 0 then
		offset = Vector3.new(0, -0.1, 0)
	elseif dir.Z > 0 then
		offset = Vector3.new(0, 0, 0.1)
	elseif dir.Z < 0 then
		offset = Vector3.new(0, 0, -0.1)
	end
	return offset
end

--anticheat bypass--
print("loading client anticheat bypass")  --method by discord.gg/exothium
function handleClientAntiCheatBypass()
    if ACBYPASS_SYNC == true then return end

    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local Method = getnamecallmethod()
        local Args = {...}
        if Method == "FireServer" and self.Name == "ProjectileInflict" then
            if Args[1] == game.Players.LocalPlayer.Character.PrimaryPart then
                return coroutine.yield()
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)

    ACBYPASS_SYNC = true
end
handleClientAntiCheatBypass()


--thirdperson fix + desync camera fix--
local mt = getrawmetatable(game)
local oldIndex = mt.__newindex
setreadonly(mt, false)
mt.__newindex = newcclosure(function(self, index, value)
    if tostring(self) == "Humanoid" and index == "CameraOffset" then
        local offset = Vector3.zero

        if allvars.desyncbool then
            if allvars.desyncPos then
                offset += Vector3.new(-allvars.desynXp, -allvars.desynYp, -allvars.desynZp)
            end
            if allvars.desyncOr then
                -- to make
            end
        end

        if allvars.camthirdp then
            offset += Vector3.new(allvars.camthirdpX, allvars.camthirdpY, allvars.camthirdpZ)
        end

        return oldIndex(self, index, offset)
    end
    return oldIndex(self, index, value)
end)
setreadonly(mt, true)


--double jump--
uis.JumpRequest:Connect(function()
    if not allvars.doublejump then return end
    
    local ctime = tick()
    if ctime - dbjumplast < dbjumpdelay then return end
    
    local state = localplayer.Character.Humanoid:GetState()
    if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
        if candbjump then
            localplayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            candbjump = false
            dbjumplast = ctime
        end
    end
end)
localplayer.Character.Humanoid.StateChanged:Connect(function(_, state)
    if not allvars.doublejump then return end
    
    if state == Enum.HumanoidStateType.Jumping then
        candbjump = true
        dbjumplast = tick()
    elseif state == Enum.HumanoidStateType.Landed then
        candbjump = false
    end
end)
localplayer.CharacterAdded:Connect(function()
    task.wait(1.5)

    localplayer.Character.Humanoid.StateChanged:Connect(function(_, state)
        if not allvars.doublejump then return end
        
        if state == Enum.HumanoidStateType.Jumping then
            candbjump = true
            dbjumplast = tick()
        elseif state == Enum.HumanoidStateType.Landed then
            candbjump = false
        end
    end)
end)


--player logs--
game.Players.PlayerAdded:Connect(function(plr)
    if joindetect then
        Library:Notify(plr.Name .. " joined this server", 3, Color3.fromRGB(0,255,0))
    end
end)
game.Players.PlayerRemoving:Connect(function(plr)
    if leavedetect then
        Library:Notify(plr.Name .. " left this server", 3, Color3.fromRGB(255,0,0))
    end
end)


--melee force hit--
local mt = getrawmetatable(game)
local oldNamecall2 = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local Method = getnamecallmethod()
    local args = {...}
    if Method == "FireServer" and self.Name == "MeleeInflict" then
        if malwayspower then
            args[3] = "PowerAttack"
        end
        return oldNamecall2(self, table.unpack(args))
    end
    return oldNamecall2(self, ...)
end)
setreadonly(mt, true)
local meleeray
meleeray = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not mforcehit then return meleeray(self, ...) end

    if method == "Raycast" and aimtargetpart ~= nil and debug.getinfo(5, "f").short_src == "ReplicatedStorage.Modules.FPS.Melee" then
        local tpart = aimtargetpart
        local tchar = tpart.Parent
        local npart = tchar:FindFirstChild(mhitpart)
        if not npart then return meleeray(self, ...) end
        if (npart.Position - localplayer.Character.Head.Position).Magnitude > 11 then return meleeray(self, ...) end
        
        return {
            Instance = npart,
            Position = npart.Position,
            Normal = Vector3.new(1, 0, 0),
            Material = npart.Material,
            Distance = (npart.Position - localplayer.Character.Head.Position).Magnitude
        }
    end

    return meleeray(self, ...)
end)




--upangle editor--
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if Method == "FireServer" and self.Name == "UpdateTilt" then
        if allvars.upanglebool then
            Args[1] = allvars.upanglenum
            return oldNamecall(self, table.unpack(Args))
        elseif allvars.invisbool and allvars.desyncbool then
            Args[1] = 0.75
            return oldNamecall(self, table.unpack(Args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)



localplayer.CharacterAdded:Connect(function() --set characterspawned
    characterspawned = tick()
end)


--fps table editor--
print("loading fps table editor")
do
    local mod = require(game.ReplicatedStorage.Modules.FPS)
    local ogfunc = mod.updateClient

    mod.updateClient = function(a1,a2,a3)
        arg1, arg2, arg3 = ogfunc(a1,a2,a3)
        
        a1table = a1

        if nojumptilt then
            a1.springs.jumpCameraTilt.Position = Vector3.new(0,0,0)
        end
        if allvars.noswaybool then
            a1.springs.sway.Position = Vector3.new(0,0,0)
            a1.springs.walkCycle.Position = Vector3.new(0,0,0)
            a1.springs.sprintCycle.Position = Vector3.new(0,0,0)
            a1.springs.strafeTilt.Position = Vector3.new(0,0,0)
            a1.springs.jumpTilt.Position = Vector3.new(0,0,0)
            a1.springs.sway.Speed = 0
            a1.springs.walkCycle.Speed = 0
            a1.springs.sprintCycle.Speed = 0
            a1.springs.strafeTilt.Speed = 0
            a1.springs.jumpTilt.Speed = 0
        else
            a1.springs.sway.Speed = 4
            a1.springs.walkCycle.Speed = 4
            a1.springs.sprintCycle.Speed = 4
            a1.springs.strafeTilt.Speed = 4
            a1.springs.jumpTilt.Speed = 4
        end
        if allvars.viewmodoffset then
            a1.sprintIdleOffset = CFrame.new(Vector3.new(allvars.viewmodX, allvars.viewmodY, allvars.viewmodZ))
            a1.weaponOffset = CFrame.new(Vector3.new(allvars.viewmodX, allvars.viewmodY, allvars.viewmodZ))
            a1.AimInSpeed = 9e9
        else
            a1.AimInSpeed = 0.4
        end

        return arg1, arg2, arg3
    end
end


--skin changer--
print("loading skinchanger")
function createskinchangergui()
    local a=Instance.new"Frame"
    a.Name="SkinMain"
    a.AnchorPoint=Vector2.new(0,0.5)
    a.Size=UDim2.new(0.193,0,0.478,0)
    a.BorderColor3=Color3.fromRGB(0,0,0)
    a.Position=UDim2.new(0.709,0,0.499,0)
    a.BorderSizePixel=0
    a.BackgroundColor3=Color3.fromRGB(35,35,35)
    local b=Instance.new"Frame"
    b.Name="Title"
    b.ZIndex=0
    b.Size=UDim2.new(0.9995077,0,0.0345098,0)
    b.BorderColor3=Color3.fromRGB(0,0,0)
    b.BackgroundTransparency=0.8
    b.Position=UDim2.new(3e-07,0,0,0)
    b.BorderSizePixel=0
    b.BackgroundColor3=Color3.fromRGB(0,0,0)
    b.Parent=a
    local c=Instance.new"TextLabel"
    c.Name="Label"
    c.Size=UDim2.new(1,0,0.8636364,0)
    c.BorderColor3=Color3.fromRGB(0,0,0)
    c.BackgroundTransparency=1
    c.Position=UDim2.new(0,0,0.0950089,0)
    c.BorderSizePixel=0
    c.BackgroundColor3=Color3.fromRGB(255,255,255)
    c.FontSize=5
    c.TextSize=14
    c.TextColor3=Color3.fromRGB(255,255,255)
    c.Text="Skin Changer v0.15"
    c.TextWrapped=true
    c.TextWrap=true
    c.Font=100
    c.TextScaled=true
    c.Parent=b
    local d=Instance.new"Frame"
    d.Name="Guns"
    d.Size=UDim2.new(0.9502814,0,0.4,0)
    d.BorderColor3=Color3.fromRGB(0,0,0)
    d.BackgroundTransparency=0.85
    d.Position=UDim2.new(0.0235427,0,0.0972549,0)
    d.BorderSizePixel=0
    d.BackgroundColor3=Color3.fromRGB(0,0,0)
    d.Parent=a
    local e=Instance.new"ScrollingFrame"
    e.Name="Bar"
    e.Size=UDim2.new(0.9414414,0,0.9058824,0)
    e.BorderColor3=Color3.fromRGB(0,0,0)
    e.BackgroundTransparency=1
    e.Position=UDim2.new(0.0292793,0,0.0509804,0)
    e.Active=true
    e.BorderSizePixel=0
    e.BackgroundColor3=Color3.fromRGB(255,255,255)
    e.ScrollingDirection=2
    e.CanvasSize=UDim2.new(0,0,1,0)
    e.ScrollBarThickness=3
    e.Parent=d
    local f=Instance.new"UIListLayout"
    f.SortOrder=2
    f.Wraps=true
    f.HorizontalFlex=1
    f.VerticalFlex=1
    f.Padding=UDim.new(0.03,0)
    f.Parent=e
    local g=Instance.new"UIStroke"
    g.ApplyStrokeMode=1
    g.LineJoinMode=2
    g.Thickness=2.3
    g.Color=Color3.fromRGB(40,40,40)
    g.Parent=d
    local h=Instance.new"TextLabel"
    h.Name="GunsLabel"
    h.Size=UDim2.new(0.8946342,0,0.0407843,0)
    h.BorderColor3=Color3.fromRGB(0,0,0)
    h.BackgroundTransparency=1
    h.Position=UDim2.new(0.0513673,0,0.0454902,0)
    h.BorderSizePixel=0
    h.BackgroundColor3=Color3.fromRGB(255,255,255)
    h.FontSize=5
    h.TextSize=14
    h.TextColor3=Color3.fromRGB(255,255,255)
    h.Text="Your guns : "
    h.TextWrapped=true
    h.TextWrap=true
    h.TextScaled=true
    h.Parent=a
    local i=Instance.new"Frame"
    i.Name="Skins"
    i.Size=UDim2.new(0.9502814,0,0.4188235,0)
    i.BorderColor3=Color3.fromRGB(0,0,0)
    i.BackgroundTransparency=0.85
    i.Position=UDim2.new(0.0235427,0,0.5631372,0)
    i.BorderSizePixel=0
    i.BackgroundColor3=Color3.fromRGB(0,0,0)
    i.Parent=a
    local j=Instance.new"ScrollingFrame"
    j.Name="Bar"
    j.Size=UDim2.new(0.9414414,0,0.9058824,0)
    j.BorderColor3=Color3.fromRGB(0,0,0)
    j.BackgroundTransparency=1
    j.Position=UDim2.new(0.0292793,0,0.0509804,0)
    j.Active=true
    j.BorderSizePixel=0
    j.BackgroundColor3=Color3.fromRGB(255,255,255)
    j.ScrollingDirection=2
    j.CanvasSize=UDim2.new(0,0,2.5,0)
    j.ScrollBarThickness=3
    j.Parent=i
    local k=Instance.new"UIListLayout"
    k.SortOrder=2
    k.Wraps=true
    k.HorizontalFlex=1
    k.VerticalFlex=1
    k.Padding=UDim.new(0.005,0)
    k.Parent=j
    local l=Instance.new"UIStroke"
    l.ApplyStrokeMode=1
    l.LineJoinMode=2
    l.Thickness=2.3
    l.Color=Color3.fromRGB(40,40,40)
    l.Parent=i
    local m=Instance.new"TextLabel"
    m.Name="SkinsLabel"
    m.Size=UDim2.new(0.8946342,0,0.0407843,0)
    m.BorderColor3=Color3.fromRGB(0,0,0)
    m.BackgroundTransparency=1
    m.Position=UDim2.new(0.0513673,0,0.5129412,0)
    m.BorderSizePixel=0
    m.BackgroundColor3=Color3.fromRGB(255,255,255)
    m.FontSize=5
    m.TextSize=14
    m.TextColor3=Color3.fromRGB(255,255,255)
    m.Text="Available skins (For None) : "
    m.TextWrapped=true
    m.TextWrap=true
    m.TextScaled=true
    m.Parent=a
    local n=Instance.new"UIStroke"
    n.ApplyStrokeMode=1
    n.LineJoinMode=2
    n.Thickness=2.0999999
    n.Color=Color3.fromRGB(54,162,229)
    n.Parent=a
    local o=Instance.new"Configuration"
    o.Name="Templates"
    o.Parent=a
    local p=Instance.new"Frame"
    p.Name="SkinTemplate"
    p.Size=UDim2.new(0,411,0,55)
    p.BorderColor3=Color3.fromRGB(0,0,0)
    p.BorderSizePixel=0
    p.BackgroundColor3=Color3.fromRGB(44,44,44)
    p.Parent=o
    local q=Instance.new"TextLabel"
    q.Name="SkinName"
    q.Size=UDim2.new(0.5425791,0,0.6363636,0)
    q.BorderColor3=Color3.fromRGB(0,0,0)
    q.BackgroundTransparency=1
    q.Position=UDim2.new(0.0358852,0,0.1794467,0)
    q.BorderSizePixel=0
    q.BackgroundColor3=Color3.fromRGB(255,255,255)
    q.FontSize=5
    q.TextStrokeTransparency=0
    q.TextSize=14
    q.RichText=true
    q.TextColor3=Color3.fromRGB(255,255,255)
    q.Text="TFZ98"
    q.TextWrapped=true
    q.TextWrap=true
    q.TextXAlignment=0
    q.TextScaled=true
    q.Parent=p
    local r=Instance.new"TextButton"
    r.Name="Set"
    r.Size=UDim2.new(0.377129,0,0.6363636,0)
    r.BorderColor3=Color3.fromRGB(0,0,0)
    r.Position=UDim2.new(0.5926771,0,0.1794467,0)
    r.BorderSizePixel=0
    r.BackgroundColor3=Color3.fromRGB(135,255,92)
    r.FontSize=5
    r.TextStrokeTransparency=0.44
    r.TextSize=14
    r.RichText=true
    r.TextColor3=Color3.fromRGB(255,255,255)
    r.Text="Set"
    r.TextWrapped=true
    r.TextWrap=true
    r.Font=100
    r.TextScaled=true
    r.Parent=p
    local s=Instance.new"UIStroke"
    s.ApplyStrokeMode=1
    s.LineJoinMode=2
    s.Thickness=2.3
    s.Color=Color3.fromRGB(93,144,71)
    s.Parent=r
    local t=Instance.new"UIAspectRatioConstraint"
    t.AspectRatio=7.3200002
    t.DominantAxis=1
    t.Parent=p
    local u=Instance.new"UIStroke"
    u.ApplyStrokeMode=1
    u.LineJoinMode=2
    u.Thickness=2.3
    u.Color=Color3.fromRGB(27,27,27)
    u.Parent=p
    local v=Instance.new"Frame"
    v.Name="GunTemplate"
    v.Size=UDim2.new(0,411,0,55)
    v.BorderColor3=Color3.fromRGB(0,0,0)
    v.BorderSizePixel=0
    v.BackgroundColor3=Color3.fromRGB(44,44,44)
    v.Parent=o
    local w=Instance.new"TextLabel"
    w.Name="GunName"
    w.Size=UDim2.new(0.5425791,0,0.6363636,0)
    w.BorderColor3=Color3.fromRGB(0,0,0)
    w.BackgroundTransparency=1
    w.Position=UDim2.new(0.0358852,0,0.1794467,0)
    w.BorderSizePixel=0
    w.BackgroundColor3=Color3.fromRGB(255,255,255)
    w.FontSize=5
    w.TextStrokeTransparency=0
    w.TextSize=14
    w.RichText=true
    w.TextColor3=Color3.fromRGB(255,255,255)
    w.Text="TFZ98"
    w.TextWrapped=true
    w.TextWrap=true
    w.TextXAlignment=0
    w.TextScaled=true
    w.Parent=v
    local x=Instance.new"TextButton"
    x.Name="Select"
    x.Size=UDim2.new(0.377129,0,0.6363636,0)
    x.BorderColor3=Color3.fromRGB(0,0,0)
    x.Position=UDim2.new(0.5926771,0,0.1794467,0)
    x.BorderSizePixel=0
    x.BackgroundColor3=Color3.fromRGB(135,255,92)
    x.FontSize=5
    x.TextStrokeTransparency=0.44
    x.TextSize=14
    x.RichText=true
    x.TextColor3=Color3.fromRGB(255,255,255)
    x.Text="Select"
    x.TextWrapped=true
    x.TextWrap=true
    x.Font=100
    x.TextScaled=true
    x.Parent=v
    local y=Instance.new"UIStroke"
    y.ApplyStrokeMode=1
    y.LineJoinMode=2
    y.Thickness=2.3
    y.Color=Color3.fromRGB(93,144,71)
    y.Parent=x
    local z=Instance.new"UIAspectRatioConstraint"
    z.AspectRatio=7.3200002
    z.DominantAxis=1
    z.Parent=v
    local A=Instance.new"UIStroke"
    A.ApplyStrokeMode=1
    A.LineJoinMode=2
    A.Thickness=2.3
    A.Color=Color3.fromRGB(27,27,27)    
    return a
end
function sc_setskin(skin)
    if scselected.ItemProperties:GetAttribute("CallSign") == "DV-2" and typeof(skin) == "string" then
        skin = game.ReplicatedStorage.ItemsList:FindFirstChild(skin)
        scselected.Name = skin.Name
        scselected.ItemProperties:SetAttribute("OffsetFP", skin.ItemProperties:GetAttribute("OffsetFP"))
        require(scselected.SettingsModule).Animations.FirstPerson = require(skin.SettingsModule).Animations.FirstPerson
        return
    end

    local gun = scselected
    gun.ItemProperties:SetAttribute("Skin", skin.Name)

    for _,att in pairs(gun.Attachments:GetDescendants()) do
        if att:IsA("StringValue") and att:FindFirstChild("ItemProperties") then
            att.ItemProperties:SetAttribute("Skin", skin.Name)
        end
    end
end
function sc_additem(gui, obj, itemtype)
    if itemtype == "Skin" then
        if typeof(obj) == "string" then
            local temp = gui.Templates.SkinTemplate:Clone()
            temp.Name = obj
            temp.SkinName.Text = obj
            temp.Parent = gui.Skins.Bar
            temp.Set.Activated:Connect(function()
                sc_setskin(obj)
                Library:Notify("Set knife skin to " .. obj, 3)
            end)
            return
        end

        local temp = gui.Templates.SkinTemplate:Clone()
        temp.Name = obj.Name
        temp.SkinName.Text = obj.name
        temp.Parent = gui.Skins.Bar
        temp.Set.Activated:Connect(function()
            sc_setskin(obj)
            Library:Notify("Set " .. scselected.Name .. " skin to " .. obj.Name, 3)
        end)
    elseif obj ~= "Knife" then
        local temp = gui.Templates.GunTemplate:Clone()
        temp.Name = obj.Name
        temp.GunName.Text = obj.name
        temp.Parent = gui.Guns.Bar
        temp.Select.Activated:Connect(function()
            scselected = obj
            sc_loadskins(gui, obj)
        end)
    else
        local temp = gui.Templates.GunTemplate:Clone()
        temp.Name = "Knife"
        temp.GunName.Text = "Knife"
        temp.Parent = gui.Guns.Bar
        temp.Select.Activated:Connect(function()
            for i,v in game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Equipment:GetChildren() do
                if v.ItemProperties:GetAttribute("CallSign") == "DV-2" then
                    scselected = v
                    break
                end
            end
            if scselected.ItemProperties:GetAttribute("CallSign") == "DV-2" then
                sc_loadskins(gui, obj)
            end
        end)
    end
end
function sc_removeitem(gui, gunname)
    if scselected ~= nil and scselected.Name == gunname then
        scselected = nil
        sc_clearskins(gui)
    end
    local gunitem = gui.Guns.Bar:FindFirstChild(gunname)
    if gunitem then
        gunitem:Destroy()
    end
end
function sc_clearskins(gui)
    for _,delet in pairs(gui.Skins.Bar:GetChildren()) do
        if delet:IsA("Frame") then  
            delet:Destroy()
        end
    end
end
function sc_loadskins(gui, gun)
    sc_clearskins(gui)

    if gun == "Knife" then 
        local knifeskins = {
            "DV2",
            "AnarchyTomahawk",
            "PlasmaNinjato",
            "IceAxe",
            "IceDagger",
            "Karambit",
            "Cutlass",
            "Longsword",
            "Scythe",
        }
        for i,v in knifeskins do
            sc_additem(gui, v, "Skin")
        end
        return
    end

    local skinsfold = game.ReplicatedStorage.Skins:FindFirstChild(gun.Name)
    if skinsfold then
        for _, skin in pairs(skinsfold:GetChildren()) do
            sc_additem(gui, skin, "Skin")
        end
    end
end
function skinchangerhandler()
    local skingui = createskinchangergui()
    skingui.Visible = false
    skingui.Parent = Library.ScreenGui
    scgui = skingui

    for _,gun in pairs(game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Inventory:GetChildren()) do
        sc_additem(skingui, gun, "Gun")
    end
    sc_additem(skingui, "Knife", "Gun")

    game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Inventory.ChildAdded:Connect(function(child)
        sc_additem(skingui, child, "Gun")
    end)
    game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Inventory.ChildRemoved:Connect(function(child)
        sc_removeitem(skingui, child.Name)
    end)
end
skinchangerhandler()


--viewmodel changer--
function handleViewModel()
    if allvars.viewmodbool and wcamera:FindFirstChild("ViewModel") then
        for _, obj in pairs(wcamera.ViewModel:GetDescendants()) do
            if obj:IsA("BasePart") then
                if not obj:FindFirstAncestor("Item") then
                    local mb = obj:FindFirstChildOfClass("SurfaceAppearance")
                    if mb then
                        mb:Destroy()
                    end

                    obj.Color = allvars.viewmodhandcolor
                    obj.Material = allvars.viewmodhandmat
                else
                    local mb = obj:FindFirstChildOfClass("SurfaceAppearance")
                    if mb then
                        mb:Destroy()
                    end

                    obj.Color = allvars.viewmodguncolor
                    obj.Material = allvars.viewmodgunmat
                end
            elseif obj:IsA("Model") and obj:FindFirstChild("LL") then
                obj:Destroy()
            end
        end
    end
end
wcamera.ChildAdded:Connect(function(ch)
    if ch:IsA("Model") and ch.Name == "ViewModel" then
        task.wait(0.05)
        handleViewModel()
    end
end)

--global cycle--
print("loading global cycles")

task.spawn(function() -- very slow
    while wait(10.5) do
        table.clear(aimignoreparts)
        for i,v in pairs(workspace:GetDescendants()) do
            if v:GetAttribute("PassThrough") then
                table.insert(aimignoreparts, v)
            elseif allvars.worldnomines and v.Name == "PMN2" and v:IsA("Model") then
                v:Destroy()
            end
        end
    end
end)

task.spawn(function() -- slow
    while wait(1) do
        invchecktext.Position = Vector2.new(30, (wcamera.ViewportSize.Y / 2) - 360) --on screen stuff

        if scselected ~= nil and scgui ~= nil then
            scgui.SkinsLabel.Text = "Available skins (For ".. scselected.Name.." ) : "
        else
            scgui.SkinsLabel.Text = "Available skins (For None) : "
        end

        local function handleModDetect()
            if allvars.detectmods then
                for _, player in pairs(game.Players:GetPlayers()) do
                    if detectedmods[player.Name] ~= nil then continue end

                    local pinfo = game.ReplicatedStorage.Players:FindFirstChild(player.Name)
                    if not pinfo then continue end
                    local status = pinfo:FindFirstChild("Status")
                    if not status then continue end
                    if not status:FindFirstChild("UAC") then continue end
                    if not status:FindFirstChild("GameplayVariables") then continue end

                    local function detectmod(plrname, reason)
                        detectedmods[plrname] = true
                        if mdetect == true then return end
                        mdetect = true

                        Library:Notify("Mod Detected, reason : ".. reason.. ", moderator : "..plrname, 60)
                        local notsound = Instance.new("Sound")
                        notsound.SoundId = "rbxassetid://1841354443"
                        notsound.Parent = workspace
                        notsound:Play()
                        
                        allvars.espexit = true
                        safesetvalue(false, Toggles.Extract)
                        Library:Notify("Extract ESP Enabled due to moderator", 4)
                    end

                    if status.UAC:GetAttribute("Enabled") == true then
                        detectmod(player.Name, "uac enabled")
                        continue
                    elseif status.GameplayVariables:GetAttribute("Godmode") == true then
                        detectmod(player.Name, "godmode enabled")
                        continue
                    elseif status.GameplayVariables:GetAttribute("PremiumLevel") >= 4 then
                        detectmod(player.Name, "premium level >= 4")
                        continue
                    elseif status.UAC:GetAttribute("A1Detected") == true then
                        detectmod(player.Name, "A1Detected")
                        continue
                    elseif status.UAC:GetAttribute("A2Detected") == true then
                        detectmod(player.Name, "A2Detected")
                        continue
                    elseif status.UAC:GetAttribute("A3Detected") == true then
                        detectmod(player.Name, "A3Detected")
                        continue
                    end
                end
            end
        end

        local function handleAntiMask()
            if allvars.antimaskbool == true then
                game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.HelmetMask.TitanShield.Size = UDim2.new(0,0,1,0)
                game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Mask.GP5.Size = UDim2.new(0,0,1,0)
                for i,v in pairs(game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Visor:GetChildren()) do
                    v.Size = UDim2.new(0,0,1,0)
                end
            else
                game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.HelmetMask.TitanShield.Size = UDim2.new(1,0,1,0)
                game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Mask.GP5.Size = UDim2.new(1,0,1,0)
                for i,v in pairs(game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Visor:GetChildren()) do
                    v.Size = UDim2.new(1,0,1,0)
                end
            end
        end

        local function handleRespawn()
            if localplayer.Character and localplayer.Character:FindFirstChild("Humanoid") and localplayer.Character.Humanoid.Health <= 0 and allvars.instantrespawn == true then
                localplayer.PlayerGui.RespawnMenu.Enabled = false
                game.ReplicatedStorage.Remotes.SpawnCharacter:InvokeServer()
            elseif allvars.instantrespawn == false and localplayer.Character.Humanoid.Health <= 0 then
                localplayer.PlayerGui.RespawnMenu.Enabled = true
            else
                localplayer.PlayerGui.RespawnMenu.Enabled = false
                game.ReplicatedStorage.Remotes.SpawnCharacter:InvokeServer()
            end
        end

        local function handleFoliage()
            if not folcheck then return end 
            for _, v in pairs(folcheck.Foliage:GetDescendants()) do
                if v:FindFirstChildOfClass("SurfaceAppearance") then
                    v.Transparency = allvars.worldleaves and 1 or 0
                end
            end
        end

        local function handleInventory()
            if not localplayer.Character or not localplayer.Character:FindFirstChild("HumanoidRootPart") then return end

            local offset = CFrame.new(Vector3.new(allvars.viewmodX, allvars.viewmodY, allvars.viewmodZ))
            if not offset then return end

            local inv = game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Inventory
            local eq = game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Equipment
            local cloth = game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Clothing
            if not inv then return end
            if not eq then return end
            if not cloth then return end

            for _, v in pairs(inv:GetChildren()) do
                if not v:FindFirstChild("SettingsModule") then return end
                local sett = require(v.SettingsModule)
                if allvars.viewmodoffset then
                    sett.weaponOffSet = offset
                end
                if allvars.rapidfire then
                    sett.FireRate = allvars.crapidfire and allvars.crapidfirenum or 0.001
                end
                if allvars.unlockmodes then
                    sett.FireModes = {"Auto", "Semi"}
                end
            end

            for _, v in pairs(eq:GetChildren()) do
                if not v:FindFirstChild("SettingsModule") then return end
                local sett = require(v.SettingsModule)
                if allvars.viewmodoffset then
                    sett.weaponOffSet = offset
                end
            end
        end

        if visdesync and desyncvis then
            desyncvis.Color = desynccolor
            desyncvis.Transparency = desynctrans
        elseif desyncvis then
            desyncvis.Transparency = 1
        end

        handleRespawn()
        handleFoliage()
        handleInventory()
        handleAntiMask()
        handleViewModel()
        handleModDetect()
    end
end)

local _triggerBotTimer = 0 
local fpsrequired = require(game.ReplicatedStorage.Modules.FPS)
runs.Heartbeat:Connect(function(delta) --silent aim + trigger bot fast cycle
    if not localplayer.Character or not localplayer.Character:FindFirstChild("HumanoidRootPart") or not localplayer.Character:FindFirstChild("Humanoid") then
        return
    end
	_triggerBotTimer += delta
    choosetarget(delta) --aim part

    if allvars.aimtrigger and aimtarget ~= nil and _triggerBotTimer*1000 >= allvars.triggerbotdelay then --trigger bot
        fpsrequired.action(a1table, true)
        task.wait()
        fpsrequired.action(a1table, false)
		_triggerBotTimer = 0
    end
	
end)
runs.Heartbeat:Connect(function(delta) --desync
    if aimresolver then return end

    if allvars.desyncbool and localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart") then
        if localplayer.Character.Humanoid.Health <= 0 then return end
        if (tick() - characterspawned) < 1 then return end
        
        desynctable[1] = localplayer.Character.HumanoidRootPart.CFrame
        desynctable[2] = localplayer.Character.HumanoidRootPart.AssemblyLinearVelocity

        if allvars.invisbool and invistrack then --underground update
            invistrack:Stop()
            invistrack = localplayer.Character.Humanoid.Animator:LoadAnimation(invisanim)
            invistrack:Play(.01, 1, 0)
            invistrack.TimePosition = invisnum

            local cf = localplayer.Character.HumanoidRootPart.CFrame
            local posoffset = Vector3.new(0,-2.55,0)
            local rotoffset = Vector3.new(90,0,0)
            local spoofedcf = cf
                * CFrame.new(posoffset) 
                * CFrame.Angles(math.rad(rotoffset.X), math.rad(rotoffset.Y), math.rad(rotoffset.Z))
            desynctable[3] = spoofedcf

            localplayer.Character.HumanoidRootPart.CFrame = spoofedcf
            runs.RenderStepped:Wait()
            localplayer.Character.HumanoidRootPart.CFrame = desynctable[1]
            localplayer.Character.HumanoidRootPart.AssemblyLinearVelocity = desynctable[2]
        else --default desync
            local cf = localplayer.Character.HumanoidRootPart.CFrame
            local posoffset = allvars.desyncPos and Vector3.new(allvars.desynXp, allvars.desynYp, allvars.desynZp) or Vector3.new(0,0,0)
            local rotoffset = allvars.desyncOr and Vector3.new(allvars.desynXo, allvars.desynYo, allvars.desynZo) or Vector3.new(0,0,0)
            local spoofedcf = cf
                * CFrame.new(posoffset) 
                * CFrame.Angles(math.rad(rotoffset.X), math.rad(rotoffset.Y), math.rad(rotoffset.Z))
            desynctable[3] = spoofedcf

            localplayer.Character.HumanoidRootPart.CFrame = spoofedcf
            runs.RenderStepped:Wait()
            localplayer.Character.HumanoidRootPart.CFrame = desynctable[1]
            localplayer.Character.HumanoidRootPart.AssemblyLinearVelocity = desynctable[2]
        end
    end
end)
runs.Heartbeat:Connect(function(dt) --resolver
    if aimresolver and localplayer.Character and localplayer.Character.HumanoidRootPart then
        local char = localplayer.Character
        local hrp = char.HumanoidRootPart
        local mult = CFrame.new(0, -15, 0)
        if aimresolverhh then mult = CFrame.new(0, 500, 0) end
        hrp.AssemblyLinearVelocity = -mult.Position
        char.HumanoidRootPart.CanCollide = false
        char.UpperTorso.CanCollide = false
        char.LowerTorso.CanCollide = false
        char:PivotTo(aimresolverpos * mult)
    end
end)
runs.Heartbeat:Connect(function(delta) --blink
    if not allvars.peekblink then return end
    local hrp = localplayer.Character.HumanoidRootPart

    blinktable[1] = hrp.CFrame
    blinktable[2] = hrp.AssemblyLinearVelocity
    hrp.Anchored = true
    runs.RenderStepped:Wait()
    hrp.Anchored = false

    hrp.CFrame = blinktable[1]
    hrp.AssemblyLinearVelocity = blinktable[2]
    -- if blinkbool and localplayer.Character and localplayer.Character.HumanoidRootPart then

    --     if blinkstop and localplayer.Character.Humanoid.MoveDirection.Magnitude == 0 then return end
    --     if blinknoclip then
    --         localplayer.Character.HumanoidRootPart.CanCollide = false
    --         localplayer.Character.Head.CanCollide = false
    --         localplayer.Character.UpperTorso.CanCollide = false
    --         localplayer.Character.LowerTorso.CanCollide = false
    --         workspace.Gravity = 0.1
    --     end

    --     if aimresolver then return end

    --     if not blinktemp then
    --         hrp.Anchored = true
    --         runs.RenderStepped:Wait()
    --         hrp.Anchored = false
    --     else
    --         hrp.CFrame = blinktable[1]
    --     end
    -- elseif blinknoclip and localplayer.Character and localplayer.Character.HumanoidRootPart then
    --     localplayer.Character.HumanoidRootPart.CanCollide = true
    --     localplayer.Character.Head.CanCollide = true
    --     localplayer.Character.UpperTorso.CanCollide = true
    --     localplayer.Character.LowerTorso.CanCollide = true
    -- end
end)
runs.RenderStepped:Connect(function(delta) -- global fast
    if not localplayer.Character or not localplayer.Character:FindFirstChild("HumanoidRootPart") or not localplayer.Character:FindFirstChild("Humanoid") then
        return
    end


    if allvars.desyncbool and allvars.invisbool then
        if not aimresolver then
            local vel = localplayer.Character.HumanoidRootPart.AssemblyLinearVelocity
            local newvel = Vector3.new(vel.X, math.clamp(vel.Y, -99999, 19), vel.Z)
            localplayer.Character.HumanoidRootPart.AssemblyLinearVelocity = newvel
        end
    elseif invistrack then
        invistrack:Stop()
        invistrack:Destroy()
    end


    if desyncvis and desynctable[3] then
        desyncvis.CFrame = desynctable[3] * CFrame.new(0, -0.7, 0)
        localplayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end


    --no swim--
    if noswim then
        localplayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
    else
        localplayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
    end
    


    --nofall method by ds: _hai_hai
    local humstate = localplayer.Character.Humanoid:GetState()
    if allvars.nofall and (humstate == Enum.HumanoidStateType.FallingDown or humstate == Enum.HumanoidStateType.Freefall) and localplayer.Character.HumanoidRootPart.AssemblyLinearVelocity.Y < -30 then 
        localplayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)

        if allvars.instafall and aimresolver == false then 
            local rparams = RaycastParams.new()
            rparams.IgnoreWater = false
            rparams.FilterDescendantsInstances = {
                localplayer.Character
            }
            local fray = workspace:Raycast(localplayer.Character.HumanoidRootPart.Position, Vector3.new(0, -400, 0), rparams)
            if fray then
                localplayer.Character.HumanoidRootPart.CFrame = CFrame.new(fray.Position + Vector3.new(0, 3, 0))
            end
        end
    end


    local nil1, nil2, newglobalcurrentgun = getcurrentgun(localplayer)
    globalcurrentgun = newglobalcurrentgun
    globalammo = getcurrentammo(globalcurrentgun)


    if ACBYPASS_SYNC == true and allvars.changerbool then
        localplayer.Character.Humanoid.WalkSpeed = allvars.changerspeed
        localplayer.Character.Humanoid.JumpHeight = allvars.changerjump
        localplayer.Character.Humanoid.HipHeight = allvars.changerheight
        workspace.Gravity = allvars.changergrav
    end


    if charsemifly and localplayer.Character and ACBYPASS_SYNC == true then --semifly
        local hrp = localplayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local dir = Vector3.new(0, 0, 0)

		if uis:IsKeyDown(Enum.KeyCode.W) then
			dir += wcamera.CFrame.LookVector
		elseif uis:IsKeyDown(Enum.KeyCode.S) then
			dir -= wcamera.CFrame.LookVector
		end

		if uis:IsKeyDown(Enum.KeyCode.A) then
			dir -= wcamera.CFrame.RightVector
		elseif uis:IsKeyDown(Enum.KeyCode.D) then
			dir += wcamera.CFrame.RightVector
		end

		if uis:IsKeyDown(Enum.KeyCode.Space) then
			dir += Vector3.new(0, 1, 0)
		elseif uis:IsKeyDown(Enum.KeyCode.LeftShift) then
			dir -= Vector3.new(0, 1, 0)
		end

		local closest = fly_getclosestpoint()
		if closest then
			local d = (hrp.Position - closest).Magnitude
			if d > allvars.charsemiflydist then
				local ldir = (hrp.Position - closest).Unit * allvars.charsemiflydist
				local offset = fly_getoffset(ldir)
				hrp.CFrame = CFrame.new(closest + ldir - offset)
			else
				fly_move(dir * allvars.charsemiflyspeed * runs.RenderStepped:Wait(), delta)
			end
		else
			fly_move(dir * allvars.charsemiflyspeed * runs.RenderStepped:Wait(), delta)
		end
    end


    if allvars.crossbool then --crosshair
        crosshair.Visible = true
        crosshair.Rotation += allvars.crossrot
        crosshair.Size = UDim2.new(crosssizeog.X.Scale * allvars.crosssizek, 0, crosssizeog.Y.Scale * allvars.crosssizek, 0)
        crosshair.Image = allvars.crossimg
        crosshair.ImageColor3 = allvars.crosscolor
    else
        crosshair.Visible = false
    end

    if allvars.aimdynamicfov then -- fov changer
        aimfovcircle.Radius = allvars.aimfov * (80 / wcamera.FieldOfView )
    else
        aimfovcircle.Radius = allvars.aimfov
    end


    --snapline--
    if allvars.snaplinebool and aimtargetpart then
        aimsnapline.Visible = true
        local headpos = wcamera:WorldToViewportPoint(aimtargetpart.Position)
        aimsnapline.From = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2)
        aimsnapline.To = Vector2.new(headpos.X, headpos.Y)
        aimsnapline.Color = allvars.snaplinecolor
        aimsnapline.Thickness = allvars.snaplinethick
    elseif targetinfoskip and allvars.snaplinebool and aimpretarget and showkdr then
        aimsnapline.Visible = true
        local headpos
        if aimpretarget:IsA("Model") then
            headpos = wcamera:WorldToViewportPoint(aimpretarget.HumanoidRootPart.Position)
        else
            headpos = wcamera:WorldToViewportPoint(aimpretarget.Character.HumanoidRootPart.Position)
        end
        aimsnapline.From = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2)
        aimsnapline.To = Vector2.new(headpos.X, headpos.Y)
        aimsnapline.Color = allvars.snaplinecolor
        aimsnapline.Thickness = allvars.snaplinethick
    else
        aimsnapline.Visible = false
    end


    local infotarget = nil
    if aimtarget ~= nil and aimtargetpart ~= nil and aimtargetpart.Parent then
        infotarget = aimtarget
    elseif aimpretarget and targetinfoskip then
        infotarget = aimpretarget
    end
    if infotarget then
        aimtargetname.Text = infotarget.Name
        if infotarget:IsA("Model") then
            aimtargetshots.Text = math.floor(infotarget.Humanoid.Health) .. "/100 HP"
            if showdist then
                local targetdist = math.floor((localplayer.Character.PrimaryPart.Position - infotarget.HumanoidRootPart.Position).Magnitude * 0.3336)
                aimtargetname.Text = aimtargetname.Text .. " | Distance : ".. targetdist.."m"
            end
            if showkdr then
                aimtargetname.Text = aimtargetname.Text .. " | KDR : Bot"
            end
        else
            aimtargetshots.Text = math.floor(infotarget.Character.Humanoid.Health) .. "/100 HP"
            if showdist then
                local targetdist = math.floor((localplayer.Character.PrimaryPart.Position - infotarget.Character.HumanoidRootPart.Position).Magnitude * 0.3336)
                aimtargetname.Text = aimtargetname.Text .. " | Distance : ".. targetdist.."m"
            end
            if showkdr then
                local wipestats = game.ReplicatedStorage.Players[infotarget.Name].Status.Journey.WipeStatistics
                local kdr = wipestats:GetAttribute("Deaths") / wipestats:GetAttribute("Kills")
                aimtargetname.Text = aimtargetname.Text .. " | KDR : ".. math.floor(kdr * 100 + 0.5) / 100
            end
        end
    else
        aimtargetname.Text = "None"
        aimtargetshots.Text = "0/100 HP"
    end
    aimtargetname.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2 + allvars.aimfov / 2 + 20)
    aimtargetshots.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2 + allvars.aimfov / 2 + 45)
    aimtargetvis.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2 + allvars.aimfov / 2 + 75)
    if not aimtarget then
        aimtargetvis.Text = "Not visible"
        aimtargetvis.Color = targetvisred
    elseif aimtarget then
        aimtargetvis.Text = "Visible"
        aimtargetvis.Color = targetvisgreen
    end

    aimfovcircle.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2)
    aimfovcircle.Color = allvars.aimfovcolor
    if scgui then
        scgui.Position = Window.Holder.Position + UDim2.new(0.16, 0, 0, 0)
        scgui.Visible = scbool and Window.Holder.Visible or false
    end


    local invtarget = aimtarget --inv checker
    if targetinfoskip and aimpretarget then
        invtarget = aimpretarget
    end
    if aimtarget == nil and espmaptarget ~= nil then
        invtarget = espmaptarget
    end
    if allvars.invcheck and invtarget ~= nil then
        local profile = game.ReplicatedStorage.Players:FindFirstChild(invtarget.Name)
        if profile then
            local cloth = profile.Clothing
            local inv = profile.Inventory
            local result = ""
            
            result = result .. "--HOTBAR--\n"
            for _, item in pairs(inv:GetChildren()) do
                result = result .. item.Name .. ",\n"
            end
            result = result .. "--CLOTHING--\n"
            for _, item in pairs(cloth:GetChildren()) do
                local itemName = item.Name
                local inventory = item:FindFirstChild("Inventory")
    
                if inventory then
                    result = result .. itemName .. " = {\n"
                    local count = 0
                    for _, invItem in pairs(inventory:GetChildren()) do
                        local invcount = invItem.ItemProperties:GetAttribute("Amount")
                        count = count + 1
                        if count % 2 == 0 then
                            if invcount and invcount > 1 then
                                result = result .. " " .. invItem.Name .."[x".. invcount .."]".. ","
                            else
                                result = result .. " " .. invItem.Name .. ","
                            end
                            result = result .. "\n"
                        else
                            if invcount and invcount > 1 then
                                result = result .. "    " .. invItem.Name .."[x".. invcount .."]".. ","
                            else
                                result = result .. "    " .. invItem.Name .. ","
                            end
                        end
                    end
                    result = result:sub(1, -2) .. "\n},\n"
                else
                    result = result .. itemName .. ",\n"
                end
            end

            result = result:sub(1, -3)
            result = invtarget.Name.."'s inventory:\n" .. result
    
            invchecktext.Text = result
        else
            invchecktext.Text = " "
        end
    else
        invchecktext.Text = " "
    end
end)
runs.Heartbeat:Connect(function(delta) --esp fast cycle
    if not localplayer.Character or not localplayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    for dobj, info in pairs(esptable) do --esp part
        local dtype = info.type
        local otype = info.otype
        
        if info.primary == nil or info.primary.Parent == nil then
            esptable[dobj] = nil
            if dtype == "Highlight" then
                dobj.Enabled = false
                dobj:Destroy()
            else
                dobj.Visible = false
                dobj:Remove()
            end
            continue
        end
    
        local obj
        local isHumanoid
        if otype == "Extract" or otype == "Loot" then
            obj = info.primary
            isHumanoid = true
        else
            obj = info.primary.Parent:FindFirstChild("UpperTorso")
            if not obj then
                esptable[dobj] = nil
                if dtype == "Highlight" then
                    dobj.Enabled = false
                    dobj:Destroy()
                else
                    dobj.Visible = false
                    dobj:Remove()
                end
                continue
            end
            isHumanoid = obj.Parent:FindFirstChild("Humanoid")
        end
    
        if (otype == "Bot333" and allvars.espbots == false) or (otype == "Dead333" and allvars.espdead == false) or (otype == "Extract" and allvars.espexit == false) or (otype == "Loot" and allvars.esploot == false) then
            if dtype == "Highlight" then
                dobj.Enabled = false
            else
                dobj.Visible = false
            end
            continue
        end
        
        if otype == "Bot333" and obj.Parent.Humanoid.Health == 0 then
            info.otype = "Dead333"
        end
        
        local realdist = (localplayer.Character.PrimaryPart.Position - obj.Position).Magnitude
        local studsdist = math.floor(realdist)
        local metersdist = math.floor(realdist * 0.3336)
    
        if allvars.espbool and isonscreen(obj) and isHumanoid and metersdist < allvars.esprenderdist then
            local headpos = wcamera:WorldToViewportPoint(obj.Position)
            local resultpos = Vector2.new(headpos.X, headpos.Y)
    
            if dtype == "Name" then
                if allvars.espname then
                    resultpos = resultpos - Vector2.new(0, 15)
                    if otype == "Extract" then
                        dobj.Text = obj.Name
                    elseif otype == "Dead333" then 
                        dobj.Text = obj.Parent.Name .. " [DEAD]"
                    else
                        dobj.Text = obj.Parent.Name
                    end
                    dobj.Position = resultpos
                    dobj.Size = allvars.esptextsize
                    dobj.Color = allvars.esptextcolor
                    dobj.Outline = allvars.esptextline
                    dobj.Visible = true
                else
                    dobj.Visible = false
                end
            elseif dtype == "HP" then
                if otype == "Dead333" then
                    dobj.Visible = false
                    continue
                end
    
                resultpos = resultpos - Vector2.new(0, 30)
                local plrhp = math.floor(obj.Parent.Humanoid.Health)
                local t = plrhp / 100
                dobj.Text = plrhp .. "HP"
                dobj.Position = resultpos
                dobj.Size = allvars.esptextsize
                if t >= 0.5 then
                    local factor = (t - 0.5) * 2
                    dobj.Color = Color3.new(
                        allvars.esphpmid.R + (allvars.esphpmax.R - allvars.esphpmid.R) * factor,
                        allvars.esphpmid.G + (allvars.esphpmax.G - allvars.esphpmid.G) * factor,
                        allvars.esphpmid.B + (allvars.esphpmax.B - allvars.esphpmid.B) * factor
                    )
                else
                    local factor = t * 2
                    dobj.Color = Color3.new(
                        allvars.esphpmin.R + (allvars.esphpmid.R - allvars.esphpmin.R) * factor,
                        allvars.esphpmin.G + (allvars.esphpmid.G - allvars.esphpmin.G) * factor,
                        allvars.esphpmin.B + (allvars.esphpmid.B - allvars.esphpmin.B) * factor
                    )
                end
                dobj.Visible = allvars.esphp
                dobj.Outline = allvars.esptextline
            elseif dtype == "Distance" then
                if allvars.espdistance then
                    resultpos = resultpos - Vector2.new(0, 45)
                    if allvars.espdistmode == "Meters" then
                        dobj.Text = metersdist .. "m"
                    elseif allvars.espdistmode == "Studs" then
                        dobj.Text = studsdist .. "s"
                    end
                    dobj.Position = resultpos
                    dobj.Size = allvars.esptextsize
                    dobj.Color = allvars.esptextcolor
                    dobj.Outline = allvars.esptextline
                    dobj.Visible = true
                else
                    dobj.Visible = false
                end
            elseif dtype == "Hotbar" then
                if otype == "Dead333" then
                    dobj.Visible = false
                    continue
                end
    
                resultpos = resultpos + Vector2.new(0, 15)
                local hotgun = "None"
                for _, v in pairs(obj.Parent:GetChildren()) do
                    if v:FindFirstChild("ItemRoot") then
                        hotgun = v.Name
                        break
                    end
                end
    
                dobj.Visible = allvars.esphotbar
                if otype == "Loot" then
                    local Amount
                    local TotalPrice = 0
                    local Value = 0
    
                    for _, h in pairs(obj.Parent.Inventory:GetChildren()) do
                        Amount = h.ItemProperties:GetAttribute("Amount") or 1
                        TotalPrice += h.ItemProperties:GetAttribute("Price") or 0
                        Value += (valcache[h.ItemProperties:GetAttribute("CallSign")] or 0) * Amount
                    end --original = https://rbxscript.com/post/ProjectDeltaLootEsp-P7xaS
    
                    if Value >= 20 then
                        dobj.Text = "Rate : Godly | " .. TotalPrice .. "$"
                    elseif Value >= 12 then
                        dobj.Text = "Rate : Good | " .. TotalPrice .. "$"
                    elseif Value >= 8 then
                        dobj.Text = "Rate : Not bad | " .. TotalPrice .. "$"
                    elseif Value >= 4 then
                        dobj.Text = "Rate : Bad | " .. TotalPrice .. "$"
                    end
                else
                    dobj.Text = hotgun
                end
                dobj.Position = resultpos
                dobj.Size = allvars.esptextsize
                dobj.Outline = allvars.esptextline
                dobj.Color = allvars.esptextcolor
            elseif dtype == "Highlight" then
                if otype == "Dead333" or dobj.Parent == nil or obj == nil or obj.Parent == nil or not obj.Parent:IsA("Model") or obj.Parent.Humanoid.Health == 0 then
                    esptable[dobj] = nil
                    dobj.Enabled = false
                    dobj:Destroy()
                    continue
                end
    
                dobj.FillColor = allvars.espfillcolor
                dobj.OutlineColor = allvars.esplinecolor
                dobj.FillTransparency = allvars.espchamsfill
                dobj.OutlineTransparency = allvars.espchamsline
                dobj.Enabled = allvars.esphigh
            end
        else
            if dtype == "Highlight" then
                dobj.Enabled = false
            else
                dobj.Visible = false
            end
        end
    end
end)

--loaded--
scriptloading = false

SaveManager:LoadAutoloadConfig()
Library:Toggle()

print("loaded")
Library:Notify("Ardour", "Script loaded")

