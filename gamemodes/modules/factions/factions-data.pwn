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
#define FACTIONS_LOADER "factions"
#define FACTION_NONE (0)
#define FACTION_POLICE (1)
#define FACTION_FBI (2)
#define FACTION_NATIONAL_GUARD (3)
#define FACTION_MEDICS (4)
#define FACTION_LCN (5)
#define FACTION_YAKUZA (6)
#define FACTION_MAYOR (7)
#define FACTION_HITMAN (8)
#define FACTION_NEWS (9)
#define FACTION_TAXI (10)
#define FACTION_SCHOOL (11)
#define FACTION_COUNT (12)
#define FACTION_RANK_MAX (6)
#define FACTION_TITLE_LEN (32)
#define FACTION_CALLBACK_LEN (32)
#define FACTION_TEXT_LEN (64)
#define FACTION_LINE_LEN (160)

enum
{
    FACTION_PREDICATE_HAS_JOB = 0,
    FACTION_PREDICATE_IN_FAMILY,
    FACTION_PREDICATE_IS_JAILED,
    FACTION_PREDICATE_IS_PAINTBALLING,
    FACTION_PREDICATE_COUNT
}

static s_FactionLeader[MAX_PLAYERS];
static s_FactionMember[MAX_PLAYERS];
static s_FactionRank[MAX_PLAYERS];
static bool:s_FactionLoaded[MAX_PLAYERS];
static s_FactionTeam[MAX_PLAYERS];
static bool:s_FactionOnDuty[MAX_PLAYERS];
static bool:s_FactionLaptop[MAX_PLAYERS];
static s_FactionSchoolSpawn[MAX_PLAYERS];
static bool:s_FactionDutyHandled[MAX_PLAYERS];
static s_FactionPredicates[FACTION_PREDICATE_COUNT][FACTION_CALLBACK_LEN];

static const s_FactionRankTitles[FACTION_COUNT][FACTION_RANK_MAX + 1][FACTION_TITLE_LEN] =
{
    {"", "", "", "", "", "", ""},
    {"Cadet", "Cadet", "Officer", "Sergeant", "Lieutenant", "Captain", "Chief"},
    {"Intern", "Professional Staff", "Special Agent Trainee", "Special Agent", "Special Agent in Charge", "Assistant Director in Charge", "Director"},
    {"Private", "Private", "Sergeant", "Major", "Captain", "Lieutenant", "General"},
    {"", "", "", "", "", "", ""},
    {"", "", "", "", "", "", ""},
    {"", "", "", "", "", "", ""},
    {"", "", "", "", "", "", ""},
    {"Freelancer", "Freelancer", "Marksman", "Agent", "Special Agent", "Vice-Director", "Director"},
    {"Intern", "Intern", "Local Reporter", "Local Editor", "Network Anchor", "Network Editor", "Network Producer"},
    {"Trainee", "Trainee", "Taxi Rookie", "Cabbie", "Dispatcher", "Shift Supervisor", "Taxi Company Owner"},
    {"Trainee", "Trainee", "Instructor", "Senior Instructor", "Manager", "Under Boss", "Boss"}
};

static const s_FactionMafiaTitles[FACTION_RANK_MAX + 1][FACTION_TITLE_LEN] =
{
    "Outsider", "Outsider", "Associate", "Soldier", "Capo", "Underboss", "Godfather"
};

forward Factions_LoadStart(playerid,accountid,token);
forward Factions_OnTeamChanged(playerid);
forward Factions_OnDuty(playerid);

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
static Factions_Reset(playerid)
{
    s_FactionLeader[playerid] = 0;
    s_FactionMember[playerid] = 0;
    s_FactionRank[playerid] = 0;
    s_FactionLoaded[playerid] = false;
    s_FactionTeam[playerid] = 0;
    s_FactionOnDuty[playerid] = false;
    s_FactionLaptop[playerid] = false;
    s_FactionSchoolSpawn[playerid] = 0;
    s_FactionDutyHandled[playerid] = false;
}

static Factions_Write(playerid,const column[],value)
{
    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_factions SET %s = %d WHERE account_id = %d",column,value,accountid));
    }
}

stock bool:Factions_IsLoaded(playerid)
{
    return Util_IsValidPlayer(playerid) && s_FactionLoaded[playerid];
}

stock Factions_GetLeader(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_FactionLeader[playerid];
}

stock Factions_GetMember(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_FactionMember[playerid];
}

stock Factions_GetRank(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_FactionRank[playerid];
}

stock bool:Factions_SetLeader(playerid,leader)
{
    if (!Factions_IsLoaded(playerid))
    {
        return false;
    }

    s_FactionLeader[playerid] = leader;
    Factions_Write(playerid,"leader",leader);
    return true;
}

stock bool:Factions_SetMember(playerid,member)
{
    if (!Factions_IsLoaded(playerid))
    {
        return false;
    }

    s_FactionMember[playerid] = member;
    Factions_Write(playerid,"member",member);
    return true;
}

stock bool:Factions_SetRank(playerid,rank)
{
    if (!Factions_IsLoaded(playerid))
    {
        return false;
    }

    s_FactionRank[playerid] = rank;
    Factions_Write(playerid,"faction_rank",rank);
    return true;
}

stock bool:Factions_IsIn(playerid,faction)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return false;
    }

    return s_FactionMember[playerid] == faction || s_FactionLeader[playerid] == faction;
}

stock bool:Factions_IsCop(playerid)
{
    return Factions_IsIn(playerid,FACTION_POLICE) || Factions_IsIn(playerid,FACTION_FBI) || Factions_IsIn(playerid,FACTION_NATIONAL_GUARD);
}

stock bool:Factions_IsMember(playerid)
{
    return Factions_IsIn(playerid,FACTION_LCN) || Factions_IsIn(playerid,FACTION_YAKUZA) || Factions_IsIn(playerid,FACTION_HITMAN);
}

stock bool:Factions_IsInstructor(playerid)
{
    return Factions_IsIn(playerid,FACTION_SCHOOL);
}

stock Factions_GetTeam(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    if (s_FactionTeam[playerid] == 0)
    {
        return Account_GetTeam(playerid);
    }

    return s_FactionTeam[playerid];
}

stock Factions_SetTeam(playerid,team)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_FactionTeam[playerid] = team;
    }
}

stock Factions_SetAccountTeam(playerid,team)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_FactionTeam[playerid] = team;
        Account_SetTeam(playerid,team);
    }
}

stock Factions_ApplyTeamColour(playerid)
{
    if (Util_IsValidPlayer(playerid))
    {
        SetPlayerColor(playerid,TEAM_HIT_COLOR);
    }
}

stock Factions_OnTeamChangedNotify(playerid)
{
    pawn_call_public("Factions_OnTeamChanged","d",playerid);
}

stock bool:Factions_IsOnDuty(playerid)
{
    return Util_IsValidPlayer(playerid) && s_FactionOnDuty[playerid];
}

stock Factions_SetOnDuty(playerid,bool:isOnDuty)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_FactionOnDuty[playerid] = isOnDuty;
    }
}

stock bool:Factions_IsOnLaptop(playerid)
{
    return Util_IsValidPlayer(playerid) && s_FactionLaptop[playerid];
}

stock Factions_SetOnLaptop(playerid,bool:isConnected)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_FactionLaptop[playerid] = isConnected;
    }
}

stock Factions_GetSchoolSpawn(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_FactionSchoolSpawn[playerid];
}

stock Factions_SetSchoolSpawn(playerid,spawn)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_FactionSchoolSpawn[playerid] = spawn;
    }
}

stock Factions_SetDutyHandled(playerid)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_FactionDutyHandled[playerid] = true;
    }
}

stock bool:Factions_RunDutyEvent(playerid)
{
    s_FactionDutyHandled[playerid] = false;
    pawn_call_public("Factions_OnDuty","d",playerid);
    return s_FactionDutyHandled[playerid];
}

stock bool:Factions_SetPredicate(predicate,const callback[])
{
    if (predicate < 0 || predicate >= FACTION_PREDICATE_COUNT)
    {
        return false;
    }

    strcopy(s_FactionPredicates[predicate],callback,FACTION_CALLBACK_LEN);
    return true;
}

stock bool:Factions_CheckPredicate(predicate,playerid,bool:fallback)
{
    if (predicate < 0 || predicate >= FACTION_PREDICATE_COUNT || s_FactionPredicates[predicate][0] == EOS)
    {
        return fallback;
    }

    return CallLocalFunction(s_FactionPredicates[predicate],"d",playerid) != 0;
}

stock bool:Factions_GetRankTitle(faction,rank,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (faction < 0 || faction >= FACTION_COUNT)
    {
        return false;
    }

    new index = rank >= 1 && rank <= FACTION_RANK_MAX ? rank : 0;
    strcopy(dest,s_FactionRankTitles[faction][index],size);
    return dest[0] != EOS;
}

stock Factions_GetMafiaTitle(rank,dest[],size = sizeof(dest))
{
    new index = rank >= 1 && rank <= FACTION_RANK_MAX ? rank : 0;
    strcopy(dest,s_FactionMafiaTitles[index],size);
}

stock Factions_SendRadio(faction,colour,const text[])
{
    foreach (new targetid : Player)
    {
        if (s_FactionMember[targetid] == faction || s_FactionLeader[targetid] == faction)
        {
            SendClientMessage(targetid,colour,text);
        }
    }
}

stock Factions_SendTeam(team,colour,const text[])
{
    foreach (new targetid : Player)
    {
        if (Factions_GetTeam(targetid) == team)
        {
            SendClientMessage(targetid,colour,text);
        }
    }
}

static Factions_Load(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT leader, member, faction_rank FROM player_factions WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    s_FactionLeader[playerid] = 0;
    s_FactionMember[playerid] = 0;
    s_FactionRank[playerid] = 0;

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("factions","load failed for player %d, starting as a civilian",playerid);
    }
    else if (cache_num_rows() == 0)
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO player_factions (account_id) VALUES (%d)",accountid));
    }
    else
    {
        cache_get_value_name_int(0,"leader",s_FactionLeader[playerid]);
        cache_get_value_name_int(0,"member",s_FactionMember[playerid]);
        cache_get_value_name_int(0,"faction_rank",s_FactionRank[playerid]);
    }

    s_FactionLoaded[playerid] = true;
    Player_LoaderDone(playerid,FACTIONS_LOADER,token);
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
public Factions_LoadStart(playerid,accountid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Factions_Load(playerid,accountid,token);
    }

    return 1;
}

public Factions_OnTeamChanged(playerid)
{
    return 1;
}

public Factions_OnDuty(playerid)
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
    Factions_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Factions_Reset(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    SetTimerEx("Factions_LoadStart",0,false,"ddd",playerid,accountid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Factions_Reset(playerid);
}
