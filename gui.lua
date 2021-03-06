local _time = tick()

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

getgenv().Player = Players.LocalPlayer
getgenv().Mouse = Player:GetMouse()
getgenv().KillPlayer = function()
    if Player.Character then
        if Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.Health = 0
        end
        wait(0.2)
        for _, v in pairs(Player.Character:GetChildren()) do
            if v.ClassName ~= "Humanoid" then
                v:Remove()
            end
        end
    end
end
getgenv().findp = function(name)
    local t = {}
    if name:lower() == "all" then
        for i,v in pairs(Players:GetPlayers()) do
            table.insert(t,v)
        end
        return t
    elseif name:lower() == "others" then
        for i,v in pairs(Players:GetPlayers()) do
            if v ~= Player then
                table.insert(t,v)
            end
        end
        return t
    elseif name:lower() == "me" then
        table.insert(t,Players)
        return t
    else
        for _,player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                if name:lower() == player.Name:sub(1,name:len()):lower() then
                    table.insert(t,player)
                end
            end
        end
        return t
    end
    return nil
end
getgenv().changeprop = function(instance, prop, value)
    if instance and instance[prop] then
        instance[prop] = value
    end
end

local flags = {
    ["silent_aim"] = false,
    ["prediction"] = false,
    ["oldprediction"] = false,
    ["godmode"] = false,
    ["truegod"] = false,
    ["tpbypass"] = false,
    ["antikill"] = false,
    ["noclip"] = false,
    ["blink"] = false,
    ["antiaim"] = false,
    ["bullet_trails"] = false,
    ["selected_silent_aim"] = false,
    ["old_blink"] = false,
    ["noslow"] = false,
    ["reloading"] = false,
    ["flying"] = false,
    ["nogh"] = false
}

local values = {
    ["velocity"] = 5,
    ["newvelocity"] = 5,
    ["aim_part"] = "Head",
    ["aim_mode"] = "Mouse",
    ["aim_target"] = nil,
    ["box_color"] = Color3.fromRGB(255,0,0),
    ["text_color"] = Color3.fromRGB(255,255,255),
    ["tracer_color"] = Color3.fromRGB(255,0,0),
    ["chams_color"] = Color3.fromRGB(255,0,0),
    ["bullet_color"] = ColorSequence.new(Color3.new(255,255,255)),
    ["chams_transparency"] = 0.5,
    ["walkspeed"] = 16,
    ["runspeed"] = 25,
    ["crouchspeed"] = 8,
    ["jumppower"] = 37.5,
    ["blinkspeed"] = 0.5,
    ["trail_transparency"] = 0,
    ["trail_time"] = 2,
    ["aim_target_pos"] = nil,
    ["flyspeed"] = 5,
    ["config_name"] = ""
}

local MovementKeys = {
    ["w"] = false,
    ["a"] = false,
    ["s"] = false,
    ["d"] = false,
    ["q"] = false,
    ["e"] = false,
    ["shift"] = false,
    ["rightclick"] = false,
}

local connections = {
    ["bullet_trails"] = nil,
    ["color"] = nil,
    ["removevelocity"] = nil,
    ["changestate"] = nil,
}

local KeyBinds = {
    ["noclip"] = Enum.KeyCode.X,
    ["fly"] = Enum.KeyCode.F
}

local function loadSettings(File)
    local Content = readfile(File)
    Content = game:GetService("HttpService"):JSONDecode(Content)
    flags = Content.flags
    values = Content.values
    KeyBinds = {}
    KeyBinds["noclip"] = Enum.KeyCode[Content.KeyBinds["noclip"]]
    KeyBinds["fly"] = Enum.KeyCode[Content.KeyBinds["fly"]]
    return File
end

local function saveSettings()
    local tb = {flags = flags,values = values,KeyBinds = {}}
    for i,v in pairs(KeyBinds) do
        if tostring(v) == "InputObject" then
            v = v.KeyCode
        end
        tb.KeyBinds[i] = tostring(v):gsub("Enum.KeyCode.","")
    end
    local Content = game:GetService("HttpService"):JSONEncode(tb)
    writefile("streets_default.cfg",Content)
end

local fileDir,isFolder,makeFolder = syn_io_listdir or list_files,syn_io_isfolder or isfolder,syn_io_makefolder or makeFolder
local Configs = {}

if fileDir and isFolder and makeFolder then
    if not isFolder("streets_configs") then makeFolder("streets_configs"); end
    for _, File in pairs(fileDir("streets_configs")) do
        if isfile(File) then
            local FileName = File:gsub("streets_configs\\", "")
            Configs[FileName] = File
        end
    end
end

if Configs["streets_default.cfg"] then
    loadSettings(Configs["streets_default.cfg"])
else
    writefile("streets_default.cfg", game:GetService("HttpService"):JSONEncode({flags = flags,values = values,KeyBinds = KeyBinds}))
end

local function getAimbotCFrame()
    local AimbotCFrame;
    local Root = values["aim_target"].Character.findFirstChild(values["aim_target"].Character, values["aim_part"])
    if flags["prediction"] and Root then
        AimbotCFrame = (Root.CFrame + Root.Velocity / values["newvelocity"]) + (Root.RotVelocity / values["newvelocity"]) -- THANKS CY LOOOOOOOOOOOOOL
    elseif flags["oldprediction"] and Root then
        AimbotCFrame = (Root.CFrame + Root.Velocity / values["velocity"]) + (Root.RotVelocity / values["velocity"])
    elseif Root then
        AimbotCFrame = Root.CFrame
    end
    return AimbotCFrame
end

local function WorldToViewportPoint(Pos)
    return workspace.CurrentCamera:WorldToViewportPoint(Pos)
end

local function WorldToScreenPoint(Pos)
    return workspace.CurrentCamera.WorldToScreenPoint(workspace.CurrentCamera, Pos)
end

local function FindFirstChild(self, Object)
    return self.FindFirstChild(self, Object)
end

local function picktarget()
    local Target;
    local RangeMouse = math.huge;
    local Range = math.huge;
    for i,v in pairs(game.Players.GetPlayers(game.Players)) do
        if v ~= Player then
            if game.PlaceId ~= 455366377 and FindFirstChild(workspace, v.Name) and FindFirstChild(FindFirstChild(workspace, v.Name), "Head") then
                local Position, OnScreen = WorldToScreenPoint(FindFirstChild(workspace, v.Name).Head.Position)
                Position = Vector2.new(Position.X, Position.Y)
                local MousePosition = Vector2.new(Mouse.X,Mouse.Y)
                local Distance = (Position - MousePosition).magnitude
                local Distance2 = (Player.Character.Head.Position - workspace[v.Name].Head.Position).magnitude
                if values["aim_mode"] == "Mouse" then
                    if Distance < RangeMouse then
                        RangeMouse = Distance
                        Target = v
                    end
                elseif values["aim_mode"] == "Closest" then
                    if Distance2 < Range then
                        Range = Distance2
                        Target = v
                    end
                end
            elseif game.PlaceId == 455366377 and FindFirstChild(workspace.Live, v.Name) and FindFirstChild(FindFirstChild(workspace.Live, v.Name), "Head") then
                local Position, OnScreen = WorldToScreenPoint(FindFirstChild(workspace.Live, v.Name).Head.Position)
                Position = Vector2.new(Position.X, Position.Y)
                local MousePosition = Vector2.new(Mouse.X,Mouse.Y)
                local Distance = (Position - MousePosition).magnitude
                local Distance2 = (Player.Character.Head.Position - workspace.Live[v.Name].Head.Position).magnitude
                if values["aim_mode"] then
                    if Distance < RangeMouse then
                        RangeMouse = Distance
                        Target = v
                    end
                elseif values["aim_mode"] then
                    if Distance2 < Range then
                        Range = Distance2
                        Target = v
                    end
                end
            end
        end
    end
    return Target;
end

local function ToggleFly()
    if not flags["flying"] then
        flags["flying"] = true
        if Player and Player.Character and FindFirstChild(Player.Character, "Torso") then
            local Torso = Player.Character.Torso
            local Velocity,Gyro = Instance.new("BodyVelocity", Torso), Instance.new("BodyGyro", Torso)

            Velocity.MaxForce = Vector3.new(9e9,9e9,9e9)
            Velocity.Velocity = Vector3.new(0,0.1,0)
            Gyro.P = 9e9
            Gyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
            Gyro.CFrame = Torso.CFrame

            local NewPart = Instance.new("Part", workspace)
            NewPart.Anchored = true
            NewPart.Size = Vector3.new(10,1,10)
            NewPart.Transparency = 1

            while flags["flying"] and Player and Player.Character and FindFirstChild(Player.Character, "Humanoid") and Player.Character.Humanoid.Health > 0 and Torso do
                wait()
                NewPart.CFrame = Torso.CFrame + Vector3.new(0,-3.5,0)
                local F,B,L,R = 0,0,0,0
                if MovementKeys["w"] then F = values["flyspeed"] else F = 0 end; if MovementKeys["a"] then R = -values["flyspeed"] else R = 0 end; if MovementKeys["s"] then B = -values["flyspeed"] else B = 0 end; if MovementKeys["d"] then L = values["flyspeed"] else L = 0 end
                if tonumber((F + B)) ~= 0 or tonumber((L + R)) ~= 0 then
                    Velocity.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (F + B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(L + R, (F + B) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * 50
                else
                    Velocity.Velocity = Vector3.new(0,0.1,0)
                end
                Gyro.CFrame = workspace.CurrentCamera.CoordinateFrame
            end

            NewPart:Destroy()

            Velocity:Remove()
            Gyro:Remove()
        end
    else
        flags["flying"] = false
    end
end

local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/isthatjack/ui/master/venyxlib.lua'),true))()
local UI;

--[[
    https://pastebin.com/raw/wTNFKRF2
]]

local function InitUi()
    UI = library.new("阴茎ware.cc - The Streets")
    local AimbotPage = UI:addPage("Aimbot", "4990058716")

    local silentSection = AimbotPage:addSection("Aimlock")

    local silent_toggle;
    local selected_toggle;
    local prediction_toggle;
    local old_prediction_toggle;

    silent_toggle = silentSection:addToggle("Silent Aim", flags["silent_aim"], function(bool)
        flags["silent_aim"] = bool
        if flags["silent_aim"] then
            values["aim_target"] = picktarget()
        end
    end)

    selected_toggle = silentSection:addToggle("Selected Silent Aim", flags["selected_silent_aim"], function(bool)
        flags["selected_silent_aim"] = bool
    end)

    prediction_toggle = silentSection:addToggle("Prediction", flags["prediction"], function(bool)
        flags["prediction"] = bool
    end)

    old_prediction_toggle = silentSection:addToggle("Old Prediction", flags["oldprediction"], function(bool)
        flags["oldprediction"] = bool
    end)

    local velocity_slider = silentSection:addSlider("Aimbot Velocity", 5, 1, 15, function(num)
        values["velocity"] = tonumber(num)
    end)

    local targetSection = AimbotPage:addSection("Targets")

    local aimpart_dropdown = targetSection:addDropdown("Aimpart", {"Head", "Torso"}, function(part)
        values["aim_part"] = part
    end)

    local silent_dropdown = targetSection:addDropdown("Players", {"Mouse", "Closest"}, function(mode)
        values["aim_mode"] = mode
    end)

    local target_textbox = targetSection:addTextbox("Selected Target", "Name", function(str)
        local target = findp(str)
        if target then
            values["aim_target"] = target[1]
        end
    end)

    local StreetsPage = UI:addPage("Streets", "2812081613")

    local playerSection = StreetsPage:addSection("Player")

    local godmode_toggle = playerSection:addToggle("Godmode", flags["godmode"], function(bool)
        flags["godmode"] = bool
        KillPlayer()
    end)

    local truegod_toggle = playerSection:addToggle("True Godmode", flags["truegod"], function(bool)
        flags["truegod"] = bool
        KillPlayer()
    end)

    local tpbypass_toggle = playerSection:addToggle("TP Bypass", flags["tpbypass"], function(bool)
        flags["tpbypass"] = bool
        KillPlayer()
    end)

    local antikill_toggle = playerSection:addToggle("Anti Fe-Loop", flags["antikill"], function(bool)
        flags["antikill"] = bool
    end)

    local antiaim_toggle = playerSection:addToggle("Anti-Aim", flags["antiaim"], function(bool)
        flags["antiaim"] = bool
        if flags["antiaim"] then
            if Player and Player.Character and Player.Character:FindFirstChild("Head") then
                for i = 1, 500 do
                    local bv = Instance.new("BodyVelocity", Player.Character.Head)
                    bv.MaxForce = Vector3.new(100, 100, 100)
                    bv.P = math.huge
                    bv.Velocity = Vector3.new(math.huge, math.huge, math.huge)
                end
            end
        else
            if Player and Player.Character and Player.Character:FindFirstChild("Head") then
                for i,v in pairs(Player.Character.Head:GetChildren()) do
                    if v.ClassName == "BodyVelocity" then
                        v:Remove()
                    end
                end
            end
        end
    end)

    local noslow_toggle = playerSection:addToggle("No Slow", flags["noslow"], function(bool)
        flags["noslow"] = bool
    end)

    local nogh_toggle = playerSection:addToggle("No Groundhit", flags["nogh"], function(bool)
        flags["nogh"] = bool
    end)

    local speedSection = StreetsPage:addSection("Speed")

    local ws_slider = speedSection:addSlider("Walk Speed", 16, 0, 300, function(num)
        values["walkspeed"] = tonumber(num)
        changeprop(Player.Character.Humanoid, "WalkSpeed", tonumber(num))
    end)

    local rs_slider = speedSection:addSlider("Run Speed", 25, 0, 300, function(num)
        values["runspeed"] = tonumber(num)
    end)

    local cs_slider = speedSection:addSlider("Crouch Speed", 8, 0, 300, function(num)
        values["crouchspeed"] = tonumber(num)
    end)

    local jp_slider = speedSection:addSlider("Jump Power", 38, 0, 300, function(num)
        values["jumppower"] = tonumber(num)
        changeprop(Player.Character.Humanoid, "JumpPower", tonumber(num))
    end)

    local blink_toggle = speedSection:addToggle("Blink", flags["blink"], function(bool)
        flags["blink"] = bool
    end)

    local old_blink = speedSection:addToggle("Old Blink", flags["old_blink"], function(bool)
        flags["old_blink"] = bool
    end)

    local blink_slider = speedSection:addSlider("Blink Speed", 5, 1, 50, function(num)
        values["blinkspeed"] = (tonumber(num) / 10)
    end)

    local trailSection = StreetsPage:addSection("Bullet Customization")

    local bullet_color_picker = trailSection:addColorPicker("Bullet Color", Color3.fromRGB(255,255,255), function(color)
        values["bullet_color"] = ColorSequence.new(color)
    end)

    local bullet_trail_toggle = trailSection:addToggle("Bullet Trails", flags["bullet_trails"], function(bool)
        flags["bullet_trails"] = bool
    end)

    local trail_transparency_slider = trailSection:addSlider("Trail Transparency", 0, 0, 10, function(num)
        values["trail_transparency"] = (tonumber(num) / 10)
    end)

    local trail_time_slider = trailSection:addSlider("Trail Lifetime", 2, 0, 10, function(num)
        values["trail_time"] = tonumber(num)
    end)

    local KeyPage = UI:addPage("Keybinds", "1363810537")

    local KeySection = KeyPage:addSection("Keys")

    local fly_bind = KeySection:addKeybind("Fly", KeyBinds["fly"], function() ToggleFly() end, function(updatedKey)
        KeyBinds["fly"] = updatedKey
    end)

    local noclip_bind = KeySection:addKeybind("Noclip", KeyBinds["noclip"], function() flags["noclip"] = not flags["noclip"] end, function(updatedKey)
        KeyBinds["noclip"] = updatedKey
    end)

    local ConfigPage = UI:addPage("Configs", "3457147503")

    local ConfigSection = ConfigPage:addSection("Configs")

    local config_dropdown = ConfigSection:addDropdown("Configs", Configs, function(config)
        loadSettings(config)
        spawn(function()
            game.CoreGui["阴茎ware.cc - The Streets"]:Destroy()
            wait(0.3)
            UI = nil
            InitUi()
            library:SelectPage(UI.pages[1], true)
        end)
    end)

    local config_name = ConfigSection:addTextbox("Config Name", "Name", function(str)
        values["config_name"] = str
    end)

    local save_config = ConfigSection:addButton("Save Config", function()
        local tb = {flags = flags,values = values,KeyBinds = {}}
        for i,v in pairs(KeyBinds) do
            if tostring(v) == "InputObject" then
                v = v.KeyCode
            end
            tb.KeyBinds[i] = tostring(v):gsub("Enum.KeyCode.","")
        end
        writefile(values["config_name"] .. ".cfg", game:GetService("HttpService"):JSONEncode(tb))
        print("wrote " .. values["config_name"] .. ".cfg")
    end)

    local save_default = ConfigSection:addButton("Save Default", function()
        saveSettings()
        print("saved config as default")
    end)
end

InitUi()

library:SelectPage(UI.pages[1], true)

local mt = getrawmetatable(game)
local namecall = mt.__namecall
local newindex = mt.__newindex
setreadonly(mt,false)

mt.__newindex = newcclosure(function(self,k,v)
    if checkcaller() then return newindex(self,k,v) end
    if self:IsA("Humanoid") then
        game.StarterGui:SetCore("ResetButtonCallback",true)
        if k == "WalkSpeed" and v == 0 and flags["noslow"] then
            return
        end
        if k == "JumpPower" then
            return
        end
        if k == "Health" then
            return
        end
        if k == "HipHeight" then
            return
        end
    end
    if k == "CFrame" and self:IsDescendantOf(Player.Character) then
        return
    end
    return newindex(self,k,v)
end)

mt.__namecall = newcclosure(function(self,...)
    local args = {...}
    local m = getnamecallmethod()
    if m == "BreakJoints" or m == "ClearAllChildren" and self == Player.Character then
        return wait(9e9)
    end
    if m == "Kick" or m == "Destroy" and self == Player then
        return wait(9e9)
    end
    if m == "Destroy" and tostring(self) == "BodyGyro" or m == "Destroy" and tostring(self) == "BodyVelocity" or m == "Destroy" and tostring(self) == "BodyPosition" then
        return wait(9e9)
    end
    if m == "FireServer" then
        if tostring(self) == "lIII" or tostring(self.Parent) == "ReplicatedStorage" then
            return wait(9e9)
        end
        if args[1] == "hey" then
            return wait(9e9)
        end
        if tostring(self) == "Fire" and values["aim_target"] and (flags["silent_aim"] or flags["selected_silent_aim"]) then
            if flags["silent_aim"] then
                local target = picktarget()
                values["aim_target"] = target
                if target and target.Character and FindFirstChild(target.Character, values["aim_part"]) then
                    rawset(args,1,getAimbotCFrame())
                    return namecall(self, unpack(args))
                end
            elseif flags["selected_silent_aim"] then
                local target = values["aim_target"]
                if target and target.Character and FindFirstChild(target.Character, values["aim_part"]) then
                    rawset(args,1,getAimbotCFrame())
                    return namecall(self, unpack(args))
                end
            end
        end
        if tostring(self) == "Input" and values["aim_target"] and (flags["silent_aim"] or flags["selected_silent_aim"]) then
            if flags["silent_aim"] then
                local target = picktarget()
                values["aim_target"] = target
                if target and target.Character and FindFirstChild(target.Character, values["aim_part"]) then
                    rawset(args[2],"mousehit",getAimbotCFrame())
                    return namecall(self, unpack(args))
                end
            elseif flags["selected_silent_aim"] then
                local target = values["aim_target"]
                if target and target.Character and FindFirstChild(target.Character, values["aim_part"]) then
                    rawset(args[2],"mousehit",getAimbotCFrame())
                    return namecall(self, unpack(args))
                end
            end
        end
    end
    return namecall(self, unpack(args))
end)

Player.CharacterAdded:Connect(function(Character)
    if flags["flying"] then
        flags["flying"] = false
    end
    coroutine.wrap(function()
        Character:waitForChild("HumanoidRootPart")
        if flags["tpbypass"] then
            Character.HumanoidRootPart:Remove()
        end
    end)()
    coroutine.wrap(function()
        Character:waitForChild("Stamina")
        Character:waitForChild("Used")
        Character:waitForChild("KO")
        if flags["truegod"] then
            Character.Stamina:Remove()
            Character.Used:Remove()
            Character.KO:Remove()
        end
    end)()
    coroutine.wrap(function()
        Character:waitForChild("Right Leg")
        if flags["godmode"] then
            Character["Right Leg"]:Remove()
        end
    end)()
    Character:waitForChild("Humanoid")
    Character.Humanoid.WalkSpeed = values["walkspeed"]
    Character.Humanoid.JumpPower = values["jumppower"]
    Character:waitForChild("Head")
    if flags["antiaim"] then
        for i = 1, 500 do
            local bv = Instance.new("BodyVelocity", Character.Head)
            bv.MaxForce = Vector3.new(100, 100, 100)
            bv.P = math.huge
            bv.Velocity = Vector3.new(math.huge, math.huge, math.huge)
        end
    end
    if connections["color"] then
        connections["color"]:Disconnect()
        connections["color"] = nil
    end
    connections["color"] = Character.DescendantAdded:Connect(function(obj)
        if obj:IsA("Trail") then
            obj.Color = values["bullet_color"]
            if flags["bullet_trails"] then
                obj.Lifetime = values["trail_time"]
                obj.Transparency = NumberSequence.new(values["trail_transparency"])
            end
        end
    end)
    if connections["removevelocity"] then
        connections["removevelocity"]:Disconnect()
        connections["removevelocity"] = nil
    end
    connections["removevelocity"] = Character.Humanoid.Died:Connect(function()
        for i,v in pairs(Character.Head:GetChildren()) do
            if v.ClassName == "BodyVelocity" then
                v:Remove()
            end
        end
    end)
    if connections["changestate"] then
        connections["changestate"]:Disconnect()
        connections["changestate"] = nil
    end
    connections["changestate"] = Character.Humanoid.StateChanged:Connect(function(OldState,NewState)
        if flags["flying"] or flags["nogh"] then
            if NewState == Enum.HumanoidStateType.FallingDown or NewState == Enum.HumanoidStateType.PlatformStanding then
                Character.Humanoid:ChangeState(8)
                Character.Humanoid.PlatformStanding = false
                Character.Humanoid.Sit = false
            end
        end
    end)
end)

connections["color"] = Player.Character.DescendantAdded:Connect(function(obj)
    if obj:IsA("Trail") then
        obj.Color = values["bullet_color"]
        if flags["bullet_trails"] then
            obj.Lifetime = values["trail_time"]
            obj.Transparency = NumberSequence.new(values["trail_transparency"])
        end
    end
end)

connections["removevelocity"] = Player.Character.Humanoid.Died:Connect(function()
    if Player.Character and FindFirstChild(Player.Character, "Head") then
        for i,v in pairs(Player.Character.Head:GetChildren()) do
            if v.ClassName == "BodyVelocity" then
                v:Remove()
            end
        end
    end
end)

connections["changestate"] = Player.Character.Humanoid.StateChanged:Connect(function(OldState,NewState)
    if flags["flying"] or flags["nogh"] then
        if NewState == Enum.HumanoidStateType.FallingDown or NewState == Enum.HumanoidStateType.PlatformStanding then
            Character.Humanoid:ChangeState(8)
            Character.Humanoid.PlatformStanding = false
            Character.Humanoid.Sit = false
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, Proccesed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if MovementKeys["rightclick"] then
            values["aim_target"] = picktarget()
        end
    end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        MovementKeys["rightclick"] = true
    end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        MovementKeys["shift"] = true
        if Player and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            changeprop(Player.Character.Humanoid, "WalkSpeed", values["runspeed"])
        end
    end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MovementKeys["shift"] = true
    end
    if input.KeyCode == Enum.KeyCode.RightControl then
        UI:toggle()
    end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        if Player and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            changeprop(Player.Character.Humanoid, "WalkSpeed", values["crouchspeed"])
        end
    end
    if input.KeyCode == Enum.KeyCode.W then
        MovementKeys["w"] = true
    end
    if input.KeyCode == Enum.KeyCode.A then
        MovementKeys["a"] = true
    end
    if input.KeyCode == Enum.KeyCode.S then
        MovementKeys["s"] = true
    end
    if input.KeyCode == Enum.KeyCode.D then
        MovementKeys["d"] = true
    end
    if input.KeyCode == Enum.KeyCode.Q then
        MovementKeys["q"] = true
    end
    if input.KeyCode == Enum.KeyCode.E then
        MovementKeys["e"] = true
    end
end)

UserInputService.InputEnded:Connect(function(input, Proccesed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        MovementKeys["rightclick"] = false
    end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        MovementKeys["shift"] = false
        if Player and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            changeprop(Player.Character.Humanoid, "WalkSpeed", values["walkspeed"])
        end
    end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MovementKeys["shift"] = false
    end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        if Player and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            changeprop(Player.Character.Humanoid, "WalkSpeed", values["walkspeed"])
        end
    end
    if input.KeyCode == Enum.KeyCode.W then
        MovementKeys["w"] = false
    end
    if input.KeyCode == Enum.KeyCode.A then
        MovementKeys["a"] = false
    end
    if input.KeyCode == Enum.KeyCode.S then
        MovementKeys["s"] = false
    end
    if input.KeyCode == Enum.KeyCode.D then
        MovementKeys["d"] = false
    end
    if input.KeyCode == Enum.KeyCode.Q then
        MovementKeys["q"] = false
    end
    if input.KeyCode == Enum.KeyCode.E then
        MovementKeys["e"] = false
    end
end)

coroutine.resume(coroutine.create(function()
    while wait() do
        if values["aim_target"] and values["aim_target"].Character and values["aim_target"].Character:FindFirstChild("Torso") then -- nigger'd from cyrus gg
            if values["aim_target_pos"] then
                local Mag = (values["aim_target_pos"] - values["aim_target"].Character.Torso.Position).magnitude / values["velocity"]
                if Mag > 1 then
                    values["newvelocity"] = Mag
                else
                    values["newvelocity"] = values["velocity"]
                end
                values["aim_target_pos"] = values["aim_target"].Character.Torso.Position
            else
                values["aim_target_pos"] = values["aim_target"].Character.Torso.Position
            end
        end
        if Player and Player.Character and FindFirstChild(Player.Character, "Humanoid") then
            for i, Anim in pairs(Player.Character.Humanoid:GetPlayingAnimationTracks()) do
                local Animation = Anim.Animation
                if string.find(Animation.AnimationId, "327869970") or string.find(Animation.AnimationId, "327870302") then
                    flags["reloading"] = true
                end
            end
            flags["reloading"] = false
        end
    end
end))

coroutine.resume(coroutine.create(function()
    RunService.Stepped:Connect(function()
        if flags["noclip"] then
            if Player and Player.Character then
                for i, Base in next, Player.Character:GetDescendants() do
                    if Base:IsA'BasePart' then
                        Base.CanCollide = false 
                    end
                end
            end
        end
        if flags["blink"] then
            if MovementKeys["shift"] then
                if Player and Player.Character and FindFirstChild(Player.Character, "Humanoid") then
                    local Part = Player.Character:FindFirstChild("HumanoidRootPart") or Player.Character:FindFirstChild("Torso")
                    if Part then
                        if flags["old_blink"] then
                            if MovementKeys["w"] then
                                Part.CFrame = Part.CFrame * CFrame.new(0, 0, -values["blinkspeed"])
                            end
                            if MovementKeys["a"] then
                                Part.CFrame = Part.CFrame * CFrame.new(-values["blinkspeed"], 0, 0)
                            end
                            if MovementKeys["s"] then
                                Part.CFrame = Part.CFrame * CFrame.new(0, 0, values["blinkspeed"])
                            end
                            if MovementKeys["d"] then
                                Part.CFrame = Part.CFrame * CFrame.new(values["blinkspeed"], 0, 0)
                            end
                        else
                            Part.CFrame = Part.CFrame + Vector3.new(Player.Character.Humanoid.MoveDirection.X * values["blinkspeed"],Player.Character.Humanoid.MoveDirection.Y * values["blinkspeed"],Player.Character.Humanoid.MoveDirection.Z * values["blinkspeed"])
                        end
                    end
                end
            end
        end
    end)
end))

game.StarterGui:SetCore("SendNotification", {
    Title = "Script Loaded";
    Text = "Loaded in " .. tostring(tick() - _time):sub(1,5) .. "s";
    Icon = "rbxassetid://5168269838";
    Duration = 5;
})
