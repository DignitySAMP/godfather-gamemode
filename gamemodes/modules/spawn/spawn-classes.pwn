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
static Spawn_ShowClassText(playerid,classid)
{
    new line[96];

    switch (classid)
    {
        case 1:
        {
            line = "~y~> ~p~Police Chief ~y~< ~n~Leaders only!";
        }
        case 2:
        {
            line = "~y~> ~p~FBI/ATF Leader ~y~< ~n~Leaders only!";
        }
        case 3:
        {
            line = "~y~> ~p~National Guard General ~y~< ~n~Leaders only!";
        }
        case 4:
        {
            line = "~y~> ~p~Fire/Ambulance Chief ~y~< ~n~Leaders only!";
        }
        case 5:
        {
            line = "~y~> ~p~La Cosa Nostra Leader ~y~< ~n~Leaders only!";
        }
        case 6:
        {
            line = "~y~> ~p~Yakuza Leader ~y~< ~n~Leaders only!";
        }
        case 7:
        {
            line = "~y~> ~p~Mayor ~y~< ~n~Leaders only!";
        }
        case 8:
        {
            line = "~y~> ~p~Hitman Leader ~y~< ~n~Leaders only!";
        }
        case 9:
        {
            line = "~y~> ~p~News Leader ~y~< ~n~Leaders only!";
        }
        case 10:
        {
            line = "~y~> ~p~Taxi Cab Company Leader ~y~< ~n~Leaders only!";
        }
        case 11:
        {
            line = "~y~> ~p~License Faction Leader ~y~< ~n~Leaders only!";
        }
        default:
        {
            line = "~y~> ~g~Civilian ~y~<";
        }
    }

    GameTextForPlayer(playerid,line,SPAWN_CLASS_TEXT_MS,SPAWN_CLASS_TEXT_STYLE);
}

stock Spawn_SetupClassSelection(playerid)
{
    switch (Spawn_GetClassTeam(playerid))
    {
        case TEAM_BLUE:
        {
            SetPlayerInterior(playerid,5);
            SetPlayerPos(playerid,323.4,305.6,999.1);
            SetPlayerFacingAngle(playerid,90.0);
            SetPlayerCameraPos(playerid,323.4 - 1.5 - 1.0,305.6,999.1 + 0.7);
            SetPlayerCameraLookAt(playerid,323.4 - 1.0,305.6,999.1 + 0.7);
        }
        case TEAM_ADMIN:
        {
            SetPlayerInterior(playerid,3);
            SetPlayerPos(playerid,-2654.4,1424.2,912.4);
            SetPlayerFacingAngle(playerid,90.0);
            SetPlayerCameraPos(playerid,-2654.4 - 1.5,1424.2,912.4 + 0.7);
            SetPlayerCameraLookAt(playerid,-2654.4,1424.2,912.4 + 0.7);
        }
        default:
        {
            SetPlayerInterior(playerid,0);
            SetPlayerPos(playerid,-1657.5237,1207.6644,13.6719);
            SetPlayerFacingAngle(playerid,357.6906);
            SetPlayerCameraPos(playerid,-1657.4678,1211.2292,13.6781);
            SetPlayerCameraLookAt(playerid,-1657.5237,1207.6644,13.6719);
        }
    }
}

stock Spawn_TeamFromClass(classid)
{
    if (classid >= SPAWN_CLASS_LEADER_FIRST && classid <= SPAWN_CLASS_LEADER_LAST)
    {
        return SPAWN_LEADER_TEAM;
    }

    return SPAWN_CIVILIAN_TEAM;
}

bool:Spawn_CanSelectClass(playerid)
{
    #pragma unused playerid
    return true;
}

bool:Spawn_CanRequestSpawn(playerid)
{
    return IsPlayerNPC(playerid) || Player_IsReady(playerid);
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

hook OnPlayerRequestClass(playerid,classid)
{
    if (IsPlayerNPC(playerid))
    {
        return;
    }

    PlayerPlaySound(playerid,SPAWN_CLASS_SOUND,0.0,0.0,0.0);
    Spawn_SetClassChoice(playerid,Spawn_GetPedModel(classid),Spawn_TeamFromClass(classid));
    Spawn_ShowClassText(playerid,classid);
    Spawn_SetupClassSelection(playerid);
}

hook OnPlayerRequestSpawn(playerid)
{
    if (!Spawn_CanRequestSpawn(playerid))
    {
        SendClientMessage(playerid,COLOR_LIGHTRED,SPAWN_KICK_MESSAGE);
        Account_QueueKick(playerid);
    }
}
