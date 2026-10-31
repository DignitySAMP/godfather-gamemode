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
CMD:fare(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Factions_IsIn(playerid,FACTION_TAXI) && !Jobs_Is(playerid,JOB_BUS))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Taxi / Bus Driver !");
        return 1;
    }

    if (g_TransportDuty[playerid] > 0)
    {
        Transport_EndDuty(playerid);
        return 1;
    }

    new gates = Vehicles_GetGates(GetPlayerVehicleID(playerid)), kind, maxFare;

    if (gates & VEHICLE_GATE_TAXI)
    {
        kind = TRANSPORT_TAXI;
        maxFare = TRANSPORT_TAXI_FARE_MAX;
    }
    else if (gates & VEHICLE_GATE_BUS)
    {
        kind = TRANSPORT_BUS;
        maxFare = TRANSPORT_BUS_FARE_MAX;
    }
    else
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not in a Taxi / Bus !");
        return 1;
    }

    if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not the Driver !");
        return 1;
    }

    new fareText[16];

    if (sscanf(params,"s[16]",fareText))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /fare [price]");
        return 1;
    }

    new fare = strval(fareText);

    if (fare < 1 || fare > maxFare)
    {
        new line[TRANSPORT_LINE_LEN];
        format(line,sizeof(line),"   Fare price must be between $1 and $%d !",maxFare);
        SendClientMessage(playerid,COLOR_GREY,line);
        return 1;
    }

    Transport_StartDuty(playerid,kind,fare);
    return 1;
}
