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
#define CARJACKER_LOADER "carjacker"
#define CARJACKER_PAY_COUNT (11)
#define CARJACKER_TOP_PAY (6000)
#define CARJACKER_CRANE_RADIUS (8.0)

static s_CarjackerTime[MAX_PLAYERS];
static bool:s_CarjackerLoaded[MAX_PLAYERS];
static bool:s_CarjackerHeading[MAX_PLAYERS];

static const Float:s_CarjackerCrane[3] = {-1548.3618, 123.6438, 3.2966};

static const s_CarjackerPay[4][CARJACKER_PAY_COUNT] =
{
    {1000, 1124, 1245, 1349, 1475, 1574, 1636, 1762, 1895, 1946, 2000},
    {2099, 2135, 2255, 2378, 2457, 2563, 2614, 2721, 2878, 2988, 3000},
    {3058, 3175, 3212, 3377, 3454, 3555, 3678, 3751, 3865, 3964, 4000},
    {4077, 4123, 4275, 4378, 4422, 4565, 4613, 4752, 4897, 4911, 5000}
};

static const s_CarjackerReload[5] = {1200, 1080, 960, 840, 720};

forward Carjacker_LoadStart(playerid,accountid,token);

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
stock Carjacker_GetTime(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_CarjackerTime[playerid] : 0;
}

stock bool:Carjacker_SetTime(playerid,seconds)
{
    if (!Util_IsValidPlayer(playerid) || !s_CarjackerLoaded[playerid])
    {
        return false;
    }

    s_CarjackerTime[playerid] = seconds;

    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_carjacker SET car_time = %d WHERE account_id = %d",seconds,accountid));
    }

    return true;
}

stock Carjacker_StartDrop(playerid)
{
    s_CarjackerHeading[playerid] = true;
    SetPlayerCheckpoint(playerid,s_CarjackerCrane[0],s_CarjackerCrane[1],s_CarjackerCrane[2],CARJACKER_CRANE_RADIUS);
}

static Carjacker_Clear(playerid)
{
    s_CarjackerTime[playerid] = 0;
    s_CarjackerLoaded[playerid] = false;
    s_CarjackerHeading[playerid] = false;
}

static Carjacker_Sell(playerid)
{
    new skill = Progress_AddSkill(playerid,PROGRESS_SKILL_JACK), reached = Jobs_GetSkillLevelReached(skill), tier = Jobs_GetSkillTier(skill);
    new line[JOBS_LINE_LEN], money = CARJACKER_TOP_PAY;

    if (reached > 0)
    {
        format(line,sizeof(line),"* Your Car Jack Skill is now Level %d, you will earn more Money and quicker Reload Time.",reached);
        SendClientMessage(playerid,COLOR_YELLOW,line);
    }

    if (tier < 4)
    {
        money = s_CarjackerPay[tier][random(CARJACKER_PAY_COUNT)];
    }

    format(line,sizeof(line),"You sold a car for $%d, your reload time is %d minutes.",money,s_CarjackerReload[tier] / 60);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    Account_SetCash(playerid,Account_GetCash(playerid) + money);
    Carjacker_SetTime(playerid,s_CarjackerReload[tier]);
    GameTextForPlayer(playerid,"~y~Sold the car",2500,1);
    s_CarjackerHeading[playerid] = false;
    DisablePlayerCheckpoint(playerid);
    SetVehicleToRespawn(GetPlayerVehicleID(playerid));
}

static Carjacker_ReachCrane(playerid)
{
    if (!s_CarjackerHeading[playerid])
    {
        return;
    }

    if (IsPlayerInAnyVehicle(playerid))
    {
        Carjacker_Sell(playerid);
    }
    else
    {
        GameTextForPlayer(playerid,"Not in a car",5000,1);
    }
}

static Carjacker_Tick(playerid)
{
    Vehicles_SetSeesUnlocked(playerid,Jobs_Is(playerid,JOB_CARJACKER));

    if (s_CarjackerTime[playerid] > 0)
    {
        Carjacker_SetTime(playerid,s_CarjackerTime[playerid] - 1);
    }
}

static Carjacker_Load(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT car_time FROM player_carjacker WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("carjacker","row load failed for player %d",playerid);
        return;
    }

    new seconds = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"car_time",seconds);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO player_carjacker (account_id) VALUES (%d)",accountid));
    }

    s_CarjackerTime[playerid] = seconds;
    s_CarjackerLoaded[playerid] = true;
    Player_LoaderDone(playerid,CARJACKER_LOADER,token);
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
public Carjacker_LoadStart(playerid,accountid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Carjacker_Load(playerid,accountid,token);
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
    Carjacker_Clear(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Carjacker_Clear(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    SetTimerEx("Carjacker_LoadStart",0,false,"ddd",playerid,accountid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Carjacker_Clear(playerid);
}

hook OnPlayerEnterCheckpoint(playerid)
{
    Carjacker_ReachCrane(playerid);
}

hook Tick_OnPlayerSecond(playerid)
{
    Carjacker_Tick(playerid);
}
