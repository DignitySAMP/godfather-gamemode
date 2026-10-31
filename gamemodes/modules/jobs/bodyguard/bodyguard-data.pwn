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
static s_BodyguardOffer[MAX_PLAYERS];
static s_BodyguardPrice[MAX_PLAYERS];

forward Bodyguard_Accept(playerid,const params[]);
forward Bodyguard_Cancel(playerid,const params[]);

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

static Bodyguard_Reset(playerid)
{
    s_BodyguardOffer[playerid] = OFFER_NONE;
    s_BodyguardPrice[playerid] = 0;
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
CMD:guard(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Jobs_Is(playerid,JOB_BODYGUARD))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Bodyguard!");
        return 1;
    }

    new targetid, priceText[16], price;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /guard [playerid/PartOfName] [price]");
        return 1;
    }

    if (sscanf(params,"{u}s[16]",priceText))
    {
        return 1;
    }

    if (!Jobs_ReadPrice(priceText,price))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Price not lower than 1, or above 99999!");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is offline!");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,JOBS_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can't offer protection to yourself !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You offered protection to %s for $%d.",targetName,price);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* Bodyguard %s wants to protect you for $%d, (type /accept bodyguard) to accept.",name,price);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    s_BodyguardOffer[targetid] = playerid;
    s_BodyguardPrice[targetid] = price;
    return 1;
}

/**
 *                        __  __  __                            __
 *                       |  \|  \|  \                          |  |
 *      _______  ______  | $$| $$| $$____    ______    _______ | $$   __   _______
 *     /       \|      \ | $$| $$| $$    \  |      \  /       \| $$  /  \ /       |
 *    |  $$$$$$$ \$$$$$$\| $$| $$| $$$$$$$\  \$$$$$$\|  $$$$$$$| $$_/  $$|  $$$$$$$
 *    | $$      /      $$| $$| $$| $$  | $$ /      $$| $$      | $$   $$  \$$    |
 *    | $$_____|  $$$$$$$| $$| $$| $$__/ $$|  $$$$$$$| $$_____ | $$$$$$\  _\$$$$$$|
 *     \$$     \\$$    $$| $$| $$| $$    $$ \$$    $$ \$$     \| $$  \$$\|       $$
 *      \$$$$$$$ \$$$$$$$ \$$ \$$ \$$$$$$$   \$$$$$$$  \$$$$$$$ \$$   \$$ \$$$$$$$
 *
 */
public Bodyguard_Accept(playerid,const params[])
{
    new guardid = s_BodyguardOffer[playerid], price = s_BodyguardPrice[playerid];

    if (guardid == OFFER_NONE || guardid == OFFER_STALE)
    {
        s_BodyguardOffer[playerid] = OFFER_NONE;
        SendClientMessage(playerid,COLOR_GREY,"   No-one offered you any Protection !");
        return 1;
    }

    if (Account_GetCash(playerid) < price)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You can't afford the Protection !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], guardName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(guardid,guardName,sizeof(guardName));
    format(line,sizeof(line),"* You accepted the Protection for $%d from Bodyguard %s.",price,guardName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s accepted your Protection, and the $%d was added to your PayCheck.",name,price);
    SendClientMessage(guardid,COLOR_LIGHTBLUE,line);
    Payday_AddPaycheck(guardid,price);
    Account_SetCash(playerid,Account_GetCash(playerid) - price);
    Bodyguard_Reset(playerid);
    return 1;
}

public Bodyguard_Cancel(playerid,const params[])
{
    Bodyguard_Reset(playerid);
    return 1;
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

hook OnPlayerConnect(playerid)
{
    Bodyguard_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Offer_Sweep(s_BodyguardOffer,playerid);
    Bodyguard_Reset(playerid);
}
