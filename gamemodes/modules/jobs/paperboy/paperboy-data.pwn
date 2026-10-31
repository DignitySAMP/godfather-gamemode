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
#define PAPERBOY_NEAR_RANGE (8.0)
#define PAPERBOY_ACCEPT_RANGE (5.0)

static bool:s_PaperboyBringing[MAX_PLAYERS];
static s_PaperboyOffer[MAX_PLAYERS];

forward Paperboy_Accept(playerid,const params[]);
forward Paperboy_Cancel(playerid,const params[]);
forward Paperboy_IsPaperBoy(playerid);

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

stock Paperboy_SetBringing(playerid,bool:isBringing)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_PaperboyBringing[playerid] = isBringing;
    }
}

stock bool:Paperboy_IsAtBuilding(playerid)
{
    return Property_IsNear(playerid,NEWS_BUILDING_RADIUS,NEWS_BUILDING_X,NEWS_BUILDING_Y,NEWS_BUILDING_Z);
}

static Paperboy_Clear(playerid)
{
    s_PaperboyBringing[playerid] = false;
    s_PaperboyOffer[playerid] = OFFER_NONE;
}

static Paperboy_Deliver(playerid,const params[])
{
    if (!Jobs_Is(playerid,JOB_PAPERBOY))
    {
        return 1;
    }

    if (!s_PaperboyBringing[playerid])
    {
        SendClientMessage(playerid,COLOR_GREY,"   You haven't picked up a Newspaper from the News Reporters Building yet !");
        return 1;
    }

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /deliver [playerid/PartOfName]");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,PAPERBOY_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You offered one of your Newspapers to %s.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* Paper Boy %s wants to give you a Newspaper (use /accept paper, to accept).",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    s_PaperboyOffer[targetid] = playerid;
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
public Paperboy_IsPaperBoy(playerid)
{
    return Jobs_Is(playerid,JOB_PAPERBOY) ? 1 : 0;
}

public Paperboy_Accept(playerid,const params[])
{
    new paperboyid = s_PaperboyOffer[playerid];

    if (paperboyid == OFFER_NONE || paperboyid == OFFER_STALE)
    {
        s_PaperboyOffer[playerid] = OFFER_NONE;
        SendClientMessage(playerid,COLOR_GREY,"   No-one offered you a Newspaper !");
        return 1;
    }

    if (!s_PaperboyBringing[paperboyid])
    {
        return 1;
    }

    if (!Util_IsNear(playerid,paperboyid,PAPERBOY_ACCEPT_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   The Paper Boy is not near you !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], paperboyName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(paperboyid,paperboyName,sizeof(paperboyName));
    format(line,sizeof(line),"* You have accepted a Newspaper from Paper Boy %s (use /read paper, to read).",paperboyName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s has accepted your Newspaper.",name);
    SendClientMessage(paperboyid,COLOR_LIGHTBLUE,line);
    News_GivePaper(playerid,paperboyid);
    s_PaperboyOffer[playerid] = OFFER_NONE;
    return 1;
}

public Paperboy_Cancel(playerid,const params[])
{
    s_PaperboyOffer[playerid] = OFFER_NONE;
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
    Paperboy_Clear(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Offer_Sweep(s_PaperboyOffer,playerid);
    Paperboy_Clear(playerid);
}

hook Account_OnLogout(playerid,accountid)
{
    Paperboy_Clear(playerid);
}

hook Law_OnDeliverPaper(playerid,const params[])
{
    Paperboy_Deliver(playerid,params);
}
