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
#define ARMS_LOADER "arms"
#define ARMS_NEAR_RANGE (5.0)
#define ARMS_SHOP_RADIUS (3.0)
#define ARMS_PACKAGES_MAX (10)
#define ARMS_PACKAGE_PRICE (100)
#define ARMS_PACKAGE_MATS (50)
#define ARMS_WEAPON_COUNT (8)
#define ARMS_WEAPON_NAME_LEN (12)
#define ARMS_SOUND_DONE (1052)

enum E_ARMS_WEAPON
{
    E_ARMS_WEAPON_NAME[ARMS_WEAPON_NAME_LEN],
    E_ARMS_WEAPON_ID,
    E_ARMS_WEAPON_PRICE,
    E_ARMS_WEAPON_AMMO,
    E_ARMS_WEAPON_SLOT,
    E_ARMS_WEAPON_NEEDS
}

static s_ArmsMats[MAX_PLAYERS];
static s_ArmsPackages[MAX_PLAYERS];
static bool:s_ArmsLoaded[MAX_PLAYERS];

static const Float:s_ArmsShopPos[3] = {597.1277, -1248.6479, 18.2734};
static const Float:s_ArmsFactoryPos[3] = {-2119.5469, -178.5679, 35.3203};

static const s_ArmsWeapons[ARMS_WEAPON_COUNT][E_ARMS_WEAPON] =
{
    {"sdpistol", 23, 100, 50, 2, 100},
    {"flowers", 14, 25, 1, 1, 25},
    {"eagle", 24, 150, 50, 2, 200},
    {"mp5", 29, 200, 200, 2, 200},
    {"shotgun", 25, 200, 50, 2, 200},
    {"ak47", 30, 600, 250, 2, 600},
    {"m4", 31, 600, 250, 2, 600},
    {"rifle", 33, 600, 50, 2, 600}
};

forward Arms_LoadStart(playerid,accountid,token);

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
stock Arms_GetMats(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_ArmsMats[playerid] : 0;
}

stock bool:Arms_SetMats(playerid,mats)
{
    if (!Util_IsValidPlayer(playerid) || !s_ArmsLoaded[playerid])
    {
        return false;
    }

    s_ArmsMats[playerid] = mats;

    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_arms SET mats = %d WHERE account_id = %d",mats,accountid));
    }

    return true;
}

stock Arms_GetPackages(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_ArmsPackages[playerid] : 0;
}

stock Arms_SetPackages(playerid,packages)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_ArmsPackages[playerid] = packages;
    }
}

stock bool:Arms_IsAtShop(playerid)
{
    return Property_IsNear(playerid,ARMS_SHOP_RADIUS,s_ArmsShopPos[0],s_ArmsShopPos[1],s_ArmsShopPos[2]);
}

stock bool:Arms_IsAtFactory(playerid)
{
    return Property_IsNear(playerid,ARMS_SHOP_RADIUS,s_ArmsFactoryPos[0],s_ArmsFactoryPos[1],s_ArmsFactoryPos[2]);
}

stock Arms_FindWeapon(const name[])
{
    for (new i = 0;i < ARMS_WEAPON_COUNT;i++)
    {
        if (!strcmp(name,s_ArmsWeapons[i][E_ARMS_WEAPON_NAME],true))
        {
            return i;
        }
    }

    return -1;
}

stock Arms_GetWeaponId(weapon)
{
    return s_ArmsWeapons[weapon][E_ARMS_WEAPON_ID];
}

stock Arms_GetWeaponPrice(weapon)
{
    return s_ArmsWeapons[weapon][E_ARMS_WEAPON_PRICE];
}

stock Arms_GetWeaponAmmo(weapon)
{
    return s_ArmsWeapons[weapon][E_ARMS_WEAPON_AMMO];
}

stock Arms_GetWeaponSlot(weapon)
{
    return s_ArmsWeapons[weapon][E_ARMS_WEAPON_SLOT];
}

stock Arms_GetWeaponNeeds(weapon)
{
    return s_ArmsWeapons[weapon][E_ARMS_WEAPON_NEEDS];
}

static Arms_Clear(playerid)
{
    s_ArmsMats[playerid] = 0;
    s_ArmsPackages[playerid] = 0;
    s_ArmsLoaded[playerid] = false;
}

static Arms_Load(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT mats FROM player_arms WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("arms","row load failed for player %d",playerid);
        return;
    }

    new mats = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"mats",mats);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO player_arms (account_id) VALUES (%d)",accountid));
    }

    s_ArmsMats[playerid] = mats;
    s_ArmsLoaded[playerid] = true;
    Player_LoaderDone(playerid,ARMS_LOADER,token);
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
public Arms_LoadStart(playerid,accountid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Arms_Load(playerid,accountid,token);
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
    Arms_Clear(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Arms_Clear(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    SetTimerEx("Arms_LoadStart",0,false,"ddd",playerid,accountid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Arms_Clear(playerid);
}

hook Law_OnTakeMaterials(playerid,targetid)
{
    Arms_SetMats(targetid,0);
}

hook Stats_OnBuild(playerid,targetid)
{
    Stats_SetNumber("Materials",Arms_GetMats(targetid));
}

hook Frisk_OnBuild(playerid,targetid)
{
    Misc_SetFriskItem(MISC_FRISK_ITEM_MATERIALS,Arms_GetMats(targetid) > 0);
}
