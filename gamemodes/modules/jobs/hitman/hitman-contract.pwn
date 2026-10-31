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
#define HITMAN_CONTRACT_MIN (10000)
#define HITMAN_CONTRACT_MAX (100000)
#define HITMAN_CONTRACT_MIN_LEVEL (3)
#define HITMAN_SOUND_DONE (1052)

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
stock Hitman_Search(playerid)
{
    foreach (new targetid : Player)
    {
        if (Hitman_GetHeadValue(targetid) > 0 && !Hitman_HasHit(targetid) && Factions_GetMember(targetid) != FACTION_HITMAN)
        {
            new line[JOBS_LINE_LEN], name[MAX_PLAYER_NAME + 1];
            GetPlayerName(targetid,name,sizeof(name));
            Hitman_SetFound(true,targetid);

            foreach (new hitmanid : Player)
            {
                if (Factions_IsIn(hitmanid,FACTION_HITMAN))
                {
                    SendClientMessage(hitmanid,COLOR_WHITE,"|__________________ Hitman Agency News __________________|");
                    SendClientMessage(hitmanid,COLOR_DBLUE,"*** Incoming Message: A Hit has become available. ***");
                    format(line,sizeof(line),"Person: %s   ID: %d   Value: $%d",name,targetid,Hitman_GetHeadValue(targetid));
                    SendClientMessage(hitmanid,COLOR_DBLUE,line);
                    SendClientMessage(hitmanid,COLOR_YELLOW,"Use Givehit hitmanid, to assign the Contract to one of the Hitmans.");
                    SendClientMessage(hitmanid,COLOR_WHITE,"|________________________________________________________|");
                }
            }

            return;
        }
    }

    SendClientMessage(playerid,COLOR_GREY,"   No Contracts available !");
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
CMD:contract(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid, amountText[16];

    if (sscanf(params,"us[16]",targetid,amountText))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /contract [playerid/PartOfName] [amount]");
        return 1;
    }

    new amount = strval(amountText);

    if (amount < HITMAN_CONTRACT_MIN || amount > HITMAN_CONTRACT_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Contract money must be at least $10000, and not more than $100000!");
        return 1;
    }

    if (Account_GetLevel(playerid) < HITMAN_CONTRACT_MIN_LEVEL)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"You must be level 3 to place a Contract.");
        return 1;
    }

    new line[JOBS_LINE_LEN];

    if (!Util_IsValidPlayer(targetid))
    {
        new typed[MAX_PLAYER_NAME + 1];
        Util_FirstWord(params,typed);
        format(line,sizeof(line),"   %s is not an active player.",typed);
        SendClientMessage(playerid,COLOR_GRAD1,line);
        return 1;
    }

    if (Factions_GetMember(playerid) == FACTION_HITMAN && Factions_IsIn(targetid,FACTION_HITMAN))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Cannot place Contracts on your own Agency!");
        return 1;
    }

    if (Factions_IsIn(targetid,FACTION_HITMAN))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can't contract a Hitman !");
        return 1;
    }

    if (Factions_GetTeam(targetid) == TEAM_BLUE && amount != HITMAN_CONTRACT_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Only $100000 can be placed as a Contract on Cops !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"You cannot Contract yourself!");
        return 1;
    }

    if (Account_GetCash(playerid) < amount)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   Invalid transaction amount.");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    Account_SetCash(playerid,Account_GetCash(playerid) - amount);
    Hitman_SetHeadValue(targetid,Hitman_GetHeadValue(targetid) + amount);
    format(line,sizeof(line),"%s has placed a contract on %s, for $%d.",name,targetName,amount);
    Hitman_SendAgency(COLOR_YELLOW,line);
    format(line,sizeof(line),"* You placed a contract on %s, for $%d.",targetName,amount);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    PlayerPlaySound(playerid,HITMAN_SOUND_DONE,0.0,0.0,0.0);
    return 1;
}
