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
    Law_SetSafeCheck("Death_IsSafe");
}

hook OnPlayerConnect(playerid)
{
    Death_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Death_Reset(playerid);
}

hook OnPlayerSpawn(playerid)
{
    if (!IsPlayerNPC(playerid) && Player_IsReady(playerid))
    {
        Death_SetSafeTime(playerid,DEATH_SAFE_SECONDS);
    }
}

hook Tick_OnPlayerSecond(playerid)
{
    Death_Tick(playerid);
}

hook OnPlayerDeath(playerid,killerid,WEAPON:reason)
{
    if (!IsPlayerNPC(playerid) && Player_IsReady(playerid))
    {
        Death_Process(playerid,killerid,_:reason);
    }
}
