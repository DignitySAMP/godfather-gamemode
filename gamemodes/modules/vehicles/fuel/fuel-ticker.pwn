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
#define FUEL_TICK_SECONDS (15)
#define FUEL_LOW_LEVEL (10)
#define FUEL_SOUND_LOW (1085)
#define SPEEDO_MAX_SPEED (175.0)
#define SPEEDO_HEIGHT_LIMIT (550.0)
#define SPEEDO_DIVISOR (31.0)
#define SPEEDO_ADMIN_LEVEL (1)

static s_FuelSeconds[MAX_PLAYERS];
static Float:s_SpeedFromX[MAX_PLAYERS];
static Float:s_SpeedFromY[MAX_PLAYERS];
static bool:s_SpeedHasFrom[MAX_PLAYERS];
static Float:s_StoppedX[MAX_PLAYERS];
static Float:s_StoppedY[MAX_PLAYERS];
static Float:s_StoppedZ[MAX_PLAYERS];

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
stock Speedo_ResetSample(playerid)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_SpeedHasFrom[playerid] = false;
    }
}

stock Speedo_FormatText(Float:distance, dest[], size = sizeof(dest))
{
    if (distance < 10.0)
    {
        format(dest, size, "~n~~n~~n~~n~~n~~n~~n~~g~mph :   ~w~%.0f", distance);
    }
    else if (distance < 100.0)
    {
        format(dest, size, "~n~~n~~n~~n~~n~~n~~n~~g~mph :  ~w~%.0f", distance);
    }
    else
    {
        format(dest, size, "~n~~n~~n~~n~~n~~n~~n~~g~mph : ~w~%.0f", distance);
    }
}

static Speedo_WarnAdmins(playerid, Float:distance)
{
    new name[MAX_PLAYER_NAME + 1], line[96];
    GetPlayerName(playerid, name, sizeof(name));
    format(line, sizeof(line), "AdmWarning: [%d]%s %.0f mph", playerid, name, distance);

    foreach (new adminid : Player)
    {
        if (!IsPlayerNPC(adminid) && Account_GetAdminLevel(adminid) >= SPEEDO_ADMIN_LEVEL)
        {
            SendClientMessage(adminid, COLOR_YELLOW, line);
        }
    }
}

stock Speedo_Update(playerid)
{
    if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    {
        return;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    if (z > SPEEDO_HEIGHT_LIMIT)
    {
        s_SpeedHasFrom[playerid] = false;
    }

    if (s_SpeedHasFrom[playerid])
    {
        new Float:deltaX = x - s_SpeedFromX[playerid], Float:deltaY = y - s_SpeedFromY[playerid];
        new Float:distance = (deltaX * deltaX + deltaY * deltaY) / SPEEDO_DIVISOR;

        if (g_PlayerSpeedo[playerid] == FUEL_SPEEDO_ON)
        {
            new text[96];
            Speedo_FormatText(distance, text);
            GameTextForPlayer(playerid, text, 2000, 5);
        }

        if (distance > SPEEDO_MAX_SPEED && Account_GetAdminLevel(playerid) < SPEEDO_ADMIN_LEVEL && !Vehicles_IsPlane(GetPlayerVehicleID(playerid)))
        {
            Speedo_WarnAdmins(playerid, distance);
        }
    }

    if (z < SPEEDO_HEIGHT_LIMIT)
    {
        s_SpeedFromX[playerid] = x;
        s_SpeedFromY[playerid] = y;
        s_SpeedHasFrom[playerid] = true;
    }
}

stock Fuel_CheckPlayer(playerid)
{
    if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    {
        return;
    }

    new vehicleid = GetPlayerVehicleID(playerid);

    if (g_VehicleGas[vehicleid] >= 1)
    {
        if (g_VehicleGas[vehicleid] <= FUEL_LOW_LEVEL)
        {
            PlayerPlaySound(playerid, FUEL_SOUND_LOW, 0.0, 0.0, 0.0);
        }

        if (g_PlayerFuelInfo[playerid])
        {
            new text[96];
            format(text, sizeof(text), "~r~~n~~n~~n~~n~~n~~n~~n~~n~~n~Fuel:~w~ %d%%", g_VehicleGas[vehicleid]);
            GameTextForPlayer(playerid, text, 15500, 3);
        }

        if (Vehicles_IsPlane(vehicleid) || Vehicles_IsBoat(vehicleid))
        {
            g_VehicleGas[vehicleid]++;
        }

        g_VehicleGas[vehicleid]--;
    }
    else
    {
        g_PlayerNoFuel[playerid] = true;
        TogglePlayerControllable(playerid, false);
        GameTextForPlayer(playerid, "~w~~n~~n~~n~~n~~n~~n~~n~~n~No fuel in Vehicle~n~Use /exit to leave the vehicle", 1500, 3);
    }
}

stock Fuel_StoppedPlayer(playerid)
{
    if (!IsPlayerInAnyVehicle(playerid))
    {
        return;
    }

    new vehicleid = GetPlayerVehicleID(playerid), Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    new Float:distance = Util_GetDistance3D(x, y, z, s_StoppedX[playerid], s_StoppedY[playerid], s_StoppedZ[playerid]);

    if (floatround(distance * 3600.0) == 0)
    {
        g_VehicleGas[vehicleid]++;
    }

    s_StoppedX[playerid] = x;
    s_StoppedY[playerid] = y;
    s_StoppedZ[playerid] = z;
}

stock Fuel_Tick(playerid)
{
    s_FuelSeconds[playerid]++;

    if (s_FuelSeconds[playerid] < FUEL_TICK_SECONDS)
    {
        return;
    }

    s_FuelSeconds[playerid] = 0;
    Fuel_CheckPlayer(playerid);
    Fuel_StoppedPlayer(playerid);
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
    s_FuelSeconds[playerid] = 0;
    s_SpeedHasFrom[playerid] = false;
    s_StoppedX[playerid] = 0.0;
    s_StoppedY[playerid] = 0.0;
    s_StoppedZ[playerid] = 0.0;
}

hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    if (newstate == PLAYER_STATE_ONFOOT || newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_SPAWNED)
    {
        s_SpeedHasFrom[playerid] = false;
    }
}

hook OnPlayerExitVehicle(playerid, vehicleid)
{
    if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
    {
        return;
    }

    if (g_PlayerFuelInfo[playerid])
    {
        GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~Left car", 500, 3);
    }
}

hook Tick_OnPlayerSecond(playerid)
{
    Speedo_Update(playerid);
    Fuel_Tick(playerid);
}
