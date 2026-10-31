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
forward bool:Phone_HasPhoneBook(playerid);
forward Phone_GetNumber(playerid);

CMD:number(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Phone_HasPhoneBook(playerid))
    {
        SendClientMessage(playerid, COLOR_GRAD1, "   You do not have a PhoneBook !");
        return 1;
    }

    new targetid;

    if (sscanf(params, "u", targetid))
    {
        SendClientMessage(playerid, COLOR_GRAD1, "USAGE: /number [playerid/PartOfName]");
        return 1;
    }

    if (targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid, COLOR_GRAD1, "   No Such Player !");
        return 1;
    }

    new line[128];
    format(line, sizeof(line), "Name: %s, Ph: %d", Util_GetPlayerName(targetid), Phone_GetNumber(targetid));
    SendClientMessage(playerid, COLOR_GRAD1, line);
    return 1;
}

CMD:dice(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Misc_HasDice(playerid))
    {
        SendClientMessage(playerid, COLOR_GRAD2, "   You Don't Have A Dice");
        return 1;
    }

    new line[128], dice = random(6) + 1;
    format(line, sizeof(line), "* %s Throws a Dice that lands on %d", Util_GetPlayerName(playerid), dice);
    Chat_ProxDetector(MISC_DICE_RANGE, playerid, line, TEAM_GREEN_COLOR, TEAM_GREEN_COLOR, TEAM_GREEN_COLOR, TEAM_GREEN_COLOR, TEAM_GREEN_COLOR);
    return 1;
}

CMD:fixr(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Misc_FixRadio(playerid);
    return 1;
}

CMD:time(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Misc_ShowTime(playerid);
    return 1;
}

CMD:id(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;

    if (sscanf(params, "u", targetid))
    {
        SendClientMessage(playerid, COLOR_GRAD2, "USAGE: /id [playerid/PartOfName]");
        return 1;
    }

    if (targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid))
    {
        return 1;
    }

    new line[128];
    format(line, sizeof(line), "ID: (%d) %s", targetid, Util_GetPlayerName(targetid));
    SendClientMessage(playerid, COLOR_GRAD1, line);
    return 1;
}

CMD:uncon(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    SetPlayerPos(playerid, MISC_UNCON_X, MISC_UNCON_Y, MISC_UNCON_Z);
    SetPlayerInterior(playerid, MISC_UNCON_INTERIOR);
    SetPlayerVirtualWorld(playerid, 0);
    return 1;
}

CMD:cam(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new text[32];

    if (sscanf(params, "s[32]", text))
    {
        SendClientMessage(playerid, COLOR_GRAD2, "USAGE: /cam [1/2/3/4]");
        return 1;
    }

    Misc_SetCam(playerid, strval(text));

    new line[64];
    format(line, sizeof(line), "Switching to cam %d", Misc_GetCam(playerid));
    SendClientMessage(playerid, COLOR_GRAD1, line);
    return 1;
}

CMD:stopani(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    ClearAnimations(playerid);
    return 1;
}

CMD:frisk(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;

    if (sscanf(params, "u", targetid))
    {
        SendClientMessage(playerid, COLOR_WHITE, "USAGE: /frisk [playerid/PartOfName]");
        return 1;
    }

    if (targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid, COLOR_GREY, "   That player is Offline !");
        return 1;
    }

    if (!Util_IsNear(playerid, targetid, MISC_NEAR_RANGE))
    {
        SendClientMessage(playerid, COLOR_GREY, "   That player is not near you !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid, COLOR_GREY, "You cannot Frisk yourself!");
        return 1;
    }

    Misc_ShowFrisk(playerid, targetid);
    return 1;
}
