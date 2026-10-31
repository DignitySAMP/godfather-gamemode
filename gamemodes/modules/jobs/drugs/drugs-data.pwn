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
#define DRUGS_LOADER "drugs"
#define DRUGS_NEAR_RANGE (8.0)
#define DRUGS_HOUSE_RADIUS (2.0)
#define DRUGS_GRAMS_MAX (99)
#define DRUGS_CARRY_LIMIT (15)
#define DRUGS_BUYER_LIMIT (7)
#define DRUGS_USE_GRAMS (2)
#define DRUGS_STONED_RESET (10)

static s_DrugsStock[MAX_PLAYERS];
static bool:s_DrugsLoaded[MAX_PLAYERS];
static s_DrugsOffer[MAX_PLAYERS];
static s_DrugsPrice[MAX_PLAYERS];
static s_DrugsGrams[MAX_PLAYERS];
static s_DrugsStoned[MAX_PLAYERS];

static const Float:s_DrugsHousePos[3] = {323.0342, 1118.5804, 1083.8828};

static const s_DrugsPriceTiers[5] = {200, 150, 100, 50, 10};
static const s_DrugsGramTiers[5] = {6, 12, 20, 30, 99};

forward Drugs_LoadStart(playerid,accountid,token);
forward Drugs_Accept(playerid,const params[]);
forward Drugs_Cancel(playerid,const params[]);

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
stock Drugs_GetStock(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_DrugsStock[playerid] : 0;
}

stock bool:Drugs_SetStock(playerid,grams)
{
    if (!Util_IsValidPlayer(playerid) || !s_DrugsLoaded[playerid])
    {
        return false;
    }

    s_DrugsStock[playerid] = grams;

    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_drugs SET drugs = %d WHERE account_id = %d",grams,accountid));
    }

    return true;
}

stock Drugs_SetOffer(playerid,dealerid,price,grams)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_DrugsOffer[playerid] = dealerid;
        s_DrugsPrice[playerid] = price;
        s_DrugsGrams[playerid] = grams;
    }
}

stock Drugs_GetStoned(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_DrugsStoned[playerid] : 0;
}

stock Drugs_SetStoned(playerid,counter)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_DrugsStoned[playerid] = counter;
    }
}

stock Drugs_GetPriceTier(skill,&price,&maxGrams)
{
    new tier = Jobs_GetSkillTier(skill);
    price = s_DrugsPriceTiers[tier];
    maxGrams = s_DrugsGramTiers[tier];
}

stock bool:Drugs_IsAtHouse(playerid)
{
    return Property_IsNear(playerid,DRUGS_HOUSE_RADIUS,s_DrugsHousePos[0],s_DrugsHousePos[1],s_DrugsHousePos[2]);
}

static Drugs_Clear(playerid)
{
    s_DrugsStock[playerid] = 0;
    s_DrugsLoaded[playerid] = false;
    s_DrugsOffer[playerid] = OFFER_NONE;
    s_DrugsPrice[playerid] = 0;
    s_DrugsGrams[playerid] = 0;
    s_DrugsStoned[playerid] = 0;
}

static Drugs_Wobble(playerid)
{
    new Float:angle;
    GetPlayerFacingAngle(playerid,angle);

    if (IsPlayerInAnyVehicle(playerid))
    {
        if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            SetVehicleZAngle(GetPlayerVehicleID(playerid),angle + 25.0);
        }
    }
    else
    {
        SetPlayerFacingAngle(playerid,angle + 90.0);
    }
}

static Drugs_TickStoned(playerid)
{
    if (s_DrugsStoned[playerid] < 2)
    {
        return;
    }

    s_DrugsStoned[playerid]++;

    if (s_DrugsStoned[playerid] == DRUGS_STONED_RESET)
    {
        s_DrugsStoned[playerid] = 2;
        Drugs_Wobble(playerid);
    }
}

static Drugs_Load(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT drugs FROM player_drugs WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("drugs","row load failed for player %d",playerid);
        return;
    }

    new grams = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"drugs",grams);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO player_drugs (account_id) VALUES (%d)",accountid));
    }

    s_DrugsStock[playerid] = grams;
    s_DrugsLoaded[playerid] = true;
    Player_LoaderDone(playerid,DRUGS_LOADER,token);
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
public Drugs_LoadStart(playerid,accountid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Drugs_Load(playerid,accountid,token);
    }

    return 1;
}

public Drugs_Accept(playerid,const params[])
{
    new dealerid = s_DrugsOffer[playerid];

    if (dealerid == OFFER_NONE || dealerid == OFFER_STALE)
    {
        Drugs_SetOffer(playerid,OFFER_NONE,0,0);
        SendClientMessage(playerid,COLOR_GREY,"   No-one offered you any Drugs !");
        return 1;
    }

    if (Account_GetCash(playerid) < s_DrugsPrice[playerid])
    {
        SendClientMessage(playerid,COLOR_GREY,"   You can't afford those Drugs !");
        return 1;
    }

    if (s_DrugsStock[playerid] >= DRUGS_BUYER_LIMIT)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are fully loaded with Drugs, use them first !");
        return 1;
    }

    if (s_DrugsStock[dealerid] < s_DrugsGrams[playerid])
    {
        Drugs_SetOffer(playerid,OFFER_NONE,0,0);
        SendClientMessage(playerid,COLOR_GREY,"   The Dealer doesn't have that much Drugs with him anymore !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], dealerName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(dealerid,dealerName,sizeof(dealerName));
    format(line,sizeof(line),"* You bought %d gram for $%d from Drug Dealer %s.",s_DrugsGrams[playerid],s_DrugsPrice[playerid],dealerName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s has bought your %d gram, the $%d was added to your PayCheck.",name,s_DrugsGrams[playerid],s_DrugsPrice[playerid]);
    SendClientMessage(dealerid,COLOR_LIGHTBLUE,line);
    Payday_AddPaycheck(dealerid,s_DrugsPrice[playerid]);
    new skill = Progress_AddSkill(dealerid,PROGRESS_SKILL_DRUGS);
    Account_SetCash(playerid,Account_GetCash(playerid) - s_DrugsPrice[playerid]);
    Drugs_SetStock(playerid,s_DrugsStock[playerid] + s_DrugsGrams[playerid]);
    Drugs_SetStock(dealerid,s_DrugsStock[dealerid] - s_DrugsGrams[playerid]);

    new reached = Jobs_GetSkillLevelReached(skill);

    if (reached > 0)
    {
        format(line,sizeof(line),"* Your Drug Dealer Skill is now Level %d, you can buy more Grams and Cheaper.",reached);
        SendClientMessage(dealerid,COLOR_YELLOW,line);
    }

    Drugs_SetOffer(playerid,OFFER_NONE,0,0);
    return 1;
}

public Drugs_Cancel(playerid,const params[])
{
    Drugs_SetOffer(playerid,OFFER_NONE,0,0);
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
    Drugs_Clear(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Offer_Sweep(s_DrugsOffer,playerid);
    Drugs_Clear(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    SetTimerEx("Drugs_LoadStart",0,false,"ddd",playerid,accountid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Drugs_Clear(playerid);
}

hook Tick_OnPlayerSecond(playerid)
{
    Drugs_TickStoned(playerid);
}

hook Law_OnTakeDrugs(playerid,targetid)
{
    Drugs_SetStock(targetid,0);
}

hook Stats_OnBuild(playerid,targetid)
{
    Stats_SetNumber("Drugs",Drugs_GetStock(targetid));
}

hook Frisk_OnBuild(playerid,targetid)
{
    Misc_SetFriskItem(MISC_FRISK_ITEM_DRUGS,Drugs_GetStock(targetid) > 0);
}
