local GameSettings = {}


-- Game Variables
GameSettings.intermissionDuration = 5
GameSettings.matchDuration = 90
GameSettings.minimumPlayers = 2
GameSettings.transitionTime = 5


-- Possible ways that the game can end.
GameSettings.endStates = {
        TimerUp = "TimerUp",
        FoundWinner = "FoundWinner"
}




return GameSettings