local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Tema atual (padrão)
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

-- Notificação Inicial
Rayfield:Notify({
    Title = "Script Teste Executado.",
    Content = "Aperte K para abrir",
    Duration = 8,
    Image = 'shield-check',
})

--- SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

--- VARIÁVEIS GLOBAIS

