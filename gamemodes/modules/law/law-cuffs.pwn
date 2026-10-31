/**
 *           __             __
 *          |  \           |  |
 *      ____| $$  ______  _| $$_     ______
 *     /      $$ |      \|   $$ \   |      |
 *    |  $$$$$$$  \$$$$$$\\$$$$$$    \$$$$$$|
 *    | $$  | $$ /      $$ | $$ __  /      $$
 *    | $$__| $$|  $$$$$$$ | $$|  \|  $$$$$$$
 *     \$$    $$ \$$    $$  \$$  $$ \$$    $$
 *      \$$$$$$$  \$$$$$$$   \$$$$   \$$$$$$$
 *
 */
#define LAW_TAZE_SECONDS (8)
#define LAW_CUFF_SECONDS (180)
#define LAW_TAZE_SPIN_END (15)
#define LAW_TAZE_SPIN_ANGLE (90.0)
#define LAW_CUFF_TEXT_MS (2500)
#define LAW_CUFF_TEXT_STYLE (3)

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
static Law_CuffSecond(playerid)
{
    if (g_LawTazeTime[playerid] >= 1)
    {
        g_LawTazeTime[playerid]++;

        if (g_LawTazeTime[playerid] == LAW_TAZE_SPIN_END)
        {
            g_LawTazeTime[playerid] = 0;
        }
        else
        {
            new Float:angle;
            GetPlayerFacingAngle(playerid,angle);
            SetPlayerFacingAngle(playerid,angle + LAW_TAZE_SPIN_ANGLE);
        }
    }

    if (g_LawCuff[playerid] == LAW_CUFF_TAZED)
    {
        if (g_LawCuffTime[playerid] <= 0)
        {
            TogglePlayerControllable(playerid,true);
            g_LawCuff[playerid] = LAW_CUFF_NONE;
            g_LawCuffTime[playerid] = 0;
            g_LawTazeTime[playerid] = 1;
        }
        else
        {
            g_LawCuffTime[playerid]--;
        }
    }

    if (g_LawCuff[playerid] == LAW_CUFF_CUFFED)
    {
        if (g_LawCuffTime[playerid] <= 0)
        {
            GameTextForPlayer(playerid,"~r~You broke the Cuffs, you are free!",LAW_CUFF_TEXT_MS,LAW_CUFF_TEXT_STYLE);
            TogglePlayerControllable(playerid,true);
            g_LawCuff[playerid] = LAW_CUFF_NONE;
            g_LawCuffTime[playerid] = 0;
        }
        else
        {
            g_LawCuffTime[playerid]--;
        }
    }
}

/**
 *                                   __
 *                                  |  |
 *      _______  ______ ____    ____| $$  _______
 *     /       \|      \    \  /      $$ /       |
 *    |  $$$$$$$| $$$$$$\$$$$\|  $$$$$$$|  $$$$$$$
 *    | $$      | $$ | $$ | $$| $$  | $$ \$$    |
 *    | $$_____ | $$ | $$ | $$| $$__| $$ _\$$$$$$|
 *     \$$     \| $$ | $$ | $$ \$$    $$|       $$
 *      \$$$$$$$ \$$  \$$  \$$  \$$$$$$$ \$$$$$$$
 *
 */
CMD:tazer(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Law_IsOfficer(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Cop / FBI / National Guard !");
        return 1;
    }

    if (IsPlayerInAnyVehicle(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Cannot use this while being in the Car !");
        return 1;
    }

    new suspect = Law_GetClosestPlayer(playerid);

    if (!Law_IsTarget(suspect))
    {
        return 1;
    }

    if (g_LawCuff[suspect] > LAW_CUFF_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Player already Cuffed !");
        return 1;
    }

    if (Law_GetDistance(playerid,suspect) >= LAW_CLOSE_RANGE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   No-one near you!");
        return 1;
    }

    if (Law_IsPolice(suspect))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Cannot Tazer Cops / FBI / National Guard !");
        return 1;
    }

    if (IsPlayerInAnyVehicle(suspect))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Suspect is in a Car, get him out first !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[LAW_LINE_LEN];
    GetPlayerName(suspect,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"* You were Tazed by %s for 8 seconds.",name);
    SendClientMessage(suspect,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* You Tazed %s for 8 seconds.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s shoots with his Tazer at %s, and tazed him.",name,targetName);
    Chat_ProxDetector(LAW_PROX_RANGE,playerid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    GameTextForPlayer(suspect,"~r~Tazed",LAW_CUFF_TEXT_MS,LAW_CUFF_TEXT_STYLE);
    TogglePlayerControllable(suspect,false);
    Law_SetCuff(suspect,LAW_CUFF_TAZED,LAW_TAZE_SECONDS);
    return 1;
}

CMD:cuff(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Law_IsOfficer(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Cop / FBI / National Guard !");
        return 1;
    }

    new at = 0, token[LAW_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /cuff [Playerid/PartOfName]");
        return 1;
    }

    new targetid = Law_FindPlayer(token);

    if (!Law_IsTarget(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    if (Law_IsOfficer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You can't Cuff Cops !");
        return 1;
    }

    if (g_LawCuff[targetid] > LAW_CUFF_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Player already Cuffed !");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,LAW_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    new vehicleid = GetPlayerVehicleID(playerid);

    if (vehicleid == 0 || GetPlayerState(playerid) != PLAYER_STATE_DRIVER || GetPlayerVehicleID(targetid) != vehicleid)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Player not in your Car, or you're not the Driver !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[LAW_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"* You were Cuffed by %s, till uncuff.",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* You Cuffed %s, till uncuff.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s Hand Cuffs %s, so he won't go anywhere.",name,targetName);
    Chat_ProxDetector(LAW_PROX_RANGE,playerid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    GameTextForPlayer(targetid,"~r~Cuffed",LAW_CUFF_TEXT_MS,LAW_CUFF_TEXT_STYLE);
    TogglePlayerControllable(targetid,false);
    Law_SetCuff(targetid,LAW_CUFF_CUFFED,LAW_CUFF_SECONDS);
    return 1;
}

CMD:uncuff(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Law_IsPoliceOrLeader(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Cop / FBI / National Guard !");
        return 1;
    }

    new at = 0, token[LAW_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /uncuff [Playerid/PartOfName]");
        return 1;
    }

    new targetid = Law_FindPlayer(token);

    if (!Law_IsTarget(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,LAW_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"You cannot Uncuff yourself!");
        return 1;
    }

    if (g_LawCuff[targetid] == LAW_CUFF_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player isn't Tied up !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[LAW_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"* You were Uncuffed by %s.",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* You Uncuffed %s.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    GameTextForPlayer(targetid,"~g~Uncuffed",LAW_CUFF_TEXT_MS,LAW_CUFF_TEXT_STYLE);
    TogglePlayerControllable(targetid,true);
    g_LawCuff[targetid] = LAW_CUFF_NONE;
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

hook Tick_OnPlayerSecond(playerid)
{
    if (Player_IsReady(playerid))
    {
        Law_CuffSecond(playerid);
    }
}
