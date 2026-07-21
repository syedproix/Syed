-- Ability Arena Auto TP & Auto Punch Script (Button-Based)
-- This script uses the game's built-in TP and Punch buttons

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
    TPCooldown = 0.5, -- Time between TPs (in seconds)
    PunchCooldown = 0.1, -- Time between punches (in seconds)
}

local lastTPTime = 0
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

-- Function to click TP button (finds and activates the TP button in GUI)
local function ClickTPButton(targetPlayer)
    local currentTime = tick()
    if currentTime - lastTPTime >= Config.TPCooldown then
        -- Find TP button in the GUI
        local playerGui = player:WaitForChild("PlayerGui")
        
        -- Search for buttons in the GUI (adjust path based on actual game structure)
        local tpButton = playerGui:FindFirstChild("TPButton") or
                        playerGui:FindFirstChild("TeleportButton") or
                        playerGui:FindFirstChild("MainGui"):FindFirstChild("TPButton") if playerGui:FindFirstChild("MainGui")
        
        if tpButton and tpButton:IsA("TextButton") or tpButton:IsA("ImageButton") then
            tpButton:FireEvent("MouseButton1Click") or tpButton:FireEvent("Activated")
            print("TP Button Clicked for: " .. targetPlayer.Name)
        else
            print("TP Button not found - adjust GUI path")
        end
        lastTPTime = currentTime
    end
end

-- Function to click Punch button
local function ClickPunchButton()
    local currentTime = tick()
    if currentTime - lastPunchTime >= Config.PunchCooldown then
        local playerGui = player:WaitForChild("PlayerGui")
        
        -- Search for punch button in the GUI
        local punchButton = playerGui:FindFirstChild("PunchButton") or
                           playerGui:FindFirstChild("AttackButton") or
                           playerGui:FindFirstChild("MainGui"):FindFirstChild("PunchButton") if playerGui:FindFirstChild("MainGui")
        
        if punchButton and punchButton:IsA("TextButton") or punchButton:IsA("ImageButton") then
            punchButton:FireEvent("MouseButton1Click") or punchButton:FireEvent("Activated")
        else
            print("Punch Button not found - adjust GUI path")
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
            ClickTPButton(closestPlayer.Player)
        end
        
        -- Auto Punch
        if Config.AutoPunchEnabled then
            local distance = (humanoidRootPart.Position - closestPlayer.HRP.Position).Magnitude
            if distance <= Config.PunchRange then
                ClickPunchButton()
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
