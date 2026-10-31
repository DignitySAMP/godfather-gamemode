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
#define BANK_LOADER "Bank"
#define BANK_LOCAL (103)
#define BANK_FIRST_LOGIN_BALANCE (50000)
#define BANK_TRANSFER_LEVEL (3)
#define BANK_TRANSFER_ALERT (500000)

forward Bank_BeginLoad(playerid,token);

static s_BankBalance[MAX_PLAYERS];
static bool:s_BankLoaded[MAX_PLAYERS];

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
stock bool:Bank_IsLoaded(playerid)
{
    return Util_IsValidPlayer(playerid) && s_BankLoaded[playerid];
}

stock Bank_GetBalance(playerid)
{
    if (!Bank_IsLoaded(playerid))
    {
        return 0;
    }

    return s_BankBalance[playerid];
}

stock bool:Bank_SetBalance(playerid,balance)
{
    if (!Bank_IsLoaded(playerid))
    {
        return false;
    }

    s_BankBalance[playerid] = balance;
    mysql_tquery_s(g_Mysql,str_format("UPDATE bank_accounts SET balance = %d WHERE account_id = %d",balance,Account_GetId(playerid)));
    return true;
}

stock Bank_AddBalance(playerid,amount)
{
    Bank_SetBalance(playerid,Bank_GetBalance(playerid) + amount);
    return Bank_GetBalance(playerid);
}

static Bank_Reset(playerid)
{
    s_BankBalance[playerid] = 0;
    s_BankLoaded[playerid] = false;
}

static Bank_LoadPlayer(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT balance FROM bank_accounts WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("bank","balance load failed for player %d",playerid);
        return;
    }

    new balance = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"balance",balance);
    }
    else
    {
        balance = Account_IsFirstLogin(playerid) ? BANK_FIRST_LOGIN_BALANCE : 0;
        mysql_tquery_s(g_Mysql,str_format("INSERT INTO bank_accounts (account_id, balance) VALUES (%d, %d) ON DUPLICATE KEY UPDATE balance = VALUES(balance)",accountid,balance));
    }

    s_BankBalance[playerid] = balance;
    s_BankLoaded[playerid] = true;
    Player_LoaderDone(playerid,BANK_LOADER,token);
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
public Bank_BeginLoad(playerid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Bank_LoadPlayer(playerid,Player_GetLoadAccount(playerid),token);
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
    Bank_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Bank_Reset(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    Bank_Reset(playerid);
    SetTimerEx("Bank_BeginLoad",0,false,"dd",playerid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Bank_Reset(playerid);
}

hook Stats_OnBuild(playerid,targetid)
{
    if (Bank_IsLoaded(targetid))
    {
        Stats_SetNumber("Bank",Bank_GetBalance(targetid));
    }
}
