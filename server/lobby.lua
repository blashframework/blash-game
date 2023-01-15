local Blash = exports['blash-core']:GetObject()

local LOBBY_STATUS = {
    WAITING = 'waiting',
    STARTED = 'started',
}
local lobbies = {
    ['lobby1'] = {
        players = {},
        status = LOBBY_STATUS.WAITING,
        location = 'Pre-Game'
    }
}
local players = {}

--[[
    Function for teleporting a player, setting their bucket, and giving them a weapon when joining a lobby.
    params:
        player: number,
        lobby: string
]] --
function setupPlayerForGame(player, lobby)
    TriggerClientEvent('lobbymenu:CloseMenu', player)
    local lobbyNumber = tonumber(string.match(lobby, '%d+'))
    Blash.Functions.SetPlayerBucket(player, lobbyNumber)
    local location = lobbies[lobby].location
    local spawnPoint = location.spawnPoints[math.random(#location.spawnPoints)]
    TriggerClientEvent('Blash:Command:TeleportToCoords', player, spawnPoint.x, spawnPoint.y, spawnPoint.z)
    GiveWeaponToPed(GetPlayerPed(player), Config.Gamemode.weapons[1].name, 120, false, true)
    players[player] = {
        weaponIndex = 1,
        kills = 0
    }
end

--[[
    Function to create a lobby.
    params:
        name: string
]] --
function createLobby(name)
    lobbies[name] = {}
    lobbies[name].players = {}
    lobbies[name].status = LOBBY_STATUS.WAITING
    lobbies[name].location = "Pre-Game"
end
exports('createLobby', createLobby)

--[[
    Function to join a lobby.
    params:
        name: string,
        player: number (server id)
    usages:
        joinLobby(nil, player) - Join the first available lobby
        joinLobby(name, player) - Joins the specified lobby or first available if specified can not be found
]] --
function joinLobby(name, player)
    if not player then player = source end
    print(name, player)
    if lobbies[name] then
        local lobby = lobbies[name]
        if getPlayerLobby(player) == name then
            Blash.Functions.Notify(player, 'You are already in this lobby.', 'error')
            return
        end

        if #lobbies[name].players < Config.Lobby.maxPlayersPerLobby then
            table.insert(lobbies[name].players, player)
            Blash.Functions.Notify(player, 'You\'ve joined the lobby.', 'success')
            if lobby.status == LOBBY_STATUS.STARTED then
                Blash.Functions.Notify(player, 'You are joining the game...', 'info')
                -- setupPlayerForGame(player, name)
            else
                Blash.Functions.Notify(player, 'Please wait for the lobby to start...', 'info')
            end
            return
        else
            Blash.Functions.Notify(player, 'That lobby is full.', 'error')
        end
    else
        Blash.Functions.Notify(player, 'There was an error joining that lobby.', 'error')
    end

    local newLobbyName = "lobby" .. #lobbies + 1
    createLobby(newLobbyName)
    table.insert(lobbies[newLobbyName].players, player)
    Blash.Functions.Notify(player, 'You\'ve joined the lobby (' .. newLobbyName .. ').', 'success')
end
exports('joinLobby', joinLobby)

RegisterNetEvent('blash-game:server:joinLobby', function (name)
    joinLobby(name, source)
end)

--[[
    Function to leave a lobby.
    params:
        player: string (name according to FiveM)
]] --
function leaveLobby(player)
    -- Find the lobby the player is in
    for _, lobby in pairs(lobbies) do
        for i, p in pairs(lobby.players) do
            if p == player then
                table.remove(lobby.players, i)
                Blash.Functions.SetPlayerBucket(player, 0)
                return
            end
        end
    end
end

exports('leaveLobby', leaveLobby)

--[[
    Function to get a table of all created lobbies.
]] --
function getLobbies()
    local lobbyList = {}
    for name, lobby in pairs(lobbies) do
        local lobbyInfo = {}
        lobbyInfo.name = name
        lobbyInfo.players = lobby.players
        lobbyInfo.status = lobby.status
        lobbyInfo.location = lobby.location
        if #lobby.players < Config.Lobby.maxPlayersPerLobby then
            lobbyInfo.joinable = true
        else
            lobbyInfo.joinable = false
        end
        table.insert(lobbyList, lobbyInfo)
    end
    return lobbyList
end
exports('getLobbies', getLobbies)

--[[
    Function to get the lobby a player is in.
]] --
function getPlayerLobby(player)
    for lobbyName, lobby in pairs(lobbies) do
        if lobby.players[player] then
            return lobbyName
        end
    end

    return nil
end
exports('getPlayerLobby', getPlayerLobby)

--[[
    Function to start a lobby.
    params:
        name: string
]] --
function startLobby(name)
    if not lobbies[name] then
        exports['boppe-logging']:Error('blash-game', 'joinLobby', name .. ' lobby does not exist')
        return
    end

    local lobby = lobbies[name]
    lobby.status = LOBBY_STATUS.STARTED
    lobby.location = Config.Gamemode.locations[math.random(#Config.Gamemode.locations)]
    for _, player in pairs(lobby.players) do
        setupPlayerForGame(player, name)
    end
    exports['boppe-logging']:Info('blash-game', 'joinLobby', name .. ' lobby has started!')
end

exports('startLobby', startLobby)

--[[
    Function to set the current status of a lobby.
    params:
        lobby: string
        status:
]] --
function setLobbyStatus(lobby, status)
    if not LOBBY_STATUS[status] then
        exports['boppe-logging']:Fatal('blash-game', 'setLobbyStatus', 'INVALID LOBBY STATUS. RESETTING TO WAITING.')
        status = LOBBY_STATUS.WAITING
    end
    lobby.status = status
end
exports('setLobbyStatus', setLobbyStatus)

--[[
    Function to start a lobby.
    params:
        name: string
]] --
function playerKilled(killer, _)
    if players[killer] then
        players[killer].kills = players[killer].kills + 1

        local currentWeaponIndex = players[killer].weaponIndex
        if players[killer].kills == Config.Gamemode.weapons[currentWeaponIndex].killsNeeded then
            if currentWeaponIndex < #Config.Gamemode.weapons then
                currentWeaponIndex = currentWeaponIndex + 1
                GiveWeaponToPed(GetPlayerPed(killer), Config.Gamemode.weapons[currentWeaponIndex].name, 120, false, true)
                players[killer] = {
                    weaponIndex = currentWeaponIndex,
                    kills = 0
                }
            else
                local lobby = getPlayerLobby(killer)
                for _, player in pairs(lobbies[lobby].players) do
                    SetPlayerControl(player, false, 0)
                    RemoveAllPedWeapons(GetPlayerPed(player), true)
                    Blash.Functions.Notify(player, GetPlayerName(player) .. ' has won!', 'success')
                    CreateThread(function() Wait(10000) end)
                    Blash.Functions.SetPlayerBucket(player, 0)
                    lobby.players[player] = nil
                    setLobbyStatus(lobby, LOBBY_STATUS.WAITING)
                    TriggerClientEvent('Blash:Command:TeleportToCoords', player, Config.Gamemode.spawnCoordinates.x, Config.Gamemode.spawnCoordinates.y, Config.Gamemode.spawnCoordinates.z)
                    TriggerClientEvent('lobbymenu:OpenMainMenu', player)
                    SetPlayerControl(player, true, 0)
                end
            end
        end
    end
end

AddEventHandler("playerKilled", playerKilled)

--[[
    Function to check and delete empty lobbies
]] --
function checkLobbies()
    for name, lobby in pairs(lobbies) do
        if #lobby.players == 0 and #lobbies > Config.Lobby.minLobbies then
            lobbies[name] = nil
        else
            if lobby.status == LOBBY_STATUS.WAITING then
                if #lobby.players >= Config.Lobby.minPlayersToStart then
                    startLobby(name)
                else
                    local startTime = os.time()
                    local function checkStart()
                        if #lobby.players >= Config.Lobby.minPlayersToStart or
                            os.difftime(os.time(), startTime) >= Config.Lobby.maxTimeToWait then
                            startLobby(name)
                            return
                        end
                        SetTimeout(1000, checkStart)
                    end

                    checkStart()
                end
            end
        end
    end
end

SetTimeout(10000, checkLobbies)
