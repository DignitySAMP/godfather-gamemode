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
static Instructor_ToggleSchoolSpawn(playerid)
{
    if (Factions_GetSchoolSpawn(playerid) == 0)
    {
        Factions_SetSchoolSpawn(playerid,1);
        SendClientMessage(playerid,COLOR_GREY,"   You will now spawn at the Flying School !");
    }
    else if (Factions_GetSchoolSpawn(playerid) == 1)
    {
        Factions_SetSchoolSpawn(playerid,0);
        SendClientMessage(playerid,COLOR_GREY,"   You will now spawn at the Driving School !");
    }
}

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
CMD:spawnchange(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Houses_GetKey(playerid) == HOUSE_NO_KEY)
    {
        if (Factions_IsInstructor(playerid))
        {
            Instructor_ToggleSchoolSpawn(playerid);
        }
        else
        {
            SendClientMessage(playerid,COLOR_GREY,"   You don't own / rent a House !");
        }

        return 1;
    }

    if (Staff_IsSpectating(playerid) && Account_GetAdminLevel(playerid) < 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are Spectating, can't change the Spawn right now !");
        return 1;
    }

    if (Houses_GetSpawnAtHome(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You will now spawn at your Normal Place !");
        Houses_SetSpawnAtHome(playerid,false);

        if (Factions_IsInstructor(playerid))
        {
            Instructor_ToggleSchoolSpawn(playerid);
        }
    }
    else
    {
        SendClientMessage(playerid,COLOR_GREY,"   You will now spawn at your Own / Rented House !");
        Houses_SetSpawnAtHome(playerid,true);
    }

    return 1;
}
