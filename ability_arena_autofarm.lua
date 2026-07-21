-- Ability Arena Auto TP & Auto Punch Script
-- This script automatically teleports to nearby players and punches them

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local Config = {
    Enabled = true,
    AutoTPEnabled = true,
    AutoPunchEnabled = true,
    TPRange = 50, -- Maximum distance to TP to players
    PunchRange = 5, -- Range to start punching
    PunchCooldown = 0.1, -- Time between punches (in seconds)
    TargetTeamEnemies = true, -- Only target enemy team
}

local lastPunchTime = 0

-- Function to get all players in range
local function GetPlayersInRange(range)
    local playersInRange = {}
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
            if targetHRP and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (humanoidRootPart.Position - targetHRP.Position).Magnitude
                if distance <= range then
                    table.insert(playersInRange, {
                        Player = targetPlayer,
                        Distance = distance,
                        HRP = targetHRP,
                        Humanoid = targetHumanoid
                    })
                end
            end
        end
    end
    -- Sort by distance (closest first)
    table.sort(playersInRange, function(a, b)
        return a.Distance < b.Distance
    end)
    return playersInRange
end

-- Function to teleport to a player
local function TeleportToPlayer(targetHRP)
    if humanoidRootPart and targetHRP then
        -- TP slightly behind/above the target for better punching
        local offset = (targetHRP.Position - humanoidRootPart.Position).Unit * 3
        humanoidRootPart.CFrame = targetHRP.CFrame + offset + Vector3.new(0, 2, 0)
    end
end

-- Function to punch
local function Punch()
    local currentTime = tick()
    if currentTime - lastPunchTime >= Config.PunchCooldown then
        -- Try to find punch tool or use character attack
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Punch") then
            tool.Punch:FireServer()
        elseif tool then
            tool:Activate()
        else
            -- Fallback: use humanoid:TakeDamage if needed
            local event = character:FindFirstChild("Punch")
            if event then
                event:FireServer()
            end
        end
        lastPunchTime = currentTime
    end
end

-- Function to get closest player
local function GetClosestPlayer()
    local playersInRange = GetPlayersInRange(Config.TPRange)
    return playersInRange[1] or nil
end

-- Main loop
local connection
connection = RunService.RenderStepped:Connect(function()
    if not Config.Enabled then return end
    
    -- Update character reference if needed
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        character = player.Character or player.CharacterAdded:Wait()
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        return
    end
    
    local closestPlayer = GetClosestPlayer()
    
    if closestPlayer then
        -- Auto TP
        if Config.AutoTPEnabled then
            TeleportToPlayer(closestPlayer.HRP)
        end
        
        -- Auto Punch
        if Config.AutoPunchEnabled then
            local distance = (humanoidRootPart.Position - closestPlayer.HRP.Position).Magnitude
            if distance <= Config.PunchRange then
                Punch()
            end
        end
    end
end)

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        Config.Enabled = not Config.Enabled
        print("Script " .. (Config.Enabled and "Enabled" or "Disabled"))
    elseif input.KeyCode == Enum.KeyCode.U then
        Config.AutoTPEnabled = not Config.AutoTPEnabled
        print("Auto TP " .. (Config.AutoTPEnabled and "Enabled" or "Disabled"))
    elseif input.KeyCode == Enum.KeyCode.I then
        Config.AutoPunchEnabled = not Config.AutoPunchEnabled
        print("Auto Punch " .. (Config.AutoPunchEnabled and "Enabled" or "Disabled"))
    end
end)

print("=== Ability Arena Auto Farm Script Loaded ===")
print("P - Toggle Script On/Off")
print("U - Toggle Auto TP")
print("I - Toggle Auto Punch")
print("Range: " .. Config.TPRange .. " studs")
print("Punch Range: " .. Config.PunchRange .. " studs")
