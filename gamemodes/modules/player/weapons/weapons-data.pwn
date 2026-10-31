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
#define WEAPONS_SLOTS (4)
#define WEAPONS_LOADER "weapons"

forward Weapons_LoadStart(playerid,accountid,token);

static s_WeaponsStoredId[MAX_PLAYERS][WEAPONS_SLOTS];
static s_WeaponsStoredAmmo[MAX_PLAYERS][WEAPONS_SLOTS];
static bool:s_WeaponsLoaded[MAX_PLAYERS];

static const s_WeaponsIdColumns[WEAPONS_SLOTS][8] =
{
    "gun1",
    "gun2",
    "gun3",
    "gun4"
};

static const s_WeaponsAmmoColumns[WEAPONS_SLOTS][8] =
{
    "ammo1",
    "ammo2",
    "ammo3",
    "ammo4"
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
static Weapons_Clear(playerid)
{
    for (new i = 0;i < WEAPONS_SLOTS;i++)
    {
        s_WeaponsStoredId[playerid][i] = 0;
        s_WeaponsStoredAmmo[playerid][i] = 0;
    }

    s_WeaponsLoaded[playerid] = false;
}

stock Weapons_GetStoredId(playerid,slot)
{
    if (!Util_IsValidPlayer(playerid) || slot < 1 || slot > WEAPONS_SLOTS)
    {
        return 0;
    }

    return s_WeaponsStoredId[playerid][slot - 1];
}

stock Weapons_GetStoredAmmo(playerid,slot)
{
    if (!Util_IsValidPlayer(playerid) || slot < 1 || slot > WEAPONS_SLOTS)
    {
        return 0;
    }

    return s_WeaponsStoredAmmo[playerid][slot - 1];
}

stock bool:Weapons_SetStored(playerid,slot,weaponid,ammo)
{
    if (!Util_IsValidPlayer(playerid) || slot < 1 || slot > WEAPONS_SLOTS || !s_WeaponsLoaded[playerid])
    {
        return false;
    }

    s_WeaponsStoredId[playerid][slot - 1] = weaponid;
    s_WeaponsStoredAmmo[playerid][slot - 1] = ammo;

    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_weapons SET %s = %d, %s = %d WHERE account_id = %d",s_WeaponsIdColumns[slot - 1],weaponid,s_WeaponsAmmoColumns[slot - 1],ammo,accountid));
    }

    return true;
}

stock Weapons_ClearStored(playerid)
{
    for (new slot = 1;slot <= WEAPONS_SLOTS;slot++)
    {
        Weapons_SetStored(playerid,slot,0,0);
    }
}

static Weapons_Load(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT gun1, gun2, gun3, gun4, ammo1, ammo2, ammo3, ammo4 FROM player_weapons WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    Weapons_Clear(playerid);

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("weapons","load failed for player %d, starting with nothing stored",playerid);
    }
    else if (cache_num_rows() == 0)
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO player_weapons (account_id) VALUES (%d)",accountid));
    }
    else
    {
        for (new i = 0;i < WEAPONS_SLOTS;i++)
        {
            cache_get_value_name_int(0,s_WeaponsIdColumns[i],s_WeaponsStoredId[playerid][i]);
            cache_get_value_name_int(0,s_WeaponsAmmoColumns[i],s_WeaponsStoredAmmo[playerid][i]);
        }
    }

    s_WeaponsLoaded[playerid] = true;
    Player_LoaderDone(playerid,WEAPONS_LOADER,token);
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
public Weapons_LoadStart(playerid,accountid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Weapons_Load(playerid,accountid,token);
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
    Weapons_Clear(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    SetTimerEx("Weapons_LoadStart",0,false,"ddd",playerid,accountid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Weapons_Clear(playerid);
}
