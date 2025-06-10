local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local CurrentTheme = "Ocean"

local Window = Rayfield:CreateWindow({
    Name = "Script TESTE!! - WarTycoon V2",
    Icon = 'bomb',
    LoadingTitle = "Loading Script...",
    LoadingSubtitle = "by Kazz",
    Theme = CurrentTheme,
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ScriptTeste",
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

Rayfield:Notify({
    Title = "Script Teste Executado.",
    Content = "Aperte K para abrir",
    Duration = 8,
    Image = 'shield-check',
})

local MainTab = Window:CreateTab("ESP Controls", 'eye') -- Mudei o nome e ícone
local ESPSection = MainTab:CreateSection("ESP Settings") -- Seção específica para ESP

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local Typing = false

-- Checagem de suporte
if not Drawing then
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Erro de Compatibilidade",
        Text = "ESP não suportado pelo seu executor.",
        Duration = math.huge,
        Button1 = "OK"
    })
    return
end

-- Configurações globais
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
_G.TextFont = Drawing.Fonts.UI
_G.DisableKey = Enum.KeyCode.Q

-- Toggle do ESP via Rayfield (CORRIGIDO)
local ESPToggle = MainTab:CreateToggle({
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

-- Toggle para Team Check
local TeamCheckToggle = MainTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = _G.TeamCheck,
    Flag = "TeamCheckToggle",
    Callback = function(Value)
        _G.TeamCheck = Value
    end,
})

-- Slider para tamanho do texto
local TextSizeSlider = MainTab:CreateSlider({
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

-- Controle de texto (evita conflitos com TextBox)
UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == _G.DisableKey and not Typing then
        _G.ESPVisible = not _G.ESPVisible
        ESPToggle:Set(_G.ESPVisible)
        if _G.SendNotifications then
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = "ESP Hotkey",
                Text = "ESP agora está "..tostring(_G.ESPVisible),
                Duration = 5
            })
        end
    end
end)

-- Tabela para armazenar desenhos
local ESPObjects = {}

-- Função para criar ESP por jogador
local function CreateESPForPlayer(player)
    if player == Players.LocalPlayer or ESPObjects[player] then return end

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

-- Inicializa ESP para todos os jogadores
local function CreateESP()
    for _, player in pairs(Players:GetPlayers()) do
        CreateESPForPlayer(player)
    end

    Players.PlayerAdded:Connect(CreateESPForPlayer)
end

-- Executar
local Success, Errored = pcall(CreateESP)

if Success then
    if _G.SendNotifications then
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "ESP Carregado",
            Text = "ESP carregado com sucesso! Pressione K para abrir o menu.",
            Duration = 5
        })
    end
else
    if _G.SendNotifications then
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Erro ESP",
            Text = "Erro ao carregar ESP! Veja o console (F9).",
            Duration = 5
        })
    end
    warn(Errored)
end