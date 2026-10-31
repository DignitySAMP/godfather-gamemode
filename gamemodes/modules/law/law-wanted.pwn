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
#define LAW_DECAY_MS (300000)
#define LAW_DECAY_STEP (3)
#define LAW_DECAY_RANGE (80.0)
#define LAW_WASTED_RANGE (30.0)
#define LAW_WASTED_PRICE (4000)
#define LAW_WASTED_JAIL (600)
#define LAW_WASTED_SOUND (1058)
#define LAW_SPAWN_PENALTY (500)
#define LAW_STOLEN_POINTS (2)
#define LAW_DRUNK_DRIVING_LEVEL (5)
#define LAW_VEHICLE_RUN_OVER (49)
#define LAW_TEAM_CRIMINAL_MIN (4)
#define LAW_TEAM_MAFIA_MIN (5)

forward Law_OnFreed(playerid);

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
stock Law_LevelForPoints(points)
{
    if (points >= 14)
    {
        return 10;
    }

    if (points >= 12)
    {
        return 6;
    }

    if (points >= 10)
    {
        return 5;
    }

    if (points >= 8)
    {
        return 4;
    }

    if (points >= 6)
    {
        return 3;
    }

    if (points >= 4)
    {
        return 2;
    }

    if (points == 3)
    {
        return 1;
    }

    return 0;
}

static bool:Law_RaiseLevel(playerid)
{
    new level = Law_LevelForPoints(g_LawWantedPoints[playerid]);

    if (level == 0 || g_LawWantedLevel[playerid] == level)
    {
        return false;
    }

    g_LawWantedLevel[playerid] = level;
    return true;
}

stock Law_IsCopInRange(Float:radius,playerid,copid)
{
    if (!IsPlayerConnected(playerid) || !IsPlayerConnected(copid))
    {
        return 0;
    }

    new Float:playerX, Float:playerY, Float:playerZ, Float:copX, Float:copY, Float:copZ;
    GetPlayerPos(playerid,playerX,playerY,playerZ);
    GetPlayerPos(copid,copX,copY,copZ);

    new Float:deltaX = playerX - copX, Float:deltaY = playerY - copY;

    if (deltaX < radius && deltaX > -radius && deltaY < radius && deltaY > -radius)
    {
        return 1;
    }

    return 0;
}

stock Law_SetCriminal(playerid,declare,const reason[])
{
    if (!IsPlayerConnected(playerid))
    {
        return;
    }

    g_LawCrimes[playerid]++;
    Law_WriteRow(playerid);

    new turned[MAX_PLAYER_NAME + 1], turner[MAX_PLAYER_NAME + 1], line[LAW_LINE_LEN];
    GetPlayerName(playerid,turned,sizeof(turned));
    Law_SetCrimeText(playerid,LAW_CRIME_OFFENCE,reason);

    if (declare == INVALID_PLAYER_ID)
    {
        strcopy(turner,"Unknown");
        Law_SetCrimeText(playerid,LAW_CRIME_CLAIMANT,turner);
    }
    else if (IsPlayerConnected(declare))
    {
        GetPlayerName(declare,turner,sizeof(turner));
        Law_SetCrimeText(playerid,LAW_CRIME_CLAIMANT,turner);
        Law_SetCrimeText(declare,LAW_CRIME_ACCUSED,turned);
        Law_SetCrimeText(declare,LAW_CRIME_REPORT,reason);
    }

    format(line,sizeof(line),"You've committed a Crime ( %s ). Reporter: %s.",reason,turner);
    SendClientMessage(playerid,COLOR_LIGHTRED,line);

    if (g_LawWantedPoints[playerid] <= 0)
    {
        return;
    }

    new bool:changed = Law_RaiseLevel(playerid);

    if (g_LawWantedLevel[playerid] >= 1 && Factions_GetTeam(playerid) == TEAM_GREEN)
    {
        Factions_SetTeam(playerid,TEAM_ORANGE);
    }

    if (changed)
    {
        format(line,sizeof(line),"Current Wanted Level: %d",g_LawWantedLevel[playerid]);
        SendClientMessage(playerid,COLOR_YELLOW,line);
        format(line,sizeof(line),"HQ: All Units APB: Reporter: %s",turner);
        Factions_SendRadio(FACTION_POLICE,TEAM_BLUE_COLOR,line);
        format(line,sizeof(line),"HQ: Crime: %s, Suspect: %s",reason,turned);
        Factions_SendRadio(FACTION_POLICE,TEAM_BLUE_COLOR,line);
    }
}

stock Law_SetFree(playerid,declare,const reason[])
{
    if (!IsPlayerConnected(playerid))
    {
        return;
    }

    Law_ClearCrime(playerid);

    new turned[MAX_PLAYER_NAME + 1], turner[MAX_PLAYER_NAME + 1], line[LAW_LINE_LEN];

    if (declare == INVALID_PLAYER_ID)
    {
        strcopy(turner,"911");
    }
    else if (IsPlayerConnected(declare))
    {
        GetPlayerName(declare,turner,sizeof(turner));
    }

    GetPlayerName(playerid,turned,sizeof(turned));
    format(line,sizeof(line),"SMS: %s, Because you %s, you are no longer a Criminal, Sender: MOLE (555)",turned,reason);
    pawn_call_public("Law_OnFreed","d",playerid);
    SendClientMessage(playerid,COLOR_YELLOW,line);
    format(line,sizeof(line),"HQ: All Units Officer %s Has Completed Assignment",turner);
    Factions_SendRadio(FACTION_POLICE,COLOR_DBLUE,line);
    format(line,sizeof(line),"HQ: %s Has Been Processed, %s",turned,reason);
    Factions_SendRadio(FACTION_POLICE,COLOR_DBLUE,line);
}

stock Law_AddCrime(playerid,points,declare,const reason[])
{
    Law_AddWantedPoints(playerid,points);
    Law_SetCriminal(playerid,declare,reason);
}

stock Law_ClearRecord(playerid)
{
    Law_ClearWanted(playerid);
    Law_ClearCrime(playerid);

    if (Factions_GetTeam(playerid) == TEAM_ORANGE)
    {
        Factions_SetTeam(playerid,TEAM_GREEN);
        Factions_ApplyTeamColour(playerid);
    }
}

static Law_DecayPlayer(playerid)
{
    foreach (new copid : Player)
    {
        if (!IsPlayerNPC(copid) && Factions_GetTeam(copid) == TEAM_BLUE && Law_IsCopInRange(LAW_DECAY_RANGE,playerid,copid))
        {
            return;
        }
    }

    g_LawWantedPoints[playerid] -= LAW_DECAY_STEP;

    if (g_LawWantedPoints[playerid] < 0)
    {
        g_LawWantedPoints[playerid] = 0;
    }

    new line[LAW_LINE_LEN];

    if (g_LawWantedPoints[playerid] > 0)
    {
        if (Law_RaiseLevel(playerid))
        {
            format(line,sizeof(line),"Current Wanted Level: %d",g_LawWantedLevel[playerid]);
            SendClientMessage(playerid,COLOR_YELLOW,line);
        }

        return;
    }

    if (g_LawWantedLevel[playerid] != 0)
    {
        Law_ClearCrime(playerid);
        g_LawWantedLevel[playerid] = 0;
        SendClientMessage(playerid,COLOR_YELLOW,"Current Wanted Level: 0");
    }

    if (Factions_GetTeam(playerid) == TEAM_ORANGE)
    {
        Factions_SetTeam(playerid,TEAM_GREEN);
        Factions_ApplyTeamColour(playerid);
    }
}

stock Law_DecayAll()
{
    foreach (new playerid : Player)
    {
        if (!IsPlayerNPC(playerid) && Player_IsReady(playerid))
        {
            Law_DecayPlayer(playerid);
        }
    }
}

static Law_MurderCrime(killerid,weaponid)
{
    if (weaponid == LAW_VEHICLE_RUN_OVER)
    {
        Law_SetCriminal(killerid,INVALID_PLAYER_ID,"Hit And Run");
    }
    else
    {
        Law_SetCriminal(killerid,INVALID_PLAYER_ID,"First Degree Murder");
    }
}

static Law_DeathRules(playerid,killerid,weaponid)
{
    new victimTeam = Factions_GetTeam(playerid), bool:hasKiller = Law_IsTarget(killerid) && killerid != playerid, killerTeam = 0;

    if (hasKiller)
    {
        killerTeam = Factions_GetTeam(killerid);

        if (GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
        {
            return;
        }
    }

    Law_ClearCrime(playerid);

    if (Factions_CheckPredicate(FACTION_PREDICATE_IS_PAINTBALLING,playerid,false))
    {
        return;
    }

    if (hasKiller)
    {
        if (victimTeam >= LAW_TEAM_CRIMINAL_MIN)
        {
            if (killerTeam != TEAM_BLUE)
            {
                Law_AddWantedPoints(killerid,2);
            }

            if (killerTeam == TEAM_GREEN)
            {
                Law_MurderCrime(killerid,weaponid);
            }
        }
        else if (victimTeam == TEAM_BLUE)
        {
            if (killerTeam >= TEAM_GREEN)
            {
                Law_AddWantedPoints(killerid,2);
                Law_MurderCrime(killerid,weaponid);
            }

            if (killerTeam >= LAW_TEAM_MAFIA_MIN && !Law_IsSpawnProtected(playerid))
            {
                Law_AddWantedPoints(killerid,2);
            }
        }
        else if (victimTeam == TEAM_GREEN)
        {
            if (killerTeam != TEAM_BLUE)
            {
                Law_AddWantedPoints(killerid,2);
            }

            if (killerTeam >= TEAM_GREEN || killerTeam == TEAM_CYAN)
            {
                Law_MurderCrime(killerid,weaponid);
            }
        }
        else if (victimTeam == TEAM_CYAN)
        {
            if (killerTeam == TEAM_ORANGE && weaponid != LAW_VEHICLE_RUN_OVER)
            {
                Law_SetCriminal(killerid,INVALID_PLAYER_ID,"First Degree Murder");
            }
            else if (killerTeam == TEAM_GREEN && weaponid == LAW_VEHICLE_RUN_OVER)
            {
                Law_SetCriminal(killerid,INVALID_PLAYER_ID,"Hit And Run");
            }
        }
    }

    if (victimTeam >= TEAM_GREEN && g_LawWantedPoints[playerid] > 0 && killerTeam == TEAM_BLUE)
    {
        Law_SetFree(playerid,killerid,"Got Killed");
    }
}

static Law_WastedRule(playerid)
{
    new level = g_LawWantedLevel[playerid];

    if (level < 1)
    {
        return;
    }

    new price = level * LAW_WASTED_PRICE, bool:copNear = false, line[LAW_LINE_LEN];

    foreach (new copid : Player)
    {
        if (!IsPlayerNPC(copid) && Factions_GetTeam(copid) == TEAM_BLUE && Law_IsCopInRange(LAW_WASTED_RANGE,playerid,copid))
        {
            copNear = true;
            format(line,sizeof(line),"~w~Running Suspect~r~Killed~n~Bonus~g~$%d",price);
            GameTextForPlayer(copid,line,5000,1);
            Law_AdjustCash(copid,price / 2);
            PlayerPlaySound(copid,LAW_WASTED_SOUND,0.0,0.0,0.0);
        }
    }

    if (!copNear)
    {
        return;
    }

    Law_AdjustCash(playerid,-price);
    Law_SetWantedDeaths(playerid,Law_GetWantedDeaths(playerid) + 1);
    Law_SetSentence(playerid,LAW_JAIL_CELL,level * LAW_WASTED_JAIL);
    format(line,sizeof(line),"* You are in Jail for %d Seconds and lose $%d because of running away and getting shot by the Officer.",g_LawJailTime[playerid],price);
    SendClientMessage(playerid,COLOR_LIGHTRED,line);
    Law_ClearWanted(playerid);
}

static Law_SpawnPenalty(playerid)
{
    new points = g_LawWantedPoints[playerid];

    if (points > 0)
    {
        new cost = points * LAW_SPAWN_PENALTY, line[LAW_LINE_LEN];
        format(line,sizeof(line),"You lost $%d for dying with %d Wanted Points.",cost,points);
        SendClientMessage(playerid,COLOR_YELLOW,line);
        Law_AdjustCash(playerid,-cost);
        Law_SetWantedDeaths(playerid,Law_GetWantedDeaths(playerid) + 1);
    }

    Law_ClearWanted(playerid);
}

static Law_StolenVehicle(playerid,kind)
{
    if (kind == VEHICLE_STEAL_POLICE)
    {
        if (Factions_GetLeader(playerid) >= FACTION_POLICE && Factions_GetLeader(playerid) <= FACTION_NATIONAL_GUARD)
        {
            return;
        }

        Law_AddCrime(playerid,LAW_STOLEN_POINTS,INVALID_PLAYER_ID,"Stealing A Police Vehicle");
    }
    else if (kind == VEHICLE_STEAL_AMBULANCE)
    {
        if (Factions_IsIn(playerid,FACTION_MEDICS))
        {
            return;
        }

        Law_AddCrime(playerid,LAW_STOLEN_POINTS,INVALID_PLAYER_ID,"Stealing An Ambulance");
    }
}

static Law_DrunkDriving(playerid,vehicleid)
{
    if (Vehicles_IsBoat(vehicleid) || Vehicles_IsPlane(vehicleid))
    {
        return;
    }

    if (Shops_GetDrunk(playerid) >= LAW_DRUNK_DRIVING_LEVEL)
    {
        Law_AddCrime(playerid,1,INVALID_PLAYER_ID,"Drunk Driving");
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
public Law_OnFreed(playerid)
{
    return 1;
}

Timer_Declare(Law_DecayTimer)
{
    Law_DecayAll();
    return true;
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

hook Vehicles_OnStealAttempt(playerid,vehicleid,kind)
{
    #pragma unused vehicleid

    if (Player_IsReady(playerid))
    {
        Law_StolenVehicle(playerid,kind);
    }
}

hook Vehicles_OnDriverEnter(playerid,vehicleid)
{
    if (Player_IsReady(playerid))
    {
        Law_DrunkDriving(playerid,vehicleid);
    }
}

hook OnPlayerStateChange(playerid,PLAYER_STATE:newstate,PLAYER_STATE:oldstate)
{
    if (newstate == PLAYER_STATE_WASTED && !IsPlayerNPC(playerid) && Player_IsReady(playerid))
    {
        Law_WastedRule(playerid);
    }
}

hook OnPlayerDeath(playerid,killerid,WEAPON:reason)
{
    if (!IsPlayerNPC(playerid) && Player_IsReady(playerid))
    {
        Law_DeathRules(playerid,killerid,_:reason);
    }
}

hook OnPlayerSpawn(playerid)
{
    if (!IsPlayerNPC(playerid) && Player_IsReady(playerid))
    {
        Law_SpawnPenalty(playerid);
    }
}
