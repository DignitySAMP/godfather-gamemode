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
#define JOBS_LOADER "Jobs"
#define JOBS_CALLBACK_LEN (32)
#define JOBS_LINE_LEN (144)
#define JOBS_NAME_LEN (16)

#define JOB_NONE (0)
#define JOB_DETECTIVE (1)
#define JOB_LAWYER (2)
#define JOB_WHORE (3)
#define JOB_DRUGS (4)
#define JOB_CARJACKER (5)
#define JOB_NEWS (6)
#define JOB_MECHANIC (7)
#define JOB_BODYGUARD (8)
#define JOB_ARMS (9)
#define JOB_CARDEALER (10)
#define JOB_BOXER (12)
#define JOB_BUS (14)
#define JOB_PAPERBOY (15)
#define JOB_TRUCKER (16)
#define JOB_LAST (16)
#define JOB_COUNT (17)

#define JOBS_CONTRACT_MAX (25)
#define JOBS_CONTRACT_FULL (10)
#define JOBS_CONTRACT_DONOR (2)
#define JOBS_CONTRACT_TICK_MS (1800000)
#define JOBS_PLACE_RADIUS (3.0)
#define JOBS_PLACE_COUNT (13)
#define JOBS_PRICE_MIN (1)
#define JOBS_PRICE_MAX (99999)
#define JOBS_NEAR_RANGE (8.0)

static s_JobsJob[MAX_PLAYERS];
static s_JobsContract[MAX_PLAYERS];
static s_JobsPending[MAX_PLAYERS];
static bool:s_JobsLoaded[MAX_PLAYERS];
static s_JobsMissionCheck[JOBS_CALLBACK_LEN];

static const s_JobsNames[JOB_COUNT][JOBS_NAME_LEN] =
{
    "None",
    "Detective",
    "Lawyer",
    "Whore",
    "Drugs Dealer",
    "Car Jacker",
    "News Reporter",
    "Car Mechanic",
    "Bodyguard",
    "Arms Dealer",
    "Car Dealer",
    "None",
    "Boxer",
    "None",
    "Bus Driver",
    "Paper Boy",
    "Trucker"
};

static const Float:s_JobsPlaceCoords[JOBS_PLACE_COUNT][3] =
{
    {359.5408, 206.7693, 1008.3828},
    {347.7374, 193.7241, 1014.1875},
    {1215.1304, -11.8431, 1000.9219},
    {2166.3772, -1675.3829, 15.0859},
    {1109.3318, -1796.3042, 16.5938},
    {-1932.3859, 276.2117, 41.0391},
    {2226.1716, -1718.1792, 13.5165},
    {1366.4325, -1275.2096, 13.5469},
    {531.7930, -1292.4044, 17.2422},
    {766.0804, 14.5133, 1000.7004},
    {1154.2208, -1770.8203, 16.5992},
    {-2040.9436, 456.2395, 35.1719},
    {-77.7288, -1136.3896, 1.0781}
};

static const s_JobsPlaceJobs[JOBS_PLACE_COUNT] =
{
    JOB_DETECTIVE,
    JOB_LAWYER,
    JOB_WHORE,
    JOB_DRUGS,
    JOB_CARJACKER,
    JOB_MECHANIC,
    JOB_BODYGUARD,
    JOB_ARMS,
    JOB_CARDEALER,
    JOB_BOXER,
    JOB_BUS,
    JOB_PAPERBOY,
    JOB_TRUCKER
};

static const bool:s_JobsPlaceBarsFamilies[JOBS_PLACE_COUNT] =
{
    true,
    false,
    true,
    true,
    false,
    true,
    true,
    true,
    false,
    true,
    true,
    true,
    true
};

forward Jobs_BeginLoad(playerid,token);
forward Jobs_ReadJob(playerid);
forward Jobs_PredicateHasJob(playerid);

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
stock bool:Jobs_IsLoaded(playerid)
{
    return Util_IsValidPlayer(playerid) && s_JobsLoaded[playerid];
}

stock Jobs_Reset(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return;
    }

    s_JobsJob[playerid] = JOB_NONE;
    s_JobsContract[playerid] = 0;
    s_JobsPending[playerid] = 0;
    s_JobsLoaded[playerid] = false;
}

static Jobs_Write(playerid,const column[],value)
{
    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_jobs SET %s = %d WHERE account_id = %d",column,value,accountid));
    }
}

stock Jobs_GetJob(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return JOB_NONE;
    }

    return s_JobsJob[playerid];
}

stock bool:Jobs_Is(playerid,job)
{
    return Util_IsValidPlayer(playerid) && s_JobsJob[playerid] == job;
}

stock bool:Jobs_SetJob(playerid,job)
{
    if (!Jobs_IsLoaded(playerid) || job < JOB_NONE || job > JOB_LAST)
    {
        return false;
    }

    s_JobsJob[playerid] = job;
    Jobs_Write(playerid,"job",job);
    return true;
}

stock Jobs_GetContractTime(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_JobsContract[playerid];
}

stock bool:Jobs_SetContractTime(playerid,hours)
{
    if (!Jobs_IsLoaded(playerid))
    {
        return false;
    }

    s_JobsContract[playerid] = hours;
    Jobs_Write(playerid,"contract_time",hours);
    return true;
}

stock Jobs_GetPending(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return JOB_NONE;
    }

    return s_JobsPending[playerid];
}

stock Jobs_SetPending(playerid,job)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_JobsPending[playerid] = job;
    }
}

stock Jobs_GetName(job,dest[],size = sizeof(dest))
{
    if (job < JOB_NONE || job > JOB_LAST)
    {
        strcopy(dest,"None",size);
        return;
    }

    strcopy(dest,s_JobsNames[job],size);
}

stock Jobs_FindPlace(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return -1;
    }

    for (new i = 0;i < JOBS_PLACE_COUNT;i++)
    {
        if (Property_IsNear(playerid,JOBS_PLACE_RADIUS,s_JobsPlaceCoords[i][0],s_JobsPlaceCoords[i][1],s_JobsPlaceCoords[i][2]))
        {
            return i;
        }
    }

    return -1;
}

stock Jobs_GetPlaceJob(place)
{
    if (place < 0 || place >= JOBS_PLACE_COUNT)
    {
        return JOB_NONE;
    }

    return s_JobsPlaceJobs[place];
}

stock bool:Jobs_PlaceBarsFamilies(place)
{
    if (place < 0 || place >= JOBS_PLACE_COUNT)
    {
        return false;
    }

    return s_JobsPlaceBarsFamilies[place];
}

stock bool:Jobs_IsInFamily(playerid)
{
    return Factions_GetMember(playerid) > 0 || Factions_CheckPredicate(FACTION_PREDICATE_IN_FAMILY,playerid,false);
}

stock Jobs_GetSkillTier(skill)
{
    if (skill <= 50)
    {
        return 0;
    }

    if (skill <= 100)
    {
        return 1;
    }

    if (skill <= 200)
    {
        return 2;
    }

    if (skill <= 400)
    {
        return 3;
    }

    return 4;
}

stock Jobs_GetSkillLevelReached(skill)
{
    switch (skill)
    {
        case 50:
        {
            return 2;
        }
        case 100:
        {
            return 3;
        }
        case 200:
        {
            return 4;
        }
        case 400:
        {
            return 5;
        }
    }

    return 0;
}

stock Jobs_SendJobMessage(job,colour,const text[])
{
    foreach (new targetid : Player)
    {
        if (!IsPlayerNPC(targetid) && Jobs_GetJob(targetid) == job)
        {
            SendClientMessage(targetid,colour,text);
        }
    }
}

stock bool:Jobs_SetMissionCheck(const callback[])
{
    strcopy(s_JobsMissionCheck,callback,JOBS_CALLBACK_LEN);
    return true;
}

stock bool:Jobs_IsOnMission(playerid)
{
    if (s_JobsMissionCheck[0] == EOS)
    {
        return false;
    }

    return CallLocalFunction(s_JobsMissionCheck,"d",playerid) != 0;
}

stock bool:Jobs_ReadPrice(const text[],&price)
{
    price = strval(text);
    return price >= JOBS_PRICE_MIN && price <= JOBS_PRICE_MAX;
}

static Jobs_LoadPlayer(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT job, contract_time FROM player_jobs WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("jobs","row load failed for player %d",playerid);
        return;
    }

    new job = JOB_NONE, contract = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"job",job);
        cache_get_value_name_int(0,"contract_time",contract);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT INTO player_jobs (account_id) VALUES (%d) ON DUPLICATE KEY UPDATE account_id = account_id",accountid));
    }

    s_JobsJob[playerid] = job;
    s_JobsContract[playerid] = contract;
    s_JobsPending[playerid] = 0;
    s_JobsLoaded[playerid] = true;
    Player_LoaderDone(playerid,JOBS_LOADER,token);
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
public Jobs_BeginLoad(playerid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Jobs_LoadPlayer(playerid,Player_GetLoadAccount(playerid),token);
    }

    return 1;
}

public Jobs_ReadJob(playerid)
{
    return Jobs_GetJob(playerid);
}

public Jobs_PredicateHasJob(playerid)
{
    return Jobs_GetJob(playerid) > JOB_NONE ? 1 : 0;
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
    Jobs_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Jobs_Reset(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    Jobs_Reset(playerid);
    SetTimerEx("Jobs_BeginLoad",0,false,"dd",playerid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Jobs_Reset(playerid);
}

hook Stats_OnBuild(playerid,targetid)
{
    if (Jobs_IsLoaded(targetid))
    {
        new name[JOBS_NAME_LEN];
        Jobs_GetName(Jobs_GetJob(targetid),name);
        Stats_SetText("Job",name);
    }
}
