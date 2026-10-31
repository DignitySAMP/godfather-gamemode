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
#define BUSINESS_RENTAL_NO_SHOP (-1)

static s_BusinessKey[MAX_PLAYERS];
static bool:s_BusinessKeyLoaded[MAX_PLAYERS];

forward Business_BeginLoad(playerid,token);
forward Business_OnKeyChanged(playerid,key);

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
stock bool:Business_IsKeyLoaded(playerid)
{
    return Util_IsValidPlayer(playerid) && s_BusinessKeyLoaded[playerid];
}

stock Business_GetKey(playerid)
{
    if (!Business_IsKeyLoaded(playerid))
    {
        return BUSINESS_NO_KEY;
    }

    return s_BusinessKey[playerid];
}

stock bool:Business_IsOwner(playerid,key)
{
    if (!Business_IsValid(key))
    {
        return false;
    }

    new name[BUSINESS_NAME_LEN];
    Property_GetPlayerName(playerid,name);
    return Business_IsOwnerName(key,name);
}

stock Business_GetOwnedKey(playerid)
{
    new key = Business_GetKey(playerid);

    if (key != BUSINESS_NO_KEY && Business_IsOwner(playerid,key))
    {
        return key;
    }

    return BUSINESS_NO_KEY;
}

stock Business_SyncRental(playerid)
{
    new key = Business_GetOwnedKey(playerid), shop = BUSINESS_RENTAL_NO_SHOP;

    if (key == BUSINESS_SPECIAL_BASE + SBIZ_RENT_A)
    {
        shop = SBIZ_RENT_A;
    }
    else if (key == BUSINESS_SPECIAL_BASE + SBIZ_RENT_B)
    {
        shop = SBIZ_RENT_B;
    }

    Rental_SetBossShop(playerid,shop);
}

stock bool:Business_SetKey(playerid,key)
{
    if (!Business_IsKeyLoaded(playerid))
    {
        return false;
    }

    if (key != BUSINESS_NO_KEY && !Business_IsValid(key))
    {
        return false;
    }

    s_BusinessKey[playerid] = key;
    mysql_tquery_s(g_Mysql,str_format("INSERT INTO business_keys (account_id, business_key) VALUES (%d, %d) ON DUPLICATE KEY UPDATE business_key = VALUES(business_key)",Account_GetId(playerid),key));
    Business_SyncRental(playerid);
    pawn_call_public("Business_OnKeyChanged","dd",playerid,key);
    return true;
}

static Business_ResetPlayer(playerid)
{
    s_BusinessKey[playerid] = BUSINESS_NO_KEY;
    s_BusinessKeyLoaded[playerid] = false;
    Rental_SetBossShop(playerid,BUSINESS_RENTAL_NO_SHOP);
}

static Business_LoadPlayer(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT business_key FROM business_keys WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("business","key load failed for player %d",playerid);
        return;
    }

    new key = BUSINESS_NO_KEY;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"business_key",key);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT INTO business_keys (account_id, business_key) VALUES (%d, %d) ON DUPLICATE KEY UPDATE business_key = VALUES(business_key)",accountid,key));
    }

    if (key != BUSINESS_NO_KEY && !Business_IsValid(key))
    {
        Log_Warn("business","player %d held the unknown business key %d, cleared",playerid,key);
        key = BUSINESS_NO_KEY;
    }

    s_BusinessKey[playerid] = key;
    s_BusinessKeyLoaded[playerid] = true;
    Business_SyncRental(playerid);
    Player_LoaderDone(playerid,BUSINESS_LOADER,token);
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
public Business_BeginLoad(playerid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Business_LoadPlayer(playerid,Player_GetLoadAccount(playerid),token);
    }

    return 1;
}

public Business_OnKeyChanged(playerid,key)
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
    Business_ResetPlayer(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Business_ResetPlayer(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    Business_ResetPlayer(playerid);
    SetTimerEx("Business_BeginLoad",0,false,"dd",playerid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Business_ResetPlayer(playerid);
}

hook Business_OnOwnerChanged(key)
{
    foreach (new playerid : Player)
    {
        if (Business_IsKeyLoaded(playerid))
        {
            Business_SyncRental(playerid);
        }
    }
}

hook Stats_OnBuild(playerid,targetid)
{
    if (Business_IsKeyLoaded(targetid))
    {
        Stats_SetNumber("BusinessKey",Business_GetKey(targetid));
    }
}
