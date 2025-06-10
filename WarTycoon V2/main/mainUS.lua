local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "WarTycoon Script",
   Icon = 'bomb',
   LoadingTitle = "Loading Script...",
   LoadingSubtitle = "by Kazz",
   Theme = "Ocean",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = false,
      FolderName = "WarTycoon",
      FileName = "Config"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

-- Initial Notification
Rayfield:Notify({
   Title = "Bypass Script Executed!",
   Content = "Press K to open the menu.",
   Duration = 8,
   Image = 'shield-check',
})

--- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

--- MAIN GLOBAL VARIABLES
local InfiniteJumpEnabled = false
local NoClipEnabled = false
local SpeedHackEnabled = false
local CanTeleport = true
local LastAirdrop = nil
local WalkSpeedNormal = 16
local WalkSpeedBoost = 50

--- FLY GLOBAL VARIABLES
local LocalPlayer = Players.LocalPlayer
local FlyEnabled = false
local FlySpeed = 50
local FlyConnection = nil
local BodyVelocity = nil
local BodyAngularVelocity = nil

-- Fly Controls
local Controls = {
   W = false, -- Forward
   A = false, -- Left
   S = false, -- Backward
   D = false, -- Right
   Space = false, -- Up
   LeftShift = false, -- Down
}

--- ESP GLOBAL VARIABLES
local Typing = false
_G.SendNotifications = true
_G.DefaultSettings = false
_G.TeamCheck = false
_G.ESPVisible = true
_G.TextColor = Color3.fromRGB(255, 80, 10)
_G.TextSize = 14
_G.Center = true
_G.Outline = true
_G.OutlineColor = Color3.fromRGB(0, 0, 0)
_G.TextTransparency = 0.7
_G.TextFont = Drawing and Drawing.Fonts.UI or nil
_G.DisableKey = Enum.KeyCode.Q

local ESPObjects = {}

--- MAIN FUNCTIONS ---

--- INFINITE JUMP FUNCTION
if not jumpConnection then
   jumpConnection = UIS.JumpRequest:Connect(function()
      if InfiniteJumpEnabled then
         local humanoid = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
         if humanoid then
            humanoid:ChangeState("Jumping")
         end
      end
   end)
end

--- NOCLIP FUNCTION
RunService.Stepped:Connect(function()
   if NoClipEnabled and Players.LocalPlayer.Character then
      for _, part in pairs(Players.LocalPlayer.Character:GetDescendants()) do
         if part:IsA("BasePart") and part.CanCollide == true then
            part.CanCollide = false
         end
      end
   end
end)

--- SPEED FUNCTION
local function SetPlayerSpeed(enabled)
   local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
   local humanoid = character:FindFirstChildOfClass("Humanoid")
   if humanoid then
      humanoid.WalkSpeed = enabled and WalkSpeedBoost or WalkSpeedNormal
   end
end

Players.LocalPlayer.CharacterAdded:Connect(function(char)
   char:WaitForChild("Humanoid")
   task.wait(0.2)
   if SpeedHackEnabled then
      SetPlayerSpeed(true)
   end
   
   -- Reactivate fly after respawn if enabled
   if FlyEnabled then
      task.wait(1)
      CreateFlyObjects()
   end
end)

--- TELEPORT FUNCTION
local function TeleportTo(position)
   local character = Players.LocalPlayer.Character
   if character and character:FindFirstChild("HumanoidRootPart") then
      character:MoveTo(position)
   end
end

--- AIRDROP CHECK FUNCTION
local beamsFolder = workspace:WaitForChild("Beams")

beamsFolder.ChildAdded:Connect(function(child)
   if child:IsA("BasePart") and string.match(child.Name, "^Airdrop_%d+") then
      LastAirdrop = child
      Rayfield:Notify({
         Title = "Airdrop Detected!",
         Content = "New airdrop appeared: " .. child.Name,
         Duration = 5,
         Image = 'bell',
      })
   end
end)

--- FLY FUNCTIONS ---

-- Function to create BodyVelocity
function CreateFlyObjects()
   local character = LocalPlayer.Character
   if not character or not character:FindFirstChild("HumanoidRootPart") then
      return false
   end
   
   local rootPart = character.HumanoidRootPart
   
   -- Remove existing objects
   if BodyVelocity then
      BodyVelocity:Destroy()
   end
   if BodyAngularVelocity then
      BodyAngularVelocity:Destroy()
   end
   
   -- Create new objects
   BodyVelocity = Instance.new("BodyVelocity")
   BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
   BodyVelocity.Velocity = Vector3.new(0, 0, 0)
   BodyVelocity.Parent = rootPart
   
   BodyAngularVelocity = Instance.new("BodyAngularVelocity")
   BodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
   BodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
   BodyAngularVelocity.Parent = rootPart
   
   return true
end

-- Function to remove fly objects
local function RemoveFlyObjects()
   if BodyVelocity then
      BodyVelocity:Destroy()
      BodyVelocity = nil
   end
   if BodyAngularVelocity then
      BodyAngularVelocity:Destroy()
      BodyAngularVelocity = nil
   end
end

-- Main fly function
local function UpdateFly()
   local character = LocalPlayer.Character
   if not character or not character:FindFirstChild("HumanoidRootPart") then
      return
   end
   
   local rootPart = character.HumanoidRootPart
   local humanoid = character:FindFirstChildOfClass("Humanoid")
   
   if not BodyVelocity or not BodyAngularVelocity then
      if not CreateFlyObjects() then
         return
      end
   end
   
   -- Calculate direction based on camera
   local camera = Camera
   local cameraCFrame = camera.CFrame
   
   -- Direction vectors
   local moveVector = Vector3.new(0, 0, 0)
   
   -- Forward/Backward (W/S)
   if Controls.W then
      moveVector = moveVector + cameraCFrame.LookVector
   end
   if Controls.S then
      moveVector = moveVector - cameraCFrame.LookVector
   end
   
   -- Left/Right (A/D)
   if Controls.A then
      moveVector = moveVector - cameraCFrame.RightVector
   end
   if Controls.D then
      moveVector = moveVector + cameraCFrame.RightVector
   end
   
   -- Up/Down (Space/Shift)
   if Controls.Space then
      moveVector = moveVector + Vector3.new(0, 1, 0)
   end
   if Controls.LeftShift then
      moveVector = moveVector - Vector3.new(0, 1, 0)
   end
   
   -- Normalize and apply speed
   if moveVector.Magnitude > 0 then
      moveVector = moveVector.Unit * FlySpeed
   end
   
   -- Apply velocity
   BodyVelocity.Velocity = moveVector
   
   -- Disable PlatformStand for better control
   if humanoid then
      humanoid.PlatformStand = true
   end
end

-- Function to toggle fly
local function ToggleFly(enabled)
   FlyEnabled = enabled
   
   if enabled then
      if CreateFlyObjects() then
         FlyConnection = RunService.Heartbeat:Connect(UpdateFly)
         
         Rayfield:Notify({
            Title = "Fly Mode Activated!",
            Content = "Use WASD + Space/Shift to fly",
            Duration = 5,
            Image = 'plane',
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "Could not activate fly mode",
            Duration = 3,
            Image = 'x',
         })
         FlyEnabled = false
      end
   else
      -- Disable fly
      if FlyConnection then
         FlyConnection:Disconnect()
         FlyConnection = nil
      end
      
      RemoveFlyObjects()
      
      -- Restore PlatformStand
      local character = LocalPlayer.Character
      if character then
         local humanoid = character:FindFirstChildOfClass("Humanoid")
         if humanoid then
            humanoid.PlatformStand = false
         end
      end
      
      Rayfield:Notify({
         Title = "Fly Mode Disabled",
         Content = "You're back on the ground",
         Duration = 3,
         Image = 'plane',
      })
   end
end

-- Event listeners for fly controls
UIS.InputBegan:Connect(function(input, gameProcessed)
   if gameProcessed then return end
   
   if FlyEnabled then
      if input.KeyCode == Enum.KeyCode.W then
         Controls.W = true
      elseif input.KeyCode == Enum.KeyCode.A then
         Controls.A = true
      elseif input.KeyCode == Enum.KeyCode.S then
         Controls.S = true
      elseif input.KeyCode == Enum.KeyCode.D then
         Controls.D = true
      elseif input.KeyCode == Enum.KeyCode.Space then
         Controls.Space = true
      elseif input.KeyCode == Enum.KeyCode.LeftShift then
         Controls.LeftShift = true
      end
   end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
   if input.KeyCode == Enum.KeyCode.W then
      Controls.W = false
   elseif input.KeyCode == Enum.KeyCode.A then
      Controls.A = false
   elseif input.KeyCode == Enum.KeyCode.S then
      Controls.S = false
   elseif input.KeyCode == Enum.KeyCode.D then
      Controls.D = false
   elseif input.KeyCode == Enum.KeyCode.Space then
      Controls.Space = false
   elseif input.KeyCode == Enum.KeyCode.LeftShift then
      Controls.LeftShift = false
   end
end)

--- ESP FUNCTIONS ---

-- Text control for ESP
UIS.TextBoxFocused:Connect(function()
    Typing = true
end)

UIS.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

-- Function to create ESP per player
local function CreateESPForPlayer(player)
    if not Drawing or player == Players.LocalPlayer or ESPObjects[player] then return end

    local ESP = Drawing.new("Text")
    ESPObjects[player] = ESP

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local char = Workspace:FindFirstChild(player.Name)
        local localChar = Players.LocalPlayer.Character

        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and localChar and localChar:FindFirstChild("HumanoidRootPart") then
            local headPos = char.Head.Position
            local Vector, OnScreen = Camera:WorldToViewportPoint(headPos)

            ESP.Size = _G.TextSize
            ESP.Center = _G.Center
            ESP.Outline = _G.Outline
            ESP.OutlineColor = _G.OutlineColor
            ESP.Color = _G.TextColor
            ESP.Transparency = _G.TextTransparency
            ESP.Font = _G.TextFont

            if OnScreen then
                local dist = (char.HumanoidRootPart.Position - localChar.HumanoidRootPart.Position).Magnitude
                local health = char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health or 0
                ESP.Position = Vector2.new(Vector.X, Vector.Y - 25)
                ESP.Text = ("("..math.floor(dist)..") "..player.Name.." ["..math.floor(health).."]")

                if _G.TeamCheck and player.Team == Players.LocalPlayer.Team then
                    ESP.Visible = false
                else
                    ESP.Visible = _G.ESPVisible
                end
            else
                ESP.Visible = false
            end
        else
            ESP.Visible = false
        end
    end)

    player.AncestryChanged:Connect(function()
        if not player:IsDescendantOf(game) then
            if ESPObjects[player] then
                ESPObjects[player]:Remove()
                ESPObjects[player] = nil
                if connection then
                    connection:Disconnect()
                end
            end
        end
    end)
end

-- Initialize ESP
local function CreateESP()
    for _, player in pairs(Players:GetPlayers()) do
        CreateESPForPlayer(player)
    end

    Players.PlayerAdded:Connect(CreateESPForPlayer)
end

--- TAB CREATION ---

--- MAIN TAB ---
local MainTab = Window:CreateTab("Main", 'align-justify')
local MainSection = MainTab:CreateSection("Movement Functions")
MainTab:CreateDivider()

MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
      InfiniteJumpEnabled = Value
      Rayfield:Notify({
         Title = "Infinite Jump",
         Content = Value and "Enabled" or "Disabled",
         Duration = 3,
         Image = 'shield-check',
      })
   end,
})

MainTab:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Flag = "NoClipToggle",
   Callback = function(Value)
      NoClipEnabled = Value
      Rayfield:Notify({
         Title = "NoClip",
         Content = Value and "Enabled" or "Disabled",
         Duration = 3,
         Image = 'shield-check',
      })
   end,
})

MainTab:CreateToggle({
   Name = "Speed Hack",
   CurrentValue = false,
   Flag = "SpeedHackToggle",
   Callback = function(Value)
      SpeedHackEnabled = Value
      SetPlayerSpeed(Value)

      Rayfield:Notify({
         Title = "Speed Hack",
         Content = Value and "Speed increased!" or "Normal speed.",
         Duration = 3,
         Image = 'zap',
      })
   end,
})

-- Fly Mode Section
local FlySection = MainTab:CreateSection("Fly Mode")

MainTab:CreateToggle({
   Name = "Fly Mode",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      ToggleFly(Value)
   end,
})

MainTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 200},
   Increment = 5,
   Suffix = " studs/s",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
      FlySpeed = Value
   end,
})

MainTab:CreateButton({
   Name = "Reset Position",
   Callback = function()
      local character = LocalPlayer.Character
      if character and character:FindFirstChild("HumanoidRootPart") then
         character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
         
         Rayfield:Notify({
            Title = "Position Reset",
            Content = "You were teleported to spawn",
            Duration = 3,
            Image = 'home',
         })
      end
   end,
})


--- ESP TAB ---
local EspTab = Window:CreateTab('ESP', 'eye')
local EspSection = EspTab:CreateSection('ESP Functions')
EspTab:CreateDivider()

-- ESP support check
if Drawing then
    EspTab:CreateToggle({
        Name = "ESP Enabled",
        CurrentValue = _G.ESPVisible,
        Flag = "ESPVisibleToggle",
        Callback = function(Value)
            _G.ESPVisible = Value
            Rayfield:Notify({
                Title = "ESP Toggle",
                Content = Value and "ESP enabled!" or "ESP disabled!",
                Duration = 3,
                Image = Value and 'eye' or 'eye-off',
            })
        end,
    })

    EspTab:CreateToggle({
        Name = "Team Check",
        CurrentValue = _G.TeamCheck,
        Flag = "TeamCheckToggle",
        Callback = function(Value)
            _G.TeamCheck = Value
        end,
    })

    EspTab:CreateSlider({
        Name = "Text Size",
        Range = {8, 24},
        Increment = 1,
        Suffix = "px",
        CurrentValue = _G.TextSize,
        Flag = "TextSizeSlider",
        Callback = function(Value)
            _G.TextSize = Value
        end,
    })

    -- Execute ESP
    local Success, Errored = pcall(CreateESP)
    if Success then
        Rayfield:Notify({
            Title = "ESP Loaded",
            Content = "ESP loaded successfully!",
            Duration = 5,
            Image = 'eye',
        })
    else
        Rayfield:Notify({
            Title = "ESP Error",
            Content = "Error loading ESP!",
            Duration = 5,
            Image = 'x',
        })
        warn(Errored)
    end
else
    EspTab:CreateLabel("ESP not supported by your executor.")
end

--- TELEPORT TAB ---
local TPTab = Window:CreateTab('Teleport', 'map-pin')
local TPSection = TPTab:CreateSection('Teleport Features')
TPTab:CreateDivider()

TPTab:CreateButton({
   Name = "Teleport to Capture Point",
   Callback = function()
      TeleportTo(Vector3.new(-548.5264282226562, 71.5843505859375, -1364.2601318359375))
   end,
})

TPTab:CreateButton({
   Name = "Teleport to Last Airdrop",
   Callback = function()
      if LastAirdrop and LastAirdrop:IsDescendantOf(workspace) then
         TeleportTo(LastAirdrop.Position)
         Rayfield:Notify({
            Title = "Teleported",
            Content = "You went to " .. LastAirdrop.Name,
            Duration = 3,
            Image = 'map-pin',
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "No valid airdrop found!",
            Duration = 3,
            Image = 'x',
         })
      end
   end,
})

--- MISC TAB ---
local MiscTab = Window:CreateTab('Misc', 'app-window')
local MiscSection = MiscTab:CreateSection('Misc Functions')
MiscTab:CreateDivider()

-- Emergency button to disable everything
MiscTab:CreateButton({
   Name = "Disable All Functions",
   Callback = function()
      -- Disable all functions
      InfiniteJumpEnabled = false
      NoClipEnabled = false
      SpeedHackEnabled = false
      ToggleFly(false)
      
      -- Reset speed
      SetPlayerSpeed(false)
      
      -- Force complete fly cleanup
      if FlyConnection then
         FlyConnection:Disconnect()
         FlyConnection = nil
      end
      
      RemoveFlyObjects()
      
      -- Reset all controls
      for key, _ in pairs(Controls) do
         Controls[key] = false
      end
      
      Rayfield:Notify({
         Title = "System Reset",
         Content = "All functions have been disabled",
         Duration = 3,
         Image = 'shield-check',
      })
   end,
})

--- BINDS TAB ---
local BindTab = Window:CreateTab('Binds', 'keyboard')
local BindSection = BindTab:CreateSection('Select Your Keybinds')
BindTab:CreateDivider()

BindTab:CreateKeybind({
   Name = "Infinite Jump",
   CurrentKeybind = "Select",
   HoldToInteract = false,
   Flag = "Keybind1",
   Callback = function()
      InfiniteJumpEnabled = not InfiniteJumpEnabled
      Rayfield:Notify({
         Title = "Infinite Jump",
         Content = InfiniteJumpEnabled and "Enabled!" or "Disabled!",
         Duration = 3,
         Image = 'shield-check'
      })
   end,
})

BindTab:CreateKeybind({
   Name = "NoClip",
   CurrentKeybind = "Select",
   HoldToInteract = false,
   Flag = "Keybind2",
   Callback = function()
      NoClipEnabled = not NoClipEnabled
      Rayfield:Notify({
         Title = 'NoClip',
         Content = NoClipEnabled and 'Enabled!' or 'Disabled!',
         Duration = 3,
         Image = 'shield-check'
      })
   end,
})

BindTab:CreateKeybind({
   Name = "Speed Hack",
   CurrentKeybind = "Select",
   HoldToInteract = false,
   Flag = "Keybind3",
   Callback = function()
      SpeedHackEnabled = not SpeedHackEnabled
      SetPlayerSpeed(SpeedHackEnabled)
      Rayfield:Notify({
         Title = "Speed Hack",
         Content = SpeedHackEnabled and "Enabled by hotkey!" or "Disabled by hotkey!",
         Duration = 3,
         Image = 'zap',
      })
   end,
})

BindTab:CreateKeybind({
   Name = "Fly Mode",
   CurrentKeybind = "Select",
   HoldToInteract = false,
   Flag = "Keybind4",
   Callback = function()
      ToggleFly(not FlyEnabled)
   end,
})

-- Cleanup when script is removed
game.Players.PlayerRemoving:Connect(function(player)
   if player == LocalPlayer then
      ToggleFly(false)
   end
end)