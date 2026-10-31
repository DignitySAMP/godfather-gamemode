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
#define LICENSE_CAR (0)
#define LICENSE_FLY (1)
#define LICENSE_BOAT (2)
#define LICENSE_FISH (3)
#define LICENSE_GUN (4)
#define LICENSE_COUNT (5)
#define LICENSE_LOADER "licenses"

forward License_LoadStart(playerid,accountid,token);

static s_Licenses[MAX_PLAYERS][LICENSE_COUNT];
static bool:s_LicensesLoaded[MAX_PLAYERS];

static const s_LicenseColumns[LICENSE_COUNT][12] =
{
    "car",
    "fly",
    "boat",
    "fish",
    "gun"
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
static License_Clear(playerid)
{
    for (new i = 0;i < LICENSE_COUNT;i++)
    {
        s_Licenses[playerid][i] = 0;
    }

    s_LicensesLoaded[playerid] = false;
}

stock License_Get(playerid,license)
{
    if (!Util_IsValidPlayer(playerid) || license < 0 || license >= LICENSE_COUNT)
    {
        return 0;
    }

    return s_Licenses[playerid][license];
}

stock bool:License_Has(playerid,license)
{
    return License_Get(playerid,license) != 0;
}

stock bool:License_Set(playerid,license,value)
{
    if (!Util_IsValidPlayer(playerid) || license < 0 || license >= LICENSE_COUNT || !s_LicensesLoaded[playerid])
    {
        return false;
    }

    s_Licenses[playerid][license] = value;

    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_licenses SET %s = %d WHERE account_id = %d",s_LicenseColumns[license],value,accountid));
    }

    return true;
}

static License_Load(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT car, fly, boat, fish, gun FROM player_licenses WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    License_Clear(playerid);

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("licenses","load failed for player %d, starting with no licences",playerid);
    }
    else if (cache_num_rows() == 0)
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO player_licenses (account_id) VALUES (%d)",accountid));
    }
    else
    {
        for (new i = 0;i < LICENSE_COUNT;i++)
        {
            cache_get_value_name_int(0,s_LicenseColumns[i],s_Licenses[playerid][i]);
        }
    }

    s_LicensesLoaded[playerid] = true;
    Player_LoaderDone(playerid,LICENSE_LOADER,token);
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
public License_LoadStart(playerid,accountid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        License_Load(playerid,accountid,token);
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
    License_Clear(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    SetTimerEx("License_LoadStart",0,false,"ddd",playerid,accountid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    License_Clear(playerid);
}
