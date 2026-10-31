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
#define GOVERNMENT_GOV_RANK (5)
#define GOVERNMENT_TAX_MAX (5000)
#define GOVERNMENT_TAX_VAULT_SHARE (2)

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
static Government_CountCops()
{
    new count = 0;

    foreach (new playerid : Player)
    {
        if (Factions_GetTeam(playerid) == TEAM_BLUE && Factions_GetMember(playerid) == FACTION_POLICE)
        {
            count++;
        }
    }

    return count;
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
CMD:government(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (Factions_GetTeam(playerid) != TEAM_BLUE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Cop !");
        return 1;
    }

    if (Factions_GetRank(playerid) < GOVERNMENT_GOV_RANK)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You need to be Rank 5 to be able to use this !");
        return 1;
    }

    new text[FACTION_TEXT_LEN];
    Util_ReadRest(params,0,text);

    if (text[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/gov)ernment [text]");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], line[FACTION_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    SendClientMessageToAll(COLOR_WHITE,"|___________ Government News Announcement ___________|");
    format(line,sizeof(line),"Officer %s: %s",name,text);
    SendClientMessageToAll(COLOR_DBLUE,line);
    return 1;
}

ALT:gov=CMD:government;

CMD:settax(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (Factions_GetLeader(playerid) != FACTION_MAYOR)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not the Mayor !");
        return 1;
    }

    new amountText[16];

    if (sscanf(params,"s[16]",amountText))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /settax [amount]");
        return 1;
    }

    new amount = strval(amountText);

    if (amount < 1 || amount > GOVERNMENT_TAX_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Tax may not be below 1 or above 5000 !");
        return 1;
    }

    Payday_SetTaxValue(amount);

    new line[64];
    format(line,sizeof(line),"* The Tax is $%d per player, from now on.",Payday_GetTaxValue());
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    return 1;
}

CMD:givetax(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Factions_GetLeader(playerid) != FACTION_MAYOR)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not the Mayor !");
        return 1;
    }

    if (Payday_GetTaxPool() < 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   There is no Money left in the Tax Vault !");
        return 1;
    }

    new cops = Government_CountCops();

    if (cops < 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   There are no Cops Online at the moment !");
        return 1;
    }

    new price = Payday_GetTaxPool() / GOVERNMENT_TAX_VAULT_SHARE / cops, line[96];

    foreach (new targetid : Player)
    {
        if (Factions_GetTeam(targetid) == TEAM_BLUE && Factions_GetMember(targetid) == FACTION_POLICE)
        {
            format(line,sizeof(line),"* You received $%d from the Tax Vault from the Mayor.",price);
            SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
            Account_SetCash(targetid,Account_GetCash(targetid) + price);
            Payday_SetTaxPool(Payday_GetTaxPool() - price);
        }
    }

    return 1;
}
