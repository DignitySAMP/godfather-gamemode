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
#define FUEL_STATION_COUNT (14)

static const Float:s_FuelStations[FUEL_STATION_COUNT][4] =
{
    {1004.0070, -939.3102, 42.1797, 6.0},
    {1944.3260, -1772.9254, 13.3906, 6.0},
    {-90.5515, -1169.4578, 2.4079, 6.0},
    {-1609.7958, -2718.2048, 48.5391, 6.0},
    {-2029.4968, 156.4366, 28.9498, 6.0},
    {-2408.7590, 976.0934, 45.4175, 8.0},
    {-2243.9629, -2560.6477, 31.8841, 5.0},
    {-1676.6323, 414.0262, 6.9484, 8.0},
    {2202.2349, 2474.3494, 10.5258, 6.0},
    {614.9333, 1689.7418, 6.6968, 10.0},
    {-1328.8250, 2677.2173, 49.7665, 8.0},
    {70.3882, 1218.6783, 18.5165, 6.0},
    {2113.7390, 920.1079, 10.5255, 8.0},
    {-1327.7218, 2678.8723, 50.0625, 6.0}
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
stock bool:Fuel_IsAtGasStation(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return false;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    for (new i = 0; i < FUEL_STATION_COUNT; i++)
    {
        new Float:radius = s_FuelStations[i][3];
        new Float:deltaX = x - s_FuelStations[i][0], Float:deltaY = y - s_FuelStations[i][1], Float:deltaZ = z - s_FuelStations[i][2];

        if (deltaX < radius && deltaX > -radius && deltaY < radius && deltaY > -radius && deltaZ < radius && deltaZ > -radius)
        {
            return true;
        }
    }

    return false;
}

stock Fuel_RefillPlayer(playerid)
{
    new vehicleid = GetPlayerVehicleID(playerid), missing = FUEL_MAX - g_VehicleGas[vehicleid];

    if (!g_PlayerRefueling[playerid])
    {
        return;
    }

    new line[96];

    if (Account_GetCash(playerid) >= missing + 4)
    {
        g_VehicleGas[vehicleid] += missing;

        new price = missing * Vehicles_GetShopPrice(VEHICLE_SHOP_GAS);
        format(line, sizeof(line), "* Vehicle filled up, for: $%d.", price);
        SendClientMessage(playerid, COLOR_LIGHTBLUE, line);
        Account_SetCash(playerid, Account_GetCash(playerid) - price);
        Vehicles_SellFromShop(playerid, VEHICLE_SHOP_GAS, price, false);
        g_PlayerRefueling[playerid] = false;
    }
    else
    {
        format(line, sizeof(line), "* Not enough Money to refill, it costs $%d to fill your Vehicle.", missing);
        SendClientMessage(playerid, COLOR_LIGHTBLUE, line);
        g_PlayerRefueling[playerid] = false;
    }
}

stock bool:Fuel_BuyCan(playerid)
{
    if (!Fuel_IsAtGasStation(playerid))
    {
        SendClientMessage(playerid, COLOR_GREY, "   You're not at a Gas Station!");
        return false;
    }

    new price = FUEL_CAN_AMOUNT * Vehicles_GetShopPrice(VEHICLE_SHOP_GAS), line[96];
    format(line, sizeof(line), "* You filled your Gas Can with 20%% Fuel for $%d", price);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, line);
    Fuel_SetCan(playerid, FUEL_CAN_AMOUNT);
    Account_SetCash(playerid, Account_GetCash(playerid) - price);
    return true;
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
public Fuel_FillTimer()
{
    foreach (new playerid : Player)
    {
        if (!IsPlayerNPC(playerid))
        {
            Fuel_RefillPlayer(playerid);
        }
    }

    return 1;
}
