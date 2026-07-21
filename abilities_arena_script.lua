-- Abilities Arena Script for Delta Executor
-- Features: Auto TP to Player + Auto Punch

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local Settings = {
    AutoTPEnabled = false,
    AutoPunchEnabled = false,
    TPKey = Enum.KeyCode.T,
    PunchKey = Enum.KeyCode.P,
    PunchDelay = 0.05,
    MaxTPDistance = 500,
}

-- Target Management
local TargetPlayer = nil

-- Function to get nearest player
local function GetNearestPlayer()
    local nearestPlayer = nil
    local nearestDistance = Settings.MaxTPDistance
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherChar = otherPlayer.Character
            local otherHRP = otherChar:FindFirstChild("HumanoidRootPart")
            
            if otherHRP then
                local distance = (humanoidRootPart.Position - otherHRP.Position).Magnitude
                
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = otherPlayer
                end
            end
        end
    end
    
    return nearestPlayer
end

-- Function to teleport to player
local function TeleportToPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if targetHRP then
            -- Teleport in front of the player
            local teleportOffset = (targetHRP.CFrame.LookVector * -3) + Vector3.new(0, 0, 0)
            humanoidRootPart.CFrame = targetHRP.CFrame + teleportOffset
        end
    end
end

-- Function to send punch request to server
local function PunchPlayer()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Try common punch remote names
    local punchRemote = replicatedStorage:FindFirstChild("Punch") or 
                        replicatedStorage:FindFirstChild("Hit") or
                        replicatedStorage:FindFirstChild("Attack") or
                        replicatedStorage:FindFirstChild("PunchPlayer")
    
    if punchRemote and punchRemote:IsA("RemoteFunction") then
        pcall(function()
            punchRemote:InvokeServer()
        end)
    elseif punchRemote and punchRemote:IsA("RemoteEvent") then
        pcall(function()
            punchRemote:FireServer()
        end)
    end
end

-- Auto TP Loop
local function AutoTPLoop()
    while Settings.AutoTPEnabled do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            local nearestPlayer = GetNearestPlayer()
            
            if nearestPlayer then
                TargetPlayer = nearestPlayer
                TeleportToPlayer(TargetPlayer)
            end
        end
        
        wait(0.1)
    end
end

-- Auto Punch Loop
local function AutoPunchLoop()
    while Settings.AutoPunchEnabled do
        if player.Character then
            PunchPlayer()
        end
        
        wait(Settings.PunchDelay)
    end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle Auto TP
    if input.KeyCode == Settings.TPKey then
        Settings.AutoTPEnabled = not Settings.AutoTPEnabled
        print("Auto TP: " .. (Settings.AutoTPEnabled and "ENABLED ✓" or "DISABLED ✗"))
        
        if Settings.AutoTPEnabled then
            task.spawn(AutoTPLoop)
        end
    end
    
    -- Toggle Auto Punch
    if input.KeyCode == Settings.PunchKey then
        Settings.AutoPunchEnabled = not Settings.AutoPunchEnabled
        print("Auto Punch: " .. (Settings.AutoPunchEnabled and "ENABLED ✓" or "DISABLED ✗"))
        
        if Settings.AutoPunchEnabled then
            task.spawn(AutoPunchLoop)
        end
    end
end)

-- Handle character respawn
Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("========================================")
print("Abilities Arena Script Loaded!")
print("========================================")
print("Press T to toggle Auto TP to nearest player")
print("Press P to toggle Auto Punch")
print("========================================")
