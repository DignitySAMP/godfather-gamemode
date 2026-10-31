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

hook OnGameModeInit()
{
    Karting_ResetRound();
    Karting_StartTicker();
}

hook OnPlayerConnect(playerid)
{
    Karting_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Karting_Leave(playerid);
}

hook Account_OnLogout(playerid,accountid)
{
    Karting_Leave(playerid);
}

hook Business_OnSpecialEntered(playerid,sbiz)
{
    if (sbiz == SBIZ_KARTING)
    {
        Karting_Join(playerid);
    }
}

hook Vehicles_OnDriverEnter(playerid,vehicleid)
{
    if (Karting_IsJoined(playerid) && (Vehicles_GetGates(vehicleid) & VEHICLE_GATE_KART))
    {
        Karting_EnterKart(playerid);
    }
}

hook Vehicles_OnGateCheck(playerid,vehicleid,gate)
{
    if (gate == VEHICLE_GATE_KART && Karting_IsJoined(playerid))
    {
        Vehicles_GateAllow(playerid);
    }
}

hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    if (newstate == PLAYER_STATE_ONFOOT)
    {
        Karting_LeaveKart(playerid);
    }
}

hook OnPlayerEnterCheckpoint(playerid)
{
    Karting_ReachCheckpoint(playerid);
}
