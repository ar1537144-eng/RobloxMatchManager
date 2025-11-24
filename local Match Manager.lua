local MatchManager = {}


-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")




-- Module Scripts
local moduleScripts = ServerStorage:WaitForChild("ModuleScripts")
local playerManager = require(moduleScripts:WaitForChild("PlayerManager"))
local gameSettings = require(moduleScripts:WaitForChild("GameSettings"))
local timer = require(moduleScripts:WaitForChild("Timer"))


-- Events
local events = ServerStorage:WaitForChild("Events")
local matchStart = events:WaitForChild("MatchStart")
local matchEnd = events:WaitForChild("MatchEnd")


-- Values
local displayValues = ReplicatedStorage:WaitForChild("DisplayValues")
local timeLeft = displayValues:WaitForChild("TimeLeft")


local myTimer = timer.new()


-- Local Functions


local function stopTimer()
        myTimer:stop()
end


local function timeUp()
        matchEnd:Fire(gameSettings.endStates.TimerUp)
end


local function startTimer()
        print("Timer started")
        myTimer:start(gameSettings.matchDuration)
        myTimer.finished:Connect(timeUp)


        while myTimer:isRunning() do
                -- Adding +1 makes sure the timer display ends at 1 instead of 0.
                timeLeft.Value = (math.floor(myTimer:getTimeLeft() + 1))
                -- By not setting the time for wait, it offers more accurate looping
                task.wait()
        end
end




-- Module Functions
function MatchManager.prepareGame()
        playerManager.sendPlayersToMatch()
        matchStart:Fire()
end


function MatchManager.getEndStatus(endState)
        local statusToReturn


        if endState == gameSettings.endStates.FoundWinner then
                local winnerName = playerManager.getWinnerName()
                statusToReturn = "Winner is : " .. winnerName
        elseif endState == gameSettings.endStates.TimerUp then
                statusToReturn = "Time ran out!"
        else 
                statusToReturn = "Error found"
        end
        return statusToReturn
end


function MatchManager.cleanupMatch()
        playerManager.removeAllWeapons()
end


function MatchManager.resetMatch()
        playerManager.resetPlayers()
end


matchStart.Event:Connect(startTimer)
matchEnd.Event:Connect(stopTimer)


return MatchManager
