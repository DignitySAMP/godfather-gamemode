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
static s_HouseKey[MAX_PLAYERS];
static bool:s_HouseKeyLoaded[MAX_PLAYERS];
static bool:s_HouseSpawnAtHome[MAX_PLAYERS];
static bool:s_HouseHomeWaypoint[MAX_PLAYERS];

forward Houses_BeginLoad(playerid,token);

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
stock bool:Houses_IsKeyLoaded(playerid)
{
    return Util_IsValidPlayer(playerid) && s_HouseKeyLoaded[playerid];
}

stock Houses_GetKey(playerid)
{
    if (!Houses_IsKeyLoaded(playerid))
    {
        return HOUSE_NO_KEY;
    }

    return s_HouseKey[playerid];
}

stock bool:Houses_IsOwner(playerid,house)
{
    if (!Houses_IsValid(house))
    {
        return false;
    }

    new name[HOUSE_NAME_LEN];
    Property_GetPlayerName(playerid,name);
    return Houses_IsOwnerName(house,name);
}

stock Houses_SyncVehicles(playerid)
{
    new key = Houses_GetKey(playerid);

    if (key == HOUSE_NO_KEY)
    {
        Vehicles_SetPlayerHouse(playerid,HOUSE_NO_KEY,false);
        return;
    }

    Vehicles_SetPlayerHouse(playerid,key,Houses_IsOwner(playerid,key));
}

stock bool:Houses_SetKey(playerid,key)
{
    if (!Houses_IsKeyLoaded(playerid))
    {
        return false;
    }

    if (key != HOUSE_NO_KEY && !Houses_IsValid(key))
    {
        return false;
    }

    s_HouseKey[playerid] = key;
    mysql_tquery_s(g_Mysql,str_format("INSERT INTO house_keys (account_id, house_key) VALUES (%d, %d) ON DUPLICATE KEY UPDATE house_key = VALUES(house_key)",Account_GetId(playerid),key));
    Houses_SyncVehicles(playerid);
    return true;
}

stock Houses_GetOwnedHouse(playerid)
{
    new key = Houses_GetKey(playerid);

    if (key != HOUSE_NO_KEY && Houses_IsOwner(playerid,key))
    {
        return key;
    }

    return HOUSE_NO_KEY;
}

stock Houses_SetSpawnAtHome(playerid,bool:spawnAtHome)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_HouseSpawnAtHome[playerid] = spawnAtHome;
    }
}

stock bool:Houses_GetSpawnAtHome(playerid)
{
    return Util_IsValidPlayer(playerid) && s_HouseSpawnAtHome[playerid];
}

stock Houses_SetHomeWaypoint(playerid,bool:isActive)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_HouseHomeWaypoint[playerid] = isActive;
    }
}

stock bool:Houses_HasHomeWaypoint(playerid)
{
    return Util_IsValidPlayer(playerid) && s_HouseHomeWaypoint[playerid];
}

static Houses_ResetPlayer(playerid)
{
    s_HouseKey[playerid] = HOUSE_NO_KEY;
    s_HouseKeyLoaded[playerid] = false;
    s_HouseSpawnAtHome[playerid] = true;
    s_HouseHomeWaypoint[playerid] = false;
    Vehicles_SetPlayerHouse(playerid,HOUSE_NO_KEY,false);
}

static Houses_LoadPlayer(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT house_key FROM house_keys WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("houses","key load failed for player %d",playerid);
        return;
    }

    new key = HOUSE_NO_KEY;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"house_key",key);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT INTO house_keys (account_id, house_key) VALUES (%d, %d) ON DUPLICATE KEY UPDATE house_key = VALUES(house_key)",accountid,key));
    }

    if (key != HOUSE_NO_KEY && !Houses_IsValid(key))
    {
        Log_Warn("houses","player %d held the unknown house key %d, cleared",playerid,key);
        key = HOUSE_NO_KEY;
    }

    s_HouseKey[playerid] = key;
    s_HouseKeyLoaded[playerid] = true;
    Houses_SyncVehicles(playerid);
    Player_LoaderDone(playerid,HOUSES_LOADER,token);
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
public Houses_BeginLoad(playerid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Houses_LoadPlayer(playerid,Player_GetLoadAccount(playerid),token);
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
    Houses_ResetPlayer(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Houses_ResetPlayer(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    Houses_ResetPlayer(playerid);
    SetTimerEx("Houses_BeginLoad",0,false,"dd",playerid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Houses_ResetPlayer(playerid);
}

hook Stats_OnBuild(playerid,targetid)
{
    if (Houses_IsKeyLoaded(targetid))
    {
        Stats_SetNumber("HouseKey",Houses_GetKey(targetid));
    }
}

hook Houses_OnOwnerChanged(house)
{
    foreach (new playerid : Player)
    {
        if (Houses_GetKey(playerid) == house)
        {
            Houses_SyncVehicles(playerid);
        }
    }
}
