local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SCRIPTZIN COMPLETO",
   Icon = 'bomb',
   LoadingTitle = "Loading Script...",
   LoadingSubtitle = "by Kazz",
   Theme = "Ocean",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ScriptzinCompleto",
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

-- Notificação Inicial
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
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

--- VARIÁVEIS GLOBAIS MAIN
local InfiniteJumpEnabled = false
local NoClipEnabled = false
local SpeedHackEnabled = false
local CanTeleport = true
local LastAirdrop = nil
local WalkSpeedNormal = 16
local WalkSpeedBoost = 50

--- VARIÁVEIS GLOBAIS ESP
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

--- FUNÇÕES PRINCIPAIS ---

--- FUNÇÃO PULO INFINITO
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
   task.wait(0.2)
   if SpeedHackEnabled then
      SetPlayerSpeed(true)
   end
end)

--- FUNÇÃO TELEPORTE
local function TeleportTo(position)
   local character = Players.LocalPlayer.Character
   if character and character:FindFirstChild("HumanoidRootPart") then
      character:MoveTo(position)
   end
end

--- FUNÇÃO VERIFICAR AIRDROP
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

--- FUNÇÕES ESP ---

-- Controle de texto para ESP
UIS.TextBoxFocused:Connect(function()
    Typing = true
end)

UIS.TextBoxFocusReleased:Connect(function()
    Typing = false
end)


-- Função para criar ESP por jogador
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

-- Inicializa ESP
local function CreateESP()
    for _, player in pairs(Players:GetPlayers()) do
        CreateESPForPlayer(player)
    end

    Players.PlayerAdded:Connect(CreateESPForPlayer)
end

--- CRIAÇÃO DAS ABAS ---

--- ABA MAIN ---
local MainTab = Window:CreateTab("Main", 'align-justify')
local MainSection = MainTab:CreateSection("Main Functions")
MainTab:CreateDivider()

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

--- ABA ESP ---
local EspTab = Window:CreateTab('ESP', 'eye')
local EspSection = EspTab:CreateSection('ESP Functions')
EspTab:CreateDivider()

-- Checagem de suporte ESP
if Drawing then
    EspTab:CreateToggle({
        Name = "ESP Ativado",
        CurrentValue = _G.ESPVisible,
        Flag = "ESPVisibleToggle",
        Callback = function(Value)
            _G.ESPVisible = Value
            if _G.SendNotifications then
                game:GetService("StarterGui"):SetCore("SendNotification",{
                    Title = "ESP Toggle",
                    Text = "ESP agora está "..tostring(_G.ESPVisible),
                    Duration = 3
                })
            end
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
        Name = "Tamanho do Texto",
        Range = {8, 24},
        Increment = 1,
        Suffix = "px",
        CurrentValue = _G.TextSize,
        Flag = "TextSizeSlider",
        Callback = function(Value)
            _G.TextSize = Value
        end,
    })

    -- Executar ESP
    local Success, Errored = pcall(CreateESP)
    if Success then
        if _G.SendNotifications then
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = "ESP Carregado",
                Text = "ESP carregado com sucesso!",
                Duration = 5
            })
        end
    else
        if _G.SendNotifications then
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = "Erro ESP",
                Text = "Erro ao carregar ESP!",
                Duration = 5
            })
        end
        warn(Errored)
    end
else
    EspTab:CreateLabel("ESP não suportado pelo seu executor.")
end

--- ABA TELEPORT ---
local TPTab = Window:CreateTab('Teleport', 'map-pin')
local TPSection = TPTab:CreateSection('Teleport Features')
TPTab:CreateDivider()

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

--- ABA MISC ---
local MiscTab = Window:CreateTab('Misc', 'app-window')
local MiscSection = MiscTab:CreateSection('Misc Functions')
MiscTab:CreateDivider()

--- ABA BINDS ---
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
         Title = "Pulo Infinito",
         Content = InfiniteJumpEnabled and "Ativado!" or "Desativado!",
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
         Content = NoClipEnabled and 'Ativado!' or 'Desativado',
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
         Content = SpeedHackEnabled and "Ativado por tecla!" or "Desativado por tecla!",
         Duration = 3,
         Image = 'zap',
      })
   end,
})