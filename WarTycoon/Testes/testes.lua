-- SERVIÇOS
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- VARIÁVEIS GLOBAIS
local InfiniteJumpEnabled = false
local jumpConnection
local velocidadeAtual = 16
local espAtivo = false
local nomesAtivo = false
local linhasAtivo = false
local healthESPAtivo = false
local flyAtivo = false
local caixasAtuais = {}
local nomesAtuais = {}
local linhasAtuais = {}
local healthESPAtuais = {}
local velocidadeConnection
local flyConnection
local flySpeed = 50       

-- UI
local Window = Rayfield:CreateWindow({
   Name = "WarTycoon - Script",
   Icon = 0,
   LoadingTitle = "Teste HUB",
   LoadingSubtitle = "Feito Por: Kazz",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "configWarTycoon",
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "Key - Kazz",
      Subtitle = "Key System - Kazz Scripts",
      Note = "Speak to Kazz",
      FileName = "Exemplo - Key",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"https://pastebin.com/raw/irHhJtMC"}
   }
})

-- CRIAÇÃO DAS ABAS
local MainTab = Window:CreateTab("Main", 'list')
local EspTab = Window:CreateTab("ESP", 'eye')

-- NOTIFICAÇÃO INICIAL
Rayfield:Notify({
   Title = "Script Executado!",
   Content = "Pressione K para abrir",
   Duration = 8,
   Image = 'shield-check',
})

-- FUNÇÕES DE MOVIMENTO
local function manterVelocidade()
   local char = Players.LocalPlayer.Character
   if char then
      local humanoid = char:FindFirstChildOfClass("Humanoid")
      if humanoid and humanoid.WalkSpeed ~= velocidadeAtual then
         humanoid.WalkSpeed = velocidadeAtual
      end
   end
end

local function iniciarMonitoramentoVelocidade()
   if velocidadeConnection then
      velocidadeConnection:Disconnect()
   end
   velocidadeConnection = RunService.Heartbeat:Connect(manterVelocidade)
end

-- SISTEMA DE VOO
local function iniciarVoo()
   local char = Players.LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   
   local bodyVelocity = Instance.new("BodyVelocity")
   bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
   bodyVelocity.Velocity = Vector3.new(0, 0, 0)
   bodyVelocity.Parent = char.HumanoidRootPart
   
   local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
   bodyAngularVelocity.MaxTorque = Vector3.new(400000, 400000, 400000)
   bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
   bodyAngularVelocity.Parent = char.HumanoidRootPart
   
   flyConnection = RunService.Heartbeat:Connect(function()
      if not flyAtivo then return end
      
      local camera = workspace.CurrentCamera
      local moveVector = Vector3.new(0, 0, 0)
      
      if UIS:IsKeyDown(Enum.KeyCode.W) then
         moveVector = moveVector + camera.CFrame.LookVector
      end
      if UIS:IsKeyDown(Enum.KeyCode.S) then
         moveVector = moveVector - camera.CFrame.LookVector
      end
      if UIS:IsKeyDown(Enum.KeyCode.A) then
         moveVector = moveVector - camera.CFrame.RightVector
      end
      if UIS:IsKeyDown(Enum.KeyCode.D) then
         moveVector = moveVector + camera.CFrame.RightVector
      end
      if UIS:IsKeyDown(Enum.KeyCode.Space) then
         moveVector = moveVector + Vector3.new(0, 1, 0)
      end
      if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
         moveVector = moveVector - Vector3.new(0, 1, 0)
      end
      
      bodyVelocity.Velocity = moveVector * flySpeed
   end)
end

local function pararVoo()
   local char = Players.LocalPlayer.Character
   if char and char:FindFirstChild("HumanoidRootPart") then
      local bodyVelocity = char.HumanoidRootPart:FindFirstChild("BodyVelocity")
      local bodyAngularVelocity = char.HumanoidRootPart:FindFirstChild("BodyAngularVelocity")
      
      if bodyVelocity then bodyVelocity:Destroy() end
      if bodyAngularVelocity then bodyAngularVelocity:Destroy() end
   end
   
   if flyConnection then
      flyConnection:Disconnect()
      flyConnection = nil
   end
end

-- PULO INFINITO
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



-- ===========================================
-- UI PRINCIPAL - ABA MAIN
-- ===========================================
MainTab:CreateToggle({
   Name = "Pulo Infinito",
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

MainTab:CreateSlider({
   Name = "Velocidade de Movimento",
   Range = {0, 100},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = velocidadeAtual,
   Flag = "SpeedSlider",
   Callback = function(Value)
      velocidadeAtual = Value
      local char = Players.LocalPlayer.Character
      if char then
         local humanoid = char:FindFirstChildOfClass("Humanoid")
         if humanoid then
            humanoid.WalkSpeed = Value
         end
      end
      iniciarMonitoramentoVelocidade()
   end,
})

MainTab:CreateToggle({
   Name = "Fly/Voar",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      flyAtivo = Value
      if flyAtivo then
         iniciarVoo()
         Rayfield:Notify({
            Title = "Sistema de Voo",
            Content = "Ativado! Use WASD + Space/Shift",
            Duration = 4,
            Image = 'shield-check',
         })
      else
         pararVoo()
         Rayfield:Notify({
            Title = "Sistema de Voo",
            Content = "Desativado",
            Duration = 3,
            Image = 'shield-check',
         })
      end
   end,
})

MainTab:CreateSlider({
   Name = "Velocidade de Voo",
   Range = {10, 150},
   Increment = 5,
   Suffix = " Speed",
   CurrentValue = flySpeed,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
      flySpeed = Value
   end,
})

-- RECARREGAR CONFIGURAÇÕES AO SPAWNAR
Players.LocalPlayer.CharacterAdded:Connect(function(char)
   char:WaitForChild("Humanoid").WalkSpeed = velocidadeAtual
   iniciarMonitoramentoVelocidade()
   
   -- Reativar voo se estava ativo
   if flyAtivo then
      task.wait(1)
      iniciarVoo()
   end
end)

if Players.LocalPlayer.Character then
   iniciarMonitoramentoVelocidade()
end

-- ===========================================
-- ESP FUNÇÕES
-- ===========================================
local function criarCaixaJogador(jogador)
   if jogador == Players.LocalPlayer then return end
   local char = jogador.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   if caixasAtuais[jogador] then return end

   local highlight = Instance.new("Highlight")
   highlight.Adornee = char
   highlight.FillColor = Color3.fromRGB(0, 255, 0)
   highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
   highlight.FillTransparency = 0.8
   highlight.OutlineTransparency = 0.2
   highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
   highlight.Name = "ESPHighlight"
   highlight.Parent = char
   caixasAtuais[jogador] = highlight
end

local function criarNomeJogador(jogador)
   if jogador == Players.LocalPlayer then return end
   local char = jogador.Character
   if not char or not char:FindFirstChild("Head") then return end
   if nomesAtuais[jogador] then return end

   local nameGui = Instance.new("BillboardGui")
   nameGui.Size = UDim2.new(0, 100, 0, 25)
   nameGui.StudsOffset = Vector3.new(0, 3, 0)
   nameGui.Adornee = char:FindFirstChild("Head")
   nameGui.AlwaysOnTop = true
   nameGui.Name = "ESPNameGui"
   nameGui.Parent = char

   local nameLabel = Instance.new("TextLabel")
   nameLabel.Size = UDim2.new(1, 0, 1, 0)
   nameLabel.BackgroundTransparency = 1
   nameLabel.Text = jogador.Name
   nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
   nameLabel.TextStrokeTransparency = 0
   nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
   nameLabel.TextScaled = true
   nameLabel.Font = Enum.Font.SourceSansBold
   nameLabel.Parent = nameGui

   nomesAtuais[jogador] = nameGui
end

local function criarLinhaJogador(jogador)
   if jogador == Players.LocalPlayer then return end
   local char = jogador.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   if linhasAtuais[jogador] then return end

   local beam = Instance.new("Beam")
   local att0 = Instance.new("Attachment")
   local att1 = Instance.new("Attachment")

   att0.Name = "BeamStart"
   att1.Name = "BeamEnd"

   local localChar = Players.LocalPlayer.Character
   if localChar and localChar:FindFirstChild("HumanoidRootPart") then
      att0.Parent = localChar.HumanoidRootPart
      att1.Parent = char.HumanoidRootPart

      beam.Attachment0 = att0
      beam.Attachment1 = att1
      beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
      beam.Width0 = 0.1
      beam.Width1 = 0.1
      beam.Transparency = NumberSequence.new(0.3)
      beam.FaceCamera = true
      beam.Name = "ESPBeam"
      beam.Parent = workspace

      linhasAtuais[jogador] = {beam = beam, att0 = att0, att1 = att1}
   end
end

local function criarHealthESP(jogador)
   if jogador == Players.LocalPlayer then return end
   local char = jogador.Character
   if not char or not char:FindFirstChild("Head") then return end
   if healthESPAtuais[jogador] then return end
   
   local humanoid = char:FindFirstChildOfClass("Humanoid")
   if not humanoid then return end

   -- GUI muito compacta
   local healthGui = Instance.new("BillboardGui")
   healthGui.Size = UDim2.new(0, 30, 0, 50)
   healthGui.StudsOffset = Vector3.new(-1.8, 0.5, 0)
   healthGui.Adornee = char:FindFirstChild("HumanoidRootPart")
   healthGui.AlwaysOnTop = true
   healthGui.Name = "ESPHealthGui"
   healthGui.Parent = char

   -- Fundo da barra (mais fino)
   local healthBg = Instance.new("Frame")
   healthBg.Size = UDim2.new(0.2, 0, 0.9, 0)
   healthBg.Position = UDim2.new(0, 0, 0.05, 0)
   healthBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
   healthBg.BorderSizePixel = 1
   healthBg.BorderColor3 = Color3.fromRGB(255, 255, 255)
   healthBg.Parent = healthGui

   -- Barra de vida vertical
   local healthBar = Instance.new("Frame")
   local healthPercent = humanoid.Health / humanoid.MaxHealth
   healthBar.Size = UDim2.new(1, 0, healthPercent, 0)
   healthBar.Position = UDim2.new(0, 0, 1 - healthPercent, 0)
   healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
   healthBar.BorderSizePixel = 0
   healthBar.Name = "HealthBar"
   healthBar.Parent = healthBg

   -- Texto pequeno ao lado
   local healthText = Instance.new("TextLabel")
   healthText.Size = UDim2.new(0.8, 0, 0.15, 0)
   healthText.Position = UDim2.new(0.2, 0, 0.4, 0)
   healthText.BackgroundTransparency = 1
   healthText.Text = math.floor(humanoid.Health)
   healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
   healthText.TextStrokeTransparency = 0
   healthText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
   healthText.TextScaled = true
   healthText.Font = Enum.Font.SourceSans
   healthText.Name = "HealthText"
   healthText.Parent = healthGui

   healthESPAtuais[jogador] = {gui = healthGui, bar = healthBar, text = healthText, humanoid = humanoid}
   
   -- Atualizar vida em tempo real
   local healthConnection
   healthConnection = humanoid.HealthChanged:Connect(function(health)
      if healthESPAtuais[jogador] then
         local maxHealth = humanoid.MaxHealth
         local healthPercent = health / maxHealth
         
         healthBar.Size = UDim2.new(1, 0, healthPercent, 0)
         healthBar.Position = UDim2.new(0, 0, 1 - healthPercent, 0)
         healthText.Text = math.floor(health)
         
         -- Mudar cor baseada na vida
         if healthPercent > 0.6 then
            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
         elseif healthPercent > 0.3 then
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
         else
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
         end
      else
         healthConnection:Disconnect()
      end
   end)
end

local function removerCaixas()
   for jogador, elemento in pairs(caixasAtuais) do
      if elemento and elemento.Parent then
         elemento:Destroy()
      end
   end
   caixasAtuais = {}
end

local function removerNomes()
   for jogador, nameGui in pairs(nomesAtuais) do
      if nameGui and nameGui.Parent then
         nameGui:Destroy()
      end
   end
   nomesAtuais = {}
end

local function removerLinhas()
   for jogador, elementos in pairs(linhasAtuais) do
      if elementos then
         if elementos.beam and elementos.beam.Parent then
            elementos.beam:Destroy()
         end
         if elementos.att0 and elementos.att0.Parent then
            elementos.att0:Destroy()
         end
         if elementos.att1 and elementos.att1.Parent then
            elementos.att1:Destroy()
         end
      end
   end
   linhasAtuais = {}
end

local function removerHealthESP()
   for jogador, elementos in pairs(healthESPAtuais) do
      if elementos and elementos.gui and elementos.gui.Parent then
         elementos.gui:Destroy()
      end
   end
   healthESPAtuais = {}
end

local function atualizarESP()
   for _, jogador in ipairs(Players:GetPlayers()) do
      if espAtivo then criarCaixaJogador(jogador) end
      if nomesAtivo then criarNomeJogador(jogador) end
      if linhasAtivo then criarLinhaJogador(jogador) end
      if healthESPAtivo then criarHealthESP(jogador) end
   end
end

-- ATUALIZAR PERIODICAMENTE
RunService.RenderStepped:Connect(function()
   if espAtivo or nomesAtivo or linhasAtivo or healthESPAtivo then
      atualizarESP()
   end
end)

-- EVENTOS DE JOGADORES
Players.PlayerAdded:Connect(function(player)
   player.CharacterAdded:Connect(function()
      task.wait(2)
      if espAtivo then criarCaixaJogador(player) end
      if nomesAtivo then criarNomeJogador(player) end
      if linhasAtivo then criarLinhaJogador(player) end
      if healthESPAtivo then criarHealthESP(player) end
   end)
end)

Players.PlayerRemoving:Connect(function(player)
   if caixasAtuais[player] then caixasAtuais[player]:Destroy() end
   if nomesAtuais[player] then nomesAtuais[player]:Destroy() end
   if healthESPAtuais[player] then healthESPAtuais[player].gui:Destroy() end
   if linhasAtuais[player] then
      local elementos = linhasAtuais[player]
      if elementos.beam then elementos.beam:Destroy() end
      if elementos.att0 then elementos.att0:Destroy() end
      if elementos.att1 then elementos.att1:Destroy() end
   end
end)


-- ===========================================
-- UI DO ESP - ABA ESP
-- ===========================================
EspTab:CreateToggle({
   Name = "Caixa nos Jogadores",
   CurrentValue = false,
   Flag = "ESPPlayersToggle",
   Callback = function(Value)
      espAtivo = Value
      if not espAtivo then removerCaixas() else atualizarESP() end
      
      Rayfield:Notify({
         Title = "ESP - Caixas",
         Content = Value and "Ativado" or "Desativado",
         Duration = 2,
         Image = 'shield-check',
      })
   end,
})

EspTab:CreateToggle({
   Name = "Mostrar Nome dos Jogadores",
   CurrentValue = false,
   Flag = "ESPNamesToggle",
   Callback = function(Value)
      nomesAtivo = Value
      if not nomesAtivo then removerNomes() else atualizarESP() end
      
      Rayfield:Notify({
         Title = "ESP - Nomes",
         Content = Value and "Ativado" or "Desativado",
         Duration = 2,
         Image = 'shield-check',
      })
   end
})

EspTab:CreateToggle({
   Name = "Mostrar Linhas aos Jogadores",
   CurrentValue = false,
   Flag = "ESPLinesToggle",
   Callback = function(Value)
      linhasAtivo = Value
      if not linhasAtivo then removerLinhas() else atualizarESP() end
      
      Rayfield:Notify({
         Title = "ESP - Linhas",
         Content = Value and "Ativado" or "Desativado",
         Duration = 2,
         Image = 'shield-check',
      })
   end
})

EspTab:CreateToggle({
   Name = "Health ESP (Barras de Vida)",
   CurrentValue = false,
   Flag = "HealthESPToggle",
   Callback = function(Value)
      healthESPAtivo = Value
      if not healthESPAtivo then removerHealthESP() else atualizarESP() end
      
      Rayfield:Notify({
         Title = "ESP - Health",
         Content = Value and "Ativado" or "Desativado",
         Duration = 2,
         Image = 'shield-check',
      })
   end
})


local BindsTab = Window:CreateTab("Binds","keyboard")

local Keybind = BindsTab:CreateKeybind({
   Name = "Keybind Example",
   CurrentKeybind = "Q",
   HoldToInteract = false,
   Flag = "Keybind1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Keybind)
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

   end,
})