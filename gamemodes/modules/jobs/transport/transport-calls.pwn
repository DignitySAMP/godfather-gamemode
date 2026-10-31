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
static const s_TransportRoles[TRANSPORT_KINDS][8] =
{
    "Taxi",
    "Bus"
};

static const s_TransportCommands[TRANSPORT_KINDS][8] =
{
    "taxi",
    "bus"
};

forward Transport_ServiceTaxi(playerid,const params[]);
forward Transport_ServiceBus(playerid,const params[]);
forward Transport_AcceptTaxi(playerid,const params[]);
forward Transport_AcceptBus(playerid,const params[]);
forward Transport_CancelTaxi(playerid,const params[]);
forward Transport_CancelBus(playerid,const params[]);

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
static Transport_SendTaxiCompany(const text[])
{
    foreach (new targetid : Player)
    {
        if (Factions_IsIn(targetid,FACTION_TAXI) && Chat_IsFamilyEnabled(targetid))
        {
            SendClientMessage(targetid,TEAM_AZTECAS_COLOR,text);
        }
    }
}

static Transport_Service(playerid,kind)
{
    new line[TRANSPORT_LINE_LEN], name[MAX_PLAYER_NAME + 1];

    if (g_TransportDrivers[kind] < 1)
    {
        format(line,sizeof(line),"   There are no %s Drivers On Duty at the moment, try again later !",s_TransportRoles[kind]);
        SendClientMessage(playerid,COLOR_GREY,line);
        return;
    }

    if (g_TransportDuty[playerid] > 0)
    {
        format(line,sizeof(line),"   You can't call for a %s now !",s_TransportRoles[kind]);
        SendClientMessage(playerid,COLOR_GREY,line);
        return;
    }

    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"** %s is in need of a %s Driver. (use /accept %s to accept the call)",name,s_TransportRoles[kind],s_TransportCommands[kind]);

    if (kind == TRANSPORT_TAXI)
    {
        Transport_SendTaxiCompany(line);
    }
    else
    {
        Jobs_SendJobMessage(JOB_BUS,TEAM_AZTECAS_COLOR,line);
    }

    format(line,sizeof(line),"* You have called for a %s Driver, wait for a reply.",s_TransportRoles[kind]);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    g_TransportCaller[kind] = playerid;
}

static Transport_Accept(playerid,kind)
{
    new line[TRANSPORT_LINE_LEN];

    if (g_TransportDuty[playerid] != kind + 1)
    {
        format(line,sizeof(line),"   You are not a %s Driver !",s_TransportRoles[kind]);
        SendClientMessage(playerid,COLOR_GREY,line);
        return;
    }

    if (g_TransportCallTime[kind][playerid] > 0)
    {
        format(line,sizeof(line),"   You have already accepted a %s Call !",s_TransportRoles[kind]);
        SendClientMessage(playerid,COLOR_GREY,line);
        return;
    }

    if (Jobs_IsOnMission(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   On a mission right now, can't use this command !");
        return;
    }

    new callerid = g_TransportCaller[kind];

    if (callerid == OFFER_NONE || callerid == OFFER_STALE)
    {
        g_TransportCaller[kind] = OFFER_NONE;
        format(line,sizeof(line),"   No-one called for a %s yet !",s_TransportRoles[kind]);
        SendClientMessage(playerid,COLOR_GREY,line);
        return;
    }

    new name[MAX_PLAYER_NAME + 1], callerName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(callerid,callerName,sizeof(callerName));
    format(line,sizeof(line),"* You have accepted the %s Call from %s, you will see the marker until you have reached it.",s_TransportRoles[kind],callerName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s Driver %s has accepted your %s Call please wait at your current Position.",s_TransportRoles[kind],name,s_TransportRoles[kind]);
    SendClientMessage(callerid,COLOR_LIGHTBLUE,line);

    if (kind == TRANSPORT_BUS)
    {
        new Float:x, Float:y, Float:z;
        GetPlayerPos(callerid,x,y,z);
        SetPlayerCheckpoint(playerid,x,y,z,TRANSPORT_CHECKPOINT_SIZE);
    }

    format(line,sizeof(line),"~w~%s Caller~n~~r~Goto redmarker",s_TransportRoles[kind]);
    Property_GameText(playerid,line,5000,1);
    g_TransportCallTime[kind][playerid] = 1;
    g_TransportAccepted[kind][playerid] = callerid;
    g_TransportCaller[kind] = OFFER_NONE;
}

static Transport_Cancel(playerid,kind)
{
    if (g_TransportDuty[playerid] == kind + 1 && g_TransportCallTime[kind][playerid] > 0)
    {
        g_TransportAccepted[kind][playerid] = OFFER_NONE;
        Property_GameText(playerid,"~w~You have~n~~r~Canceled the call",5000,1);
        g_TransportCallTime[kind][playerid] = 0;
        DisablePlayerCheckpoint(playerid);
        return;
    }

    if (g_TransportCaller[kind] == playerid)
    {
        g_TransportCaller[kind] = OFFER_NONE;
    }

    new line[48];
    format(line,sizeof(line),"~w~%s Caller~n~~r~Canceled the call",s_TransportRoles[kind]);

    foreach (new driverid : Player)
    {
        if (g_TransportAccepted[kind][driverid] == playerid)
        {
            g_TransportAccepted[kind][driverid] = OFFER_NONE;
            Property_GameText(driverid,line,5000,1);
            g_TransportCallTime[kind][driverid] = 0;
            DisablePlayerCheckpoint(driverid);
        }
    }
}

stock Transport_FollowCaller(playerid)
{
    for (new kind = 0;kind < TRANSPORT_KINDS;kind++)
    {
        if (g_TransportCallTime[kind][playerid] <= 0)
        {
            continue;
        }

        new callerid = g_TransportAccepted[kind][playerid];

        if (Util_IsValidPlayer(callerid))
        {
            new Float:x, Float:y, Float:z;
            GetPlayerPos(callerid,x,y,z);
            SetPlayerCheckpoint(playerid,x,y,z,TRANSPORT_CHECKPOINT_SIZE);
        }
    }
}

stock Transport_ReachCaller(playerid)
{
    for (new kind = 0;kind < TRANSPORT_KINDS;kind++)
    {
        if (g_TransportCallTime[kind][playerid] > 0 && g_TransportAccepted[kind][playerid] != OFFER_NONE)
        {
            g_TransportAccepted[kind][playerid] = OFFER_NONE;
            Property_GameText(playerid,"~w~Reached destination",5000,1);
            g_TransportCallTime[kind][playerid] = 0;
            DisablePlayerCheckpoint(playerid);
            return;
        }
    }
}

static Transport_DropCaller(leaving)
{
    new line[48];

    for (new kind = 0;kind < TRANSPORT_KINDS;kind++)
    {
        if (g_TransportCaller[kind] == leaving)
        {
            g_TransportCaller[kind] = OFFER_STALE;
        }

        format(line,sizeof(line),"~w~%s Caller~n~~r~Left the game",s_TransportRoles[kind]);

        foreach (new driverid : Player)
        {
            if (driverid != leaving && g_TransportAccepted[kind][driverid] == leaving)
            {
                g_TransportAccepted[kind][driverid] = OFFER_NONE;
                Property_GameText(driverid,line,5000,1);
                g_TransportCallTime[kind][driverid] = 0;
                DisablePlayerCheckpoint(driverid);
            }
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
public Transport_ServiceTaxi(playerid,const params[])
{
    Transport_Service(playerid,TRANSPORT_TAXI);
    return 1;
}

public Transport_ServiceBus(playerid,const params[])
{
    Transport_Service(playerid,TRANSPORT_BUS);
    return 1;
}

public Transport_AcceptTaxi(playerid,const params[])
{
    Transport_Accept(playerid,TRANSPORT_TAXI);
    return 1;
}

public Transport_AcceptBus(playerid,const params[])
{
    Transport_Accept(playerid,TRANSPORT_BUS);
    return 1;
}

public Transport_CancelTaxi(playerid,const params[])
{
    Transport_Cancel(playerid,TRANSPORT_TAXI);
    return 1;
}

public Transport_CancelBus(playerid,const params[])
{
    Transport_Cancel(playerid,TRANSPORT_BUS);
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

hook OnPlayerDisconnect(playerid,reason)
{
    Transport_DropCaller(playerid);
}

hook OnPlayerEnterCheckpoint(playerid)
{
    Transport_ReachCaller(playerid);
}

hook Tick_OnPlayerSecond(playerid)
{
    Transport_FollowCaller(playerid);
}

hook Vehicles_OnGateCheck(playerid,vehicleid,gate)
{
    if (gate == VEHICLE_GATE_BUS && Jobs_Is(playerid,JOB_BUS))
    {
        Vehicles_GateAllow(playerid);
    }
}
