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
CMD:dropcar(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Jobs_Is(playerid,JOB_CARJACKER))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Car Jacker !");
        return 1;
    }

    if (Jobs_IsOnMission(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   On a mission right now, can't use this command !");
        return 1;
    }

    if (Carjacker_GetTime(playerid) != 0)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You already Dropped a car, wait till your reload time is over !");
        return 1;
    }

    GameTextForPlayer(playerid,"~w~Car Selling ~n~~r~Drop the car at the Crane",5000,1);
    Carjacker_StartDrop(playerid);
    return 1;
}
