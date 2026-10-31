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
#define DOORS_LEAK_MAX_Z (600.0)

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
stock bool:Doors_Rescue(playerid)
{
    new local = Account_GetLocal(playerid), doorid = Doors_FindByLocal(local);

    if (doorid != INVALID_DOOR_ID)
    {
        new Float:x, Float:y, Float:z;
        Doors_GetEntrance(doorid,x,y,z);
        SetPlayerInterior(playerid,0);
        Doors_ResetWorld(playerid);
        SetPlayerPos(playerid,x,y,z);
        Account_SetLocal(playerid,DOOR_LOCAL_OUTSIDE);
        Account_SetInterior(playerid,0);
        return true;
    }

    Log_Warn("doors","player %d fell out of the unknown place %d, sent to the spawn point",playerid,local);

    new Float:x, Float:y, Float:z, Float:angle, interior;
    Spawn_GetDefaultPoint(Account_GetOrigin(playerid),x,y,z,angle,interior);
    SetPlayerInterior(playerid,interior);
    Doors_ResetWorld(playerid);
    SetPlayerPos(playerid,x,y,z);
    Account_SetLocal(playerid,DOOR_LOCAL_OUTSIDE);
    Account_SetInterior(playerid,interior);
    return false;
}

stock bool:Doors_HasLeaked(playerid)
{
    if (Account_GetLocal(playerid) == DOOR_LOCAL_OUTSIDE || Account_GetInterior(playerid) == 0)
    {
        return false;
    }

    new doorid = Doors_FindByLocal(Account_GetLocal(playerid));

    if (doorid != INVALID_DOOR_ID)
    {
        new Float:exitX, Float:exitY, Float:exitZ;
        Doors_GetExit(doorid,exitX,exitY,exitZ);

        if (exitZ < DOORS_LEAK_MAX_Z)
        {
            return false;
        }
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    return z != 0.0 && z < DOORS_LEAK_MAX_Z;
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

hook Spawn_OnChoose(playerid)
{
    Doors_ResetWorld(playerid);
}

hook Tick_OnPlayerSecond(playerid)
{
    if (Player_IsReady(playerid) && Doors_HasLeaked(playerid))
    {
        Doors_Rescue(playerid);
    }
}
