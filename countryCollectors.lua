local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Function to move a model to the player
local function moveModelToPlayer(model, player)
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        model:SetPrimaryPartCFrame(humanoidRootPart.CFrame * CFrame.new(0, 0, 0))
    end
end

-- Function to recursively process parts and models
local function processObject(object, player)
    if object:IsA("Model") then
        -- If it's a model, set its PrimaryPart if not already set
        if not object.PrimaryPart then
            local firstPart = object:FindFirstChildWhichIsA("BasePart")
            if firstPart then
                object.PrimaryPart = firstPart
            end
        end
        
        if object.PrimaryPart then
            moveModelToPlayer(object, player)
        end
    elseif object:IsA("BasePart") then
        -- If it's a part, move it directly
        object.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
    end
    
    -- Process children recursively
    for _, child in ipairs(object:GetChildren()) do
        processObject(child, player)
    end
end

-- The main script
local function moveCtAreaToPlayer()
    local player = Players.LocalPlayer
    local ctAreaFolder = Workspace:FindFirstChild("ctAreaFolder")
    
    if not ctAreaFolder then
        warn("ctAreaFolder not found in Workspace!")
        return
    end
    
    for _, object in ipairs(ctAreaFolder:GetChildren()) do
        processObject(object, player)
    end
end

-- Execute the script
moveCtAreaToPlayer()
