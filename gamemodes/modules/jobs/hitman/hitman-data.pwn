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
#define HITMAN_LOADER "hitman"
#define HITMAN_NEWS_SLOTS (5)
#define HITMAN_NEWS_LEN (128)
#define HITMAN_NEWS_EMPTY "Nothing"
#define HITMAN_NEWS_NOBODY "No-one"
#define HITMAN_NONE (INVALID_PLAYER_ID)

static s_HitmanHeadValue[MAX_PLAYERS];
static bool:s_HitmanLoaded[MAX_PLAYERS];
static bool:s_HitmanGotHit[MAX_PLAYERS];
static s_HitmanChase[MAX_PLAYERS];
static s_HitmanChased[MAX_PLAYERS];
static s_HitmanOrder[MAX_PLAYERS];
static bool:s_HitmanPlacedNews[MAX_PLAYERS];

static bool:s_HitmanHitFound;
static s_HitmanHitId = HITMAN_NONE;

static bool:s_HitmanNewsTaken[HITMAN_NEWS_SLOTS];
static s_HitmanNewsText[HITMAN_NEWS_SLOTS][HITMAN_NEWS_LEN];
static s_HitmanNewsContact[HITMAN_NEWS_SLOTS][HITMAN_NEWS_LEN];

forward Hitman_LoadStart(playerid,accountid,token);

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
stock Hitman_GetHeadValue(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_HitmanHeadValue[playerid] : 0;
}

stock bool:Hitman_SetHeadValue(playerid,value)
{
    if (!Util_IsValidPlayer(playerid) || !s_HitmanLoaded[playerid])
    {
        return false;
    }

    s_HitmanHeadValue[playerid] = value;

    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_hitman SET head_value = %d WHERE account_id = %d",value,accountid));
    }

    return true;
}

stock bool:Hitman_HasHit(playerid)
{
    return Util_IsValidPlayer(playerid) && s_HitmanGotHit[playerid];
}

stock Hitman_SetHit(playerid,bool:hasHit)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_HitmanGotHit[playerid] = hasHit;
    }
}

stock Hitman_GetChase(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_HitmanChase[playerid] : HITMAN_NONE;
}

stock Hitman_SetChase(playerid,targetid)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_HitmanChase[playerid] = targetid;
    }
}

stock Hitman_SetChased(playerid,hitmanid)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_HitmanChased[playerid] = hitmanid;
    }
}

stock Hitman_GetOrder(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_HitmanOrder[playerid] : 0;
}

stock Hitman_SetOrder(playerid,package)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_HitmanOrder[playerid] = package;
    }
}

stock bool:Hitman_HasPlacedNews(playerid)
{
    return Util_IsValidPlayer(playerid) && s_HitmanPlacedNews[playerid];
}

stock Hitman_SetPlacedNews(playerid,bool:hasPlaced)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_HitmanPlacedNews[playerid] = hasPlaced;
    }
}

stock bool:Hitman_IsHitFound()
{
    return s_HitmanHitFound;
}

stock Hitman_GetFoundId()
{
    return s_HitmanHitId;
}

stock Hitman_SetFound(bool:isFound,hitid)
{
    s_HitmanHitFound = isFound;
    s_HitmanHitId = hitid;
}

stock bool:Hitman_IsNewsTaken(slot)
{
    return slot >= 0 && slot < HITMAN_NEWS_SLOTS && s_HitmanNewsTaken[slot];
}

stock Hitman_GetNewsText(slot,dest[],size = sizeof(dest))
{
    if (slot < 0 || slot >= HITMAN_NEWS_SLOTS)
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_HitmanNewsText[slot],size);
}

stock Hitman_GetNewsContact(slot,dest[],size = sizeof(dest))
{
    if (slot < 0 || slot >= HITMAN_NEWS_SLOTS)
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_HitmanNewsContact[slot],size);
}

stock Hitman_PlaceNews(slot,const text[],const contact[])
{
    if (slot < 0 || slot >= HITMAN_NEWS_SLOTS)
    {
        return;
    }

    strcopy(s_HitmanNewsText[slot],text,HITMAN_NEWS_LEN);
    strcopy(s_HitmanNewsContact[slot],contact,HITMAN_NEWS_LEN);
    s_HitmanNewsTaken[slot] = true;
}

stock Hitman_ClearNews(slot)
{
    if (slot < 0 || slot >= HITMAN_NEWS_SLOTS)
    {
        return;
    }

    if (s_HitmanNewsTaken[slot])
    {
        foreach (new playerid : Player)
        {
            if (s_HitmanPlacedNews[playerid] && !strcmp(Util_GetPlayerName(playerid),s_HitmanNewsContact[slot]))
            {
                s_HitmanPlacedNews[playerid] = false;
            }
        }
    }

    strcopy(s_HitmanNewsText[slot],HITMAN_NEWS_EMPTY,HITMAN_NEWS_LEN);
    strcopy(s_HitmanNewsContact[slot],HITMAN_NEWS_NOBODY,HITMAN_NEWS_LEN);
    s_HitmanNewsTaken[slot] = false;
}

stock Hitman_SendAgency(colour,const text[])
{
    foreach (new playerid : Player)
    {
        if (Factions_IsIn(playerid,FACTION_HITMAN) && Chat_IsFamilyEnabled(playerid))
        {
            SendClientMessage(playerid,colour,text);
        }
    }
}

static Hitman_Clear(playerid)
{
    s_HitmanHeadValue[playerid] = 0;
    s_HitmanLoaded[playerid] = false;
    s_HitmanGotHit[playerid] = false;
    s_HitmanChase[playerid] = HITMAN_NONE;
    s_HitmanChased[playerid] = HITMAN_NONE;
    s_HitmanOrder[playerid] = 0;
    s_HitmanPlacedNews[playerid] = false;
}

static Hitman_ReleaseChaser(playerid)
{
    if (!s_HitmanGotHit[playerid] || s_HitmanChased[playerid] == HITMAN_NONE)
    {
        return;
    }

    new chaser = s_HitmanChased[playerid];

    if (IsPlayerConnected(chaser))
    {
        SendClientMessage(chaser,COLOR_YELLOW,"Your Hit has left the server.");
        s_HitmanChase[chaser] = HITMAN_NONE;
    }
}

static Hitman_ReleaseVictim(playerid)
{
    new victim = s_HitmanChase[playerid];

    if (victim == HITMAN_NONE || !IsPlayerConnected(victim))
    {
        return;
    }

    if (s_HitmanChased[victim] == playerid)
    {
        s_HitmanGotHit[victim] = false;
        s_HitmanChased[victim] = HITMAN_NONE;
    }
}

static Hitman_Payout(victimid,killerid)
{
    if (s_HitmanHeadValue[victimid] <= 0 || !Util_IsValidPlayer(killerid))
    {
        return;
    }

    if (Factions_GetTeam(killerid) != TEAM_HIT && Factions_GetLeader(killerid) != FACTION_HITMAN)
    {
        return;
    }

    if (s_HitmanChase[killerid] != victimid)
    {
        return;
    }

    new line[JOBS_LINE_LEN], killerName[MAX_PLAYER_NAME + 1], victimName[MAX_PLAYER_NAME + 1], reward = s_HitmanHeadValue[victimid];
    GetPlayerName(killerid,killerName,sizeof(killerName));
    GetPlayerName(victimid,victimName,sizeof(victimName));
    Account_SetCash(killerid,Account_GetCash(killerid) + reward);
    format(line,sizeof(line),"<< Hitman %s has fulfilled the contract on %s and collected $%d >>",killerName,victimName,reward);
    Hitman_SendAgency(COLOR_YELLOW,line);
    Hitman_SetHeadValue(victimid,0);
    s_HitmanGotHit[victimid] = false;
    s_HitmanChased[victimid] = HITMAN_NONE;
    s_HitmanChase[killerid] = HITMAN_NONE;
}

static Hitman_ResetBoard()
{
    for (new slot = 0;slot < HITMAN_NEWS_SLOTS;slot++)
    {
        strcopy(s_HitmanNewsText[slot],HITMAN_NEWS_EMPTY,HITMAN_NEWS_LEN);
        strcopy(s_HitmanNewsContact[slot],HITMAN_NEWS_NOBODY,HITMAN_NEWS_LEN);
        s_HitmanNewsTaken[slot] = false;
    }
}

static Hitman_Load(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT head_value FROM player_hitman WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("hitman","row load failed for player %d",playerid);
        return;
    }

    new value = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"head_value",value);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO player_hitman (account_id) VALUES (%d)",accountid));
    }

    s_HitmanHeadValue[playerid] = value;
    s_HitmanLoaded[playerid] = true;
    Player_LoaderDone(playerid,HITMAN_LOADER,token);
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
public Hitman_LoadStart(playerid,accountid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Hitman_Load(playerid,accountid,token);
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

hook OnGameModeInit()
{
    Hitman_ResetBoard();
    Hitman_SetFound(false,HITMAN_NONE);
}

hook OnPlayerConnect(playerid)
{
    Hitman_Clear(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Hitman_ReleaseChaser(playerid);
    Hitman_ReleaseVictim(playerid);
    Hitman_Clear(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    SetTimerEx("Hitman_LoadStart",0,false,"ddd",playerid,accountid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Hitman_ReleaseChaser(playerid);
    Hitman_ReleaseVictim(playerid);
    Hitman_Clear(playerid);
}

hook Death_OnKilled(playerid,killerid,reason)
{
    Hitman_Payout(playerid,killerid);
}
