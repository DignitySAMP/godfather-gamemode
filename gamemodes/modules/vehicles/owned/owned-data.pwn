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
#define VEHICLE_NO_HIRE (0)
#define VEHICLE_LAST_DRIVER_NONE (299)
#define VEHICLE_LAST_DRIVER_ABANDONED (300)
#define VEHICLE_LAST_DRIVER_RESPAWN (301)
#define VEHICLE_LAST_DRIVER_BUSY (255)
#define VEHICLE_CARCHECK_MS (30000)
#define VEHICLE_STEAL_POLICE (1)
#define VEHICLE_STEAL_AMBULANCE (2)
#define VEHICLE_DENY_MEMBER (1)
#define VEHICLE_DENY_RANK (2)
#define VEHICLE_PLANE_UNLOCK_FIRST (99)
#define VEHICLE_PLANE_UNLOCK_LAST (109)

forward Vehicles_OnGateCheck(playerid, vehicleid, gate);
forward Vehicles_OnStealAttempt(playerid, vehicleid, kind);
forward Vehicles_OnDriverEnter(playerid, vehicleid);
forward Vehicles_OnTimeCheck(playerid);

new g_VehicleLastDriver[VEHICLE_MAX];
new bool:g_VehicleLocked[VEHICLE_MAX];

new g_PlayerLastCar[MAX_PLAYERS];
new g_PlayerHireCar[MAX_PLAYERS];
new bool:g_PlayerSwitchKey[MAX_PLAYERS];
static s_PlayerHouse[MAX_PLAYERS];
static bool:s_PlayerHouseOwner[MAX_PLAYERS];
new g_PlayerBoughtCar[MAX_PLAYERS];
new g_PlayerBoughtCalls[MAX_PLAYERS];
new bool:g_PlayerSeesUnlocked[MAX_PLAYERS];
new bool:g_PlayerLesson[MAX_PLAYERS];
new bool:g_PlayerDebtWarned[MAX_PLAYERS];
new bool:g_PlayerGateAllowed[MAX_PLAYERS];
new g_PlayerGateReason[MAX_PLAYERS];

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
stock Vehicles_ResetDrivers()
{
    for (new vehicleid = 0; vehicleid < VEHICLE_MAX; vehicleid++)
    {
        g_VehicleLastDriver[vehicleid] = VEHICLE_LAST_DRIVER_NONE;
        g_VehicleLocked[vehicleid] = false;
    }
}

stock Vehicles_ResetPlayer(playerid)
{
    g_PlayerLastCar[playerid] = 0;
    g_PlayerHireCar[playerid] = VEHICLE_NO_HIRE;
    g_PlayerSwitchKey[playerid] = false;
    s_PlayerHouse[playerid] = VEHICLE_NO_HOUSE;
    s_PlayerHouseOwner[playerid] = false;
    g_PlayerBoughtCar[playerid] = 0;
    g_PlayerBoughtCalls[playerid] = 0;
    g_PlayerSeesUnlocked[playerid] = false;
    g_PlayerLesson[playerid] = false;
    g_PlayerDebtWarned[playerid] = false;
    g_PlayerGateAllowed[playerid] = false;
    g_PlayerGateReason[playerid] = VEHICLE_DENY_MEMBER;
}

stock Vehicles_SetLockState(vehicleid, bool:locked)
{
    if (vehicleid >= 1 && vehicleid <= MAX_VEHICLES)
    {
        g_VehicleLocked[vehicleid] = locked;
    }
}

stock Vehicles_LockCar(vehicleid)
{
    if (!Util_IsValidVehicle(vehicleid))
    {
        return;
    }

    foreach (new playerid : Player)
    {
        SetVehicleParamsForPlayer(vehicleid, playerid, 0, 1);
    }
}

stock Vehicles_UnlockCar(vehicleid)
{
    if (!Util_IsValidVehicle(vehicleid) || Vehicles_IsPlane(vehicleid))
    {
        return;
    }

    foreach (new playerid : Player)
    {
        SetVehicleParamsForPlayer(vehicleid, playerid, 0, 0);
    }
}

stock Vehicles_ReleaseLock(vehicleid)
{
    Vehicles_SetLockState(vehicleid, false);
    Vehicles_UnlockCar(vehicleid);
}

stock Vehicles_InitLockDoors(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    for (new vehicleid = 1; vehicleid <= MAX_VEHICLES; vehicleid++)
    {
        if (g_VehicleLocked[vehicleid] && IsValidVehicle(vehicleid))
        {
            SetVehicleParamsForPlayer(vehicleid, playerid, 0, 1);
        }
    }
}

stock Vehicles_GetLastCar(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return g_PlayerLastCar[playerid];
}

stock Vehicles_GetHireCar(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return VEHICLE_NO_HIRE;
    }

    return g_PlayerHireCar[playerid];
}

stock Vehicles_SetHireCar(playerid, vehicleid)
{
    if (Util_IsValidPlayer(playerid) && vehicleid >= 0 && vehicleid <= MAX_VEHICLES)
    {
        g_PlayerHireCar[playerid] = vehicleid;
    }
}

stock Vehicles_ClearHireCar(playerid)
{
    Vehicles_SetHireCar(playerid, VEHICLE_NO_HIRE);
}

stock Vehicles_ClearKeysTo(vehicleid)
{
    foreach (new playerid : Player)
    {
        if (g_PlayerHireCar[playerid] == vehicleid)
        {
            g_PlayerHireCar[playerid] = VEHICLE_NO_HIRE;
        }
    }
}

stock Vehicles_GetPlayerHouse(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return VEHICLE_NO_HOUSE;
    }

    return s_PlayerHouse[playerid];
}

stock bool:Vehicles_IsPlayerHouseOwner(playerid)
{
    return Util_IsValidPlayer(playerid) && s_PlayerHouse[playerid] != VEHICLE_NO_HOUSE && s_PlayerHouseOwner[playerid];
}

stock Vehicles_SetPlayerHouse(playerid, houseid, bool:isOwner)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    s_PlayerHouse[playerid] = houseid;
    s_PlayerHouseOwner[playerid] = isOwner && houseid != VEHICLE_NO_HOUSE;
}

stock Vehicles_GetPlayerHouseCar(playerid)
{
    new houseid = Vehicles_GetPlayerHouse(playerid);

    if (houseid == VEHICLE_NO_HOUSE)
    {
        return 0;
    }

    return Vehicles_GetHouseCar(houseid);
}

stock Vehicles_GetBoughtCalls(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return g_PlayerBoughtCalls[playerid];
}

stock Vehicles_SetBoughtCar(playerid, vehicleid, calls)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_PlayerBoughtCar[playerid] = vehicleid;
        g_PlayerBoughtCalls[playerid] = calls;
    }
}

stock Vehicles_SetSeesUnlocked(playerid, bool:enabled)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_PlayerSeesUnlocked[playerid] = enabled;
    }
}

stock Vehicles_SetLessonActive(playerid, bool:active)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_PlayerLesson[playerid] = active;
    }
}

stock bool:Vehicles_IsLessonActive(playerid)
{
    return Util_IsValidPlayer(playerid) && g_PlayerLesson[playerid];
}

stock bool:Vehicles_HasDebtWarning(playerid)
{
    return Util_IsValidPlayer(playerid) && g_PlayerDebtWarned[playerid];
}

stock Vehicles_GateAllow(playerid)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_PlayerGateAllowed[playerid] = true;
    }
}

stock Vehicles_GateDeny(playerid, reason = VEHICLE_DENY_MEMBER)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_PlayerGateAllowed[playerid] = false;
        g_PlayerGateReason[playerid] = reason;
    }
}

stock bool:Vehicles_IsOccupiedOrKept(vehicleid)
{
    foreach (new playerid : Player)
    {
        if (IsPlayerInVehicle(playerid, vehicleid) || g_PlayerHireCar[playerid] == vehicleid)
        {
            return true;
        }
    }

    return false;
}

stock bool:Vehicles_Tow(vehicleid)
{
    if (!Util_IsValidVehicle(vehicleid))
    {
        return false;
    }

    if (Vehicles_IsOccupiedOrKept(vehicleid))
    {
        g_VehicleLastDriver[vehicleid] = VEHICLE_LAST_DRIVER_BUSY;
        return false;
    }

    new Float:x, Float:y, Float:z, Float:angle;

    if (!Vehicles_GetSpawnPoint(Vehicles_GetKey(vehicleid), x, y, z, angle))
    {
        return false;
    }

    SetVehiclePos(vehicleid, x, y, z);
    SetVehicleZAngle(vehicleid, angle);
    return true;
}

stock bool:Vehicles_Respawn(vehicleid)
{
    if (!Util_IsValidVehicle(vehicleid))
    {
        return false;
    }

    if (Vehicles_IsOccupiedOrKept(vehicleid))
    {
        g_VehicleLastDriver[vehicleid] = VEHICLE_LAST_DRIVER_BUSY;
        return false;
    }

    SetVehicleToRespawn(vehicleid);
    g_VehicleLastDriver[vehicleid] = VEHICLE_LAST_DRIVER_NONE;
    return true;
}

stock Vehicles_AgeAbandoned()
{
    for (new vehicleid = 1; vehicleid <= MAX_VEHICLES; vehicleid++)
    {
        if (!IsValidVehicle(vehicleid))
        {
            continue;
        }

        if (g_VehicleLastDriver[vehicleid] == VEHICLE_LAST_DRIVER_RESPAWN)
        {
            Vehicles_Respawn(vehicleid);
        }

        if (g_VehicleLastDriver[vehicleid] >= VEHICLE_LAST_DRIVER_ABANDONED)
        {
            g_VehicleLastDriver[vehicleid]++;
        }
    }
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

hook Vehicles_OnCreated(vehicleid, key)
{
    g_VehicleLastDriver[vehicleid] = VEHICLE_LAST_DRIVER_NONE;
    g_VehicleLocked[vehicleid] = Vehicles_GetKind(vehicleid) == VEHICLE_KIND_HOUSE;
}
