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
#define VEHICLE_NEWS_CHOPPER_MODEL (488)
#define VEHICLE_NEWS_CHOPPER_SKILL (200)

static const s_GateBits[10] =
{
    VEHICLE_GATE_COP, VEHICLE_GATE_AMBULANCE, VEHICLE_GATE_GUARDAIR, VEHICLE_GATE_FIRE, VEHICLE_GATE_BUS,
    VEHICLE_GATE_SCHOOL, VEHICLE_GATE_TAXI, VEHICLE_GATE_HITMAN, VEHICLE_GATE_NEWS, VEHICLE_GATE_KART
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
static Vehicles_GetGateText(gate, reason, dest[], size = sizeof(dest))
{
    dest[0] = EOS;

    switch (gate)
    {
        case VEHICLE_GATE_GUARDAIR:
        {
            if (reason == VEHICLE_DENY_RANK)
            {
                strcopy(dest, "   You need Rank 3 to Fly this baby !", size);
            }
        }
        case VEHICLE_GATE_FIRE:
        {
            strcopy(dest, "   You are not a Fireman !", size);
        }
        case VEHICLE_GATE_BUS:
        {
            strcopy(dest, "   You are not a Bus Driver !", size);
        }
        case VEHICLE_GATE_SCHOOL:
        {
            strcopy(dest, "   You are not a School Instructor !", size);
        }
        case VEHICLE_GATE_TAXI:
        {
            strcopy(dest, "   You are not a Taxi Driver !", size);
        }
        case VEHICLE_GATE_HITMAN:
        {
            if (reason == VEHICLE_DENY_RANK)
            {
                strcopy(dest, "   Your Rank is too Low !", size);
            }
            else
            {
                strcopy(dest, "   You are not a Hitman !", size);
            }
        }
        case VEHICLE_GATE_NEWS:
        {
            strcopy(dest, "   You are not a News Reporter !", size);
        }
    }
}

static Vehicles_ApplyGate(playerid, vehicleid, gate)
{
    g_PlayerGateAllowed[playerid] = false;
    g_PlayerGateReason[playerid] = VEHICLE_DENY_MEMBER;

    if (gate == VEHICLE_GATE_SCHOOL && g_PlayerLesson[playerid])
    {
        return;
    }

    pawn_call_public("Vehicles_OnGateCheck", "ddd", playerid, vehicleid, gate);

    if (g_PlayerGateAllowed[playerid])
    {
        return;
    }

    new text[64];
    Vehicles_GetGateText(gate, g_PlayerGateReason[playerid], text);

    if (text[0] != EOS)
    {
        SendClientMessage(playerid, COLOR_GREY, text);
    }

    RemovePlayerFromVehicle(playerid);
}

#define VEHICLE_LICENCE_OK (0)
#define VEHICLE_LICENCE_BOAT (1)
#define VEHICLE_LICENCE_PLANE (2)
#define VEHICLE_LICENCE_CAR (3)

static Vehicles_MissingLicence(playerid, vehicleid)
{
    if (Vehicles_IsBoat(vehicleid))
    {
        return License_Has(playerid, LICENSE_BOAT) ? VEHICLE_LICENCE_OK : VEHICLE_LICENCE_BOAT;
    }

    if (Vehicles_IsPlane(vehicleid))
    {
        return (License_Has(playerid, LICENSE_FLY) || g_PlayerLesson[playerid]) ? VEHICLE_LICENCE_OK : VEHICLE_LICENCE_PLANE;
    }

    return (License_Has(playerid, LICENSE_CAR) || g_PlayerLesson[playerid]) ? VEHICLE_LICENCE_OK : VEHICLE_LICENCE_CAR;
}

static Vehicles_CheckLicence(playerid, vehicleid)
{
    switch (Vehicles_MissingLicence(playerid, vehicleid))
    {
        case VEHICLE_LICENCE_BOAT:
        {
            SendClientMessage(playerid, COLOR_GREY, "   You don't know how to Sail yet, so you left the Boat !");
            RemovePlayerFromVehicle(playerid);
        }
        case VEHICLE_LICENCE_PLANE:
        {
            SendClientMessage(playerid, COLOR_GREY, "   You don't know how to Fly yet, so you left the Plane !");
            RemovePlayerFromVehicle(playerid);
        }
        case VEHICLE_LICENCE_CAR:
        {
            SendClientMessage(playerid, COLOR_GREY, "   You don't know how to Drive yet, so you left the Car !");
            RemovePlayerFromVehicle(playerid);
        }
    }
}

static Vehicles_CheckNewsChopper(playerid, vehicleid)
{
    if (!(Vehicles_GetGates(vehicleid) & VEHICLE_GATE_NEWS) || GetVehicleModel(vehicleid) != VEHICLE_NEWS_CHOPPER_MODEL)
    {
        return;
    }

    if (Progress_GetSkill(playerid, PROGRESS_SKILL_NEWS) < VEHICLE_NEWS_CHOPPER_SKILL)
    {
        SendClientMessage(playerid, COLOR_GREY, "   Your News Reporter Skill is too low, can't fly the Chopper yet !");
        RemovePlayerFromVehicle(playerid);
    }
}

static Vehicles_TrackLastCar(playerid, vehicleid)
{
    new oldcar = g_PlayerLastCar[playerid];
    new housecar = Vehicles_GetPlayerHouseCar(playerid);

    if (oldcar != 0 && housecar != oldcar && g_PlayerHireCar[playerid] != oldcar && vehicleid != housecar)
    {
        if (g_VehicleLastDriver[oldcar] == playerid && oldcar != vehicleid)
        {
            g_VehicleLastDriver[oldcar] = VEHICLE_LAST_DRIVER_ABANDONED;
            Vehicles_ReleaseLock(oldcar);
        }
    }

    g_PlayerLastCar[playerid] = vehicleid;
    g_VehicleLastDriver[vehicleid] = playerid;
}

stock Vehicles_HandleDriver(playerid, vehicleid)
{
    if (!Util_IsValidVehicle(vehicleid))
    {
        return;
    }

    Vehicles_CheckLicence(playerid, vehicleid);

    pawn_call_public("Vehicles_OnDriverEnter", "dd", playerid, vehicleid);

    new gates = Vehicles_GetGates(vehicleid);

    for (new i = 0; i < sizeof(s_GateBits); i++)
    {
        if (gates & s_GateBits[i])
        {
            Vehicles_ApplyGate(playerid, vehicleid, s_GateBits[i]);
        }
    }

    Vehicles_CheckNewsChopper(playerid, vehicleid);
    Vehicles_TrackLastCar(playerid, vehicleid);
}

stock Vehicles_HandleDisconnect(playerid)
{
    new key = g_PlayerHireCar[playerid];

    if (key != VEHICLE_NO_HIRE)
    {
        g_VehicleLastDriver[key] = VEHICLE_LAST_DRIVER_ABANDONED;
        Vehicles_ReleaseLock(key);
    }

    new lastcar = g_PlayerLastCar[playerid];

    if (lastcar > 0)
    {
        g_VehicleLastDriver[lastcar] = VEHICLE_LAST_DRIVER_ABANDONED;

        if (Vehicles_GetPlayerHouseCar(playerid) != lastcar)
        {
            Vehicles_ReleaseLock(lastcar);
        }
    }
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
public Vehicles_OnGateCheck(playerid, vehicleid, gate)
{
    return 1;
}

public Vehicles_OnStealAttempt(playerid, vehicleid, kind)
{
    return 1;
}

public Vehicles_OnDriverEnter(playerid, vehicleid)
{
    return 1;
}

public Vehicles_OnTimeCheck(playerid)
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
    Vehicles_ResetPlayer(playerid);
}

hook OnPlayerDisconnect(playerid, reason)
{
    Vehicles_HandleDisconnect(playerid);
    Vehicles_ResetPlayer(playerid);
}

hook OnPlayerSpawn(playerid)
{
    Vehicles_InitLockDoors(playerid);
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    if (ispassenger || Account_GetTeam(playerid) < 3)
    {
        return;
    }

    if (Vehicles_IsCopCar(vehicleid))
    {
        pawn_call_public("Vehicles_OnStealAttempt", "ddd", playerid, vehicleid, VEHICLE_STEAL_POLICE);
    }

    if (Vehicles_IsAmbulance(vehicleid))
    {
        pawn_call_public("Vehicles_OnStealAttempt", "ddd", playerid, vehicleid, VEHICLE_STEAL_AMBULANCE);
    }
}

hook Tick_OnPlayerSecond(playerid)
{
    if (!Player_IsReady(playerid) || GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    {
        return;
    }

    new vehicleid = GetPlayerVehicleID(playerid);

    if (vehicleid != INVALID_VEHICLE_ID && Vehicles_MissingLicence(playerid, vehicleid) != VEHICLE_LICENCE_OK)
    {
        RemovePlayerFromVehicle(playerid);
    }
}

hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    if (newstate == PLAYER_STATE_DRIVER)
    {
        Vehicles_HandleDriver(playerid, GetPlayerVehicleID(playerid));
    }
}
