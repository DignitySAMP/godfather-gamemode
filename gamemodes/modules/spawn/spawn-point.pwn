/**
 *      ______                                   __      __
 *     /      \                                 |  \    |  |
 *    |  $$$$$$\ __    __  _______    _______  _| $$_    \$$  ______   _______    _______
 *    | $$_  \$$|  \  |  \|       \  /       \|   $$ \  |  \ /      \ |       \  /       |
 *    | $$ \    | $$  | $$| $$$$$$$\|  $$$$$$$ \$$$$$$  | $$|  $$$$$$\| $$$$$$$\|  $$$$$$$
 *    | $$$$    | $$  | $$| $$  | $$| $$        | $$ __ | $$| $$  | $$| $$  | $$ \$$    |
 *    | $$      | $$__/ $$| $$  | $$| $$_____   | $$|  \| $$| $$__/ $$| $$  | $$ _\$$$$$$|
 *    | $$       \$$    $$| $$  | $$ \$$     \   \$$  $$| $$ \$$    $$| $$  | $$|       $$
 *     \$$        \$$$$$$  \$$   \$$  \$$$$$$$    \$$$$  \$$  \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
stock Spawn_ApplyTeamColour(playerid)
{
    if (IsPlayerConnected(playerid))
    {
        SetPlayerColor(playerid,TEAM_HIT_COLOR);
    }
}

stock Spawn_Begin(playerid)
{
    new Float:x, Float:y, Float:z;
    Account_GetPosition(playerid,x,y,z);
    SetSpawnInfo(playerid,Account_GetTeam(playerid),Account_GetModel(playerid),x,y,z,1.0,WEAPON:0,0,WEAPON:0,0,WEAPON:0,0);
    SpawnPlayer(playerid);
}

stock Spawn_Place(playerid)
{
    Spawn_ClearPoint(playerid);
    pawn_call_public("Spawn_OnChoose","d",playerid);

    new Float:x, Float:y, Float:z, Float:angle, interior;

    if (Spawn_HasPoint(playerid))
    {
        Spawn_GetPoint(playerid,x,y,z,angle,interior);
        SetPlayerInterior(playerid,interior);
        SetPlayerPos(playerid,x,y,z);
        SetPlayerFacingAngle(playerid,angle);
        Spawn_ApplyTeamColour(playerid);
        return;
    }

    Spawn_GetDefaultPoint(Account_GetOrigin(playerid),x,y,z,angle,interior);
    SetPlayerInterior(playerid,interior);
    SetPlayerPos(playerid,x,y,z);
    SetPlayerFacingAngle(playerid,angle);
    Account_SetInterior(playerid,interior);
    Spawn_ApplyTeamColour(playerid);
}

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
public Spawn_OnChoose(playerid)
{
    return 1;
}

/**
 *     __                            __
 *    |  \                          |  |
 *    | $$____    ______    ______  | $$   __   _______
 *    | $$    \  /      \  /      \ | $$  /  \ /       |
 *    | $$$$$$$\|  $$$$$$\|  $$$$$$\| $$_/  $$|  $$$$$$$
 *    | $$  | $$| $$  | $$| $$  | $$| $$   $$  \$$    |
 *    | $$  | $$| $$__/ $$| $$__/ $$| $$$$$$\  _\$$$$$$|
 *    | $$  | $$ \$$    $$ \$$    $$| $$  \$$\|       $$
 *     \$$   \$$  \$$$$$$   \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
#include <pp-hooks>

hook OnPlayerConnect(playerid)
{
    Spawn_ResetPlayer(playerid);
    SetPlayerColor(playerid,COLOR_GRAD2);
}

hook Player_OnReady(playerid)
{
    Spawn_Begin(playerid);
}

hook OnPlayerSpawn(playerid)
{
    if (IsPlayerNPC(playerid))
    {
        return;
    }

    if (!Player_IsReady(playerid))
    {
        SendClientMessage(playerid,COLOR_LIGHTRED,SPAWN_KICK_MESSAGE);
        Account_QueueKick(playerid);
        return;
    }

    if (Account_GetChar(playerid) > 0)
    {
        SetPlayerSkin(playerid,Account_GetChar(playerid));
    }
    else
    {
        SetPlayerSkin(playerid,Account_GetModel(playerid));
    }

    if (Account_GetTutorial(playerid) == 0)
    {
        Account_BeginRegistration(playerid);
    }

    Spawn_Place(playerid);
}
