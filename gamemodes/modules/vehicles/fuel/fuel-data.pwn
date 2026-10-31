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
#define FUEL_MAX (100)
#define FUEL_CAN_AMOUNT (20)
#define FUEL_CAN_LIMIT (81)
#define FUEL_REFUEL_MS (5000)
#define FUEL_LOADER "fuel"
#define FUEL_SOUND_TOGGLE (1145)
#define FUEL_SPEEDO_NONE (0)
#define FUEL_SPEEDO_OFF (1)
#define FUEL_SPEEDO_ON (2)
#define FUEL_MECHANIC_LIMIT (110)

forward Fuel_LoadStart(playerid, accountid, token);
forward Fuel_FillTimer();

new g_VehicleGas[VEHICLE_MAX];
new g_PlayerSpeedo[MAX_PLAYERS];
new bool:g_PlayerFuelInfo[MAX_PLAYERS];
new bool:g_PlayerNoFuel[MAX_PLAYERS];
new bool:g_PlayerRefueling[MAX_PLAYERS];

static s_FuelCan[MAX_PLAYERS];
static bool:s_FuelLoaded[MAX_PLAYERS];

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

stock Fuel_AddCapped(vehicleid, amount)
{
    if (vehicleid >= 0 && vehicleid <= MAX_VEHICLES && g_VehicleGas[vehicleid] < FUEL_MECHANIC_LIMIT)
    {
        g_VehicleGas[vehicleid] += amount;
    }
}

stock Fuel_FillAll()
{
    for (new vehicleid = 0; vehicleid <= MAX_VEHICLES; vehicleid++)
    {
        g_VehicleGas[vehicleid] = FUEL_MAX;
    }
}

stock Fuel_SetSpeedometer(playerid, mode)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    g_PlayerSpeedo[playerid] = mode;

    new accountid = Account_GetId(playerid);

    if (s_FuelLoaded[playerid] && accountid > 0)
    {
        mysql_tquery_s(g_Mysql, str_format("UPDATE player_fuel SET speedometer = %d WHERE account_id = %d", mode, accountid));
    }
}

stock Fuel_GetCan(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_FuelCan[playerid];
}

stock bool:Fuel_SetCan(playerid, amount)
{
    if (!Util_IsValidPlayer(playerid) || !s_FuelLoaded[playerid])
    {
        return false;
    }

    s_FuelCan[playerid] = amount;

    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql, str_format("UPDATE player_fuel SET can = %d WHERE account_id = %d", amount, accountid));
    }

    return true;
}

stock bool:Fuel_ReleaseStranded(playerid)
{
    if (!Util_IsValidPlayer(playerid) || !g_PlayerNoFuel[playerid])
    {
        return false;
    }

    TogglePlayerControllable(playerid, true);
    RemovePlayerFromVehicle(playerid);
    g_PlayerNoFuel[playerid] = false;
    return true;
}

stock bool:Vehicles_ReleaseDriver(playerid)
{
    new bool:released = Fuel_ReleaseStranded(playerid);

    if (Rental_IsFrozen(playerid))
    {
        Rental_Unfreeze(playerid);
        RemovePlayerFromVehicle(playerid);
        released = true;
    }

    return released;
}

static Fuel_Clear(playerid)
{
    s_FuelCan[playerid] = 0;
    s_FuelLoaded[playerid] = false;
    g_PlayerSpeedo[playerid] = FUEL_SPEEDO_NONE;
    g_PlayerFuelInfo[playerid] = false;
    g_PlayerNoFuel[playerid] = false;
    g_PlayerRefueling[playerid] = false;
}

static Fuel_Load(playerid, accountid, token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql, str_format("SELECT can, speedometer FROM player_fuel WHERE account_id = %d LIMIT 1", accountid), false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    new can = 0, speedometer = FUEL_SPEEDO_NONE;

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("fuel", "load failed for player %d, starting with an empty can", playerid);
    }
    else if (cache_num_rows() == 0)
    {
        mysql_tquery_s(g_Mysql, str_format("INSERT IGNORE INTO player_fuel (account_id) VALUES (%d)", accountid));
    }
    else
    {
        cache_get_value_name_int(0, "can", can);
        cache_get_value_name_int(0, "speedometer", speedometer);
    }

    s_FuelCan[playerid] = can;
    g_PlayerSpeedo[playerid] = speedometer;
    s_FuelLoaded[playerid] = true;

    if (can != 0 && Account_GetDonateRank(playerid) < 1)
    {
        Fuel_SetCan(playerid, 0);
    }

    Player_LoaderDone(playerid, FUEL_LOADER, token);
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
public Fuel_LoadStart(playerid, accountid, token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Fuel_Load(playerid, accountid, token);
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
    Fuel_Clear(playerid);
}

hook Account_OnLogin(playerid, accountid)
{
    SetTimerEx("Fuel_LoadStart", 0, false, "ddd", playerid, accountid, Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid, accountid)
{
    Fuel_Clear(playerid);
}
