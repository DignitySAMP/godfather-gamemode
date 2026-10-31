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
static License_SendList(viewerid,ownerid)
{
    new line[128];
    format(line, sizeof(line), "** Drivers License: %s.", License_Has(ownerid, LICENSE_CAR) ? ("Passed") : ("Not Passed"));
    SendClientMessage(viewerid, COLOR_GREY, line);
    format(line, sizeof(line), "** Flying License: %s.", License_Has(ownerid, LICENSE_FLY) ? ("Passed") : ("Not Passed"));
    SendClientMessage(viewerid, COLOR_GREY, line);
    format(line, sizeof(line), "** Sailing License: %s.", License_Has(ownerid, LICENSE_BOAT) ? ("Passed") : ("Not Passed"));
    SendClientMessage(viewerid, COLOR_GREY, line);
    format(line, sizeof(line), "** Fishing License: %s.", License_Has(ownerid, LICENSE_FISH) ? ("Passed") : ("Not Passed"));
    SendClientMessage(viewerid, COLOR_GREY, line);
    format(line, sizeof(line), "** Weapon License: %s.", License_Has(ownerid, LICENSE_GUN) ? ("Passed") : ("Not Passed"));
    SendClientMessage(viewerid, COLOR_GREY, line);
}

CMD:licenses(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid, COLOR_WHITE, "|__________________ Licenses __________________|");
    License_SendList(playerid, playerid);
    SendClientMessage(playerid, COLOR_WHITE, "|______________________________________________|");
    return 1;
}

CMD:showlicenses(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;

    if (sscanf(params, "u", targetid))
    {
        SendClientMessage(playerid, COLOR_WHITE, "USAGE: /showlicenses [playerid/PartOfName]");
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
        SendClientMessage(playerid, COLOR_GREY, "You cannot Show Licenses to yourself, use /licenses!");
        return 1;
    }

    new line[128], name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof(name));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    format(line, sizeof(line), "|__________ Licenses of %s __________|", name);
    SendClientMessage(targetid, COLOR_WHITE, line);
    License_SendList(targetid, playerid);
    format(line, sizeof(line), "* %s has shown his Licenses to you.", name);
    SendClientMessage(targetid, COLOR_LIGHTBLUE, line);
    format(line, sizeof(line), "* You have shown your Licenses to %s.", targetName);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, line);
    return 1;
}
