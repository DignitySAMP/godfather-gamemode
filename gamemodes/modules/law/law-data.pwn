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
#define LAW_LOADER "Law"
#define LAW_JAIL_NONE (0)
#define LAW_JAIL_CELL (1)
#define LAW_JAIL_PRISON (2)
#define LAW_CRIME_LEN (64)
#define LAW_CRIME_BLANK "********"
#define LAW_REASON_LEN (64)
#define LAW_TOKEN_LEN (64)
#define LAW_CALLBACK_LEN (32)
#define LAW_LINE_LEN (144)
#define LAW_CUFF_NONE (0)
#define LAW_CUFF_TAZED (1)
#define LAW_CUFF_CUFFED (2)
#define LAW_NEAR_RANGE (8.0)
#define LAW_CLOSE_RANGE (5.0)
#define LAW_PROX_RANGE (30.0)

enum
{
    LAW_CRIME_ACCUSED = 0,
    LAW_CRIME_REPORT,
    LAW_CRIME_OFFENCE,
    LAW_CRIME_CLAIMANT,
    LAW_CRIME_FIELDS
}

new g_LawCrimes[MAX_PLAYERS];
new g_LawArrested[MAX_PLAYERS];
new g_LawWantedDeaths[MAX_PLAYERS];
new g_LawJailed[MAX_PLAYERS];
new g_LawJailTime[MAX_PLAYERS];
new bool:g_LawLoaded[MAX_PLAYERS];
new bool:g_LawDirty[MAX_PLAYERS];
new g_LawWantedPoints[MAX_PLAYERS];
new g_LawWantedLevel[MAX_PLAYERS];
new g_LawCrimeText[MAX_PLAYERS][LAW_CRIME_FIELDS][LAW_CRIME_LEN];
new g_LawBail[MAX_PLAYERS];
new g_LawLawyerWait[MAX_PLAYERS];
new bool:g_LawLawyerCall[MAX_PLAYERS];
new g_LawTicketOfficer[MAX_PLAYERS];
new g_LawTicketAmount[MAX_PLAYERS];
new g_LawCuff[MAX_PLAYERS];
new g_LawCuffTime[MAX_PLAYERS];
new g_LawTazeTime[MAX_PLAYERS];
new g_LawPaperCheck[LAW_CALLBACK_LEN];
new g_LawSafeCheck[LAW_CALLBACK_LEN];

forward Law_BeginLoad(playerid,token);

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
stock bool:Law_IsLoaded(playerid)
{
    return Util_IsValidPlayer(playerid) && g_LawLoaded[playerid];
}

stock Law_WriteRow(playerid)
{
    if (!Law_IsLoaded(playerid))
    {
        return;
    }

    g_LawDirty[playerid] = false;
    mysql_tquery_s(g_Mysql,str_format("UPDATE player_law SET crimes = %d, arrested = %d, wanted_deaths = %d, jailed = %d, jail_time = %d WHERE account_id = %d",g_LawCrimes[playerid],g_LawArrested[playerid],g_LawWantedDeaths[playerid],g_LawJailed[playerid],g_LawJailTime[playerid],Account_GetId(playerid)));
}

stock Law_Flush(playerid)
{
    if (Law_IsLoaded(playerid) && g_LawDirty[playerid])
    {
        Law_WriteRow(playerid);
    }
}

stock Law_ClearCrime(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 1;
    }

    for (new field = 0;field < LAW_CRIME_FIELDS;field++)
    {
        strcopy(g_LawCrimeText[playerid][field],LAW_CRIME_BLANK,LAW_CRIME_LEN);
    }

    return 1;
}

stock Law_SetCrimeText(playerid,field,const text[])
{
    if (Util_IsValidPlayer(playerid) && field >= 0 && field < LAW_CRIME_FIELDS)
    {
        strcopy(g_LawCrimeText[playerid][field],text,LAW_CRIME_LEN);
    }
}

stock Law_GetCrimeText(playerid,field,dest[],size = sizeof(dest))
{
    if (!Util_IsValidPlayer(playerid) || field < 0 || field >= LAW_CRIME_FIELDS)
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,g_LawCrimeText[playerid][field],size);
}

stock Law_Reset(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return;
    }

    g_LawCrimes[playerid] = 0;
    g_LawArrested[playerid] = 0;
    g_LawWantedDeaths[playerid] = 0;
    g_LawJailed[playerid] = LAW_JAIL_NONE;
    g_LawJailTime[playerid] = 0;
    g_LawLoaded[playerid] = false;
    g_LawDirty[playerid] = false;
    g_LawWantedPoints[playerid] = 0;
    g_LawWantedLevel[playerid] = 0;
    g_LawBail[playerid] = 0;
    g_LawLawyerWait[playerid] = 0;
    g_LawLawyerCall[playerid] = false;
    g_LawTicketOfficer[playerid] = INVALID_PLAYER_ID;
    g_LawTicketAmount[playerid] = 0;
    g_LawCuff[playerid] = LAW_CUFF_NONE;
    g_LawCuffTime[playerid] = 0;
    g_LawTazeTime[playerid] = 0;

    for (new field = 0;field < LAW_CRIME_FIELDS;field++)
    {
        strcopy(g_LawCrimeText[playerid][field],LAW_CRIME_BLANK,LAW_CRIME_LEN);
    }
}

stock Law_GetCrimes(playerid)
{
    return Util_IsValidPlayer(playerid) ? g_LawCrimes[playerid] : 0;
}

stock Law_GetArrested(playerid)
{
    return Util_IsValidPlayer(playerid) ? g_LawArrested[playerid] : 0;
}

stock Law_SetArrested(playerid,value)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_LawArrested[playerid] = value;
        Law_WriteRow(playerid);
    }
}

stock Law_GetWantedDeaths(playerid)
{
    return Util_IsValidPlayer(playerid) ? g_LawWantedDeaths[playerid] : 0;
}

stock Law_SetWantedDeaths(playerid,value)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_LawWantedDeaths[playerid] = value;
        Law_WriteRow(playerid);
    }
}

stock Law_GetJailed(playerid)
{
    return Util_IsValidPlayer(playerid) ? g_LawJailed[playerid] : LAW_JAIL_NONE;
}

stock bool:Law_IsJailed(playerid)
{
    return Law_GetJailed(playerid) > LAW_JAIL_NONE;
}

stock Law_GetJailTime(playerid)
{
    return Util_IsValidPlayer(playerid) ? g_LawJailTime[playerid] : 0;
}

stock Law_SetJailTime(playerid,seconds)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_LawJailTime[playerid] = seconds;
        Law_WriteRow(playerid);
    }
}

stock Law_SetSentence(playerid,type,seconds)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_LawJailed[playerid] = type;
        g_LawJailTime[playerid] = seconds;
        Law_WriteRow(playerid);
    }
}

stock Law_GetWantedPoints(playerid)
{
    return Util_IsValidPlayer(playerid) ? g_LawWantedPoints[playerid] : 0;
}

stock Law_SetWantedPoints(playerid,points)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_LawWantedPoints[playerid] = points;
    }
}

stock Law_AddWantedPoints(playerid,points)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_LawWantedPoints[playerid] += points;
    }
}

stock Law_GetWantedLevel(playerid)
{
    return Util_IsValidPlayer(playerid) ? g_LawWantedLevel[playerid] : 0;
}

stock Law_SetWantedLevel(playerid,level)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_LawWantedLevel[playerid] = level;
    }
}

stock Law_ClearWanted(playerid)
{
    Law_SetWantedPoints(playerid,0);
    Law_SetWantedLevel(playerid,0);
}

stock Law_GetBail(playerid)
{
    return Util_IsValidPlayer(playerid) ? g_LawBail[playerid] : 0;
}

stock Law_SetBail(playerid,amount)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_LawBail[playerid] = amount;
    }
}

stock Law_SetLawyerWait(playerid,wait)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_LawLawyerWait[playerid] = wait;
    }
}

stock bool:Law_IsAwaitingLawyer(playerid)
{
    return Util_IsValidPlayer(playerid) && g_LawLawyerCall[playerid];
}

stock Law_CancelLawyer(playerid)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_LawLawyerWait[playerid] = 0;
        g_LawLawyerCall[playerid] = false;
    }
}

stock Law_GetTicketOfficer(playerid)
{
    return Util_IsValidPlayer(playerid) ? g_LawTicketOfficer[playerid] : INVALID_PLAYER_ID;
}

stock Law_GetTicketAmount(playerid)
{
    return Util_IsValidPlayer(playerid) ? g_LawTicketAmount[playerid] : 0;
}

stock Law_SetTicket(playerid,officerid,amount)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_LawTicketOfficer[playerid] = officerid;
        g_LawTicketAmount[playerid] = amount;
    }
}

stock Law_ClearTicket(playerid)
{
    Law_SetTicket(playerid,INVALID_PLAYER_ID,0);
}

stock Law_SetCuff(playerid,cuffState,seconds)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_LawCuff[playerid] = cuffState;
        g_LawCuffTime[playerid] = seconds;
    }
}

stock bool:Law_SetPaperCheck(const callback[])
{
    strcopy(g_LawPaperCheck,callback,LAW_CALLBACK_LEN);
    return true;
}

stock bool:Law_CheckPaper(playerid)
{
    if (g_LawPaperCheck[0] == EOS)
    {
        return false;
    }

    return CallLocalFunction(g_LawPaperCheck,"d",playerid) != 0;
}

stock bool:Law_SetSafeCheck(const callback[])
{
    strcopy(g_LawSafeCheck,callback,LAW_CALLBACK_LEN);
    return true;
}

stock bool:Law_IsSpawnProtected(playerid)
{
    if (g_LawSafeCheck[0] == EOS)
    {
        return false;
    }

    return CallLocalFunction(g_LawSafeCheck,"d",playerid) != 0;
}

stock Law_FindPlayer(const token[])
{
    new targetid = INVALID_PLAYER_ID;

    if (sscanf(token,"u",targetid))
    {
        return INVALID_PLAYER_ID;
    }

    return targetid;
}

stock bool:Law_IsTarget(targetid)
{
    return targetid != INVALID_PLAYER_ID && IsPlayerConnected(targetid);
}

stock bool:Law_IsOfficer(playerid)
{
    return Factions_GetTeam(playerid) == TEAM_BLUE || Factions_IsCop(playerid);
}

stock bool:Law_IsPolice(playerid)
{
    return Factions_GetTeam(playerid) == TEAM_BLUE;
}

stock bool:Law_IsPoliceOrLeader(playerid)
{
    new leader = Factions_GetLeader(playerid);
    return Law_IsPolice(playerid) || leader == FACTION_POLICE || leader == FACTION_FBI || leader == FACTION_NATIONAL_GUARD;
}

stock bool:Law_NeedsDuty(playerid)
{
    return Factions_GetMember(playerid) == FACTION_POLICE && !Factions_IsOnDuty(playerid);
}

stock Law_GetClosestPlayer(playerid)
{
    new closest = INVALID_PLAYER_ID, Float:best = 99999.99, Float:x1, Float:y1, Float:z1;
    GetPlayerPos(playerid,x1,y1,z1);

    foreach (new i : Player)
    {
        if (i == playerid || IsPlayerNPC(i))
        {
            continue;
        }

        new Float:x2, Float:y2, Float:z2;
        GetPlayerPos(i,x2,y2,z2);
        new Float:distance = floatsqroot((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1));

        if (distance < best)
        {
            best = distance;
            closest = i;
        }
    }

    return closest;
}

stock Float:Law_GetDistance(playerid,targetid)
{
    new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2;
    GetPlayerPos(playerid,x1,y1,z1);
    GetPlayerPos(targetid,x2,y2,z2);
    return floatsqroot((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1));
}

stock Law_SendNews(colour,const text[])
{
    foreach (new targetid : Player)
    {
        if (!IsPlayerNPC(targetid) && Chat_IsNewsEnabled(targetid))
        {
            SendClientMessage(targetid,colour,text);
        }
    }
}

stock Law_AdjustCash(playerid,amount)
{
    Account_SetCash(playerid,Account_GetCash(playerid) + amount);
}

static Law_LoadPlayer(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT crimes, arrested, wanted_deaths, jailed, jail_time FROM player_law WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("law","row load failed for player %d",playerid);
        return;
    }

    new crimes = 0, arrested = 0, wantedDeaths = 0, jailed = 0, jailTime = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"crimes",crimes);
        cache_get_value_name_int(0,"arrested",arrested);
        cache_get_value_name_int(0,"wanted_deaths",wantedDeaths);
        cache_get_value_name_int(0,"jailed",jailed);
        cache_get_value_name_int(0,"jail_time",jailTime);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT INTO player_law (account_id) VALUES (%d) ON DUPLICATE KEY UPDATE account_id = account_id",accountid));
    }

    g_LawCrimes[playerid] = crimes;
    g_LawArrested[playerid] = arrested;
    g_LawWantedDeaths[playerid] = wantedDeaths;
    g_LawJailed[playerid] = jailed;
    g_LawJailTime[playerid] = jailTime;
    g_LawLoaded[playerid] = true;
    Player_LoaderDone(playerid,LAW_LOADER,token);
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
public Law_BeginLoad(playerid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Law_LoadPlayer(playerid,Player_GetLoadAccount(playerid),token);
    }

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
    Law_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Law_Flush(playerid);
    Law_Reset(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    Law_Reset(playerid);
    SetTimerEx("Law_BeginLoad",0,false,"dd",playerid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Law_Flush(playerid);
    Law_Reset(playerid);
}

hook Database_OnPlayerSave(playerid,E_SAVE_REASON:reason)
{
    Law_Flush(playerid);
}

hook Stats_OnBuild(playerid,targetid)
{
    if (Law_IsLoaded(targetid))
    {
        Stats_SetNumber("Crimes",Law_GetCrimes(targetid));
        Stats_SetNumber("Arrests",Law_GetArrested(targetid));
        Stats_SetNumber("WantedDeaths",Law_GetWantedDeaths(targetid));
        Stats_SetNumber("WantedLevel",Law_GetWantedLevel(targetid));
    }
}
