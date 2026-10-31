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
#define CALL_MEDIC (0)
#define CALL_MECHANIC (1)
#define CALL_COUNT (2)
#define CALL_SECONDS (30)
#define CALL_SOUND (1056)
#define CALL_CHECKPOINT_SIZE (5.0)

static s_CallCaller[CALL_COUNT] = {OFFER_NONE, OFFER_NONE};
static s_CallTime[CALL_COUNT][MAX_PLAYERS];

static const s_CallLabels[CALL_COUNT][16] =
{
    "Medic",
    "Mechanic"
};

static const s_CallRoles[CALL_COUNT][16] =
{
    "Medic",
    "Car Mechanic"
};

static const s_CallCommands[CALL_COUNT][16] =
{
    "medic",
    "mechanic"
};

static const s_CallGameTexts[CALL_COUNT][40] =
{
    "~w~Medic Caller~n~~r~Goto redmarker",
    "~w~Mechanic Caller~n~~r~Goto redmarker"
};

forward Jobs_ServiceMedic(playerid,const params[]);
forward Jobs_AcceptMedic(playerid,const params[]);
forward Jobs_CancelMedic(playerid,const params[]);

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

static Calls_Reset(playerid)
{
    for (new kind = 0;kind < CALL_COUNT;kind++)
    {
        s_CallTime[kind][playerid] = 0;
    }
}

static Calls_Drop(leaving)
{
    for (new kind = 0;kind < CALL_COUNT;kind++)
    {
        if (s_CallCaller[kind] == leaving)
        {
            s_CallCaller[kind] = OFFER_STALE;
        }
    }
}

stock Calls_Request(playerid,kind,onDuty)
{
    new line[JOBS_LINE_LEN], name[MAX_PLAYER_NAME + 1];

    if (onDuty < 1)
    {
        format(line,sizeof(line),"   There are no %ss On Duty at the moment, try again later !",s_CallRoles[kind]);
        SendClientMessage(playerid,COLOR_GREY,line);
        return;
    }

    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"** %s is in need of a %s. (use /accept %s to accept the call)",name,s_CallRoles[kind],s_CallCommands[kind]);

    if (kind == CALL_MEDIC)
    {
        Factions_SendRadio(FACTION_MEDICS,TEAM_AZTECAS_COLOR,line);
    }
    else
    {
        Jobs_SendJobMessage(JOB_MECHANIC,TEAM_AZTECAS_COLOR,line);
    }

    format(line,sizeof(line),"* You have called for a %s, wait for a reply.",s_CallRoles[kind]);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    s_CallCaller[kind] = playerid;
}

stock Calls_Accept(playerid,kind)
{
    new line[JOBS_LINE_LEN];

    if (s_CallTime[kind][playerid] > 0)
    {
        format(line,sizeof(line),"   You have already accepted a %s Call !",s_CallLabels[kind]);
        SendClientMessage(playerid,COLOR_GREY,line);
        return;
    }

    if (Jobs_IsOnMission(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   On a mission right now, can't use this command !");
        return;
    }

    new callerid = s_CallCaller[kind];

    if (callerid == OFFER_NONE || callerid == OFFER_STALE)
    {
        s_CallCaller[kind] = OFFER_NONE;
        format(line,sizeof(line),"   No-one called for a %s yet !",s_CallRoles[kind]);
        SendClientMessage(playerid,COLOR_GREY,line);
        return;
    }

    new name[MAX_PLAYER_NAME + 1], callerName[MAX_PLAYER_NAME + 1], Float:x, Float:y, Float:z;
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(callerid,callerName,sizeof(callerName));
    format(line,sizeof(line),"* You have accepted the %s Call from %s, you have 30 Seconds to get there.",s_CallLabels[kind],callerName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,"* After the 30 Seconds the Red Marker will disappear.");
    format(line,sizeof(line),"* %s %s has accepted your %s Call please wait at your current Position.",s_CallRoles[kind],name,s_CallLabels[kind]);
    SendClientMessage(callerid,COLOR_LIGHTBLUE,line);
    GetPlayerPos(callerid,x,y,z);
    SetPlayerCheckpoint(playerid,x,y,z,CALL_CHECKPOINT_SIZE);
    GameTextForPlayer(playerid,s_CallGameTexts[kind],5000,1);
    s_CallTime[kind][playerid] = 1;
    s_CallCaller[kind] = OFFER_NONE;
}

stock Calls_Cancel(playerid,kind)
{
    new callerid = s_CallCaller[kind];

    if (Util_IsValidPlayer(callerid))
    {
        if (callerid == playerid)
        {
            s_CallCaller[kind] = OFFER_NONE;
        }
        else
        {
            SendClientMessage(playerid,COLOR_GREY,"   You are not the current Caller !");
            return 0;
        }
    }

    return 1;
}

static Calls_Countdown(playerid,kind)
{
    if (s_CallTime[kind][playerid] <= 0)
    {
        return;
    }

    if (s_CallTime[kind][playerid] == CALL_SECONDS)
    {
        s_CallTime[kind][playerid] = 0;
        DisablePlayerCheckpoint(playerid);
        PlayerPlaySound(playerid,CALL_SOUND,0.0,0.0,0.0);
        GameTextForPlayer(playerid,"~r~RedMarker gone",2500,1);
        return;
    }

    new text[8];
    format(text,sizeof(text),"%d",CALL_SECONDS - s_CallTime[kind][playerid]);
    GameTextForPlayer(playerid,text,1500,6);
    s_CallTime[kind][playerid]++;
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
public Jobs_ServiceMedic(playerid,const params[])
{
    Calls_Request(playerid,CALL_MEDIC,Medics_GetOnDutyCount());
    return 1;
}

public Jobs_AcceptMedic(playerid,const params[])
{
    if (!Factions_IsIn(playerid,FACTION_MEDICS))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Medic !");
        return 1;
    }

    Calls_Accept(playerid,CALL_MEDIC);
    return 1;
}

public Jobs_CancelMedic(playerid,const params[])
{
    return Calls_Cancel(playerid,CALL_MEDIC);
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
    Calls_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Calls_Reset(playerid);
    Calls_Drop(playerid);
}

hook Tick_OnPlayerSecond(playerid)
{
    for (new kind = 0;kind < CALL_COUNT;kind++)
    {
        Calls_Countdown(playerid,kind);
    }
}
