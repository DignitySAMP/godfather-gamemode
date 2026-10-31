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
#define PLAYER_LOADERS_MAX (31)
#define PLAYER_LOADER_NAME_LEN (32)

static s_PlayerLoaderNames[PLAYER_LOADERS_MAX][PLAYER_LOADER_NAME_LEN];
static bool:s_PlayerLoaderActive[PLAYER_LOADERS_MAX];
static s_PlayerLoaderCount;

static s_PlayerLoadDone[MAX_PLAYERS];
static s_PlayerLoadToken[MAX_PLAYERS];
static s_PlayerLoadAccount[MAX_PLAYERS];
static bool:s_PlayerLoading[MAX_PLAYERS];
static bool:s_PlayerReady[MAX_PLAYERS];
static s_PlayerNextToken;

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
stock Player_FindLoader(const name[])
{
    for (new i = 0;i < s_PlayerLoaderCount;i++)
    {
        if (s_PlayerLoaderActive[i] && !strcmp(s_PlayerLoaderNames[i],name,true))
        {
            return i;
        }
    }

    return -1;
}

stock Player_GetFullMask()
{
    new mask = 0;

    for (new i = 0;i < s_PlayerLoaderCount;i++)
    {
        if (s_PlayerLoaderActive[i])
        {
            mask |= (1 << i);
        }
    }

    return mask;
}

stock bool:Player_RegisterLoader(const name[])
{
    if (Player_FindLoader(name) != -1)
    {
        return true;
    }

    new slot = -1;

    for (new i = 0;i < s_PlayerLoaderCount;i++)
    {
        if (!s_PlayerLoaderActive[i])
        {
            slot = i;
            break;
        }
    }

    if (slot == -1)
    {
        if (s_PlayerLoaderCount >= PLAYER_LOADERS_MAX)
        {
            Log_Error("player","no room for loader %s: raise PLAYER_LOADERS_MAX, players would never become ready",name);
            return false;
        }

        slot = s_PlayerLoaderCount++;
    }

    strcopy(s_PlayerLoaderNames[slot],name,PLAYER_LOADER_NAME_LEN);
    s_PlayerLoaderActive[slot] = true;
    return true;
}

bool:Player_IsReady(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_PlayerReady[playerid] && IsPlayerConnected(playerid);
}

stock Player_GetLoadToken(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return 0;
    }

    return s_PlayerLoadToken[playerid];
}

stock Player_GetLoadAccount(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return 0;
    }

    return s_PlayerLoadAccount[playerid];
}

static Player_ClearLoad(playerid)
{
    s_PlayerLoadToken[playerid] = ++s_PlayerNextToken;
    s_PlayerLoadDone[playerid] = 0;
    s_PlayerLoadAccount[playerid] = 0;
    s_PlayerLoading[playerid] = false;
    s_PlayerReady[playerid] = false;
}

static Player_CheckReady(playerid)
{
    if (!s_PlayerLoading[playerid] || s_PlayerReady[playerid])
    {
        return;
    }

    new full = Player_GetFullMask();

    if ((s_PlayerLoadDone[playerid] & full) != full)
    {
        return;
    }

    s_PlayerLoading[playerid] = false;
    s_PlayerReady[playerid] = true;
    pawn_call_public("Player_OnReady","d",playerid);
}

stock Player_BeginLoad(playerid,accountid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid))
    {
        return 0;
    }

    Player_ClearLoad(playerid);
    s_PlayerLoading[playerid] = true;
    s_PlayerLoadAccount[playerid] = accountid;
    SetTimerEx("Player_FireLogin",0,false,"dd",playerid,s_PlayerLoadToken[playerid]);
    return s_PlayerLoadToken[playerid];
}

stock Player_EndSession(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return;
    }

    Player_ClearLoad(playerid);
}

stock bool:Player_LoaderDone(playerid,const name[],token)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid))
    {
        return false;
    }

    if (!s_PlayerLoading[playerid] || token != s_PlayerLoadToken[playerid])
    {
        return false;
    }

    new slot = Player_FindLoader(name);

    if (slot == -1)
    {
        Log_Warn("player","loader %s reported done but is not registered",name);
        return false;
    }

    s_PlayerLoadDone[playerid] |= (1 << slot);
    Player_CheckReady(playerid);
    return true;
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
forward Player_OnReady(playerid);

public Player_OnReady(playerid)
{
    return 1;
}

forward Player_FireLogin(playerid,token);

public Player_FireLogin(playerid,token)
{
    if (!IsPlayerConnected(playerid) || !s_PlayerLoading[playerid] || token != s_PlayerLoadToken[playerid])
    {
        return 1;
    }

    pawn_call_public("Account_OnLogin","dd",playerid,s_PlayerLoadAccount[playerid]);

    if (IsPlayerConnected(playerid) && token == s_PlayerLoadToken[playerid])
    {
        Player_CheckReady(playerid);
    }

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
    Player_ClearLoad(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    s_PlayerLoadToken[playerid] = ++s_PlayerNextToken;
    s_PlayerLoading[playerid] = false;
}
