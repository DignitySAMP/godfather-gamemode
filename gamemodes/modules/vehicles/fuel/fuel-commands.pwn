/**
 *                                   __
 *                                  |  |
 *      _______  ______ ____    ____| $$  _______
 *     /       \|      \    \  /      $$ /       |
 *    |  $$$$$$$| $$$$$$\$$$$\|  $$$$$$$|  $$$$$$$
 *    | $$      | $$ | $$ | $$| $$  | $$ \$$    |
 *    | $$_____ | $$ | $$ | $$| $$__| $$ _\$$$$$$|
 *     \$$     \| $$ | $$ | $$ \$$    $$|       $$
 *      \$$$$$$$ \$$  \$$  \$$  \$$$$$$$ \$$$$$$$
 *
 */
CMD:speedo(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (g_PlayerSpeedo[playerid] == FUEL_SPEEDO_OFF)
    {
        Fuel_SetSpeedometer(playerid, FUEL_SPEEDO_ON);
        GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~g~on", 5000, 5);
        PlayerPlaySound(playerid, FUEL_SOUND_TOGGLE, 0.0, 0.0, 0.0);
    }
    else if (g_PlayerSpeedo[playerid] == FUEL_SPEEDO_ON)
    {
        Fuel_SetSpeedometer(playerid, FUEL_SPEEDO_OFF);
        GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~r~off", 5000, 5);
        PlayerPlaySound(playerid, FUEL_SOUND_TOGGLE, 0.0, 0.0, 0.0);
    }
    else
    {
        SendClientMessage(playerid, COLOR_GRAD1, "you don't have a speedometer");
    }

    return 1;
}

CMD:fuel(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!g_PlayerFuelInfo[playerid])
    {
        g_PlayerFuelInfo[playerid] = true;
        GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~g~Fuel Info on", 5000, 5);
        PlayerPlaySound(playerid, FUEL_SOUND_TOGGLE, 0.0, 0.0, 0.0);
    }
    else
    {
        g_PlayerFuelInfo[playerid] = false;
        GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~r~Fuel Info off", 5000, 5);
        PlayerPlaySound(playerid, FUEL_SOUND_TOGGLE, 0.0, 0.0, 0.0);
    }

    return 1;
}

CMD:fill(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Fuel_IsAtGasStation(playerid))
    {
        SendClientMessage(playerid, COLOR_GREY, "   You're not at a Gas Station!");
        return 1;
    }

    GameTextForPlayer(playerid, "~w~~n~~n~~n~~n~~n~~n~~n~~n~~n~Re-Fueling Vehicle, please wait", 2000, 3);
    SetTimer("Fuel_FillTimer", FUEL_REFUEL_MS, false);
    g_PlayerRefueling[playerid] = true;
    return 1;
}

CMD:fillcar(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Fuel_GetCan(playerid) <= 0)
    {
        SendClientMessage(playerid, COLOR_GREY, "   You have no Fuel left in your Gas Can !");
        return 1;
    }

    new vehicleid = Vehicles_GetLastCar(playerid);

    if (g_VehicleGas[vehicleid] >= FUEL_CAN_LIMIT)
    {
        SendClientMessage(playerid, COLOR_GREY, "   Your Car still got enough Fuel to drive with !");
        return 1;
    }

    SendClientMessage(playerid, COLOR_LIGHTBLUE, "   You filled your car with 20 percent Fuel from your Gas Can.");
    g_VehicleGas[vehicleid] += FUEL_CAN_AMOUNT;
    Fuel_SetCan(playerid, 0);
    return 1;
}
