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
#define BOXING_LOADER "boxing"
#define BOXING_BOOT_LOADER "Boxing_LoadOnBoot"
#define BOXING_NAME_LEN (24)
#define BOXING_GYM_RADIUS (20.0)
#define BOXING_NEAR_RANGE (8.0)
#define BOXING_START_DELAY (20)
#define BOXING_TITLE_DELAY (60)
#define BOXING_RING_INTERIOR (5)
#define BOXING_LOSS_HEALTH (12.0)
#define BOXING_DIZZY_HEALTH (28.0)
#define BOXING_EXHAUSTED_HEALTH (20.0)
#define BOXING_NON_BOXER_HEALTH (30)

static s_BoxingWins[MAX_PLAYERS];
static s_BoxingLoses[MAX_PLAYERS];
static bool:s_BoxingLoaded[MAX_PLAYERS];
static s_BoxingOffer[MAX_PLAYERS];
static bool:s_BoxingFighting[MAX_PLAYERS];
static s_BoxingWait[MAX_PLAYERS];

static bool:s_BoxingInRing;
static bool:s_BoxingRoundStarted;
static s_BoxingBoxer1 = INVALID_PLAYER_ID;
static s_BoxingBoxer2 = INVALID_PLAYER_ID;
static s_BoxingChampion = INVALID_PLAYER_ID;
static s_BoxingDelay;

static s_BoxingTitleName[BOXING_NAME_LEN];
static s_BoxingTitleWins;
static s_BoxingTitleLoses;

static const s_BoxingHealthTiers[5] = {40, 50, 60, 70, 80};

static const Float:s_BoxingRingPos[2][4] =
{
    {758.7064, -1.8038, 1001.5942, 313.1165},
    {762.9852, 2.4439, 1001.5942, 131.8632}
};

static const Float:s_BoxingExitPos[3] = {765.8433, 3.2924, 1000.7186};

forward Boxing_LoadStart(playerid,accountid,token);
forward Boxing_LoadOnBoot();
forward Boxing_Accept(playerid,const params[]);
forward Boxing_Cancel(playerid,const params[]);
forward Boxing_FightCheck(playerid);

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
stock Boxing_GetWins(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_BoxingWins[playerid] : 0;
}

stock Boxing_GetLoses(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_BoxingLoses[playerid] : 0;
}

static Boxing_Write(playerid)
{
    new accountid = Account_GetId(playerid);

    if (accountid > 0 && s_BoxingLoaded[playerid])
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_boxing SET wins = %d, loses = %d WHERE account_id = %d",s_BoxingWins[playerid],s_BoxingLoses[playerid],accountid));
    }
}

stock bool:Boxing_SetWins(playerid,wins)
{
    if (!Util_IsValidPlayer(playerid) || !s_BoxingLoaded[playerid])
    {
        return false;
    }

    s_BoxingWins[playerid] = wins;
    Boxing_Write(playerid);
    return true;
}

stock bool:Boxing_SetLoses(playerid,loses)
{
    if (!Util_IsValidPlayer(playerid) || !s_BoxingLoaded[playerid])
    {
        return false;
    }

    s_BoxingLoses[playerid] = loses;
    Boxing_Write(playerid);
    return true;
}

stock bool:Boxing_IsFighting(playerid)
{
    return Util_IsValidPlayer(playerid) && s_BoxingFighting[playerid];
}

stock Boxing_SetOffer(playerid,challenger)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_BoxingOffer[playerid] = challenger;
    }
}

stock bool:Boxing_IsRingBusy()
{
    return s_BoxingInRing;
}

stock Boxing_GetTitleName(dest[],size = sizeof(dest))
{
    strcopy(dest,s_BoxingTitleName,size);
}

stock Boxing_GetTitleWins()
{
    return s_BoxingTitleWins;
}

stock Boxing_GetTitleLoses()
{
    return s_BoxingTitleLoses;
}

stock Boxing_GetHealthTier(playerid)
{
    return s_BoxingHealthTiers[Jobs_GetSkillTier(Progress_GetSkill(playerid,PROGRESS_SKILL_BOX))];
}

static Boxing_SaveTitle()
{
    mysql_tquery_s(g_Mysql,str_format("REPLACE INTO boxing_champion (id, wins, name, loses) VALUES (1, %d, '%e', %d)",s_BoxingTitleWins,s_BoxingTitleName,s_BoxingTitleLoses));
}

stock Boxing_SetTitle(const name[],wins,loses)
{
    strcopy(s_BoxingTitleName,name,BOXING_NAME_LEN);
    s_BoxingTitleWins = wins;
    s_BoxingTitleLoses = loses;
    Boxing_SaveTitle();
}

stock bool:Boxing_IsTitleHolder(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return false;
    }

    return !strcmp(s_BoxingTitleName,Util_GetPlayerName(playerid),true);
}

static Boxing_ClearPlayer(playerid)
{
    s_BoxingWins[playerid] = 0;
    s_BoxingLoses[playerid] = 0;
    s_BoxingLoaded[playerid] = false;
    s_BoxingOffer[playerid] = OFFER_NONE;
    s_BoxingFighting[playerid] = false;
    s_BoxingWait[playerid] = 0;
}

static Boxing_ClearRing()
{
    s_BoxingInRing = false;
    s_BoxingRoundStarted = false;
    s_BoxingBoxer1 = INVALID_PLAYER_ID;
    s_BoxingBoxer2 = INVALID_PLAYER_ID;
    s_BoxingChampion = INVALID_PLAYER_ID;
}

static Boxing_SendToExit(playerid)
{
    SetPlayerPos(playerid,s_BoxingExitPos[0],s_BoxingExitPos[1],s_BoxingExitPos[2]);
    SetPlayerInterior(playerid,BOXING_RING_INTERIOR);
}

static Boxing_StartMatch(challenger,accepter)
{
    new challengerName[MAX_PLAYER_NAME + 1], accepterName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(challenger,challengerName,sizeof(challengerName));
    GetPlayerName(accepter,accepterName,sizeof(accepterName));

    new challengerHealth = Boxing_GetHealthTier(challenger), accepterHealth = BOXING_NON_BOXER_HEALTH;

    if (Jobs_Is(accepter,JOB_BOXER))
    {
        accepterHealth = Boxing_GetHealthTier(accepter);
    }

    format(line,sizeof(line),"* You have accepted the Boxing Challenge from %s, and will fight with %d Health.",challengerName,accepterHealth);
    SendClientMessage(accepter,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s has accepted your Boxing Challenge Request, you will fight with %d Health.",accepterName,challengerHealth);
    SendClientMessage(challenger,COLOR_LIGHTBLUE,line);

    SetPlayerHealth(accepter,float(accepterHealth));
    SetPlayerHealth(challenger,float(challengerHealth));
    SetPlayerInterior(accepter,BOXING_RING_INTERIOR);
    SetPlayerInterior(challenger,BOXING_RING_INTERIOR);
    SetPlayerVirtualWorld(accepter,GetPlayerVirtualWorld(challenger));
    SetPlayerPos(accepter,s_BoxingRingPos[1][0],s_BoxingRingPos[1][1],s_BoxingRingPos[1][2]);
    SetPlayerFacingAngle(accepter,s_BoxingRingPos[1][3]);
    SetPlayerPos(challenger,s_BoxingRingPos[0][0],s_BoxingRingPos[0][1],s_BoxingRingPos[0][2]);
    SetPlayerFacingAngle(challenger,s_BoxingRingPos[0][3]);
    TogglePlayerControllable(accepter,false);
    TogglePlayerControllable(challenger,false);
    GameTextForPlayer(accepter,"~r~Waiting",3000,1);
    GameTextForPlayer(challenger,"~r~Waiting",3000,1);

    if (Boxing_IsTitleHolder(accepter))
    {
        format(line,sizeof(line),"Boxing News: Boxing Champion %s will fight VS %s, in 60 seconds (Grove Street Gym).",accepterName,challengerName);
        Chat_SendOoc(COLOR_WHITE,line);
        s_BoxingChampion = accepter;
        s_BoxingDelay = BOXING_TITLE_DELAY;
    }

    if (Boxing_IsTitleHolder(challenger))
    {
        format(line,sizeof(line),"Boxing News: Boxing Champion %s will fight VS %s, in 60 seconds (Grove Street Gym).",challengerName,accepterName);
        Chat_SendOoc(COLOR_WHITE,line);
        s_BoxingChampion = challenger;
        s_BoxingDelay = BOXING_TITLE_DELAY;
    }

    s_BoxingWait[accepter] = 1;
    s_BoxingWait[challenger] = 1;

    if (s_BoxingDelay < 1)
    {
        s_BoxingDelay = BOXING_START_DELAY;
    }

    s_BoxingInRing = true;
    s_BoxingBoxer1 = challenger;
    s_BoxingBoxer2 = accepter;
    s_BoxingFighting[accepter] = true;
    s_BoxingFighting[challenger] = true;
    s_BoxingOffer[accepter] = OFFER_NONE;
}

static Boxing_ApplyChampion(winner,loser)
{
    new champion = s_BoxingChampion;

    if (champion == INVALID_PLAYER_ID || !IsPlayerConnected(champion))
    {
        return;
    }

    new line[JOBS_LINE_LEN], winnerName[MAX_PLAYER_NAME + 1], loserName[MAX_PLAYER_NAME + 1];
    GetPlayerName(winner,winnerName,sizeof(winnerName));
    GetPlayerName(loser,loserName,sizeof(loserName));

    if (champion != winner)
    {
        if (Jobs_Is(winner,JOB_BOXER))
        {
            s_BoxingChampion = winner;
            Boxing_SetTitle(winnerName,s_BoxingWins[winner],s_BoxingLoses[winner]);
            format(line,sizeof(line),"Boxing News: %s has Won the fight against Champion %s and is now the new Boxing Champion.",winnerName,loserName);
            Chat_SendOoc(COLOR_WHITE,line);
        }
        else
        {
            SendClientMessage(winner,COLOR_LIGHTBLUE,"* You would have been the Champion if you had the Boxer Job !");
        }

        return;
    }

    format(line,sizeof(line),"Boxing News: Boxing Champion %s has Won the fight against %s.",winnerName,loserName);
    Chat_SendOoc(COLOR_WHITE,line);
    s_BoxingTitleWins = s_BoxingWins[winner];
    s_BoxingTitleLoses = s_BoxingLoses[winner];
    Boxing_SaveTitle();
}

static Boxing_Recover(boxerid)
{
    new Float:health;
    GetPlayerHealth(boxerid,health);

    if (health < BOXING_EXHAUSTED_HEALTH)
    {
        SendClientMessage(boxerid,COLOR_LIGHTBLUE,"* You feel exhausted from the Fight, go eat somewhere.");
        SetPlayerHealth(boxerid,30.0);
    }
    else
    {
        SendClientMessage(boxerid,COLOR_LIGHTBLUE,"* You feel perfect, even after the Fight.");
        SetPlayerHealth(boxerid,50.0);
    }
}

static Boxing_EndMatch(loser,winner)
{
    new boxer1 = s_BoxingBoxer1, boxer2 = s_BoxingBoxer2;

    if (IsPlayerConnected(boxer1) && IsPlayerConnected(boxer2))
    {
        new loserName[MAX_PLAYER_NAME + 1], winnerName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
        Boxing_SendToExit(boxer1);
        Boxing_SendToExit(boxer2);
        GetPlayerName(loser,loserName,sizeof(loserName));
        GetPlayerName(winner,winnerName,sizeof(winnerName));

        if (Jobs_Is(loser,JOB_BOXER))
        {
            Boxing_SetLoses(loser,s_BoxingLoses[loser] + 1);
        }

        if (Jobs_Is(winner,JOB_BOXER))
        {
            Boxing_SetWins(winner,s_BoxingWins[winner] + 1);
        }

        Boxing_ApplyChampion(winner,loser);

        format(line,sizeof(line),"* You have Lost the Fight against %s.",winnerName);
        SendClientMessage(loser,COLOR_LIGHTBLUE,line);
        Property_GameText(loser,"~r~You lost",3500,1);
        format(line,sizeof(line),"* You have Won the Fight against %s.",loserName);
        SendClientMessage(winner,COLOR_LIGHTBLUE,line);
        Property_GameText(winner,"~g~You won",3500,1);

        Boxing_Recover(boxer1);
        Boxing_Recover(boxer2);
        GameTextForPlayer(boxer1,"~g~Match Over",5000,1);
        GameTextForPlayer(boxer2,"~g~Match Over",5000,1);

        if (Jobs_Is(winner,JOB_BOXER))
        {
            Progress_AddSkill(winner,PROGRESS_SKILL_BOX);
        }

        s_BoxingFighting[boxer1] = false;
        s_BoxingFighting[boxer2] = false;
    }

    Boxing_ClearRing();
}

static Boxing_TickWait(playerid)
{
    if (s_BoxingWait[playerid] <= 0)
    {
        return;
    }

    if (s_BoxingWait[playerid] >= s_BoxingDelay)
    {
        s_BoxingDelay = 0;
        s_BoxingWait[playerid] = 0;
        PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
        GameTextForPlayer(playerid,"~g~Match Started",5000,1);
        TogglePlayerControllable(playerid,true);
        s_BoxingRoundStarted = true;
        return;
    }

    new line[8];
    format(line,sizeof(line),"%d",s_BoxingDelay - s_BoxingWait[playerid]);
    GameTextForPlayer(playerid,line,1500,6);
    s_BoxingWait[playerid]++;
}

static Boxing_TickRound(playerid)
{
    if (!s_BoxingRoundStarted || !s_BoxingFighting[playerid])
    {
        return;
    }

    new Float:health, Float:angle;
    GetPlayerHealth(playerid,health);

    if (health < BOXING_DIZZY_HEALTH)
    {
        GetPlayerFacingAngle(playerid,angle);
        SetPlayerFacingAngle(playerid,angle + 85.0);
    }

    if (health >= BOXING_LOSS_HEALTH)
    {
        return;
    }

    if (playerid == s_BoxingBoxer1)
    {
        Boxing_EndMatch(s_BoxingBoxer1,s_BoxingBoxer2);
    }
    else if (playerid == s_BoxingBoxer2)
    {
        Boxing_EndMatch(s_BoxingBoxer2,s_BoxingBoxer1);
    }
}

static Boxing_Interrupt(playerid)
{
    if (!s_BoxingFighting[playerid])
    {
        return;
    }

    new other = INVALID_PLAYER_ID;

    if (s_BoxingBoxer1 == playerid)
    {
        other = s_BoxingBoxer2;
    }
    else if (s_BoxingBoxer2 == playerid)
    {
        other = s_BoxingBoxer1;
    }

    if (other != INVALID_PLAYER_ID && IsPlayerConnected(other))
    {
        s_BoxingFighting[other] = false;
        Boxing_SendToExit(other);
        GameTextForPlayer(other,"~r~Match interrupted",5000,1);
    }

    Boxing_ClearRing();
}

static Boxing_Load(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT wins, loses FROM player_boxing WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("boxing","row load failed for player %d",playerid);
        return;
    }

    new wins = 0, loses = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"wins",wins);
        cache_get_value_name_int(0,"loses",loses);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO player_boxing (account_id) VALUES (%d)",accountid));
    }

    s_BoxingWins[playerid] = wins;
    s_BoxingLoses[playerid] = loses;
    s_BoxingLoaded[playerid] = true;
    Player_LoaderDone(playerid,BOXING_LOADER,token);
}

static Boxing_BootTask()
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_new("SELECT wins, name, loses FROM boxing_champion WHERE id = 1 LIMIT 1"),false);

    s_BoxingTitleName[0] = EOS;
    s_BoxingTitleWins = 0;
    s_BoxingTitleLoses = 0;

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("boxing","champion load failed, the title stays empty");
    }
    else if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"wins",s_BoxingTitleWins);
        cache_get_value_name(0,"name",s_BoxingTitleName,BOXING_NAME_LEN);
        cache_get_value_name_int(0,"loses",s_BoxingTitleLoses);
    }

    Log_Info("boxing","champion %s loaded",s_BoxingTitleName);
    Boot_LoaderDone();
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
public Boxing_LoadStart(playerid,accountid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Boxing_Load(playerid,accountid,token);
    }

    return 1;
}

public Boxing_LoadOnBoot()
{
    Boxing_BootTask();
    return 1;
}

public Boxing_Accept(playerid,const params[])
{
    new challenger = s_BoxingOffer[playerid];

    if (challenger == OFFER_NONE || challenger == OFFER_STALE)
    {
        s_BoxingOffer[playerid] = OFFER_NONE;
        SendClientMessage(playerid,COLOR_GREY,"   No-one offered you a Boxing Challenge !");
        return 1;
    }

    Boxing_StartMatch(challenger,playerid);
    return 1;
}

public Boxing_Cancel(playerid,const params[])
{
    s_BoxingOffer[playerid] = OFFER_NONE;
    return 1;
}

public Boxing_FightCheck(playerid)
{
    return Boxing_IsFighting(playerid) ? 1 : 0;
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
    Boxing_ClearPlayer(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Boxing_Interrupt(playerid);
    Offer_Sweep(s_BoxingOffer,playerid);
    Boxing_ClearPlayer(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    SetTimerEx("Boxing_LoadStart",0,false,"ddd",playerid,accountid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Boxing_Interrupt(playerid);
    Boxing_ClearPlayer(playerid);
}

hook Tick_OnPlayerSecond(playerid)
{
    Boxing_TickWait(playerid);
    Boxing_TickRound(playerid);
}
