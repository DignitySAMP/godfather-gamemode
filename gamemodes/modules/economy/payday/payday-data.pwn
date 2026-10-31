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
#define PAYDAY_LOADER "Payday"
#define PAYDAY_ELIGIBLE_AT (5)
#define PAYDAY_COUNTER_CAP (6)
#define PAYDAY_DONOR_EXP_EVERY (5)

static s_PaydayConnectTime[MAX_PLAYERS];
static s_PaydayPaycheck[MAX_PLAYERS];
static s_PaydayCounter[MAX_PLAYERS];
static s_PaydayHad[MAX_PLAYERS];
static bool:s_PaydayLoaded[MAX_PLAYERS];
static bool:s_PaydayDirty[MAX_PLAYERS];

forward Payday_OnBegin(playerid);
forward Payday_OnCompute(playerid);
forward Payday_OnBillPaid(playerid,amount);
forward Payday_OnFinished();
forward Payday_BeginLoad(playerid,token);

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
stock bool:Payday_IsLoaded(playerid)
{
    return Util_IsValidPlayer(playerid) && s_PaydayLoaded[playerid];
}

static Payday_WriteRow(playerid)
{
    if (!Payday_IsLoaded(playerid))
    {
        return;
    }

    s_PaydayDirty[playerid] = false;
    mysql_tquery_s(g_Mysql,str_format("UPDATE payday_players SET connect_time = %d, paycheck = %d, payday = %d, payday_had = %d WHERE account_id = %d",s_PaydayConnectTime[playerid],s_PaydayPaycheck[playerid],s_PaydayCounter[playerid],s_PaydayHad[playerid],Account_GetId(playerid)));
}

stock Payday_Flush(playerid)
{
    if (Payday_IsLoaded(playerid) && s_PaydayDirty[playerid])
    {
        Payday_WriteRow(playerid);
    }
}

stock Payday_GetConnectTime(playerid)
{
    return Payday_IsLoaded(playerid) ? s_PaydayConnectTime[playerid] : 0;
}

stock Payday_SetConnectTime(playerid,hours)
{
    if (Payday_IsLoaded(playerid))
    {
        s_PaydayConnectTime[playerid] = hours;
        Payday_WriteRow(playerid);
    }
}

stock Payday_GetPaycheck(playerid)
{
    return Payday_IsLoaded(playerid) ? s_PaydayPaycheck[playerid] : 0;
}

stock Payday_SetPaycheck(playerid,amount)
{
    if (Payday_IsLoaded(playerid))
    {
        s_PaydayPaycheck[playerid] = amount;
        Payday_WriteRow(playerid);
    }
}

stock Payday_AddPaycheck(playerid,amount)
{
    if (!Payday_IsLoaded(playerid))
    {
        return 0;
    }

    s_PaydayPaycheck[playerid] += amount;
    Payday_WriteRow(playerid);
    return s_PaydayPaycheck[playerid];
}

stock Payday_SetCounter(playerid,value)
{
    if (Payday_IsLoaded(playerid))
    {
        s_PaydayCounter[playerid] = value;
        Payday_WriteRow(playerid);
    }
}

stock Payday_GetHad(playerid)
{
    return Payday_IsLoaded(playerid) ? s_PaydayHad[playerid] : 0;
}

stock Payday_SetHad(playerid,value)
{
    if (Payday_IsLoaded(playerid))
    {
        s_PaydayHad[playerid] = value;
        Payday_WriteRow(playerid);
    }
}

stock bool:Payday_IsEligible(playerid)
{
    return Payday_IsLoaded(playerid) && s_PaydayCounter[playerid] >= PAYDAY_ELIGIBLE_AT;
}

stock Payday_AddEligibility(playerid)
{
    if (Payday_IsLoaded(playerid) && s_PaydayCounter[playerid] < PAYDAY_COUNTER_CAP)
    {
        s_PaydayCounter[playerid]++;
        Payday_WriteRow(playerid);
    }
}

stock Payday_AccruePaycheck(playerid,amount)
{
    if (Payday_IsLoaded(playerid) && amount > 0)
    {
        s_PaydayPaycheck[playerid] += amount;
        s_PaydayDirty[playerid] = true;
    }
}

static Payday_Reset(playerid)
{
    s_PaydayConnectTime[playerid] = 0;
    s_PaydayPaycheck[playerid] = 0;
    s_PaydayCounter[playerid] = 0;
    s_PaydayHad[playerid] = 0;
    s_PaydayLoaded[playerid] = false;
    s_PaydayDirty[playerid] = false;
}

static Payday_LoadPlayer(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT connect_time, paycheck, payday, payday_had FROM payday_players WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("payday","row load failed for player %d",playerid);
        return;
    }

    new connectTime = 0, paycheck = 0, counter = 0, had = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"connect_time",connectTime);
        cache_get_value_name_int(0,"paycheck",paycheck);
        cache_get_value_name_int(0,"payday",counter);
        cache_get_value_name_int(0,"payday_had",had);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT INTO payday_players (account_id) VALUES (%d) ON DUPLICATE KEY UPDATE account_id = account_id",accountid));
    }

    s_PaydayConnectTime[playerid] = connectTime;
    s_PaydayPaycheck[playerid] = paycheck;
    s_PaydayCounter[playerid] = counter;
    s_PaydayHad[playerid] = had;
    s_PaydayLoaded[playerid] = true;
    Player_LoaderDone(playerid,PAYDAY_LOADER,token);
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
public Payday_BeginLoad(playerid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Payday_LoadPlayer(playerid,Player_GetLoadAccount(playerid),token);
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
    Payday_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Payday_Flush(playerid);
    Payday_Reset(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    Payday_Reset(playerid);
    SetTimerEx("Payday_BeginLoad",0,false,"dd",playerid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Payday_Flush(playerid);
    Payday_Reset(playerid);
}

hook Database_OnPlayerSave(playerid,E_SAVE_REASON:reason)
{
    Payday_Flush(playerid);
}

hook Stats_OnBuild(playerid,targetid)
{
    if (Payday_IsLoaded(targetid))
    {
        Stats_SetNumber("PlayingHours",Payday_GetConnectTime(targetid));
    }
}
