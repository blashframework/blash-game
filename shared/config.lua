Config = {}

Config.Lobby = {
    minLobbies = 1,
    maxPlayersPerLobby = 20,
    maxTimeToWait = 2,
    minPlayersToStart = 10
}

Config.Gamemode = {
    spawnCoordinates = { x = -1041.48, y = -2735.51, z = 20.16 },
    locations = {
        { 
            name = "Downtown Los Santos",
            spawnPoints = {
                { x = -1041.48, y = -2735.51, z = 20.16 },
                { x = -1043.45, y = -2733.51, z = 20.16 },
                { x = -1045.42, y = -2731.51, z = 20.16 }
            }
        },
        { 
            name = "Vinewood Hills",
            spawnPoints = {
                { x = 699.01, y = 586.66, z = 130.83 },
                { x = 701.01, y = 584.66, z = 130.83 },
                { x = 703.01, y = 582.66, z = 130.83 }
            }
        },
        { 
            name = "Paleto Bay",
            spawnPoints = {
                { x = -447.33, y = 6012.35, z = 31.72 },
                { x = -449.33, y = 6014.35, z = 31.72 },
                { x = -451.33, y = 6016.35, z = 31.72 }
            }
        },
        { 
            name = "Sandy Shores",
            spawnPoints = {
                { x = 1961.21, y = 3814.82, z = 32.34 },
                { x = 1963.21, y = 3816.82, z = 32.34 },
                { x = 1965.21, y = 3818.82, z = 32.34 }
            }
        }
    },
    -- weapons should be listed in order
    weapons = {
        {
            name = 'weapon_carbinerifle',
            killsNeeded = 2
        }
    }
}