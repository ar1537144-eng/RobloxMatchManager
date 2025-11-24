local PlayerManager = {}


-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")


-- Modules
local moduleScripts = ServerStorage:WaitForChild("ModuleScripts")
local gameSettings = require(moduleScripts:WaitForChild("GameSettings"))


-- Events
local events = ServerStorage:WaitForChild("Events")
local matchEnd = events:WaitForChild("MatchEnd")


-- Map Variables
local lobbySpawn = workspace.Lobby.SpawnLocation
local arenaMap = workspace.Arena
local spawnLocations = arenaMap.SpawnLocations


-- Values
local displayValues = ReplicatedStorage:WaitForChild("DisplayValues")
local playersLeft = displayValues:WaitForChild("PlayersLeft")


-- Player Variables
local activePlayers = {}
local playerWeapon = ServerStorage.Weapon




-- Local Functions


local function checkPlayerCount()
        if #activePlayers == 1 then
                matchEnd:Fire(gameSettings.endStates.FoundWinner)
        end
end


local function removeActivePlayer(player)
        for playerKey, whichPlayer in activePlayers do
                if whichPlayer == player then
                        table.remove(activePlayers, playerKey)
                        playersLeft.Value = #activePlayers
                        checkPlayerCount()
                end
        end
end


local function respawnPlayerInLobby(player)
        player.RespawnLocation = lobbySpawn
        player:LoadCharacter()
end        


local function onPlayerJoin(player)
        player.RespawnLocation = lobbySpawn
end


local function preparePlayer(player, whichSpawn)
        player.RespawnLocation = whichSpawn
        player:LoadCharacter()


        local character = player.Character or player.CharacterAdded:Wait()
        local sword = playerWeapon:Clone()
        sword.Parent = character


        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
                respawnPlayerInLobby(player)
                removeActivePlayer(player)
        end)
end


local function removePlayerWeapon(whichPlayer)
        -- Check to see if a player exist in case they disconnected or left.
        if whichPlayer then
                local character = whichPlayer.Character


                -- If the player has it currently on their character
                local weapon = character:FindFirstChild("Weapon")


                if weapon then
                        weapon:Destroy()
                end


                -- If the player has the weapon in their backpack
                local backpackWeapon = whichPlayer.Backpack:FindFirstChild("Weapon") 


                if backpackWeapon then
                        backpackWeapon:Destroy()
                end
        else
                print("No player to remove weapon")
        end
end




-- Module Functions
function PlayerManager.sendPlayersToMatch()
        local arenaSpawns = spawnLocations:GetChildren()


        for playerKey, whichPlayer in Players:GetPlayers() do
                table.insert(activePlayers, whichPlayer)


                local spawnLocation = table.remove(arenaSpawns, 1)
                preparePlayer(whichPlayer, spawnLocation)
        end


        playersLeft.Value = #activePlayers
end


function PlayerManager.getWinnerName()
        local winningPlayer = activePlayers[1]


        if winningPlayer then
                return winningPlayer.Name
        else
                return "Error: No winning player found"
        end
end


function PlayerManager.removeAllWeapons()
        for playerKey, whichPlayer in activePlayers do
                removePlayerWeapon(whichPlayer)
        end
end


function PlayerManager.resetPlayers()
        for playerKey, whichPlayer in activePlayers do
                respawnPlayerInLobby(whichPlayer)
        end


        activePlayers = {}
end




-- Events
Players.PlayerAdded:Connect(onPlayerJoin)


return PlayerManager