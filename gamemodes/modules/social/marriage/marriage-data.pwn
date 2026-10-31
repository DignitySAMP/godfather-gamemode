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
#define MARRIAGE_LOADER "Marriage"
#define MARRIAGE_COST (100000)
#define MARRIAGE_NAME_LEN (MAX_PLAYER_NAME + 1)
#define MARRIAGE_NO_ONE "No-one"
#define MARRIAGE_LINE_LEN (160)
#define MARRIAGE_TOKEN_LEN (16)
#define MARRIAGE_NEAR_RANGE (8.0)
#define MARRIAGE_ACCEPT_RANGE (10.0)
#define MARRIAGE_WITNESS_RANGE (12.0)
#define MARRIAGE_CHURCH_RADIUS (10.0)
#define MARRIAGE_CHURCH_X (-1988.6638)
#define MARRIAGE_CHURCH_Y (1117.8837)
#define MARRIAGE_CHURCH_Z (54.4726)
#define MARRIAGE_SEX_MALE (1)
#define MARRIAGE_SEX_FEMALE (2)

static bool:s_MarriageMarried[MAX_PLAYERS];
static s_MarriageSpouse[MAX_PLAYERS][MARRIAGE_NAME_LEN];
static bool:s_MarriageLoaded[MAX_PLAYERS];

static s_MarriageProposeOffer[MAX_PLAYERS];
static s_MarriageWitnessOffer[MAX_PLAYERS];
static s_MarriageDivorceOffer[MAX_PLAYERS];
static s_MarriageWitness[MAX_PLAYERS];
static s_MarriageProposedTo[MAX_PLAYERS];
static s_MarriageGotProposedBy[MAX_PLAYERS];
static bool:s_MarriageCeremony[MAX_PLAYERS];

forward Marriage_LoadStart(playerid,accountid,token);
forward Marriage_PredicateIsMarried(playerid);
forward Marriage_AcceptWitness(playerid,const params[]);
forward Marriage_CancelWitness(playerid,const params[]);
forward Marriage_AcceptMarriage(playerid,const params[]);
forward Marriage_CancelMarriage(playerid,const params[]);
forward Marriage_AcceptDivorce(playerid,const params[]);
forward Marriage_CancelDivorce(playerid,const params[]);
forward Marriage_ChatCeremony(playerid,const text[]);

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
stock bool:Marriage_IsLoaded(playerid)
{
    return Util_IsValidPlayer(playerid) && s_MarriageLoaded[playerid];
}

stock bool:Marriage_IsMarried(playerid)
{
    return Marriage_IsLoaded(playerid) && s_MarriageMarried[playerid];
}

stock Marriage_GetSpouse(playerid,dest[],size = sizeof(dest))
{
    if (!Marriage_IsLoaded(playerid))
    {
        strcopy(dest,MARRIAGE_NO_ONE,size);
        return;
    }

    strcopy(dest,s_MarriageSpouse[playerid],size);
}

stock bool:Marriage_IsInCeremony(playerid)
{
    return Util_IsValidPlayer(playerid) && s_MarriageCeremony[playerid];
}

stock Marriage_GetProposeOffer(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_MarriageProposeOffer[playerid] : OFFER_NONE;
}

stock Marriage_GetWitnessOffer(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_MarriageWitnessOffer[playerid] : OFFER_NONE;
}

stock Marriage_GetDivorceOffer(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_MarriageDivorceOffer[playerid] : OFFER_NONE;
}

stock Marriage_GetWitness(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_MarriageWitness[playerid] : OFFER_NONE;
}

stock Marriage_GetProposedTo(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_MarriageProposedTo[playerid] : OFFER_NONE;
}

stock Marriage_GetGotProposedBy(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_MarriageGotProposedBy[playerid] : OFFER_NONE;
}

stock Marriage_SetProposeOffer(playerid,offerer)
{
    s_MarriageProposeOffer[playerid] = offerer;
}

stock Marriage_SetWitnessOffer(playerid,offerer)
{
    s_MarriageWitnessOffer[playerid] = offerer;
}

stock Marriage_SetDivorceOffer(playerid,offerer)
{
    s_MarriageDivorceOffer[playerid] = offerer;
}

stock Marriage_SetWitness(playerid,witness)
{
    s_MarriageWitness[playerid] = witness;
}

stock Marriage_BeginCeremony(proposed,proposer)
{
    s_MarriageCeremony[proposed] = true;
    s_MarriageProposedTo[proposer] = proposed;
    s_MarriageGotProposedBy[proposed] = proposer;
    s_MarriageWitness[proposer] = OFFER_NONE;
    s_MarriageProposeOffer[proposed] = OFFER_NONE;
}

stock Marriage_PassCeremony(proposed,proposer)
{
    s_MarriageCeremony[proposer] = true;
    s_MarriageCeremony[proposed] = false;
    s_MarriageGotProposedBy[proposed] = OFFER_NONE;
}

stock Marriage_ClearCeremony(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return;
    }

    s_MarriageCeremony[playerid] = false;
    s_MarriageProposedTo[playerid] = OFFER_NONE;
    s_MarriageGotProposedBy[playerid] = OFFER_NONE;
}

stock Marriage_Clear(playerid)
{
    if (!IsPlayerConnected(playerid))
    {
        return;
    }

    Marriage_Store(playerid,false,MARRIAGE_NO_ONE);
}

stock Marriage_Store(playerid,bool:married,const spouse[])
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    s_MarriageMarried[playerid] = married;
    strcopy(s_MarriageSpouse[playerid],spouse,MARRIAGE_NAME_LEN);

    if (s_MarriageLoaded[playerid])
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT INTO player_marriage (account_id, married, married_to) VALUES (%d, %d, '%e') ON DUPLICATE KEY UPDATE married = VALUES(married), married_to = VALUES(married_to)",Account_GetId(playerid),married ? 1 : 0,spouse));
    }
}

stock bool:Marriage_IsSpouseName(playerid,const name[])
{
    return Marriage_IsLoaded(playerid) && !strcmp(s_MarriageSpouse[playerid],name,true);
}

stock Marriage_ResetVolatile(playerid)
{
    s_MarriageProposeOffer[playerid] = OFFER_NONE;
    s_MarriageWitnessOffer[playerid] = OFFER_NONE;
    s_MarriageDivorceOffer[playerid] = OFFER_NONE;
    s_MarriageWitness[playerid] = OFFER_NONE;
    s_MarriageProposedTo[playerid] = OFFER_NONE;
    s_MarriageGotProposedBy[playerid] = OFFER_NONE;
    s_MarriageCeremony[playerid] = false;
}

stock Marriage_Reset(playerid)
{
    Marriage_ResetVolatile(playerid);
    s_MarriageMarried[playerid] = false;
    strcopy(s_MarriageSpouse[playerid],MARRIAGE_NO_ONE,MARRIAGE_NAME_LEN);
    s_MarriageLoaded[playerid] = false;
}

stock Marriage_SweepLeaver(playerid)
{
    Offer_Sweep(s_MarriageProposeOffer,playerid);
    Offer_Sweep(s_MarriageWitnessOffer,playerid);
    Offer_Sweep(s_MarriageDivorceOffer,playerid);
    Offer_Sweep(s_MarriageWitness,playerid);
    Offer_Sweep(s_MarriageProposedTo,playerid);
    Offer_Sweep(s_MarriageGotProposedBy,playerid);
}

static Marriage_Load(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT married, married_to FROM player_marriage WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("marriage","row load failed for player %d",playerid);
        return;
    }

    new married = 0, spouse[MARRIAGE_NAME_LEN];
    strcopy(spouse,MARRIAGE_NO_ONE,MARRIAGE_NAME_LEN);

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"married",married);
        cache_get_value_name(0,"married_to",spouse,MARRIAGE_NAME_LEN);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO player_marriage (account_id) VALUES (%d)",accountid));
    }

    s_MarriageMarried[playerid] = married != 0;
    strcopy(s_MarriageSpouse[playerid],spouse,MARRIAGE_NAME_LEN);
    s_MarriageLoaded[playerid] = true;
    Player_LoaderDone(playerid,MARRIAGE_LOADER,token);
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
public Marriage_LoadStart(playerid,accountid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Marriage_Load(playerid,accountid,token);
    }

    return 1;
}

public Marriage_PredicateIsMarried(playerid)
{
    return Marriage_IsMarried(playerid) ? 1 : 0;
}
