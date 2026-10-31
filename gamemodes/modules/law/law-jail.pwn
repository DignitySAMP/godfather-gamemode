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
#define LAW_CELL_X (264.6288)
#define LAW_CELL_Y (77.5742)
#define LAW_CELL_Z (1001.0391)
#define LAW_CELL_INTERIOR (6)
#define LAW_CELL_EXIT_X (268.0903)
#define LAW_CELL_EXIT_Y (77.6489)
#define LAW_CELL_EXIT_Z (1001.0391)
#define LAW_PRISON_X (107.2300)
#define LAW_PRISON_Y (1920.6311)
#define LAW_PRISON_Z (18.5208)
#define LAW_PRISON_SPAWN_X (268.5777)
#define LAW_PRISON_SPAWN_Y (1857.9351)
#define LAW_PRISON_SPAWN_Z (9.8133)
#define LAW_PRISON_EXIT_X (90.2101)
#define LAW_PRISON_EXIT_Y (1920.4854)
#define LAW_PRISON_EXIT_Z (17.9422)
#define LAW_PRISON_MAX_X (337.5694)
#define LAW_PRISON_MIN_X (101.5826)
#define LAW_PRISON_MAX_Y (1940.9759)
#define LAW_PRISON_MIN_Y (1798.7453)
#define LAW_DEBT_JAIL_SECONDS (240)
#define LAW_AMMUNATION_JAIL_SECONDS (300)
#define LAW_AMMUNATION_RADIUS (20.0)
#define LAW_LAWYER_PROMPT_1 (1)
#define LAW_LAWYER_PROMPT_2 (8)
#define LAW_LAWYER_PROMPT_3 (15)
#define LAW_LAWYER_TIMEOUT (20)
#define LAW_AMMUNATION_COUNT (5)

static const Float:s_LawAmmunations[LAW_AMMUNATION_COUNT][3] =
{
    {292.0274, -36.0291, 1001.5156},
    {308.2740, -141.2833, 999.6016},
    {294.3212, -108.7869, 1001.5156},
    {288.8592, -80.4535, 1001.5156},
    {316.9583, -165.4707, 999.6010}
};

forward Law_OnLawyerRequested(playerid);
forward Law_PredicateIsJailed(playerid);
forward Law_ReadJailTime(playerid);
forward Law_ChatLawyer(playerid,const text[]);

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
stock Law_Place(playerid,type)
{
    if (type == LAW_JAIL_CELL)
    {
        SetPlayerInterior(playerid,LAW_CELL_INTERIOR);
        SetPlayerVirtualWorld(playerid,0);
        SetPlayerPos(playerid,LAW_CELL_X,LAW_CELL_Y,LAW_CELL_Z);
        Account_SetInterior(playerid,LAW_CELL_INTERIOR);
        Account_SetLocal(playerid,DOOR_LOCAL_OUTSIDE);
    }
    else if (type == LAW_JAIL_PRISON)
    {
        SetPlayerVirtualWorld(playerid,0);
        SetPlayerPos(playerid,LAW_PRISON_X,LAW_PRISON_Y,LAW_PRISON_Z);
        SetPlayerWorldBounds(playerid,LAW_PRISON_MAX_X,LAW_PRISON_MIN_X,LAW_PRISON_MAX_Y,LAW_PRISON_MIN_Y);
        Account_SetLocal(playerid,DOOR_LOCAL_OUTSIDE);
    }
}

stock bool:Law_Jail(playerid,seconds,type)
{
    if (!Law_IsLoaded(playerid) || (type != LAW_JAIL_CELL && type != LAW_JAIL_PRISON))
    {
        return false;
    }

    Law_Place(playerid,type);
    Law_SetSentence(playerid,type,seconds);
    return true;
}

stock bool:Law_Release(playerid)
{
    if (!Law_IsLoaded(playerid) || g_LawJailed[playerid] <= LAW_JAIL_NONE)
    {
        return false;
    }

    if (g_LawJailed[playerid] == LAW_JAIL_CELL)
    {
        SetPlayerInterior(playerid,LAW_CELL_INTERIOR);
        SetPlayerVirtualWorld(playerid,0);
        SetPlayerPos(playerid,LAW_CELL_EXIT_X,LAW_CELL_EXIT_Y,LAW_CELL_EXIT_Z);
        Account_SetInterior(playerid,LAW_CELL_INTERIOR);
        Account_SetLocal(playerid,DOOR_LOCAL_OUTSIDE);
    }
    else if (g_LawJailed[playerid] == LAW_JAIL_PRISON)
    {
        ClearPlayerWorldBounds(playerid);
        SetPlayerInterior(playerid,0);
        SetPlayerVirtualWorld(playerid,0);
        SetPlayerPos(playerid,LAW_PRISON_EXIT_X,LAW_PRISON_EXIT_Y,LAW_PRISON_EXIT_Z);
        Account_SetInterior(playerid,0);
        Account_SetLocal(playerid,DOOR_LOCAL_OUTSIDE);
    }

    Law_SetSentence(playerid,LAW_JAIL_NONE,0);
    SendClientMessage(playerid,COLOR_GRAD1,"   You have paid your debt to society.");
    GameTextForPlayer(playerid,"~g~Freedom~n~~w~Try to be a better citizen",5000,1);

    if (Factions_GetTeam(playerid) == TEAM_ORANGE)
    {
        Factions_SetTeam(playerid,TEAM_GREEN);
    }

    Law_ClearCrime(playerid);
    Factions_ApplyTeamColour(playerid);
    return true;
}

static Law_JailSecond(playerid)
{
    if (g_LawJailed[playerid] <= LAW_JAIL_NONE)
    {
        return;
    }

    if (g_LawLawyerWait[playerid] != 0)
    {
        return;
    }

    if (g_LawJailTime[playerid] > 0)
    {
        g_LawJailTime[playerid]--;
        g_LawDirty[playerid] = true;
    }

    if (g_LawJailTime[playerid] <= 0)
    {
        Law_Release(playerid);
    }
}

static Law_LawyerSecond(playerid)
{
    if (g_LawLawyerWait[playerid] < 1)
    {
        return;
    }

    g_LawLawyerCall[playerid] = true;

    if (g_LawLawyerWait[playerid] == LAW_LAWYER_PROMPT_1)
    {
        SendClientMessage(playerid,COLOR_LIGHTRED,"Do you want a Lawyer? (Type yes or no)");
    }

    g_LawLawyerWait[playerid]++;

    if (g_LawLawyerWait[playerid] == LAW_LAWYER_PROMPT_2 || g_LawLawyerWait[playerid] == LAW_LAWYER_PROMPT_3)
    {
        SendClientMessage(playerid,COLOR_LIGHTRED,"Do you want a Lawyer? (Type yes or no)");
    }

    if (g_LawLawyerWait[playerid] == LAW_LAWYER_TIMEOUT)
    {
        SendClientMessage(playerid,COLOR_LIGHTRED,"There is no Lawyer available to you anymore, Jail Time started.");
        Law_CancelLawyer(playerid);
    }
}

static Law_AmmunationSecond(playerid)
{
    for (new i = 0;i < LAW_AMMUNATION_COUNT;i++)
    {
        if (Property_IsNear(playerid,LAW_AMMUNATION_RADIUS,s_LawAmmunations[i][0],s_LawAmmunations[i][1],s_LawAmmunations[i][2]))
        {
            GameTextForPlayer(playerid,"~r~Jailed for going to ammunation",5000,1);
            Law_Jail(playerid,LAW_AMMUNATION_JAIL_SECONDS,LAW_JAIL_CELL);
            return;
        }
    }
}

static Law_DebtJail(playerid)
{
    if (!Law_IsLoaded(playerid) || !Vehicles_HasDebtWarning(playerid))
    {
        return;
    }

    new line[LAW_LINE_LEN];
    SendClientMessage(playerid,COLOR_LIGHTRED,"You failed to pay your debt, Jail time.");
    GameTextForPlayer(playerid,"~r~Busted!",2000,1);
    Law_Jail(playerid,LAW_DEBT_JAIL_SECONDS,LAW_JAIL_CELL);
    ResetPlayerWeapons(playerid);
    Law_SetWantedPoints(playerid,0);
    format(line,sizeof(line),"You are jailed for %d seconds.   Bail: Unable",g_LawJailTime[playerid]);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
}

static Law_ChooseSpawn(playerid)
{
    if (!Law_IsLoaded(playerid))
    {
        return;
    }

    if (g_LawJailed[playerid] == LAW_JAIL_CELL)
    {
        Spawn_SetPoint(playerid,LAW_CELL_X,LAW_CELL_Y,LAW_CELL_Z,0.0,LAW_CELL_INTERIOR,SPAWN_PRIORITY_JAIL);
    }
    else if (g_LawJailed[playerid] == LAW_JAIL_PRISON)
    {
        Spawn_SetPoint(playerid,LAW_PRISON_SPAWN_X,LAW_PRISON_SPAWN_Y,LAW_PRISON_SPAWN_Z,0.0,0,SPAWN_PRIORITY_PRISON);
    }
}

static Law_FinishSpawn(playerid)
{
    if (!Law_IsLoaded(playerid))
    {
        return;
    }

    new priority = Spawn_GetPointPriority(playerid);

    if (g_LawJailed[playerid] == LAW_JAIL_CELL && priority == SPAWN_PRIORITY_JAIL)
    {
        SendClientMessage(playerid,COLOR_LIGHTRED,"Incomplete Jail Sentence, back to jail.");
        Account_SetInterior(playerid,LAW_CELL_INTERIOR);
        Account_SetLocal(playerid,DOOR_LOCAL_OUTSIDE);
    }
    else if (g_LawJailed[playerid] == LAW_JAIL_PRISON && priority == SPAWN_PRIORITY_PRISON)
    {
        SetPlayerWorldBounds(playerid,LAW_PRISON_MAX_X,LAW_PRISON_MIN_X,LAW_PRISON_MAX_Y,LAW_PRISON_MIN_Y);
        Account_SetInterior(playerid,0);
        Account_SetLocal(playerid,DOOR_LOCAL_OUTSIDE);
    }
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
public Law_OnLawyerRequested(playerid)
{
    return 1;
}

public Law_PredicateIsJailed(playerid)
{
    return Law_IsJailed(playerid) ? 1 : 0;
}

public Law_ReadJailTime(playerid)
{
    return Law_GetJailTime(playerid);
}

public Law_ChatLawyer(playerid,const text[])
{
    if (!Law_IsAwaitingLawyer(playerid))
    {
        return 0;
    }

    new at = 0, token[LAW_TOKEN_LEN];
    Util_ReadToken(text,at,token);

    if (token[0] != EOS && !strcmp(token,"yes",true))
    {
        pawn_call_public("Law_OnLawyerRequested","d",playerid);
        SendClientMessage(playerid,COLOR_LIGHTRED,"A message has been sent to all available Lawyers, please wait.");
    }
    else
    {
        SendClientMessage(playerid,COLOR_LIGHTRED,"There is no Lawyer available to you anymore, Jail Time started.");
    }

    Law_CancelLawyer(playerid);
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
    if (!Player_IsReady(playerid) || !Law_IsLoaded(playerid))
    {
        return;
    }

    Law_JailSecond(playerid);
    Law_LawyerSecond(playerid);
    Law_AmmunationSecond(playerid);
}

hook Payday_OnBegin(playerid)
{
    Law_DebtJail(playerid);
}

hook Spawn_OnChoose(playerid)
{
    Law_ChooseSpawn(playerid);
}

hook OnPlayerSpawn(playerid)
{
    if (!IsPlayerNPC(playerid) && Player_IsReady(playerid))
    {
        Law_FinishSpawn(playerid);
    }
}
