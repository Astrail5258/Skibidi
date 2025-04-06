local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local localPlayer = PlayersService.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- List of greetings to detect (updated)
local greetingsToDetect = {"how are you", "howdy", "you good", "you ok", "are you", "what new"}

-- List of responses to send
local responses = {
    "I'm doing great, you?",  
    "Everything is good!",  
    "Great!",  
    "Such a good world.",
    "The weather is so good today!",
    "Everything is alright, what about you?",
    "Alright, what's new?"
}

local lastResponseTime = 0
local cooldownDuration = 7 -- 7 seconds cooldown

-- Function to send chat messages
local function sendChat(msg)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
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

-- Function to get a random response
local function getRandomResponse()
    return responses[math.random(1, #responses)]
end

-- Function to check if a message contains a greeting
local function containsGreeting(message)
    local lowerMessage = string.lower(message)
    for _, greeting in ipairs(greetingsToDetect) do
        if string.find(lowerMessage, greeting) then
            return true
        end
    end
    return false
end

-- Function to check if a player is within range
local function isPlayerInRange(player)
    local playerCharacter = player.Character
    if playerCharacter then
        local playerHRP = playerCharacter:FindFirstChild("HumanoidRootPart")
        if playerHRP then
            return (playerHRP.Position - humanoidRootPart.Position).Magnitude <= 15
        end
    end
    return false
end

-- Function to handle chat messages
local function onChatted(player, message)
    if player ~= localPlayer and isPlayerInRange(player) and containsGreeting(message) then
        local currentTime = tick()
        if currentTime - lastResponseTime >= cooldownDuration then
            wait(math.random(1, 3))
            sendChat(getRandomResponse())
            lastResponseTime = currentTime
        end
    end
end

-- Connect to PlayerAdded event
PlayersService.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        onChatted(player, message)
    end)
end)

-- Connect to existing players
for _, player in ipairs(PlayersService:GetPlayers()) do
    player.Chatted:Connect(function(message)
        onChatted(player, message)
    end)
end

localPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("Auto-response script is now running!")
  
