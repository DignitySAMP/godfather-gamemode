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
#define NEWS_LIVE_RANGE (5.0)

static s_NewsLiveOffer[MAX_PLAYERS];
static s_NewsLiveTalking[MAX_PLAYERS];

forward News_LiveAccept(playerid,const params[]);
forward News_LiveCancel(playerid,const params[]);
forward News_ChatLive(playerid,const text[]);

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

stock News_SetLiveOffer(playerid,reporterid)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_NewsLiveOffer[playerid] = reporterid;
    }
}

stock News_GetLivePartner(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return INVALID_PLAYER_ID;
    }

    return s_NewsLiveTalking[playerid];
}

stock bool:News_IsTalkingLive(playerid)
{
    return News_GetLivePartner(playerid) != INVALID_PLAYER_ID;
}

stock News_EndLive(playerid)
{
    new partner = News_GetLivePartner(playerid);

    SendClientMessage(playerid,COLOR_LIGHTBLUE,"* Live Conversation ended.");

    if (Util_IsValidPlayer(partner))
    {
        SendClientMessage(partner,COLOR_LIGHTBLUE,"* Live Conversation ended.");
        TogglePlayerControllable(partner,true);
        s_NewsLiveTalking[partner] = INVALID_PLAYER_ID;
    }

    TogglePlayerControllable(playerid,true);
    s_NewsLiveTalking[playerid] = INVALID_PLAYER_ID;
}

static News_ResetLive(playerid)
{
    s_NewsLiveOffer[playerid] = OFFER_NONE;
    s_NewsLiveTalking[playerid] = INVALID_PLAYER_ID;
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
public News_LiveAccept(playerid,const params[])
{
    new reporterid = s_NewsLiveOffer[playerid];

    if (reporterid == OFFER_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   No-one gave you a Live Conversation offer !");
        return 1;
    }

    if (!Util_IsValidPlayer(reporterid))
    {
        return 1;
    }

    if (!Util_IsNear(playerid,reporterid,NEWS_LIVE_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are too far away from the News Reporter !");
        return 1;
    }

    SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You are frozen till the Live Conversation ends.");
    SendClientMessage(reporterid,COLOR_LIGHTBLUE,"* You are frozen till the Live Conversation ends (use /live again).");
    TogglePlayerControllable(playerid,false);
    TogglePlayerControllable(reporterid,false);
    s_NewsLiveTalking[playerid] = reporterid;
    s_NewsLiveTalking[reporterid] = playerid;
    s_NewsLiveOffer[playerid] = OFFER_NONE;
    return 1;
}

public News_LiveCancel(playerid,const params[])
{
    s_NewsLiveOffer[playerid] = OFFER_NONE;
    return 1;
}

public News_ChatLive(playerid,const text[])
{
    if (s_NewsLiveTalking[playerid] == INVALID_PLAYER_ID)
    {
        return 0;
    }

    new line[NEWS_TEXT_LEN], name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));

    if (Jobs_Is(playerid,JOB_NEWS))
    {
        format(line,sizeof(line),"LiveNR %s: %s",name,text);
    }
    else
    {
        format(line,sizeof(line),"LivePlayer %s: %s",name,text);
    }

    News_Send(COLOR_LIGHTGREEN,line);
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
    News_ResetLive(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    new partner = s_NewsLiveTalking[playerid];

    if (Util_IsValidPlayer(partner) && partner != playerid)
    {
        SendClientMessage(partner,COLOR_LIGHTBLUE,"* Live Conversation ended.");
        TogglePlayerControllable(partner,true);
        s_NewsLiveTalking[partner] = INVALID_PLAYER_ID;
    }

    Offer_Sweep(s_NewsLiveOffer,playerid);
    News_ResetLive(playerid);
}

hook Account_OnLogout(playerid,accountid)
{
    if (s_NewsLiveTalking[playerid] != INVALID_PLAYER_ID)
    {
        News_EndLive(playerid);
    }

    News_ResetLive(playerid);
}
