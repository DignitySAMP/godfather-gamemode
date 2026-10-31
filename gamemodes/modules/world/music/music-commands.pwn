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
CMD:music(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Music_HasCdPlayer(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You don't have a CD-Player !");
        return 1;
    }

    new option[32];

    if (sscanf(params,"s[32]",option))
    {
        SendClientMessage(playerid,COLOR_WHITE,"|__________________ Music __________________|");
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /music [name]");
        SendClientMessage(playerid,COLOR_GREY,"Available names: On, Off, Next");
        SendClientMessage(playerid,COLOR_WHITE,"|___________________________________________|");
        return 1;
    }

    if (!strcmp(option,"on",true))
    {
        GameTextForPlayer(playerid,"~n~~n~~n~~n~~n~~n~~n~~g~CD Player On",5000,5);
        Music_PlayCurrent(playerid);
    }
    else if (!strcmp(option,"off",true))
    {
        GameTextForPlayer(playerid,"~n~~n~~n~~n~~n~~n~~n~~r~CD Player Off",5000,5);
        Misc_FixRadio(playerid);
    }
    else if (!strcmp(option,"next",true))
    {
        Music_NextTrack(playerid);
    }
    else
    {
        SendClientMessage(playerid,COLOR_GREY,"   Unknown music command !");
    }

    return 1;
}
