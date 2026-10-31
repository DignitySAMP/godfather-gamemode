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
#define LOTTO_LOADER "Lotto"
#define LOTTO_DEFAULT_JACKPOT (250000)
#define LOTTO_TICKET_PRICE (1500)
#define LOTTO_NUMBER_MAX (80)

static s_LottoJackpot = LOTTO_DEFAULT_JACKPOT;
static s_LottoTicket[MAX_PLAYERS];
static bool:s_LottoLoaded[MAX_PLAYERS];

forward Task:Lotto_LoadState();
forward Lotto_BeginLoad(playerid,token);

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
stock Lotto_GetJackpot()
{
    return s_LottoJackpot;
}

stock Lotto_SetJackpot(amount)
{
    s_LottoJackpot = amount;
    mysql_tquery_s(g_Mysql,str_format("UPDATE lotto_state SET jackpot = %d WHERE id = 1",amount));
}

stock bool:Lotto_IsLoaded(playerid)
{
    return Util_IsValidPlayer(playerid) && s_LottoLoaded[playerid];
}

stock Lotto_GetTicket(playerid)
{
    return Lotto_IsLoaded(playerid) ? s_LottoTicket[playerid] : 0;
}

stock bool:Lotto_SetTicket(playerid,number)
{
    if (!Lotto_IsLoaded(playerid))
    {
        return false;
    }

    s_LottoTicket[playerid] = number;
    mysql_tquery_s(g_Mysql,str_format("UPDATE lotto_tickets SET ticket = %d WHERE account_id = %d",number,Account_GetId(playerid)));
    return true;
}

static Lotto_Reset(playerid)
{
    s_LottoTicket[playerid] = 0;
    s_LottoLoaded[playerid] = false;
}

static Lotto_LoadPlayer(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT ticket FROM lotto_tickets WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("lotto","ticket load failed for player %d",playerid);
        return;
    }

    new ticket = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"ticket",ticket);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT INTO lotto_tickets (account_id, ticket) VALUES (%d, 0) ON DUPLICATE KEY UPDATE ticket = ticket",accountid));
    }

    s_LottoTicket[playerid] = ticket;
    s_LottoLoaded[playerid] = true;
    Player_LoaderDone(playerid,LOTTO_LOADER,token);
}

#pragma warning push
#pragma warning disable 204
async Task:Lotto_LoadState()
{
    await mysql_aquery_s(g_Mysql,str_new("SELECT jackpot FROM lotto_state WHERE id = 1 LIMIT 1"),false);

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"jackpot",s_LottoJackpot);
    }
    else
    {
        s_LottoJackpot = LOTTO_DEFAULT_JACKPOT;
    }

    return async 1;
}
#pragma warning pop

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
public Lotto_BeginLoad(playerid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Lotto_LoadPlayer(playerid,Player_GetLoadAccount(playerid),token);
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
    Lotto_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Lotto_Reset(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    Lotto_Reset(playerid);
    SetTimerEx("Lotto_BeginLoad",0,false,"dd",playerid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Lotto_Reset(playerid);
}

hook Stats_OnBuild(playerid,targetid)
{
    if (Lotto_IsLoaded(targetid))
    {
        Stats_SetNumber("LottoNr",Lotto_GetTicket(targetid));
    }
}
