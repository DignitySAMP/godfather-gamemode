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
    Factions_SetPredicate(FACTION_PREDICATE_IS_PAINTBALLING,"Paintball_IsPlaying");
    Paintball_ResetRound();
    Paintball_StartTicker();
}

hook OnPlayerConnect(playerid)
{
    Paintball_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Paintball_Leave(playerid);
}

hook Account_OnLogout(playerid,accountid)
{
    Paintball_Leave(playerid);
}

hook Business_OnSpecialEntered(playerid,sbiz)
{
    if (sbiz == SBIZ_PAINTBALL)
    {
        Paintball_Join(playerid);
    }
}

hook Death_OnPaintballKill(playerid,killerid)
{
    Paintball_CountKill(killerid);
}

hook Spawn_OnChoose(playerid)
{
    if (Paintball_IsPaintballing(playerid))
    {
        new Float:x, Float:y, Float:z;
        Paintball_PickSpawn(x,y,z);
        Spawn_SetPoint(playerid,x,y,z,0.0,0,SPAWN_PRIORITY_PAINTBALL);
    }
}

hook OnPlayerSpawn(playerid)
{
    Paintball_ArmSpawned(playerid);
}
