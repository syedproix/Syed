-- Abilities Arena Script v2 - Delta Executor Compatible
-- Debug & Improved Version

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

print("[DEBUG] Script loaded successfully")

-- Settings
local Settings = {
    AutoTPEnabled = false,
    AutoPunchEnabled = false,
    TPKey = Enum.KeyCode.T,
    PunchKey = Enum.KeyCode.P,
    PunchDelay = 0.01, -- Very fast punching
    MaxTPDistance = 1000,
}

-- Function to get nearest player
local function GetNearestPlayer()
    local nearestPlayer = nil
    local nearestDistance = Settings.MaxTPDistance
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherHRP and otherPlayer.Character:FindFirstChild("Humanoid") then
                if otherPlayer.Character.Humanoid.Health > 0 then
                    local distance = (humanoidRootPart.Position - otherHRP.Position).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestPlayer = otherPlayer
                    end
                end
            end
        end
    end
    
    return nearestPlayer
end

-- Teleport function
local function TeleportToPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP and humanoidRootPart then
            humanoidRootPart.CFrame = targetHRP.CFrame + targetHRP.CFrame.LookVector * -5
        end
    end
end

-- Punch function - tries multiple methods
local function PunchPlayer()
    pcall(function()
        -- Method 1: Check for Punch button in GUI
        local playerGui = player:WaitForChild("PlayerGui")
        local screenGui = playerGui:FindFirstChild("ScreenGui")
        
        if screenGui then
            local punchBtn = screenGui:FindFirstChild("PunchButton") or 
                            screenGui:FindFirstChild("Punch") or
                            screenGui:FindFirstChildOfClass("TextButton")
            
            if punchBtn then
                punchBtn:Invoke()
                print("[DEBUG] Punched via GUI button")
                return
            end
        end
    end)
    
    pcall(function()
        -- Method 2: Fire server event
        local rs = game:GetService("ReplicatedStorage")
        local punch = rs:FindFirstChild("Punch") or rs:FindFirstChild("Hit") or rs:FindFirstChild("Attack")
        
        if punch and punch:IsA("RemoteEvent") then
            punch:FireServer()
        elseif punch and punch:IsA("RemoteFunction") then
            punch:InvokeServer()
        end
    end)
    
    pcall(function()
        -- Method 3: Try workspace punch
        local workspace_punch = game.Workspace:FindFirstChild("Punch")
        if workspace_punch then
            workspace_punch:FireServer()
        end
    end)
end

-- Auto TP Loop
local function AutoTPLoop()
    while Settings.AutoTPEnabled do
        pcall(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                humanoidRootPart = player.Character.HumanoidRootPart
                local target = GetNearestPlayer()
                if target then
                    TeleportToPlayer(target)
                end
            end
        end)
        wait(0.05)
    end
end

-- Auto Punch Loop
local function AutoPunchLoop()
    while Settings.AutoPunchEnabled do
        pcall(function()
            PunchPlayer()
        end)
        wait(Settings.PunchDelay)
    end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Settings.TPKey then
        Settings.AutoTPEnabled = not Settings.AutoTPEnabled
        print("[AUTO TP] " .. (Settings.AutoTPEnabled and "✓ ENABLED" or "✗ DISABLED"))
        
        if Settings.AutoTPEnabled then
            task.spawn(AutoTPLoop)
        end
    end
    
    if input.KeyCode == Settings.PunchKey then
        Settings.AutoPunchEnabled = not Settings.AutoPunchEnabled
        print("[AUTO PUNCH] " .. (Settings.AutoPunchEnabled and "✓ ENABLED" or "✗ DISABLED"))
        
        if Settings.AutoPunchEnabled then
            task.spawn(AutoPunchLoop)
        end
    end
end)

-- Character respawn handler
Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    print("[DEBUG] Character respawned")
end)

print("╔════════════════════════════════════╗")
print("║  ABILITIES ARENA SCRIPT v2         ║")
print("║  Press T - Toggle Auto TP          ║")
print("║  Press P - Toggle Auto Punch       ║")
print("╚════════════════════════════════════╝")
