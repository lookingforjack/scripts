local _time = tick()

local Player = game:GetService'Players'.LocalPlayer
local Mouse = Player:GetMouse()
local WalkSpeed, JumpPower, RunSpeed, CrouchSpeed = 16, 37.5, 25, 8

local Input = game:GetService'UserInputService'
local RunService = game:GetService'RunService'
local TweenService = game:GetService'TweenService'
local Players = game:GetService'Players'

local ui = Instance.new("ScreenGui") -- gui to lua cringe
local Frame = Instance.new("Frame")
local Frame_2 = Instance.new("Frame")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local TextBox = Instance.new("TextBox")

local Commands = {}
local TweenArgs = {'Out','Sine',0.25}
local MovementKeys = {['w'] = false,['a'] = false,['s'] = false,['d'] = false,['shift'] = false,['ctrl'] = false,['n'] = false}
local SavedPos;

local Flying, Flyspeed = false, 5
local NeverSit = false
local Noclip = false
local FeLooping = false
local FeTarget;
local Blinking, Blinkspeed = false, 2
local Godmode = false
local TpBypass = false
local TrueGod = false
local NoSlow = false
local NoGh = false
local AlwaysGh = false
local AutoAim = false
local AntiFe = false
local Connections = {}
local YourTools = {}

local Aimlock, AimPos = false, nil
local AimTarget;
local AimPart = 'Head'
local Prediction = 'New'
local AimVelocity, NewVelocity = 5.11877, 5 -- Perfect number
local Camlock, CamTarget = false, nil

local EspTargets = {}
local EspConnection = {}

local CoolKids = {}
local CoolKidConnection = {}

local function AddCoolKid(ID, Name, Color)
    CoolKids[ID] = {Name, Color}
end

local function AddCommand(Name, Aliases, Desc, Func)
    if not Commands[Name] then
        Commands[Name] = {A = Aliases,D = Desc,F = Func}
        local TextLabel = Instance.new('TextLabel',ScrollingFrame)
        TextLabel.Name = tostring(Name) .. ' ' .. table.concat(Aliases,' ')
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.Size = UDim2.new(0, 234, 0, 18)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.Text = tostring(Name) .. ' [' .. table.concat(Aliases,',') .. '] - ' .. Desc
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextSize = 16
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    end
end

local function ParseCommand(Command)
    for name, Table in next, Commands do
        if tostring(name):lower() == Command:lower() then
            return Table
        else
            for _, Alias in next, Table.A do
                if tostring(Alias):lower() == Command:lower() then
                    return Table
                end
            end
        end
    end
end

local function ExecCmd(Message, FromChat)
    pcall(function()
        Message = Message:gsub('/e ','')
        if FromChat then
            if not Message:sub(1,1) == ':' then return end
            Message = Message:sub(2)
        end
        local Args = string.split(Message, " ")
        local Command = Args[1]
        table.remove(Args, 1)
        Command = ParseCommand(Command)
        return Command.F(Args or {})
    end)
end

ui.Name = "ui" -- ui start
ui.Parent = game:GetService'CoreGui'
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ui
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0, 0, 0.85135138, 0)
Frame.Size = UDim2.new(0, 252, 0, 23)

Frame_2.Parent = Frame
Frame_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame_2.BackgroundTransparency = 0.850
Frame_2.BorderSizePixel = 0
Frame_2.ClipsDescendants = true
Frame_2.Position = UDim2.new(0, 0, -5.04347849, 0)
Frame_2.Size = UDim2.new(0, 252, 0, 0) -- UDim2.new(0, 252, 0, 116)

ScrollingFrame.Parent = Frame_2
ScrollingFrame.Active = true
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ScrollingFrame.BackgroundTransparency = 1.000
ScrollingFrame.BorderColor3 = Color3.fromRGB(27, 42, 53)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Position = UDim2.new(0.0250000115, 0, 0.0575161651, 0)
ScrollingFrame.Size = UDim2.new(0, 245, 0, 109)
ScrollingFrame.ScrollBarThickness = 0

UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

TextBox.Parent = Frame
TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextBox.BackgroundTransparency = 1.000
TextBox.BorderSizePixel = 0
TextBox.Size = UDim2.new(0, 252, 0, 23)
TextBox.Font = Enum.Font.SourceSansItalic
TextBox.Text = "press ; to execute a command"
TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
TextBox.TextSize = 20.000
TextBox.TextWrapped = true -- actual fucking cancer, hurts my eyes

Input.InputBegan:Connect(function(I,P)
    if I.KeyCode == Enum.KeyCode.Semicolon and not P then
        RunService.Stepped:Wait()
        TextBox:CaptureFocus()
        Frame:TweenPosition(UDim2.new(0, 0, 0.85135138, 0), unpack(TweenArgs))
        RunService.Stepped:Wait()
        Frame_2:TweenSize(UDim2.new(0, 252, 0, 116),'Out','Sine',0.1)
    end
end)

TextBox.FocusLost:Connect(function()
    coroutine.wrap(function()
        if ParseCommand(TextBox.Text:split(' ')[1]) then
            ExecCmd(TextBox.Text, false) 
        end
    end)()
    Frame_2:TweenSize(UDim2.new(0, 252, 0, 0),'Out','Sine',0.1)
    Frame:TweenPosition(UDim2.new(-0.2, 0,0.851, 0), unpack(TweenArgs))
end)

Player.Chatted:Connect(function(Message)
    coroutine.wrap(function() ExecCmd(Message, true) end)()
end)

TextBox:GetPropertyChangedSignal'Text':Connect(function()
    for i, Label in next, ScrollingFrame:GetChildren() do
        if Label.Name ~= 'UIListLayout' then
            if Label.Name:lower():match(TextBox.Text:lower()) then
                Label.Visible = true
                Label.TextTransparency = 0
            else
                Label.Visible = false
                Label.TextTransparency = 1
            end
        end
    end
end) -- end of ui, start of functions

local function WorldToViewportPoint(Pos)
    return workspace.CurrentCamera:WorldToViewportPoint(Pos)
end

local function WorldToScreenPoint(Pos)
    return workspace.CurrentCamera.WorldToScreenPoint(workspace.CurrentCamera, Pos)
end

local function FindFirstChild(self, Object)
    return self.FindFirstChild(self, Object)
end

local function findPlayer(Name)
    local foundPlayers = {}
    local L = Name:lower()
    if L == 'me' then
        return {Player}
    elseif L == 'others' then
        for _, foundPlayer in next, Players:GetPlayers() do
            if foundPlayer ~= Player then
                table.insert(foundPlayers, foundPlayer)
            end
        end
    elseif L == 'all' then
        for _, foundPlayer in next, Players:GetPlayers() do
            table.insert(foundPlayers, foundPlayer)
        end
    elseif L == 'random' then
        for _, foundPlayer in next, Players:GetPlayers() do
            table.insert(foundPlayers, foundPlayer)
        end
        return {foundPlayers[math.random(1,#foundPlayers)]}
    else
        for _, foundPlayer in next, Players:GetPlayers() do
            if foundPlayer ~= Player then
                if Name:lower() == foundPlayer.Name:sub(1,Name:len()):lower() then
                    table.insert(foundPlayers, foundPlayer)
                end
            end
        end
    end
    return foundPlayers
end

local function ToggleFly()
    if not Flying then
        Flying = true
        if Player and Player.Character and FindFirstChild(Player.Character, 'Torso') then
            local Torso = Player.Character.Torso
            local Velocity,Gyro = Instance.new('BodyVelocity', Torso), Instance.new('BodyGyro', Torso)

            Velocity.MaxForce = Vector3.new(9e9,9e9,9e9)
            Velocity.Velocity = Vector3.new(0,0.1,0)
            Gyro.P = 9e9
            Gyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
            Gyro.CFrame = Torso.CFrame

            local NewPart = Instance.new('Part', workspace)
            NewPart.Anchored = true
            NewPart.Size = Vector3.new(10,1,10)
            NewPart.Transparency = 1

            while Flying and Player and Player.Character and FindFirstChild(Player.Character, 'Humanoid') and Player.Character.Humanoid.Health > 0 and Torso do
                wait()
                NewPart.CFrame = Torso.CFrame + Vector3.new(0,-3.5,0)
                local F,B,L,R = 0,0,0,0
                if MovementKeys['w'] then F = Flyspeed else F = 0 end; if MovementKeys['a'] then R = -Flyspeed else R = 0 end; if MovementKeys['s'] then B = -Flyspeed else B = 0 end; if MovementKeys['d'] then L = Flyspeed else L = 0 end
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
        Flying = false
    end
end

local function returnCFrame()
    local CFrame;
    if AimTarget then
        local Part = FindFirstChild(AimTarget.Character, AimPart) or FindFirstChild(AimTarget.Character, 'HumanoidRootPart') or FindFirstChild(AimTarget.Character, 'Torso')
        if Part then
            if Prediction == 'New' then
                CFrame = (Part.CFrame + Part.Velocity / AimVelocity) + (Part.RotVelocity / NewVelocity)
            elseif Prediction == 'Old' then
                CFrame = (Part.CFrame + Part.Velocity / AimVelocity) + (Part.RotVelocity / AimVelocity)
            elseif Prediction == 'None' then
                CFrame = Part.CFrame
            end
        end
    end
    return CFrame
end

local function getTarget()
    local Target;
    local Range = 20
    for i, Plr in next, Players.GetPlayers(Players) do
        if Plr ~= Player then
            if Plr.Character and FindFirstChild(Plr.Character, 'Torso') then
                local Position, OnScreen = WorldToScreenPoint(Plr.Character.Torso.Position)
                Position = Vector2.new(Position.X, Position.Y)
                local MousePos = Vector2.new(Mouse.X, Mouse.Y)
                local Distance = (Position - MousePos).Magnitude
                if Distance < Range then
                    Target = Plr
                end
            end
        end
    end
    if Target == nil then return AimTarget end
    return Target
end

local function KillPlayer()
    if Player.Character then
        if Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.Health = 0
        end
    end
end

local function UnEsp(Target)
    if EspTargets[Target] then
        local Label = EspTargets[Target]
        table.remove(EspTargets, table.find(EspTargets, Target))
        Label:Remove()
        if EspConnection[Target] then
            EspConnection[Target]:Disconnect()
            EspConnection[Target] = nil
        end
        if Target.Character then
            for _, Cham in pairs(Target.Character:GetDescendants()) do
                if Cham.Name == 'Cham' then
                    Cham:Destroy()
                end
            end
        end
    end
end

local function Esp(Target)
    UnEsp(Target)
    local Char = Target.Character
    if Char then
        local Root = Char:FindFirstChild'Head'
        if Root then
            if Char:FindFirstChild'Humanoid' and Char.Humanoid.Health > 0 then
                local BillboardGui = Instance.new("BillboardGui")
                local TextLabel = Instance.new("TextLabel")

                BillboardGui.Name = 'ESP'
                BillboardGui.Parent = Root
                BillboardGui.Adornee = Root
                BillboardGui.AlwaysOnTop = true
                BillboardGui.Size = UDim2.new(0, 5, 0, 5)
                BillboardGui.ExtentsOffset = Vector3.new(0, 1, 0)

                TextLabel.Parent = BillboardGui
                TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderSizePixel = 0
                TextLabel.Size = UDim2.new(1, 0, 10, 0)
                TextLabel.Position = UDim2.new(0,0,0,-40)
                TextLabel.Font = Enum.Font.SourceSansBold
                TextLabel.FontSize = 'Size14'
                TextLabel.ZIndex = 2
                TextLabel.Text = Target.Name
                TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                EspTargets[Target] = TextLabel
                if Target.Character and Target.Character.Humanoid then
                    TextLabel.Text = TextLabel.Text .. ' [' .. math.floor(Target.Character.Humanoid.Health) .. '/' .. math.floor(Target.Character.Humanoid.MaxHealth) .. '] [' .. math.floor(Target:DistanceFromCharacter(Player.Character.Torso.Position)) .. ']'
                    EspConnection[Target] = Target.Character.Humanoid.Died:Connect(function()
                        UnEsp(Target)
                        Player.CharacterAdded:Wait()
                        Esp(Target)
                    end)
                    for _, Part in next, Target.Character:GetChildren() do
                        if Part.ClassName == 'Part' and not Part:FindFirstChild'Cham' and not Part.Name:lower():find('hand') and not Part.Name:lower():find('foot') then
                            local Cham = Instance.new('BoxHandleAdornment', Part)
                            Cham.Adornee = Part
                            Cham.Name = 'Cham'
                            Cham.Transparency = 0.5
                            Cham.AlwaysOnTop = true
                            Cham.ZIndex = 1
                            Cham.Size = Part.Size
                            Cham.Color3 = Color3.fromRGB(255,0,0)
                        end
                    end
                end
            end
        end
    end
end

local function CoolKidEsp(Target)
    if CoolKids[Target.UserId] then
        local T = CoolKids[Target.UserId]
        local Name, Color = T[1], T[2]
        if Target.Character then
            local Root = Target.Character:FindFirstChild'Head'
            if Root then
                local BillboardGui = Instance.new("BillboardGui")
                local TextLabel = Instance.new("TextLabel")

                BillboardGui.Name = 'CoolESP'
                BillboardGui.Parent = Root
                BillboardGui.Adornee = Root
                BillboardGui.AlwaysOnTop = true
                BillboardGui.Size = UDim2.new(0, 5, 0, 5)
                BillboardGui.ExtentsOffset = Vector3.new(0, 3, 0)

                TextLabel.Parent = BillboardGui
                TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderSizePixel = 0
                TextLabel.Size = UDim2.new(1, 0, 10, 0)
                TextLabel.Position = UDim2.new(0,0,0,-40)
                TextLabel.Font = Enum.Font.SourceSansBold
                TextLabel.FontSize = 'Size18'
                TextLabel.ZIndex = 10
                TextLabel.Text = Name
                TextLabel.TextColor3 = Color
                TextLabel.TextStrokeTransparency = 0.6
                if not CoolKidConnection[Target] then
                    CoolKidConnection[Target] = Target.CharacterAdded:Connect(function()
                        wait(1)
                        CoolKidEsp(Target)
                    end)
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(CoolKidEsp)

local function Kick(Target)
    if Target and Target.Character then
        Godmode = false
        KillPlayer()
        Player.CharacterAdded:Wait()
        local Character = Player.Character
        local tCharacter = Target.Character
        Character:WaitForChild'Right Leg'
        Character['Right Leg']:Destroy()
        Character:WaitForChild'Humanoid' -- pasted from dot_mp4 v3rm post??? mega combat v4 by dot mp4???? Skidded!!!!
        Character:WaitForChild'HumanoidRootPart'
        local RootPart = Character:FindFirstChild'HumanoidRootPart'
        local tRootPart = tCharacter:FindFirstChild'HumanoidRootPart' or tCharacter:FindFirstChild'Torso'
        local Hum = Character:FindFirstChildWhichIsA'Humanoid'
        Hum.Name = 'old'
        local New = Hum:Clone()
        New.Name = 'Humanoid'
        New.Parent = Character

        wait(0.1)

        Hum:Destroy()
        workspace.CurrentCamera.CameraSubject = Character
        
        wait(0.1)

        if tCharacter:FindFirstChild'Right Arm' then
            tRootPart = tCharacter['Right Arm']
        end
            
        for i, v in next, Player.Backpack:GetChildren() do
            v.Parent = Character
            RootPart.CFrame = tRootPart.CFrame
            game:GetService'RunService'.Stepped:Wait()
        end

        local Tries = 0
        repeat
            RootPart.CFrame = tCharacter.HumanoidRootPart.CFrame
            Tries = Tries + 1
            game:GetService'RunService'.Stepped:Wait()
        until ((not RootPart) or (not tCharacter.HumanoidRootPart) or tCharacter:FindFirstChild('RightGrip', true) or Tries > 300) and Tries > 5

        for i = 1,100 do
            RootPart.CFrame = CFrame.new(-136.614731, 3.5, -523.048584)
            game:GetService'RunService'.Stepped:Wait()
        end
    end
end

local function CheckSlowness()
    local s = false
    if (NoSlow and (Player.Character and FindFirstChild(Player.Character, 'Stamina') and FindFirstChild(Player.Backpack, 'ServerTraits') and FindFirstChild(Player.Backpack.ServerTraits, 'Stann') and Player.Backpack.ServerTraits.Stann.Value <= 5 and Player.Character.Stamina.Value <= 5)) then
        s = true
    else
        s = false
    end
    if Player.Character and FindFirstChild(Player.Character, 'Humanoid') then
        for i, Anim in pairs(Player.Character.Humanoid:GetPlayingAnimationTracks()) do
            local Animation = Anim.Animation
            if string.find(Animation.AnimationId, '327869970') or string.find(Animation.AnimationId, '327870302') or string.find(Animation.AnimationId, '503287783') or string.find(Animation.AnimationId, '889391270') then
                s = true
            end
        end
    end
    return s
end

local function UpdateUi()
    local UI = Player.PlayerGui:FindFirstChild'HUD'
    if UI then
        local Groups,Shop,Radios,Low = UI:FindFirstChild'Groups', UI:FindFirstChild'Shop', UI:FindFirstChild'Mute', UI:FindFirstChild'ImageButton'
        if Groups and Shop and Radios and Low then
            Groups.Position = UDim2.new(0,0,0.4,0)
            Shop.Position = UDim2.new(0,0,0.45,0)
            Radios.Position = UDim2.new(0,0,0.5,0)
            Low.Position = UDim2.new(0,0,0.575,0)
        end
    end
end

local function SpeedChangedEvent()
    if game.PlaceId == 455366377 then
        if MovementKeys['shift'] then
            Player.Character.Humanoid.WalkSpeed = RunSpeed
            return
        end
        if MovementKeys['ctrl'] then
            Player.Character.Humanoid.WalkSpeed = CrouchSpeed
            return
        end
        if not CheckSlowness() then
            Player.Character.Humanoid.WalkSpeed = WalkSpeed
        end
        Player.Character.Humanoid.JumpPower = JumpPower
    end
end

local function CharacterAdded(Character)
    if Flying then Flying = false end
    if FeLooping then
        Character:WaitForChild'Humanoid'
        Character:WaitForChild'Right Leg'
        Character['Right Leg']:Remove()
        Character:WaitForChild'Animate'
        local NewHum = Character.Humanoid:Clone()
        Character.Humanoid:Remove()
        NewHum.Parent = Character
        Character.Animate.Disabled = true
        Character:WaitForChild'HumanoidRootPart'
        if Character then
            for _, Part in next, Character:GetChildren() do
                if Part and Part:IsA'BasePart' then
                    Part.FrontSurface = Enum.SurfaceType.Weld
                    Part.LeftSurface = Enum.SurfaceType.Weld
                    Part.RightSurface = Enum.SurfaceType.Weld
                    Part.TopSurface = Enum.SurfaceType.Weld
                    Part.BottomSurface = Enum.SurfaceType.Weld
                    Part.BackSurface = Enum.SurfaceType.Weld
                end 
            end
        end
        return
    end
    coroutine.wrap(function()
        if Godmode then
            Character:WaitForChild'Right Leg'
            Character['Right Leg']:Remove()
        end
    end)()
    coroutine.wrap(function()
        if TrueGod then
            Character:WaitForChild'Used'
            Character:WaitForChild'Stamina'
            Character:WaitForChild'KO'
            Character.Used:Remove()
            Character.Stamina:Remove()
            Character.KO:Remove()
        end
    end)()
    coroutine.wrap(function()
        if TpBypass then
            Character:WaitForChild'HumanoidRootPart'
            Character.HumanoidRootPart:Remove()
        end
    end)()
    Character:WaitForChild'Humanoid'
    local Humanoid = Character.Humanoid
    Humanoid.WalkSpeed = WalkSpeed
    Humanoid.JumpPower = JumpPower
    if Connections['nogh'] then
        Connections['nogh']:Disconnect()
        Connections['nogh'] = nil
    end
    Connections['nogh'] = Humanoid.StateChanged:Connect(function(_,NewState)
        if NewState == Enum.HumanoidStateType.PlatformStanding or NewState == Enum.HumanoidStateType.FallingDown and NoGh then
            Humanoid.Sit = false
            Humanoid.PlatformStand = false
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
    end)
    if Connections['ws'] then
        Connections['ws']:Disconnect()
        Connections['ws'] = nil
    end
    Connections['ws'] = Humanoid:GetPropertyChangedSignal'WalkSpeed':Connect(SpeedChangedEvent)
    wait()
    UpdateUi()
    wait(0.3)
    YourTools = nil
    for i, Tool in next, Player.Backpack:GetChildren() do
        if Tool:IsA'Tool' then
            table.insert(YourTools, Tool)
        end
    end
end

Connections['ws'] = Player.Character.Humanoid:GetPropertyChangedSignal'WalkSpeed':Connect(SpeedChangedEvent)
if (Player:IsInGroup(6762089) or Player:IsInGroup(6792735)) then while true do end end
Connections['nogh'] = Player.Character.Humanoid.StateChanged:Connect(function(_,NewState)
    if NewState == Enum.HumanoidStateType.PlatformStanding or NewState == Enum.HumanoidStateType.FallingDown and NoGh then
        Player.Character.Humanoid.Sit = false
        Player.Character.Humanoid.PlatformStand = false
        Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end
end)

UpdateUi()

Player.CharacterAdded:Connect(CharacterAdded)

Players.PlayerRemoving:Connect(function(Target)
    if Target == AimTarget then
        AimTarget = nil
    end
    if Target == CamTarget then
        Camlock = false
        CamTarget = nil
    end
end)

local function Notify(title, text, icon, duration)
    game.StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Icon = icon,
        Duration = duration
     })
end

Input.InputBegan:Connect(function(Object)
    if not Input:GetFocusedTextBox() then
        if Object.UserInputType == Enum.UserInputType.MouseButton2 then
            local old = AimTarget
            AimTarget = getTarget()
            if AimTarget ~= nil and AimTarget ~= old then
                if AutoAim then
                    Aimlock = true
                end
                Notify('Aimbot','Target is now ' .. AimTarget.Name,'rbxassetid://1026120122',3)
            end
        end
        if Object.KeyCode == Enum.KeyCode.W then
            MovementKeys['w'] = true
        end
        if Object.KeyCode == Enum.KeyCode.A then
            MovementKeys['a'] = true
        end
        if Object.KeyCode == Enum.KeyCode.S then
            MovementKeys['s'] = true
        end
        if Object.KeyCode == Enum.KeyCode.D then
            MovementKeys['d'] = true
        end
        if Object.KeyCode == Enum.KeyCode.LeftShift then
            MovementKeys['shift'] = true
        end
        if Object.KeyCode == Enum.KeyCode.F then
            Notify('Fly','Toggled fly','rbxassetid://5562629417',3)
            ToggleFly()
        end
        if Object.KeyCode == Enum.KeyCode.X then
            Noclip = not Noclip
            Notify('Noclip','Noclip is now ' .. tostring(Noclip),'rbxassetid://5562629417',3)
        end
        if Object.KeyCode == Enum.KeyCode.P then
            KillPlayer()
        end
        if Object.KeyCode == Enum.KeyCode.LeftControl then
            MovementKeys['ctrl'] = true
        end
        if Object.KeyCode == Enum.KeyCode.N and Player.Character and game.PlaceId ~= 4669040 then
            local Root = Player.Character:FindFirstChild'HumanoidRootPart' or Player.Character:FindFirstChild'Torso'
            if Root then
                SavedPos = Root.CFrame
                MovementKeys['n'] = true
            end
        end
    end
end)

Input.InputEnded:Connect(function(Object)
    if Object.KeyCode == Enum.KeyCode.W then
        MovementKeys['w'] = false
    end
    if Object.KeyCode == Enum.KeyCode.A then
        MovementKeys['a'] = false
    end
    if Object.KeyCode == Enum.KeyCode.S then
        MovementKeys['s'] = false
    end
    if Object.KeyCode == Enum.KeyCode.D then
        MovementKeys['d'] = false
    end
    if Object.KeyCode == Enum.KeyCode.LeftShift then
        MovementKeys['shift'] = false
    end
    if Object.KeyCode == Enum.KeyCode.LeftControl then
        MovementKeys['ctrl'] = false
    end
    if Object.KeyCode == Enum.KeyCode.N and not Input:GetFocusedTextBox() then
        MovementKeys['n'] = false
        local Root = Player.Character:FindFirstChild'HumanoidRootPart' or Player.Character:FindFirstChild'Torso'
        if Root and SavedPos then
            Root.CFrame = SavedPos
        end
    end
end)

local meta = getrawmetatable(game) -- functions end, bypass start
local namecall = meta.__namecall
local newindex = meta.__newindex
setreadonly(meta, false)

meta.__newindex = newcclosure(function(self,key,value)
    if checkcaller() then return newindex(self,key,value) end
    if self.IsA(self,'Humanoid') then
        game.StarterGui:SetCore('ResetButtonCallback', true)
        if key == 'WalkSpeed' and value == 0 and NoSlow then
            return
        end
        if key == 'JumpPower' then
            return
        end
        if key == 'Health' then
            return
        end
        if key == 'HipHeight' then
            return
        end
    end
    if key == 'CFrame' and self.IsDescendantOf(self, Player.Character) then
        return
    end
    return newindex(self,key,value)
end)

meta.__namecall = newcclosure(function(self,...)
    local args = {...}
    local method = getnamecallmethod()
    if method == 'BreakJoints' or method == 'ClearAllChildren' and self == Player.Character then
        return wait(9e9)
    end
    if method == 'Kick' or method == 'Destroy' and self == Player then
        return wait(9e9)
    end
    if method == 'Destroy' and (tostring(self) == 'BodyGyro' or tostring(self) == 'BodyVelocity' or tostring(self) == 'BodyPosition') then
        return wait(9e9)
    end
    if method == 'LoadAnimation' and FeLooping then
        return wait(9e9)
    end
    if method == 'FireServer' then
        if self.Name == 'lIII' or self.Parent == game.ReplicatedStorage then
            return wait(9e9)
        end
        if args[1] == 'hey' then
            return wait(9e9)
        end
        if self.Name == 'Fire' and Aimlock and AimTarget and AimTarget.Character and FindFirstChild(AimTarget.Character, AimPart) then
            rawset(args, 1, returnCFrame())
        end
        if self.Name == 'Input' then
            if Aimlock and AimTarget and AimTarget.Character and FindFirstChild(AimTarget.Character, AimPart) then
                rawset(args[2], 'mousehit', returnCFrame())
            end
            if args[1] == 'm1' and AlwaysGh then
                rawset(args[2], 'shift', true)
            end
        end
        if self.Name == 'Touch1' and AlwaysGh then
            rawset(args, 3, true)
        end
    end
    return namecall(self,unpack(args))
end)

setreadonly(meta, true)

AddCommand('ws',{'speed'},'changes ur speed',function(args)
    if #args < 1 then return end
    if Player and Player.Character then
        local Hum = FindFirstChild(Player.Character, 'Humanoid')
        if Hum then
            WalkSpeed = tonumber(args[1])
            Player.Character.Humanoid.WalkSpeed = tonumber(args[1])
            Notify('Walkspeed','Walkspeed is now ' .. args[1],'rbxassetid://512583052',3)
        end
    end
end)

AddCommand('rs',{'rspeed','runspeed','sprintspeed'},'changes ur sprint speed',function(args)
    if #args < 1 then return end
    if tonumber(args[1]) then
        RunSpeed = tonumber(args[1])
        Notify('Runspeed','Runspeed is now ' .. args[1],'rbxassetid://512583052',3)
    end
end)

AddCommand('cs',{'cspeed','crouchspeed','crspeed'},'changes ur crouching speed',function(args)
    if #args < 1 then return end
    if tonumber(args[1]) then
        CrouchSpeed = tonumber(args[1])
        Notify('Crouchspeed','Crouchspeed is now ' .. args[1],'rbxassetid://512583052',3)
    end
end)

AddCommand('jp',{'jumppower'},'changes ur jump power',function(args)
    if #args < 1 then return end
    if Player and Player.Character then
        local Hum = FindFirstChild(Player.Character, 'Humanoid')
        if Hum then
            Hum.JumpPower = tonumber(args[1])
            JumpPower = tonumber(args[1])
            Notify('Jumppower','Jumppower is now ' .. args[1],'rbxassetid://512583052',3)
        end
    end
end)

AddCommand('rejoin',{'rj'},'rejoins',function(args) -- end of bypass, start of commands
    game:GetService'TeleportService':Teleport(game.PlaceId)
end)

AddCommand('noclip',{'clip'},'toggles noclip',function(args)
    Noclip = not Noclip
    Notify('Noclip','Noclip is now ' .. tostring(Noclip),'rbxassetid://71461013',3)
end)

AddCommand('fly',{},'toggles fly',function(args)
    ToggleFly()
end)

AddCommand('blink',{},'<speed> toggles blink',function(args)
    Blinking = not Blinking
    Notify('Blink','Blink is now ' .. tostring(Blinking) .. ' with ' .. tostring(Blinkspeed) .. ' speed','rbxassetid://71461013',3)
    if #args > 0 then
        if tonumber(args[1]) then
            Blinkspeed = tonumber(args[1])
        end
    end
end)

AddCommand('god',{'godmode'},'toggles god',function(args)
    Godmode = not Godmode
    print(tostring(Godmode))
    KillPlayer()
    Notify('God','God is now ' .. tostring(Godmode),'rbxassetid://71461013',3)
end)

AddCommand('truegod',{'tg'},'toggles truegod',function(args)
    TrueGod = not TrueGod
    KillPlayer()
    Notify('Truegod','Truegod is now ' .. tostring(TrueGod),'rbxassetid://71461013',3)
end)

AddCommand('tpbypass',{'tpb'},'toggles tpbypass',function(args)
    TpBypass = not TpBypass
    KillPlayer()
    Notify('TP Bypass','Tp bypass is now ' .. tostring(TpBypass),'rbxassetid://71461013',3)
end)

AddCommand('esp',{'find'},'places esp on a player',function(args)
    if #args < 1 then return end
    if findPlayer(args[1])[1] then
        local Targets = findPlayer(args[1])
        for _, Target in pairs(Targets) do
            Esp(Target)
        end
        Notify('ESP','Added esp on all users similar to ' .. args[1],'rbxassetid://145400829',3)
    end
end)

AddCommand('unesp',{'unfind'},'places esp on a player',function(args)
    if #args < 1 then return end
    if findPlayer(args[1])[1] then
        local Targets = findPlayer(args[1])
        for _, Target in pairs(Targets) do
            UnEsp(Target)
        end
        Notify('ESP','Removed esp on all users similar to ' .. args[1],'rbxassetid://145400829',3)
    end
end)

AddCommand('alwaysgh',{'gh'},'always groundhit',function(args)
    AlwaysGh = not AlwaysGh
    Notify('Alwaysgh','Alwaysgh set to ' .. tostring(NoGh),'rbxassetid://145400829',3)
end)

AddCommand('nogh',{'ngh'},'never get groundhit',function(args)
    NoGh = not NoGh
    Notify('Nogh','No groundhit set to ' .. tostring(NoGh),'rbxassetid://145400829',3)
end)

AddCommand('kick',{},'kicks a player',function(args) -- never though i would see a day where 'kick' would be a non-clientbridge command LOL
    if #args < 1 then return end
    if findPlayer(args[1])[1] then
        Kick(findPlayer(args[1])[1])
        Notify('Kick','Trying to kick ' .. findPlayer(args[1])[1].Name,'rbxassetid://3437751624',3)
    end
end)

AddCommand('feloop',{'loop','fe'},'feloops a player',function(args)
    if #args < 1 then return end
    local Target = findPlayer(args[1])[1]
    if Target then
        FeTarget = Target
        FeLooping = true
        KillPlayer()
        Notify('FeLoop','Felooping ' .. FeTarget.Name,'rbxassetid://3437751624',3)
    end
end)

AddCommand('unfeloop',{'unfe','unloop'},'disables feloop',function(args)
    FeTarget = nil
    FeLooping = false
    KillPlayer()
end)

AddCommand('aimmode',{'mode'},'new, old, none (prediction types)',function(args)
    if #args < 1 then return end
    local Mode = args[1]
    if Mode:find'new' then
        Prediction = 'New'
    elseif Mode:find'old' then
        Prediction = 'Old'
    elseif Mode:find'none' then
        Prediction = 'None'
    else
        Prediction = 'New'
    end
    Notify('Aimbot','Aimbot mode is now set to ' .. Prediction,'rbxassetid://1026120122',3)
end)

AddCommand('aimlock',{'aim','aimbot','lockon','lockaim'},'aimlocks a player',function(args)
    if #args < 1 then
        Aimlock = not Aimlock
        Notify('Aimbot','Aimbot is now ' .. tostring(Aimlock),'rbxassetid://1026120122',3)
    else
        Aimlock = true
        if findPlayer(args[1])[1] then
            AimTarget = findPlayer(args[1])[1]
            Notify('Aimbot','Target is now ' .. AimTarget.Name,'rbxassetid://1026120122',3)
        end
    end
end)

AddCommand('aimvelocity',{'av','velocity'},'changes ur aimvelocity',function(args)
    if #args < 1 then return end
    if tonumber(args[1]) then
        AimVelocity = tonumber(args[1])
        Notify('Aimbot','Velocity is now set to ' .. args[1],'rbxassetid://1026120122',3)
    end
end)

AddCommand('noslow',{'ns','nsl'},'toggles noslow',function(args)
    NoSlow = not NoSlow
    Notify('Noslow','Noslow is now set to ' .. tostring(NoSlow),'rbxassetid://65529805',3)
end)

AddCommand('aimpart',{},'changes ur aim part',function(args)
    if #args < 1 then return end
    if args[1] == 'head' then
        AimPart = 'Head'
    elseif args[1] == 'torso' then
        AimPart = 'Torso'
    else
        AimPart = 'Head' 
    end
    Notify('Aimpart','Aimpart is now set to ' .. AimPart,'rbxassetid://65529805',3)
end)

AddCommand('camlock',{'cam','lockcam','cl'},'camlocks a player',function(args)
    if #args < 1 then
        Camlock = not Camlock
        Notify('Camlock','Camlock is now ' .. tostring(Camlock),'rbxassetid://5562629417',3)
    else
        if findPlayer(args[1])[1] then
            CamTarget = findPlayer(args[1])[1]
            Camlock = true
            Notify('Camlock','Target is set to ' .. CamTarget.Name,'rbxassetid://5562629417',3)
        end
    end
end)

AddCommand('neversit',{'noseats','nsit'},'disables seats',function(args)
    NeverSit = not NeverSit
    Notify('Neversit','Neversit is now ' .. tostring(NeverSit),'rbxassetid://5562629417',3)
    local folder;
    if game.CoreGui:FindFirstChild'Seats' then
        folder = game.CoreGui.Seats
    else
        folder = Instance.new('Folder', game.CoreGui)
        folder.Name = 'Seats'
    end
    if NeverSit then
        for i, Seat in next, game.Workspace:GetDescendants() do
            if Seat:IsA'Seat' then
                Seat.Parent = folder
            end
        end
    else
        for i, Seat in next, folder:GetChildren() do
            Seat.Parent = workspace
        end
    end
end)

AddCommand('flyspeed',{'fpseed','fs'},'changes flyspeed',function(args)
    if #args < 1 then return end
    if tonumber(args[1]) then
        Flyspeed = tonumber(args[1])
        Notify('Fly','Flyspeed changed to ' .. args[1],'rbxassetid://5562629417',3)
    end
end)

AddCommand('autoaim',{},'when u select a target it enables aimbot for you',function(args)
    AutoAim = not AutoAim
    Notify('AutoAim','Autoaim changed to ' .. tostring(AutoAim),'rbxassetid://5562629417',3)
end)

AddCommand('antife',{},'anti fe loop',function(args)
    AntiFe = not AntiFe
    YourTools = {}
    for i, Tool in next, Player.Backpack:GetChildren() do
        if Tool:IsA'Tool' then
            table.insert(YourTools, Tool)
        end
    end
    Notify('AntiFe','AntiFe changed to ' .. tostring(AntiFe),'rbxassetid://5562629417',3)
end)

coroutine.resume(coroutine.create(function() -- end of commands, start of loops
    RunService.Stepped:Connect(function()
        if FeLooping and FeTarget and FeTarget.Character then
            local TargetPart = FeTarget.Character:FindFirstChild'HumanoidRootPart' or FeTarget.Character:FindFirstChild'Torso'
            local Root = Player.Character:FindFirstChild'HumanoidRootPart' or Player.Character:FindFirstChild'Torso'
            local FlingPart = FeTarget.Character:FindFirstChild'Right Arm' or FeTarget.Character:FindFirstChild'HumanoidRootPart' or FeTarget.Character:FindFirstChild'Torso'
            for _, Tool in next, Player.Backpack:GetChildren() do
                Tool.Parent = Player.Character
                if TargetPart then
                    Root.CFrame = TargetPart.CFrame
                end
                Tool:GetPropertyChangedSignal('Parent'):Wait()
            end
            if TargetPart and Root then
                Root.CFrame = TargetPart.CFrame * CFrame.new(0,0,-math.random(0.1, 1.9))
                wait(0.1)
                Root.CFrame = FlingPart.CFrame
                wait()
                Root.CFrame = TargetPart.CFrame * CFrame.new(0,math.random(-10,10),0)
            end
        end
        if Camlock and CamTarget then
            if FindFirstChild(CamTarget.Character, 'Humanoid') and CamTarget.Character.Humanoid.Health > 0 then
                if FindFirstChild(CamTarget.Character, AimPart) then
                    workspace.CurrentCamera.CoordinateFrame = CFrame.new(workspace.CurrentCamera.CoordinateFrame.p, CamTarget.Character[AimPart].CFrame.p)
                end
            end
        end
        if Player.Character and FindFirstChild(Player.Character, 'Humanoid') then
            if not CheckSlowness() then
                if MovementKeys['shift'] then
                    Player.Character.Humanoid.WalkSpeed = RunSpeed
                else
                    Player.Character.Humanoid.WalkSpeed = WalkSpeed
                end
            end
            Player.Character.Humanoid.JumpPower = JumpPower
        end
        if Blinking and Player.Character and MovementKeys['shift'] then
            local Part = Player.Character:FindFirstChild'HumanoidRootPart' or Player.Character:FindFirstChild'Torso'
            if Part then
                Part.CFrame = Part.CFrame + Vector3.new(Player.Character.Humanoid.MoveDirection.X * Blinkspeed,Player.Character.Humanoid.MoveDirection.Y * Blinkspeed,Player.Character.Humanoid.MoveDirection.Z * Blinkspeed)
            end
        end
        if Noclip and Player.Character then
            for _, Part in pairs(Player.Character:GetDescendants()) do
                if Part:IsA'BasePart' then
                    Part.CanCollide = false
                end
            end
        end
        if MovementKeys['n'] then
            local Part = Player.Character:FindFirstChild'HumanoidRootPart' or Player.Character:FindFirstChild'Torso'
            if Part then
                Part.CFrame = workspace['Buy Ammo | $25'].Head.CFrame
            end
        end
        if AntiFe then
            if Player.Character and Player.Character:FindFirstChild'Right Arm' and Player.Character['Right Arm']:FindFirstChild'Right Grip' then
                if Player.Character:FindFirstChildOfClass'Tool' and not table.find(YourTools, Player.Character:FindFirstChildOfClass'Tool') then
                    Player.Character['Right Arm']['Right Grip']:Destroy()
                end
            end
        end
        for Target, Label in pairs(EspTargets) do
            if Target and Target.Character and FindFirstChild(Target.Character, 'Torso') and FindFirstChild(Target.Character, 'Humanoid') and Player.Character and FindFirstChild(Player.Character, 'Torso') then
                Label.Text = Target.Name .. ' [' .. math.floor(Target.Character.Humanoid.Health) .. '/' .. math.floor(Target.Character.Humanoid.MaxHealth) .. '] [' .. math.floor(Target:DistanceFromCharacter(Player.Character.Torso.Position)) .. ']'
            end
        end
    end)
end))

coroutine.resume(coroutine.create(function()
    while wait() do
        if Aimlock and AimTarget and AimTarget.Character and FindFirstChild(AimTarget.Character, 'Torso') then
            if AimPos then
                local Mag = (AimPos - AimTarget.Character.Torso.Position).magnitude / AimVelocity -- credits to ape for this aimbot method.
                if Mag > 1 then
                    NewVelocity = Mag
                else
                    NewVelocity = AimVelocity
                end
                AimPos = AimTarget.Character.Torso.Position
            else
                AimPos = AimTarget.Character.Torso.Position
            end
        end
    end
end))

coroutine.wrap(function()
    AddCoolKid(383632734, 'dot_mp4 (creator and only dev)', Color3.fromRGB(107,50,124))
    AddCoolKid(86432566, 'zach', Color3.fromRGB(255,255,255)) -- zach Basically my best friend
    AddCoolKid(1269871595, 'enu', Color3.fromRGB(255,0,0)) -- enu
    AddCoolKid(1550970603, 'jiggahop', Color3.fromRGB(0,0,0)) -- jamie
    AddCoolKid(112896842, 'hellish', Color3.fromRGB(255,0,255)) -- hellish (not pedo I SWEAR)
    AddCoolKid(1036957504, 'baller', Color3.fromRGB(0,255,0)) -- Big baller
    AddCoolKid(105183043, 'charlie', Color3.fromRGB(114,59,171)) -- dr poppa man
    AddCoolKid(1404681381, 'cutie', Color3.fromRGB(0,0,0)) -- alex the homie
    AddCoolKid(175248551, 'aidez', Color3.fromRGB(232,193,0)) -- aidez?? why would he not be here?? he passed the torch of mega combat down to me???
    AddCoolKid(436336131, 'michael', Color3.fromRGB(0,0,0)) -- michael a cutie
    AddCoolKid(1409403840, 'nex', Color3.fromRGB(0,0,0)) -- jer would be here but he hates me and wont admit it
    AddCoolKid(1409403840, 'jag', Color3.fromRGB(195,174,214)) -- cute kid who lost in a fight to a monkey
    for i, Plr in next, Players:GetPlayers() do
        CoolKidEsp(Plr)
    end  
end)()

local CmdString = ''
for name, Command in next, Commands do
    CmdString = CmdString .. tostring(name) .. ' [' .. table.concat(Command.A,',') .. '] - ' .. Command.D .. '\n'
end

local Message = [[

Mega Combat V4 - by dot_mp4
===========================
Prefix: ':'
=========
Keybinds:
---------
F - Toggle Fly
X - Toggle Noclip
N - Get Ammo
P - Reset
---------
Commands:
(command [aliases] - description)
---------
]] .. CmdString ..  [[
---------
Aimbot:
---------
Right click or type ':aim target' to select target
Left click to fire at target
]]

Notify('Mega Combat V4','Loaded in ' .. tostring(tick() - _time):sub(1,6),'rbxassetid://2789783355',5)
print(Message)
Notify('Features','Press F9 to see features','rbxassetid://618516017',5)
