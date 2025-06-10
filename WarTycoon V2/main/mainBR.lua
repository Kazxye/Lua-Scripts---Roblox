local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Script WarTycoon",
   Icon = 'bomb',
   LoadingTitle = "Carregando Script...",
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

-- Notificação Inicial
Rayfield:Notify({
   Title = "Script Bypass Executado!",
   Content = "Aperte K para abrir o menu.",
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

--- VARIÁVEIS GLOBAIS FLY
local LocalPlayer = Players.LocalPlayer
local FlyEnabled = false
local FlySpeed = 50
local FlyConnection = nil
local BodyVelocity = nil
local BodyAngularVelocity = nil

-- Controles do Fly
local Controls = {
   W = false, -- Frente
   A = false, -- Esquerda
   S = false, -- Trás
   D = false, -- Direita
   Space = false, -- Cima
   LeftShift = false, -- Baixo
}

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
   
   -- Reativar fly após respawn se estiver ativado
   if FlyEnabled then
      task.wait(1)
      CreateFlyObjects()
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

--- FUNÇÕES FLY ---

-- Função para criar BodyVelocity
function CreateFlyObjects()
   local character = LocalPlayer.Character
   if not character or not character:FindFirstChild("HumanoidRootPart") then
      return false
   end
   
   local rootPart = character.HumanoidRootPart
   
   -- Remover objetos existentes
   if BodyVelocity then
      BodyVelocity:Destroy()
   end
   if BodyAngularVelocity then
      BodyAngularVelocity:Destroy()
   end
   
   -- Criar novos objetos
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

-- Função para remover objetos do fly
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

-- Função principal do fly
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
   
   -- Calcular direção baseada na câmera
   local camera = Camera
   local cameraCFrame = camera.CFrame
   
   -- Vetores de direção
   local moveVector = Vector3.new(0, 0, 0)
   
   -- Frente/Trás (W/S)
   if Controls.W then
      moveVector = moveVector + cameraCFrame.LookVector
   end
   if Controls.S then
      moveVector = moveVector - cameraCFrame.LookVector
   end
   
   -- Esquerda/Direita (A/D)
   if Controls.A then
      moveVector = moveVector - cameraCFrame.RightVector
   end
   if Controls.D then
      moveVector = moveVector + cameraCFrame.RightVector
   end
   
   -- Cima/Baixo (Space/Shift)
   if Controls.Space then
      moveVector = moveVector + Vector3.new(0, 1, 0)
   end
   if Controls.LeftShift then
      moveVector = moveVector - Vector3.new(0, 1, 0)
   end
   
   -- Normalizar e aplicar velocidade
   if moveVector.Magnitude > 0 then
      moveVector = moveVector.Unit * FlySpeed
   end
   
   -- Aplicar velocidade
   BodyVelocity.Velocity = moveVector
   
   -- Desabilitar PlatformStand para melhor controle
   if humanoid then
      humanoid.PlatformStand = true
   end
end

-- Função para ativar/desativar fly
local function ToggleFly(enabled)
   FlyEnabled = enabled
   
   if enabled then
      if CreateFlyObjects() then
         FlyConnection = RunService.Heartbeat:Connect(UpdateFly)
         
         Rayfield:Notify({
            Title = "Fly Mode Ativado!",
            Content = "Use WASD + Space/Shift para voar",
            Duration = 5,
            Image = 'plane',
         })
      else
         Rayfield:Notify({
            Title = "Erro",
            Content = "Não foi possível ativar o fly mode",
            Duration = 3,
            Image = 'x',
         })
         FlyEnabled = false
      end
   else
      -- Desativar fly
      if FlyConnection then
         FlyConnection:Disconnect()
         FlyConnection = nil
      end
      
      RemoveFlyObjects()
      
      -- Restaurar PlatformStand
      local character = LocalPlayer.Character
      if character then
         local humanoid = character:FindFirstChildOfClass("Humanoid")
         if humanoid then
            humanoid.PlatformStand = false
         end
      end
      
      Rayfield:Notify({
         Title = "Fly Mode Desativado",
         Content = "Você voltou ao chão",
         Duration = 3,
         Image = 'plane',
      })
   end
end

-- Event listeners para controles do fly
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
local MainSection = MainTab:CreateSection("Movement Functions")
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

-- Seção Fly Mode
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
   Name = "Velocidade do Fly",
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
   Name = "Resetar Posição",
   Callback = function()
      local character = LocalPlayer.Character
      if character and character:FindFirstChild("HumanoidRootPart") then
         character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
         
         Rayfield:Notify({
            Title = "Posição Resetada",
            Content = "Você foi teleportado para o spawn",
            Duration = 3,
            Image = 'home',
         })
      end
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
            Rayfield:Notify({
                Title = "ESP Toggle",
                Content = Value and "ESP ativado!" or "ESP desativado!",
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
        Rayfield:Notify({
            Title = "ESP Carregado",
            Content = "ESP carregado com sucesso!",
            Duration = 5,
            Image = 'eye',
        })
    else
        Rayfield:Notify({
            Title = "Erro ESP",
            Content = "Erro ao carregar ESP!",
            Duration = 5,
            Image = 'x',
        })
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

-- Botão de emergência para desativar tudo
MiscTab:CreateButton({
   Name = "Desativar Todas as Funções",
   Callback = function()
      -- Desativar todas as funções
      InfiniteJumpEnabled = false
      NoClipEnabled = false
      SpeedHackEnabled = false
      ToggleFly(false)
      
      -- Reset velocidade
      SetPlayerSpeed(false)
      
      -- Forçar limpeza completa do fly
      if FlyConnection then
         FlyConnection:Disconnect()
         FlyConnection = nil
      end
      
      RemoveFlyObjects()
      
      -- Reset todos os controles
      for key, _ in pairs(Controls) do
         Controls[key] = false
      end
      
      Rayfield:Notify({
         Title = "Sistema Resetado",
         Content = "Todas as funções foram desativadas",
         Duration = 3,
         Image = 'shield-check',
      })
   end,
})

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

BindTab:CreateKeybind({
   Name = "Fly Mode",
   CurrentKeybind = "Select",
   HoldToInteract = false,
   Flag = "Keybind4",
   Callback = function()
      ToggleFly(not FlyEnabled)
   end,
})

-- Cleanup quando o script for removido
game.Players.PlayerRemoving:Connect(function(player)
   if player == LocalPlayer then
      ToggleFly(false)
   end
end)