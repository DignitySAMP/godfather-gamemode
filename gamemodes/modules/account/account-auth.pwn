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
#define ACCOUNT_DUPLICATE_ENTRY_ERRNO (1062)
#define ACCOUNT_MOTD "Welcome to the Role Play - The Godfather Server."
#define ACCOUNT_HINT_SECONDS (60)

static s_AccountConnectToken[MAX_PLAYERS];
static s_AccountNextToken;
static s_AccountBcryptPending[MAX_PLAYERS];
static s_AccountBcryptStale[MAX_PLAYERS];
static s_AccountHintSeconds[MAX_PLAYERS];
static s_AccountCooldownFrom[MAX_PLAYERS];
static bool:s_AccountCooldownSet[MAX_PLAYERS];
static s_AccountPasswordBuffer[MAX_PLAYERS][ACCOUNT_PASSWORD_MAX + 1];

forward Staff_BanPlayer(playerid);

forward Account_KickPlayer(playerid,token);
forward Account_ConnectLookup(playerid,token);
forward Account_StartLogin(playerid,token);
forward Account_StartRegister(playerid,token);
forward Account_OnPasswordHashed(playerid,hashid);
forward Account_OnPasswordVerified(playerid,bool:success);

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
stock Account_QueueKick(playerid)
{
    SetTimerEx("Account_KickPlayer",ACCOUNT_KICK_DELAY_MS,false,"dd",playerid,s_AccountConnectToken[playerid]);
}

stock Account_SendPrompt(playerid)
{
    if (Account_Exists(playerid))
    {
        SendClientMessage(playerid,COLOR_YELLOW,"SERVER: That nick is registered, please login");
        SendClientMessage(playerid,COLOR_WHITE,"HINT: You can now login by typing /login <password>");
        return;
    }

    SendClientMessage(playerid,COLOR_YELLOW,"You don't have an account. Please register by using /register [password]");
}

static bool:Account_ConsumeBcrypt(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    if (s_AccountBcryptPending[playerid] > 0)
    {
        s_AccountBcryptPending[playerid]--;
    }

    if (s_AccountBcryptStale[playerid] > 0)
    {
        s_AccountBcryptStale[playerid]--;

        if (Account_GetAuthState(playerid) == ACCOUNT_AUTH_BUSY)
        {
            Account_ClearHash(playerid);
            Account_SetAuthState(playerid,Account_Exists(playerid) ? ACCOUNT_AUTH_REGISTERED : ACCOUNT_AUTH_UNREGISTERED);
        }

        return false;
    }

    return true;
}

static Account_LookupName(playerid,token)
{
    yield 1;

    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));

    await mysql_aquery_s(g_Mysql,str_format("SELECT id FROM players WHERE name = '%e' LIMIT 1",name),false);

    if (!IsPlayerConnected(playerid) || token != s_AccountConnectToken[playerid])
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("account","name lookup failed for player %d",playerid);
        return;
    }

    Account_SetExists(playerid,cache_num_rows() > 0);

    if (Account_GetAuthState(playerid) == ACCOUNT_AUTH_CONNECTING)
    {
        Account_SetAuthState(playerid,Account_Exists(playerid) ? ACCOUNT_AUTH_REGISTERED : ACCOUNT_AUTH_UNREGISTERED);
    }

    Account_SendPrompt(playerid);
    Account_ShowAuthDialog(playerid);
}

static Account_StorePassword(playerid,const password[])
{
    strcopy(s_AccountPasswordBuffer[playerid],password,ACCOUNT_PASSWORD_MAX + 1);
}

static Account_WipePassword(playerid)
{
    for (new i = 0;i < ACCOUNT_PASSWORD_MAX + 1;i++)
    {
        s_AccountPasswordBuffer[playerid][i] = EOS;
    }
}

static Account_FetchHash(playerid)
{
    yield 1;

    new token = s_AccountConnectToken[playerid], name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));

    await mysql_aquery_s(g_Mysql,str_format("SELECT id, password_hash FROM players WHERE name = '%e' LIMIT 1",name),false);

    if (!IsPlayerConnected(playerid) || token != s_AccountConnectToken[playerid] || Account_GetAuthState(playerid) != ACCOUNT_AUTH_BUSY)
    {
        Account_WipePassword(playerid);
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Account_WipePassword(playerid);
        Log_Error("account","hash lookup failed for player %d",playerid);
        Account_SetAuthState(playerid,Account_Exists(playerid) ? ACCOUNT_AUTH_REGISTERED : ACCOUNT_AUTH_UNREGISTERED);
        Account_RetryAuthDialog(playerid);
        return;
    }

    if (cache_num_rows() == 0)
    {
        Account_WipePassword(playerid);
        Account_SetExists(playerid,false);
        Account_SetAuthState(playerid,ACCOUNT_AUTH_UNREGISTERED);
        Account_SendPrompt(playerid);
        Account_RetryAuthDialog(playerid);
        return;
    }

    new hash[BCRYPT_HASH_LENGTH];
    cache_get_value_name(0,"password_hash",hash);
    Account_SetExists(playerid,true);
    Account_SetHash(playerid,hash);
    s_AccountBcryptPending[playerid]++;
    bcrypt_verify(playerid,"Account_OnPasswordVerified",s_AccountPasswordBuffer[playerid],hash);
    Account_WipePassword(playerid);
}

public Account_StartLogin(playerid,token)
{
    if (!IsPlayerConnected(playerid) || token != s_AccountConnectToken[playerid] || Account_GetAuthState(playerid) != ACCOUNT_AUTH_BUSY)
    {
        Account_WipePassword(playerid);
        return 1;
    }

    Account_FetchHash(playerid);
    return 1;
}

public Account_StartRegister(playerid,token)
{
    if (!IsPlayerConnected(playerid) || token != s_AccountConnectToken[playerid] || Account_GetAuthState(playerid) != ACCOUNT_AUTH_BUSY)
    {
        Account_WipePassword(playerid);
        return 1;
    }

    s_AccountBcryptPending[playerid]++;
    bcrypt_hash(playerid,"Account_OnPasswordHashed",s_AccountPasswordBuffer[playerid],ACCOUNT_BCRYPT_COST);
    Account_WipePassword(playerid);
    return 1;
}

stock Account_RequestLogin(playerid,const password[])
{
    if (Account_IsLoggedIn(playerid))
    {
        SendClientMessage(playerid,COLOR_WHITE,ACCOUNT_REPLY_LOGGED_IN);
        return ACCOUNT_ATTEMPT_LOGGED_IN;
    }

    if (Account_GetAuthState(playerid) == ACCOUNT_AUTH_BUSY)
    {
        return ACCOUNT_ATTEMPT_BUSY;
    }

    if (s_AccountCooldownSet[playerid] && GetTickCount() - s_AccountCooldownFrom[playerid] < ACCOUNT_LOGIN_COOLDOWN_MS)
    {
        SendClientMessage(playerid,COLOR_WHITE,ACCOUNT_REPLY_COOLDOWN);
        return ACCOUNT_ATTEMPT_COOLDOWN;
    }

    Account_SetAuthState(playerid,ACCOUNT_AUTH_BUSY);
    Account_StorePassword(playerid,password);
    SetTimerEx("Account_StartLogin",0,false,"dd",playerid,s_AccountConnectToken[playerid]);
    return ACCOUNT_ATTEMPT_STARTED;
}

stock Account_CheckRegister(playerid)
{
    if (Account_IsLoggedIn(playerid))
    {
        SendClientMessage(playerid,COLOR_WHITE,ACCOUNT_REPLY_LOGGED_IN);
        return ACCOUNT_ATTEMPT_LOGGED_IN;
    }

    if (Account_Exists(playerid))
    {
        SendClientMessage(playerid,COLOR_YELLOW,ACCOUNT_REPLY_TAKEN);
        return ACCOUNT_ATTEMPT_TAKEN;
    }

    if (Account_GetAuthState(playerid) == ACCOUNT_AUTH_BUSY)
    {
        return ACCOUNT_ATTEMPT_BUSY;
    }

    return ACCOUNT_ATTEMPT_STARTED;
}

stock Account_RequestRegister(playerid,const password[])
{
    new result = Account_CheckRegister(playerid);

    if (result != ACCOUNT_ATTEMPT_STARTED)
    {
        return result;
    }

    new line[96];
    result = Account_CheckPassword(password);

    if (result != ACCOUNT_ATTEMPT_STARTED)
    {
        Account_AttemptText(result,line);
        SendClientMessage(playerid,COLOR_WHITE,line);
        return result;
    }

    Account_SetAuthState(playerid,ACCOUNT_AUTH_BUSY);
    Account_StorePassword(playerid,password);
    SetTimerEx("Account_StartRegister",0,false,"dd",playerid,s_AccountConnectToken[playerid]);
    return ACCOUNT_ATTEMPT_STARTED;
}

static Account_FinishLogin(playerid)
{
    yield 1;

    new token = s_AccountConnectToken[playerid], name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));

    await mysql_aquery_s(g_Mysql,str_format("SELECT * FROM players WHERE name = '%e' LIMIT 1",name),false);

    if (!IsPlayerConnected(playerid) || token != s_AccountConnectToken[playerid] || Account_GetAuthState(playerid) != ACCOUNT_AUTH_BUSY)
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0 || cache_num_rows() == 0)
    {
        Log_Error("account","row load failed for player %d",playerid);
        Account_SetAuthState(playerid,ACCOUNT_AUTH_REGISTERED);
        Account_RetryAuthDialog(playerid);
        return;
    }

    Account_ApplyRow(playerid);
    Account_ClearHash(playerid);
    Account_SetFirstLogin(playerid,false);
    Account_SetSpawned(playerid,false);
    Account_ClearPositionOverride(playerid);

    new accountid = Account_GetId(playerid);
    mysql_tquery_s(g_Mysql,str_format("UPDATE players SET last_login_at = NOW(), last_ip = '%e', adjustable = 0 WHERE id = %d",Util_GetPlayerIp(playerid),accountid));

    if (Account_GetReg(playerid) == 0)
    {
        Account_SetFirstLogin(playerid,true);
        Account_SetLevel(playerid,1);
        Account_SetReg(playerid,1);
        Account_SetCash(playerid,Account_GetCash(playerid) + ACCOUNT_FIRST_LOGIN_BONUS);
    }

    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid,Account_GetCash(playerid));

    if (Account_GetLevel(playerid) == ACCOUNT_AUTOBAN_LEVEL)
    {
        Account_SetAuthState(playerid,ACCOUNT_AUTH_REGISTERED);
        Account_CloseAuthDialog(playerid);
        Staff_BanPlayer(playerid);
        return;
    }

    if (Account_GetCK(playerid) > 0)
    {
        Account_SetAuthState(playerid,ACCOUNT_AUTH_REGISTERED);
        Account_CloseAuthDialog(playerid);
        Account_QueueKick(playerid);
        return;
    }

    Account_SetAuthState(playerid,ACCOUNT_AUTH_LOGGED_IN);
    Account_CloseAuthDialog(playerid);
    s_AccountCooldownSet[playerid] = false;

    new line[128];
    format(line,sizeof(line),"SERVER: Welcome %s",name);
    SendClientMessage(playerid,COLOR_WHITE,line);
    Log_Info("account","%s has logged in.",name);

    if (Account_GetDonateRank(playerid) > 0)
    {
        SendClientMessage(playerid,COLOR_WHITE,"SERVER: You are a Premium Account user.");
    }

    if (Account_GetAdminLevel(playerid) > 0)
    {
        format(line,sizeof(line),"SERVER: You are logged in as a Level %d Admin.",Account_GetAdminLevel(playerid));
        SendClientMessage(playerid,COLOR_WHITE,line);
    }

    format(line,sizeof(line),"~w~Welcome ~n~~y~   %s",name);
    GameTextForPlayer(playerid,line,5000,1);
    SendClientMessage(playerid,COLOR_YELLOW,ACCOUNT_MOTD);

    Player_BeginLoad(playerid,accountid);
}

static Account_InsertRow(playerid,const hash[])
{
    yield 1;

    new token = s_AccountConnectToken[playerid], name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));

    await mysql_aquery_s(g_Mysql,str_format("INSERT INTO players (name, password_hash, cash, registered_at) VALUES ('%e', '%e', %d, NOW())",name,hash,ACCOUNT_STARTING_CASH),false);

    if (!IsPlayerConnected(playerid) || token != s_AccountConnectToken[playerid] || Account_GetAuthState(playerid) != ACCOUNT_AUTH_BUSY)
    {
        return;
    }

    new errorid = mysql_errno(g_Mysql);

    if (errorid == ACCOUNT_DUPLICATE_ENTRY_ERRNO)
    {
        Account_SetExists(playerid,true);
        Account_SetAuthState(playerid,ACCOUNT_AUTH_REGISTERED);
        SendClientMessage(playerid,COLOR_YELLOW,ACCOUNT_REPLY_TAKEN);
        Account_RetryAuthDialog(playerid);
        return;
    }

    if (errorid != 0)
    {
        Log_Error("account","register failed for player %d (errno %d)",playerid,errorid);
        Account_SetAuthState(playerid,Account_Exists(playerid) ? ACCOUNT_AUTH_REGISTERED : ACCOUNT_AUTH_UNREGISTERED);
        Account_RetryAuthDialog(playerid);
        return;
    }

    Account_SetExists(playerid,true);
    Account_SetAuthState(playerid,ACCOUNT_AUTH_REGISTERED);
    SendClientMessage(playerid,COLOR_YELLOW,"Account registered, you can login now (/login [password]).");
    Account_ShowAuthDialog(playerid);
}

stock bool:Account_Logout(playerid)
{
    if (!Account_IsLoggedIn(playerid))
    {
        return false;
    }

    Account_SaveVolatile(playerid);
    pawn_call_public("Account_OnLogout","dd",playerid,Account_GetId(playerid));
    Player_EndSession(playerid);
    Account_SetSpawned(playerid,false);
    Account_SetAuthState(playerid,ACCOUNT_AUTH_REGISTERED);
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
public Account_OnLogin(playerid,accountid)
{
    return 1;
}

public Account_OnLogout(playerid,accountid)
{
    return 1;
}

public Account_KickPlayer(playerid,token)
{
    if (IsPlayerConnected(playerid) && token == s_AccountConnectToken[playerid])
    {
        Kick(playerid);
    }

    return 1;
}

public Account_ConnectLookup(playerid,token)
{
    if (IsPlayerConnected(playerid) && token == s_AccountConnectToken[playerid])
    {
        Account_LookupName(playerid,token);
    }

    return 1;
}

public Account_OnPasswordHashed(playerid,hashid)
{
    #pragma unused hashid

    if (!Account_ConsumeBcrypt(playerid))
    {
        return 1;
    }

    if (!IsPlayerConnected(playerid) || Account_GetAuthState(playerid) != ACCOUNT_AUTH_BUSY)
    {
        return 1;
    }

    new hash[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(hash,sizeof(hash));
    Account_InsertRow(playerid,hash);
    return 1;
}

public Account_OnPasswordVerified(playerid,bool:success)
{
    if (!Account_ConsumeBcrypt(playerid))
    {
        return 1;
    }

    if (!IsPlayerConnected(playerid) || Account_GetAuthState(playerid) != ACCOUNT_AUTH_BUSY)
    {
        return 1;
    }

    if (!success)
    {
        SendClientMessage(playerid,COLOR_WHITE,"SERVER: Password does not match your name.");
        Account_ClearHash(playerid);
        Account_SetAuthState(playerid,ACCOUNT_AUTH_REGISTERED);
        s_AccountCooldownFrom[playerid] = GetTickCount();
        s_AccountCooldownSet[playerid] = true;

        if (Account_BumpTries(playerid) == ACCOUNT_BAN_TRIES)
        {
            Account_CloseAuthDialog(playerid);
            Staff_BanPlayer(playerid);
            return 1;
        }

        Account_RetryAuthDialog(playerid);
        return 1;
    }

    Account_FinishLogin(playerid);
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
    Account_Reset(playerid);
    Account_WipePassword(playerid);
    s_AccountConnectToken[playerid] = ++s_AccountNextToken;
    s_AccountHintSeconds[playerid] = ACCOUNT_HINT_SECONDS;
    s_AccountCooldownSet[playerid] = false;

    if (IsPlayerNPC(playerid))
    {
        return;
    }

    SetTimerEx("Account_ConnectLookup",0,false,"dd",playerid,s_AccountConnectToken[playerid]);
}

hook Tick_OnPlayerSecond(playerid)
{
    if (s_AccountHintSeconds[playerid] > 0)
    {
        s_AccountHintSeconds[playerid]--;
    }

    if (s_AccountHintSeconds[playerid] == 1 && Account_Exists(playerid) && !Account_IsLoggedIn(playerid))
    {
        SendClientMessage(playerid,COLOR_WHITE,"HINT: You can now login by typing /login <password>");
    }
}

hook OnPlayerDisconnect(playerid,reason)
{
    if (Account_IsLoggedIn(playerid))
    {
        Account_SetAdjustable(playerid,1);
        Account_SaveVolatile(playerid);
    }

    s_AccountConnectToken[playerid] = ++s_AccountNextToken;
    s_AccountBcryptStale[playerid] = s_AccountBcryptPending[playerid];
    Account_WipePassword(playerid);
}

hook OnPlayerSpawn(playerid)
{
    if (Account_IsLoggedIn(playerid))
    {
        Account_SetSpawned(playerid,true);
    }
}

hook Database_OnPlayerSave(playerid,E_SAVE_REASON:reason)
{
    if (reason != E_SAVE_REASON_DISCONNECT)
    {
        Account_SaveVolatile(playerid);
    }
}
