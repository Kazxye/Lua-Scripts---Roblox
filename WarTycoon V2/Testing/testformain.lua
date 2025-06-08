local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Script - WarTycoon V2",
   Icon = 'bomb', -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Loading Script...",
   LoadingSubtitle = "by Kazz",
   Theme = "Ocean", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

-- Notificação Inicial Do script.
Rayfield:Notify({
   Title = "Script Bypass Executado!",
   Content = "Press K To open.",
   Duration = 8,
   Image = 'shield-check',
})

--- SERVIÇOS

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--- VARIÁVEIS GLOBAIS

local InfiniteJumpEnabled = false
local NoClipEnabled = false
local CanTeleport = true
local LastAirdrop = nil
local WalkSpeedNormal = 16
local WalkSpeedBoost = 50

--- Aba Principal Com todas as suas Funções.
--- MAIN MAIN MAIN
--- MAIN MAIN MAIN

--- FUNÇÃO PULO INFINITO --- 
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
--- FUNÇÃO NOCLIP 
RunService.Stepped:Connect(function()
   if NoClipEnabled and Players.LocalPlayer.Character then
      for _, part in pairs(Players.LocalPlayer.Character:GetDescendants()) do
         if part:IsA("BasePart") and part.CanCollide == true then
            part.CanCollide = false
         end
      end
   end
end)
--- FUNÇÃO VELOCIDADE
local function SetPlayerSpeed(enabled)
   local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
   local humanoid = character:FindFirstChildOfClass("Humanoid")
   if humanoid then
      humanoid.WalkSpeed = enabled and WalkSpeedBoost or WalkSpeedNormal
   end
end
Players.LocalPlayer.CharacterAdded:Connect(function(char)
   char:WaitForChild("Humanoid")
   task.wait(0.2) -- pequeno atraso para garantir que tudo carregou
   if SpeedHackEnabled then
      SetPlayerSpeed(true)
   end
end)

local MainTab = Window:CreateTab("Main", 'align-justify')
local Section = MainTab:CreateSection("Main Functions")
local Divider = MainTab:CreateDivider()

MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
      InfiniteJumpEnabled = Value
      Rayfield:Notify({
         Title = "Pulo Infinito",
         Content = Value and "Ativado" or "Desativado",
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
         Content = Value and "Ativado" or "Desativado",
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
         Content = Value and "Velocidade aumentada!" or "Velocidade normal.",
         Duration = 3,
         Image = 'zap',
      })
   end,
})

--- Aba ESP Com todas suas Funções.
--- ESP ESP ESP
--- ESP ESP ESP

local EspTab = Window:CreateTab('ESP', 'eye')
local Section = EspTab:CreateSection('ESP Functions')
local Divider = EspTab:CreateDivider()

--- Aba Misc Com todas suas funções.
--- MISC MISC MISC
--- MISC MISC MISC

local MiscTab = Window:CreateTab('Misc', 'app-window')
local Section = MiscTab:CreateSection('Misc Functions')
local Divider = MiscTab:CreateDivider()



--- ABA TELEPORT COM TODAS AS SUAS FUNÇÕES
--- TELEPORT TELEPORT TELEPORT
--- TELEPORT TELEPORT TELEPORT

local TPTab = Window:CreateTab('Teleport', 'map-pin')
local Section = TPTab:CreateSection('Teleport Features')
local Divider = TPTab:CreateDivider()

--- FUNÇÃO TELEPORTE --- 
local function TeleportTo(position)
   local character = Players.LocalPlayer.Character
   if character and character:FindFirstChild("HumanoidRootPart") then
      character:MoveTo(position)
   end
end

--- FUNÇÃO VERFICIAR AIRDROP

local beamsFolder = workspace:WaitForChild("Beams")

beamsFolder.ChildAdded:Connect(function(child)
   if child:IsA("BasePart") and string.match(child.Name, "^Airdrop_%d+") then
      LastAirdrop = child
      Rayfield:Notify({
         Title = "Airdrop Detectado!",
         Content = "Novo airdrop apareceu: " .. child.Name,
         Duration = 5,
         Image = 'bell',
      })
   end
end)

TPTab:CreateButton({
   Name = "Teleportar para Ponto de Captura",
   Callback = function()
      TeleportTo(Vector3.new(-548.5264282226562, 71.5843505859375, -1364.2601318359375))
   end,
})

TPTab:CreateButton({
   Name = "Teleportar para Último Airdrop",
   Callback = function()
      if LastAirdrop and LastAirdrop:IsDescendantOf(workspace) then
         TeleportTo(LastAirdrop.Position)
         Rayfield:Notify({
            Title = "Teleportado",
            Content = "Foste até " .. LastAirdrop.Name,
            Duration = 3,
            Image = 'map-pin',
         })
      else
         Rayfield:Notify({
            Title = "Erro",
            Content = "Nenhum airdrop válido encontrado!",
            Duration = 3,
            Image = 'x',
         })
      end
   end,
})

--- Aba Binds Com todas suas Funções.
--- BIND BIND BIND
--- BIND BIND BIND

local BindTab = Window:CreateTab('Binds', 'keyboard')
local Section = BindTab:CreateSection('Select Your Keybinds')
local Divider = BindTab:CreateDivider()

local Keybind = BindTab:CreateKeybind({
   Name = "- Infinite Jump -",
   CurrentKeybind = "Select",
   HoldToInteract = false,
   Flag = "Keybind1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function()
      InfiniteJumpEnabled = not InfiniteJumpEnabled
      Rayfield:Notify({
         Title = "Pulo Infinito",
         Content = InfiniteJumpEnabled and "Ativado!" or "Desativado!",
         Duration = 3,
         Image = 'shield-check'
      })
   end,
})

local Keybind = BindTab:CreateKeybind({
   Name = "NoClip",
   CurrentKeybind = "Select",
   HoldToInteract = false,
   Flag = "Keybind2", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function()
      NoClipEnabled = not NoClipEnabled
      Rayfield:Notify({
         Title = 'NoClip',
         Content = NoClipEnabled and 'Ativado!' or 'Desativado',
         Duration = 3,
         Image = 'shield-check'
      })
   end,
})

local Keybind = BindTab:CreateKeybind({
   Name = "Speed Hack",
   CurrentKeybind = "",
   HoldToInteract = false,
   Flag = "Keybind3",
   Callback = function()
      SpeedHackEnabled = not SpeedHackEnabled
      SetPlayerSpeed(SpeedHackEnabled)
      Rayfield:Notify({
         Title = "Speed Hack",
         Content = SpeedHackEnabled and "Ativado por tecla!" or "Desativado por tecla!",
         Duration = 3,
         Image = 'zap',
      })
   end,
})

