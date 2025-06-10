local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Fly Mode Script - WarTycoon V2",
   Icon = 'plane',
   LoadingTitle = "Loading Fly Script...",
   LoadingSubtitle = "by Kazz",
   Theme = "Ocean",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "FlyModeScript",
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
   Title = "Fly Mode Script Executado!",
   Content = "Aperte K para abrir o menu",
   Duration = 8,
   Image = 'plane',
})

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Variáveis do Fly
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

-- Função para criar BodyVelocity
local function CreateFlyObjects()
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
         Image = 'plane-off',
      })
   end
end

-- Event listeners para controles
UserInputService.InputBegan:Connect(function(input, gameProcessed)
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

UserInputService.InputEnded:Connect(function(input, gameProcessed)
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

-- Eventos para recriar objetos quando o jogador spawna
LocalPlayer.CharacterAdded:Connect(function(character)
   wait(1) -- Aguardar o character carregar completamente
   
   if FlyEnabled then
      -- Reativar fly após respawn
      CreateFlyObjects()
   end
end)

-- Interface do Rayfield
local MainTab = Window:CreateTab("Main", 'plane')
local MainSection = MainTab:CreateSection("Fly Mode Controls")
MainTab:CreateDivider()

-- Toggle principal do Fly
local FlyToggle = MainTab:CreateToggle({
   Name = "Fly Mode",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      ToggleFly(Value)
   end,
})

-- Slider de velocidade
local SpeedSlider = MainTab:CreateSlider({
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

-- Botão para resetar posição
local ResetButton = MainTab:CreateButton({
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

-- Seção de informações
MainTab:CreateSection("Controles do Fly")

MainTab:CreateLabel("WASD - Mover")
MainTab:CreateLabel("Space - Subir")
MainTab:CreateLabel("Shift - Descer")
MainTab:CreateLabel("Mouse - Olhar ao redor")

-- Seção de configurações avançadas
local ConfigSection = MainTab:CreateSection("Configurações Avançadas")

-- Toggle para manter fly após morte
local KeepFlyToggle = MainTab:CreateToggle({
   Name = "Manter Fly Após Morte",
   CurrentValue = true,
   Flag = "KeepFlyToggle",
   Info = "Reativa automaticamente o fly após respawn",
   Callback = function(Value)
      -- Esta funcionalidade já está implementada no CharacterAdded
   end,
})

-- Botão de emergência para desativar tudo
local EmergencyButton = MainTab:CreateButton({
   Name = "🚨 PARAR TUDO (Emergência)",
   Callback = function()
      ToggleFly(false)
      
      -- Forçar limpeza completa
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

-- Cleanup quando o script for removado
game.Players.PlayerRemoving:Connect(function(player)
   if player == LocalPlayer then
      ToggleFly(false)
   end
end)