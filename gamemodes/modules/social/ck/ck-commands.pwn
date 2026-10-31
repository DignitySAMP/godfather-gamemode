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
#define CK_TOKEN_LEN (64)

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
static bool:Ck_ReadSlot(playerid,const params[],&at,const usage[],&slot)
{
    new token[CK_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,usage);
        return false;
    }

    slot = strval(token);

    if (slot < 1 || slot > CK_SLOTS)
    {
        SendClientMessage(playerid,COLOR_GREY,"   CK Number can't be below 1 or above 10 !");
        return false;
    }

    slot -= 1;
    return true;
}

static Ck_RunList(playerid)
{
    new line[CK_LINE_LEN], sender[CK_NAME_LEN], target[CK_NAME_LEN];

    for (new slot = 0;slot < CK_SLOTS;slot++)
    {
        if (Ck_IsUsed(slot))
        {
            Ck_GetSender(slot,sender);
            Ck_GetTarget(slot,target);
            format(line,sizeof(line),"%d| %s wants to Character Kill %s.",slot + 1,sender,target);
            SendClientMessage(playerid,COLOR_WHITE,line);
        }
    }
}

static Ck_RunAccept(playerid,const params[],&at)
{
    new slot;

    if (!Ck_ReadSlot(playerid,params,at,"USAGE: /cks accept [cknumber]",slot))
    {
        return;
    }

    new killerid, victimid;

    if (!Ck_Accept(slot,killerid,victimid))
    {
        SendClientMessage(playerid,COLOR_YELLOW2,"Sorry, the Killer or Victim ain't Online.");
        return;
    }

    new name[MAX_PLAYER_NAME + 1], line[CK_LINE_LEN];
    GetPlayerName(victimid,name,sizeof(name));
    format(line,sizeof(line),"* An Admin has accepted your Character Kill, you can now perform your kill on %s.",name);
    SendClientMessage(killerid,COLOR_LIGHTBLUE,line);
}

static Ck_RunDelete(playerid,const params[],&at)
{
    new slot;

    if (!Ck_ReadSlot(playerid,params,at,"USAGE: /cks delete [cknumber]",slot))
    {
        return;
    }

    Ck_Clear(slot);

    new line[CK_LINE_LEN];
    format(line,sizeof(line),"* You've cleared Character Kill nr: %d",slot + 1);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
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
CMD<ADMIN_LEVEL_ADMIN>:cks(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, option[CK_TOKEN_LEN];

    if (!Util_ReadToken(params,at,option))
    {
        Ck_RunList(playerid);
        return 1;
    }

    if (!strcmp(option,"accept",true))
    {
        Ck_RunAccept(playerid,params,at);
    }
    else if (!strcmp(option,"delete",true))
    {
        Ck_RunDelete(playerid,params,at);
    }
    else
    {
        SendClientMessage(playerid,COLOR_GREY,"   Invalid CK command name !");
    }

    return 1;
}

CMD:ck(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (Account_GetLevel(playerid) < CK_MIN_LEVEL)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You must be Level 5 in order to request a Character Kill !");
        return 1;
    }

    new at = 0, token[CK_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /ck [playerid/PartOfName]");
        return 1;
    }

    new targetid = INVALID_PLAYER_ID;

    if (sscanf(token,"u",targetid) || targetid == INVALID_PLAYER_ID || !Util_IsValidPlayer(targetid) || IsPlayerNPC(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    if (Account_GetAdminLevel(targetid) >= 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can't perform Character Kills on Admins !");
        return 1;
    }

    if (Account_GetLevel(targetid) < CK_MIN_LEVEL)
    {
        SendClientMessage(playerid,COLOR_GREY,"   The Player you want to Character Kill must be Level 5 !");
        return 1;
    }

    Staff_SendAdmins(COLOR_YELLOW,"* A New Character Kill request has come in, use /cks.",3);

    if (Ck_Request(playerid,targetid) == -1)
    {
        SendClientMessage(playerid,COLOR_YELLOW2,"Sorry, all the Character Kill Slots are used, try again later.");
    }
    else
    {
        SendClientMessage(playerid,COLOR_YELLOW2,"Your Character Kill Request has been added to the list, you'll hear from an Admin soon.");
    }

    return 1;
}
