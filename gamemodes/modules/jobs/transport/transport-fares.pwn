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
static Transport_Announce(const text[])
{
    foreach (new targetid : Player)
    {
        if (!IsPlayerNPC(targetid) && Chat_IsNewsEnabled(targetid))
        {
            SendClientMessage(targetid,TEAM_GROVE_COLOR,text);
        }
    }
}

stock Transport_StartDuty(playerid,kind,fare)
{
    new name[MAX_PLAYER_NAME + 1], line[TRANSPORT_LINE_LEN];
    g_TransportDrivers[kind]++;
    g_TransportDuty[playerid] = kind + 1;
    g_TransportValue[playerid] = fare;
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),kind == TRANSPORT_TAXI ? ("Taxi Driver %s is On Duty, fare: $%d.") : ("Bus Driver %s is On Duty, fare: $%d."),name,fare);
    Transport_Announce(line);
}

stock Transport_EndDuty(playerid)
{
    new kind = g_TransportDuty[playerid] - 1, line[TRANSPORT_LINE_LEN];

    if (kind < 0 || kind >= TRANSPORT_KINDS)
    {
        return;
    }

    g_TransportDrivers[kind]--;
    g_TransportDuty[playerid] = 0;
    format(line,sizeof(line),"* You are now Off Duty and earned $%d.",g_TransportMoney[playerid]);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    Account_SetCash(playerid,Account_GetCash(playerid) + g_TransportMoney[playerid]);
    g_TransportValue[playerid] = 0;
    g_TransportMoney[playerid] = 0;
}

static Transport_Credit(driverid,passengerid,bool:leftTheGame)
{
    new owed = g_TransportCost[passengerid] - g_TransportPaid[passengerid], line[TRANSPORT_LINE_LEN];

    if (owed < 0)
    {
        owed = 0;
    }

    g_TransportMoney[driverid] += owed;
    g_TransportTime[driverid] = 0;
    g_TransportCost[driverid] = 0;

    if (leftTheGame)
    {
        format(line,sizeof(line),"~w~Passenger left~n~~g~Earned $%d",g_TransportCost[passengerid]);
        Property_GameText(driverid,line,5000,1);
        return owed;
    }

    format(line,sizeof(line),"~w~The ride cost~n~~r~$%d",g_TransportCost[passengerid]);
    Property_GameText(passengerid,line,5000,1);
    format(line,sizeof(line),"~w~Passenger left the taxi~n~~g~Earned $%d",g_TransportCost[passengerid]);
    Property_GameText(driverid,line,5000,1);
    Account_SetCash(passengerid,Account_GetCash(passengerid) - owed);
    return owed;
}

static Transport_ClearRide(playerid)
{
    g_TransportCost[playerid] = 0;
    g_TransportTime[playerid] = 0;
    g_TransportPaid[playerid] = 0;
    g_TransportDriver[playerid] = OFFER_NONE;
}

stock Transport_PassengerLeave(playerid)
{
    if (g_TransportCost[playerid] <= 0 || g_TransportDriver[playerid] == OFFER_NONE)
    {
        return;
    }

    new driverid = g_TransportDriver[playerid];

    if (Util_IsValidPlayer(driverid))
    {
        Transport_Credit(driverid,playerid,false);
    }

    Transport_ClearRide(playerid);
}

stock Transport_PassengerEnter(playerid,vehicleid)
{
    new name[MAX_PLAYER_NAME + 1], line[TRANSPORT_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));

    foreach (new driverid : Player)
    {
        if (g_TransportDuty[driverid] <= 0 || !IsPlayerInVehicle(driverid,vehicleid) || GetPlayerState(driverid) != PLAYER_STATE_DRIVER)
        {
            continue;
        }

        new value = g_TransportValue[driverid];

        if (Account_GetCash(playerid) < value)
        {
            format(line,sizeof(line),"* You need $%d to enter.",value);
            SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
            RemovePlayerFromVehicle(playerid);
            continue;
        }

        if (g_TransportDuty[driverid] == 1)
        {
            format(line,sizeof(line),"* You paid $%d to the Taxi Driver.",value);
            SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
            format(line,sizeof(line),"* Passenger %s has entered your Taxi.",name);
            SendClientMessage(driverid,COLOR_LIGHTBLUE,line);
            g_TransportTime[driverid] = 1;
            g_TransportTime[playerid] = 1;
            g_TransportCost[playerid] = value;
            g_TransportCost[driverid] = value;
            g_TransportPaid[playerid] = value;
            g_TransportDriver[playerid] = driverid;
        }
        else if (g_TransportDuty[driverid] == 2)
        {
            format(line,sizeof(line),"* You paid $%d to the Bus Driver.",value);
            SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
            format(line,sizeof(line),"* Passenger %s has entered your Bus.",name);
            SendClientMessage(driverid,COLOR_LIGHTBLUE,line);
        }

        Account_SetCash(playerid,Account_GetCash(playerid) - value);
        g_TransportMoney[driverid] += value;
    }
}

stock Transport_MeterTick(playerid)
{
    if (g_TransportTime[playerid] <= 0)
    {
        return;
    }

    if (g_TransportTime[playerid] >= TRANSPORT_METER_SECONDS)
    {
        g_TransportTime[playerid] = 1;

        new driverid = g_TransportDriver[playerid];

        if (Util_IsValidPlayer(driverid))
        {
            g_TransportCost[playerid] += g_TransportValue[driverid];
            g_TransportCost[driverid] = g_TransportCost[playerid];
        }
    }

    g_TransportTime[playerid]++;

    new line[TRANSPORT_LINE_LEN];
    format(line,sizeof(line),"~r~%d ~w~: ~g~$%d",g_TransportTime[playerid],g_TransportCost[playerid]);
    Property_GameText(playerid,line,TRANSPORT_METER_MS,6);
}

stock Transport_Leave(playerid)
{
    if (g_TransportDuty[playerid] > 0)
    {
        Transport_EndDuty(playerid);
    }

    Transport_PassengerLeave(playerid);
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

hook OnPlayerStateChange(playerid,PLAYER_STATE:newstate,PLAYER_STATE:oldstate)
{
    if (newstate == PLAYER_STATE_ONFOOT)
    {
        Transport_Leave(playerid);
    }
    else if (newstate == PLAYER_STATE_PASSENGER)
    {
        Transport_PassengerEnter(playerid,GetPlayerVehicleID(playerid));
    }
}

hook OnPlayerDisconnect(playerid,reason)
{
    if (g_TransportCost[playerid] > 0 && g_TransportDriver[playerid] != OFFER_NONE && Util_IsValidPlayer(g_TransportDriver[playerid]))
    {
        Transport_Credit(g_TransportDriver[playerid],playerid,true);
    }

    if (g_TransportDuty[playerid] > 0)
    {
        g_TransportDrivers[g_TransportDuty[playerid] - 1]--;
    }

    Offer_Sweep(g_TransportDriver,playerid);
    Transport_Reset(playerid);
}

hook Tick_OnPlayerSecond(playerid)
{
    Transport_MeterTick(playerid);
}
