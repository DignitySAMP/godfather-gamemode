/**
 *                        __  __  __                            __
 *                       |  \|  \|  \                          |  |
 *      _______  ______  | $$| $$| $$____    ______    _______ | $$   __   _______
 *     /       \|      \ | $$| $$| $$    \  |      \  /       \| $$  /  \ /       |
 *    |  $$$$$$$ \$$$$$$\| $$| $$| $$$$$$$\  \$$$$$$\|  $$$$$$$| $$_/  $$|  $$$$$$$
 *    | $$      /      $$| $$| $$| $$  | $$ /      $$| $$      | $$   $$  \$$    |
 *    | $$_____|  $$$$$$$| $$| $$| $$__/ $$|  $$$$$$$| $$_____ | $$$$$$\  _\$$$$$$|
 *     \$$     \\$$    $$| $$| $$| $$    $$ \$$    $$ \$$     \| $$  \$$\|       $$
 *      \$$$$$$$ \$$$$$$$ \$$ \$$ \$$$$$$$   \$$$$$$$  \$$$$$$$ \$$   \$$ \$$$$$$$
 *
 */
forward Chat_RouteText(playerid, const text[]);
forward bool:Spawn_CanSelectClass(playerid);
forward bool:Spawn_CanRequestSpawn(playerid);
forward bool:DriveBy_AllowShot(playerid, weaponid);
forward bool:Factions_IsCop(playerid);
forward bool:Vehicles_ReleaseDriver(playerid);
forward bool:Vehicles_SetHouseCarStyle(houseid, model, color1, color2);
forward bool:Staff_IsSpectating(playerid);
forward bool:Account_IsMuted(playerid);

forward Dialog_OnResponse(playerid, dialogid, response, listitem, const inputtext[]);

public Dialog_OnResponse(playerid, dialogid, response, listitem, const inputtext[])
{
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    pawn_call_public("Dialog_OnResponse", "dddds", playerid, dialogid, response, listitem, inputtext);
    return 0;
}

public OnPlayerUpdate(playerid)
{
    return 1;
}

public OnGameModeExit()
{
    return 1;
}

public OnPlayerConnect(playerid)
{
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    return 1;
}

public OnPlayerSpawn(playerid)
{
    return 1;
}

public OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
    return 1;
}

public OnPlayerWeaponShot(playerid, WEAPON:weaponid, BULLET_HIT_TYPE:hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
    return DriveBy_AllowShot(playerid, _:weaponid) ? 1 : 0;
}

public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
    return 1;
}

public OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
    return 1;
}

public OnRconCommand(cmd[])
{
    return 0;
}

public OnRuntimeError(code, &bool:suppress)
{
    #pragma unused suppress
    return 1;
}

public OnPlayerText(playerid, text[])
{
    return Chat_RouteText(playerid, text);
}

public OnPlayerRequestClass(playerid, classid)
{
    #pragma unused classid
    return Spawn_CanSelectClass(playerid) ? 1 : 0;
}

public OnPlayerRequestSpawn(playerid)
{
    return Spawn_CanRequestSpawn(playerid) ? 1 : 0;
}
