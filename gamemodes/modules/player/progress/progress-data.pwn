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
#define PROGRESS_SKILL_DETECTIVE (0)
#define PROGRESS_SKILL_SEX (1)
#define PROGRESS_SKILL_BOX (2)
#define PROGRESS_SKILL_LAW (3)
#define PROGRESS_SKILL_MECH (4)
#define PROGRESS_SKILL_JACK (5)
#define PROGRESS_SKILL_CAR (6)
#define PROGRESS_SKILL_NEWS (7)
#define PROGRESS_SKILL_DRUGS (8)
#define PROGRESS_SKILL_FISH (10)
#define PROGRESS_SKILL_COUNT (11)

#define PROGRESS_PERK_ALCOHOL (0)
#define PROGRESS_PERK_DRUG (1)
#define PROGRESS_PERK_MISER (2)
#define PROGRESS_PERK_TRADER (3)
#define PROGRESS_PERK_PAIN (4)
#define PROGRESS_PERK_COUNT (5)

#define PROGRESS_PERK_MAX (3)
#define PROGRESS_SPAWN_HEALTH_MAX (50.0)
#define PROGRESS_SPAWN_HEALTH_BASE (50.0)
#define PROGRESS_SPAWN_HEALTH_DONOR (100.0)
#define PROGRESS_LOADER "progress"

forward Progress_LoadStart(playerid,accountid,token);

static s_ProgressPoints[MAX_PLAYERS];
static Float:s_ProgressSpawnHealth[MAX_PLAYERS];
static s_ProgressSkills[MAX_PLAYERS][PROGRESS_SKILL_COUNT];
static s_ProgressPerks[MAX_PLAYERS][PROGRESS_PERK_COUNT];
static bool:s_ProgressLoaded[MAX_PLAYERS];

static const s_ProgressSkillColumns[PROGRESS_SKILL_COUNT][20] =
{
    "skill_detective",
    "skill_sex",
    "skill_box",
    "skill_law",
    "skill_mech",
    "skill_jack",
    "skill_car",
    "skill_news",
    "skill_drugs",
    "skill_cook",
    "skill_fish"
};

static const s_ProgressPerkColumns[PROGRESS_PERK_COUNT][20] =
{
    "perk_alcohol",
    "perk_drug",
    "perk_miser",
    "perk_trader",
    "perk_pain"
};

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
static Progress_Clear(playerid)
{
    s_ProgressPoints[playerid] = 0;
    s_ProgressSpawnHealth[playerid] = 0.0;

    for (new i = 0;i < PROGRESS_SKILL_COUNT;i++)
    {
        s_ProgressSkills[playerid][i] = 0;
    }

    for (new i = 0;i < PROGRESS_PERK_COUNT;i++)
    {
        s_ProgressPerks[playerid][i] = 0;
    }

    s_ProgressLoaded[playerid] = false;
}

static Progress_WriteInt(playerid,const column[],value)
{
    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_progress SET %s = %d WHERE account_id = %d",column,value,accountid));
    }
}

static bool:Progress_CanWrite(playerid)
{
    return Util_IsValidPlayer(playerid) && s_ProgressLoaded[playerid];
}

stock Progress_GetUpgradePoints(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_ProgressPoints[playerid];
}

stock bool:Progress_SetUpgradePoints(playerid,points)
{
    if (!Progress_CanWrite(playerid))
    {
        return false;
    }

    s_ProgressPoints[playerid] = points;
    Progress_WriteInt(playerid,"upgrade_points",points);
    return true;
}

stock bool:Progress_AddUpgradePoints(playerid,amount)
{
    return Progress_SetUpgradePoints(playerid,Progress_GetUpgradePoints(playerid) + amount);
}

stock Float:Progress_GetSpawnHealth(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0.0;
    }

    return s_ProgressSpawnHealth[playerid];
}

stock Progress_ApplySpawnHealth(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    if (Account_GetDonateRank(playerid) > 0)
    {
        SetPlayerHealth(playerid,PROGRESS_SPAWN_HEALTH_DONOR);
        return;
    }

    SetPlayerHealth(playerid,PROGRESS_SPAWN_HEALTH_BASE + Progress_GetSpawnHealth(playerid));
}

stock bool:Progress_SetSpawnHealth(playerid,Float:health)
{
    if (!Progress_CanWrite(playerid))
    {
        return false;
    }

    s_ProgressSpawnHealth[playerid] = health;

    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_progress SET spawn_health = %f WHERE account_id = %d",health,accountid));
    }

    return true;
}

stock Progress_GetPerk(playerid,perk)
{
    if (!Util_IsValidPlayer(playerid) || perk < 0 || perk >= PROGRESS_PERK_COUNT)
    {
        return 0;
    }

    return s_ProgressPerks[playerid][perk];
}

stock bool:Progress_SetPerk(playerid,perk,value)
{
    if (!Progress_CanWrite(playerid) || perk < 0 || perk >= PROGRESS_PERK_COUNT)
    {
        return false;
    }

    s_ProgressPerks[playerid][perk] = value;
    Progress_WriteInt(playerid,s_ProgressPerkColumns[perk],value);
    return true;
}

stock Progress_GetSkill(playerid,skill)
{
    if (!Util_IsValidPlayer(playerid) || skill < 0 || skill >= PROGRESS_SKILL_COUNT)
    {
        return 0;
    }

    return s_ProgressSkills[playerid][skill];
}

stock bool:Progress_SetSkill(playerid,skill,value)
{
    if (!Progress_CanWrite(playerid) || skill < 0 || skill >= PROGRESS_SKILL_COUNT)
    {
        return false;
    }

    s_ProgressSkills[playerid][skill] = value;
    Progress_WriteInt(playerid,s_ProgressSkillColumns[skill],value);
    return true;
}

stock Progress_AddSkill(playerid,skill,amount = 1)
{
    if (!Progress_CanWrite(playerid) || skill < 0 || skill >= PROGRESS_SKILL_COUNT)
    {
        return 0;
    }

    new value = s_ProgressSkills[playerid][skill] + amount;
    Progress_SetSkill(playerid,skill,value);
    return value;
}

static Progress_Load(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT * FROM player_progress WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    Progress_Clear(playerid);

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("progress","load failed for player %d, starting with defaults",playerid);
    }
    else if (cache_num_rows() == 0)
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO player_progress (account_id) VALUES (%d)",accountid));
    }
    else
    {
        cache_get_value_name_int(0,"upgrade_points",s_ProgressPoints[playerid]);
        cache_get_value_name_float(0,"spawn_health",s_ProgressSpawnHealth[playerid]);

        for (new i = 0;i < PROGRESS_SKILL_COUNT;i++)
        {
            cache_get_value_name_int(0,s_ProgressSkillColumns[i],s_ProgressSkills[playerid][i]);
        }

        for (new i = 0;i < PROGRESS_PERK_COUNT;i++)
        {
            cache_get_value_name_int(0,s_ProgressPerkColumns[i],s_ProgressPerks[playerid][i]);
        }
    }

    s_ProgressLoaded[playerid] = true;
    Player_LoaderDone(playerid,PROGRESS_LOADER,token);
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
public Progress_LoadStart(playerid,accountid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Progress_Load(playerid,accountid,token);
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
    Progress_Clear(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    SetTimerEx("Progress_LoadStart",0,false,"ddd",playerid,accountid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Progress_Clear(playerid);
}

hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    if (newstate == PLAYER_STATE_SPAWNED && !IsPlayerNPC(playerid) && Player_IsReady(playerid))
    {
        Progress_ApplySpawnHealth(playerid);
    }
}

hook Stats_OnBuild(playerid,targetid)
{
    Stats_SetFloat("SpawnHealth",Progress_GetSpawnHealth(targetid) + PROGRESS_SPAWN_HEALTH_BASE);
}
