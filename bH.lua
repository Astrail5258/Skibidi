local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local minWalkSpeed = 13.5
local maxWalkSpeed = 18
local detectionRadius = 10 -- Detection radius in studs
local lastInteractionTime = 0 -- Last time the AI interacted with a player
local interactionCooldown = 5 -- Cooldown in seconds
local speedChangeInterval = 10 -- Time interval for speed changes in seconds
local maxWalkingDistance = 30 -- Maximum distance the AI can walk away from its start position

local messages = {
    "Hello!",  
    "How are you?",   
    "What's up?",   
    "Nice to meet you!",   
    "Hello there!",  
    "Hey, what's going on?",  
    "How's it going?",  
    "Just passing by!",  
    "How's your day?",  
    "Hey there!",  
    "Nice to see you!",  
    "How's everything?",  
    "Good to see you!",  
    "What brings you here?",  
    "What's happening?",  
    "Hello, friend!",  
    "What’s new?",  
    "Greetings!",  
    "Hey, how’s it going?",  
    "Nice weather, huh?"
}

local startPosition = rootPart.Position -- Store the starting position of the AI

local function getRandomPosition()
    local randomAngle = math.random() * math.pi * 2
    local randomDistance = math.random(10, maxWalkingDistance)
    local newX = startPosition.X + math.cos(randomAngle) * randomDistance
    local newZ = startPosition.Z + math.sin(randomAngle) * randomDistance
    return Vector3.new(newX, startPosition.Y, newZ)
end

local function sendChat(msg)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
    else
        local chatEvents = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents", 10)
        if chatEvents then
            local sayMessageRequest = chatEvents:WaitForChild("SayMessageRequest", 10)
            if sayMessageRequest then
                sayMessageRequest:FireServer(msg, "All")
            end
        end
    end
end

local function isPlayerNearby()
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (otherPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            if distance <= detectionRadius then
                return otherPlayer.Character.HumanoidRootPart.Position
            end
        end
    end
    return nil
end

local function changeWalkSpeed()
    humanoid.WalkSpeed = math.random() * (maxWalkSpeed - minWalkSpeed) + minWalkSpeed
end

local function aiBehavior()
    local lastSpeedChangeTime = 0
    local lastSentMessage = ""

    while true do
        -- Change speed at a set interval
        if os.time() - lastSpeedChangeTime > speedChangeInterval then
            changeWalkSpeed()
            lastSpeedChangeTime = os.time()
        end
        
        local targetPosition = getRandomPosition()
        humanoid:MoveTo(targetPosition)
        
        while (rootPart.Position - targetPosition).Magnitude > 1 do
            -- Check if a player is nearby and handle interaction
            local playerPosition = isPlayerNearby()
            if playerPosition and os.time() - lastInteractionTime > interactionCooldown then
                humanoid:MoveTo(rootPart.Position) -- Stop walking when interacting with a player
                
                -- Rotate to face the player
                local lookAtPosition = CFrame.new(rootPart.Position, playerPosition).LookVector
                humanoid:MoveTo(playerPosition) -- Move towards the player to close the gap
                humanoid:MoveTo(rootPart.Position) -- Then stop for a second
                character:SetPrimaryPartCFrame(CFrame.new(rootPart.Position, playerPosition))
                
                local waitTime = math.random() * 2 + 2 -- Wait between 2 and 4 seconds
                wait(waitTime)
                
                -- Ensure AI doesn't send the same message twice in a row
                local randomMessage
                repeat
                    randomMessage = messages[math.random(#messages)]
                until randomMessage ~= lastSentMessage

                sendChat(randomMessage)
                lastSentMessage = randomMessage -- Update the last sent message

                lastInteractionTime = os.time() -- Update the last interaction time
                wait(1) -- Wait a second after sending the message
                break
            end
            
            -- Lower jump chance (5% chance)
            if math.random() < 0.05 then
                humanoid.Jump = true
            end
            
            -- Reduce movement stopping chance to make it less frequent (3% chance)
            if math.random() < 0.03 then
                wait(math.random() + 1) -- Random pause between 1 and 2 seconds
            end
            
            wait(0.1)
        end
        
        wait(1) -- Short pause between movements
    end
end

-- Start the AI behavior
coroutine.wrap(aiBehavior)()
