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
CMD:enter(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new doorid = Doors_FindEntrance(playerid);

    if (doorid != INVALID_DOOR_ID)
    {
        Doors_Enter(playerid,doorid);
    }

    return 1;
}

CMD:exit(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new doorid = Doors_FindExit(playerid);

    if (doorid != INVALID_DOOR_ID)
    {
        Doors_Leave(playerid,doorid);
    }

    if (Vehicles_ReleaseDriver(playerid) || doorid != INVALID_DOOR_ID)
    {
        return 1;
    }

    pawn_call_public("Doors_OnExitUnhandled","d",playerid);
    return 1;
}

CMD:open(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new doorid = Doors_FindOpenable(playerid);

    if (doorid != INVALID_DOOR_ID)
    {
        Doors_Open(playerid,doorid);
    }

    return 1;
}
