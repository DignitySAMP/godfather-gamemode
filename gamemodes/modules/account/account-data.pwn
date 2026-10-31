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
#define ACCOUNT_PASSWORD_MAX (64)
#define ACCOUNT_BCRYPT_COST (12)
#define ACCOUNT_BAN_TRIES (4)
#define ACCOUNT_PASSWORD_MIN (6)
#define ACCOUNT_LOGIN_COOLDOWN_MS (3000)
#define ACCOUNT_ATTEMPT_STARTED (0)
#define ACCOUNT_ATTEMPT_LOGGED_IN (1)
#define ACCOUNT_ATTEMPT_TAKEN (2)
#define ACCOUNT_ATTEMPT_BUSY (3)
#define ACCOUNT_ATTEMPT_COOLDOWN (4)
#define ACCOUNT_ATTEMPT_TOO_SHORT (5)
#define ACCOUNT_ATTEMPT_TOO_LONG (6)
#define ACCOUNT_ATTEMPT_HAS_SPACE (7)
#define ACCOUNT_REPLY_LOGGED_IN "SERVER: You are already logged in."
#define ACCOUNT_REPLY_TAKEN "That Username is already taken, please choose a different one."
#define ACCOUNT_REPLY_COOLDOWN "SERVER: Wait a few seconds before you try again."
#define ACCOUNT_REPLY_HAS_SPACE "SERVER: Your password cannot contain spaces."
#define ACCOUNT_REPLY_MISMATCH "SERVER: The two passwords do not match."
#define ACCOUNT_STARTING_CASH (1000)
#define ACCOUNT_FIRST_LOGIN_BONUS (5000)
#define ACCOUNT_AUTOBAN_LEVEL (-999)
#define ACCOUNT_DEFAULT_HEALTH (50.0)
#define ACCOUNT_DEFAULT_X (2246.6)
#define ACCOUNT_DEFAULT_Y (-1161.9)
#define ACCOUNT_DEFAULT_Z (1029.7)
#define ACCOUNT_DEFAULT_INTERIOR (15)
#define ACCOUNT_DEFAULT_LOCAL (255)
#define ACCOUNT_DEFAULT_TEAM (3)
#define ACCOUNT_DEFAULT_MODEL (264)
#define ACCOUNT_FALLBACK_X (1684.9)
#define ACCOUNT_FALLBACK_Y (-2244.5)
#define ACCOUNT_FALLBACK_Z (13.5)
#define ACCOUNT_KICK_DELAY_MS (500)

enum E_ACCOUNT_AUTH
{
    ACCOUNT_AUTH_CONNECTING,
    ACCOUNT_AUTH_UNREGISTERED,
    ACCOUNT_AUTH_REGISTERED,
    ACCOUNT_AUTH_BUSY,
    ACCOUNT_AUTH_LOGGED_IN
}

enum E_ACCOUNT
{
    E_ACCOUNT_ID,
    E_ACCOUNT_AUTH:E_ACCOUNT_STATE,
    E_ACCOUNT_TRIES,
    bool:E_ACCOUNT_EXISTS,
    bool:E_ACCOUNT_FIRST_LOGIN,
    bool:E_ACCOUNT_SPAWNED,
    bool:E_ACCOUNT_OVERRIDE,
    E_ACCOUNT_LEVEL,
    E_ACCOUNT_ADMIN,
    E_ACCOUNT_DONATE_RANK,
    E_ACCOUNT_REG,
    E_ACCOUNT_SEX,
    E_ACCOUNT_AGE,
    E_ACCOUNT_ORIGIN,
    E_ACCOUNT_CK,
    E_ACCOUNT_MUTED,
    E_ACCOUNT_RESPECT,
    E_ACCOUNT_CASH,
    E_ACCOUNT_KILLS,
    E_ACCOUNT_DEATHS,
    E_ACCOUNT_CHAR,
    E_ACCOUNT_INTERIOR,
    E_ACCOUNT_LOCAL,
    E_ACCOUNT_TEAM,
    E_ACCOUNT_MODEL,
    E_ACCOUNT_TUTORIAL,
    E_ACCOUNT_WARNINGS,
    E_ACCOUNT_ADJUSTABLE,
    Float:E_ACCOUNT_HEALTH,
    Float:E_ACCOUNT_X,
    Float:E_ACCOUNT_Y,
    Float:E_ACCOUNT_Z,
    Float:E_ACCOUNT_OVERRIDE_X,
    Float:E_ACCOUNT_OVERRIDE_Y,
    Float:E_ACCOUNT_OVERRIDE_Z,
    E_ACCOUNT_OVERRIDE_INTERIOR,
    E_ACCOUNT_OVERRIDE_LOCAL,
    E_ACCOUNT_HASH[BCRYPT_HASH_LENGTH]
}

static s_Account[MAX_PLAYERS][E_ACCOUNT];

forward Account_OnLogin(playerid,accountid);
forward Account_OnLogout(playerid,accountid);

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
static Account_WriteInt(playerid,const column[],value)
{
    new accountid = s_Account[playerid][E_ACCOUNT_ID];

    if (accountid <= 0)
    {
        return;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE players SET %s = %d WHERE id = %d",column,value,accountid));
}

static Account_SetInt(playerid,E_ACCOUNT:field,const column[],value)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    s_Account[playerid][field] = value;
    Account_WriteInt(playerid,column,value);
}

static Account_GetInt(playerid,E_ACCOUNT:field)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_Account[playerid][field];
}

stock Account_Reset(playerid)
{
    s_Account[playerid][E_ACCOUNT_ID] = 0;
    s_Account[playerid][E_ACCOUNT_STATE] = ACCOUNT_AUTH_CONNECTING;
    s_Account[playerid][E_ACCOUNT_TRIES] = 0;
    s_Account[playerid][E_ACCOUNT_EXISTS] = false;
    s_Account[playerid][E_ACCOUNT_FIRST_LOGIN] = false;
    s_Account[playerid][E_ACCOUNT_SPAWNED] = false;
    s_Account[playerid][E_ACCOUNT_OVERRIDE] = false;
    s_Account[playerid][E_ACCOUNT_LEVEL] = 0;
    s_Account[playerid][E_ACCOUNT_ADMIN] = 0;
    s_Account[playerid][E_ACCOUNT_DONATE_RANK] = 0;
    s_Account[playerid][E_ACCOUNT_REG] = 0;
    s_Account[playerid][E_ACCOUNT_SEX] = 0;
    s_Account[playerid][E_ACCOUNT_AGE] = 0;
    s_Account[playerid][E_ACCOUNT_ORIGIN] = 0;
    s_Account[playerid][E_ACCOUNT_CK] = 0;
    s_Account[playerid][E_ACCOUNT_MUTED] = 0;
    s_Account[playerid][E_ACCOUNT_RESPECT] = 0;
    s_Account[playerid][E_ACCOUNT_CASH] = ACCOUNT_STARTING_CASH;
    s_Account[playerid][E_ACCOUNT_KILLS] = 0;
    s_Account[playerid][E_ACCOUNT_DEATHS] = 0;
    s_Account[playerid][E_ACCOUNT_CHAR] = 0;
    s_Account[playerid][E_ACCOUNT_INTERIOR] = ACCOUNT_DEFAULT_INTERIOR;
    s_Account[playerid][E_ACCOUNT_LOCAL] = ACCOUNT_DEFAULT_LOCAL;
    s_Account[playerid][E_ACCOUNT_TEAM] = ACCOUNT_DEFAULT_TEAM;
    s_Account[playerid][E_ACCOUNT_MODEL] = ACCOUNT_DEFAULT_MODEL;
    s_Account[playerid][E_ACCOUNT_TUTORIAL] = 0;
    s_Account[playerid][E_ACCOUNT_WARNINGS] = 0;
    s_Account[playerid][E_ACCOUNT_ADJUSTABLE] = 0;
    s_Account[playerid][E_ACCOUNT_HEALTH] = ACCOUNT_DEFAULT_HEALTH;
    s_Account[playerid][E_ACCOUNT_X] = ACCOUNT_DEFAULT_X;
    s_Account[playerid][E_ACCOUNT_Y] = ACCOUNT_DEFAULT_Y;
    s_Account[playerid][E_ACCOUNT_Z] = ACCOUNT_DEFAULT_Z;
    s_Account[playerid][E_ACCOUNT_HASH][0] = EOS;
}

static Account_ReadInt(const column[])
{
    new value = 0;
    cache_get_value_name_int(0,column,value);
    return value;
}

static Float:Account_ReadFloat(const column[])
{
    new Float:value = 0.0;
    cache_get_value_name_float(0,column,value);
    return value;
}

stock Account_ApplyRow(playerid)
{
    s_Account[playerid][E_ACCOUNT_ID] = Account_ReadInt("id");
    s_Account[playerid][E_ACCOUNT_LEVEL] = Account_ReadInt("level");
    s_Account[playerid][E_ACCOUNT_ADMIN] = Account_ReadInt("admin_level");
    s_Account[playerid][E_ACCOUNT_DONATE_RANK] = Account_ReadInt("donate_rank");
    s_Account[playerid][E_ACCOUNT_REG] = Account_ReadInt("reg");
    s_Account[playerid][E_ACCOUNT_SEX] = Account_ReadInt("sex");
    s_Account[playerid][E_ACCOUNT_AGE] = Account_ReadInt("age");
    s_Account[playerid][E_ACCOUNT_ORIGIN] = Account_ReadInt("origin");
    s_Account[playerid][E_ACCOUNT_CK] = Account_ReadInt("ck");
    s_Account[playerid][E_ACCOUNT_MUTED] = Account_ReadInt("muted");
    s_Account[playerid][E_ACCOUNT_RESPECT] = Account_ReadInt("respect");
    s_Account[playerid][E_ACCOUNT_CASH] = Account_ReadInt("cash");
    s_Account[playerid][E_ACCOUNT_KILLS] = Account_ReadInt("kills");
    s_Account[playerid][E_ACCOUNT_DEATHS] = Account_ReadInt("deaths");
    s_Account[playerid][E_ACCOUNT_CHAR] = Account_ReadInt("char_skin");
    s_Account[playerid][E_ACCOUNT_INTERIOR] = Account_ReadInt("interior");
    s_Account[playerid][E_ACCOUNT_LOCAL] = Account_ReadInt("local_area");
    s_Account[playerid][E_ACCOUNT_TEAM] = Account_ReadInt("team");
    s_Account[playerid][E_ACCOUNT_MODEL] = Account_ReadInt("model");
    s_Account[playerid][E_ACCOUNT_TUTORIAL] = Account_ReadInt("tutorial");
    s_Account[playerid][E_ACCOUNT_WARNINGS] = Account_ReadInt("warnings");
    s_Account[playerid][E_ACCOUNT_ADJUSTABLE] = Account_ReadInt("adjustable");
    s_Account[playerid][E_ACCOUNT_HEALTH] = Account_ReadFloat("health");
    s_Account[playerid][E_ACCOUNT_X] = Account_ReadFloat("pos_x");
    s_Account[playerid][E_ACCOUNT_Y] = Account_ReadFloat("pos_y");
    s_Account[playerid][E_ACCOUNT_Z] = Account_ReadFloat("pos_z");
}

stock E_ACCOUNT_AUTH:Account_GetAuthState(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return ACCOUNT_AUTH_CONNECTING;
    }

    return s_Account[playerid][E_ACCOUNT_STATE];
}

stock Account_SetAuthState(playerid,E_ACCOUNT_AUTH:newState)
{
    s_Account[playerid][E_ACCOUNT_STATE] = newState;
}

stock bool:Account_IsLoggedIn(playerid)
{
    return Util_IsValidPlayer(playerid) && s_Account[playerid][E_ACCOUNT_STATE] == ACCOUNT_AUTH_LOGGED_IN;
}

stock bool:Account_Exists(playerid)
{
    return Util_IsValidPlayer(playerid) && s_Account[playerid][E_ACCOUNT_EXISTS];
}

stock Account_SetExists(playerid,bool:exists)
{
    s_Account[playerid][E_ACCOUNT_EXISTS] = exists;
}

stock bool:Account_IsFirstLogin(playerid)
{
    return Util_IsValidPlayer(playerid) && s_Account[playerid][E_ACCOUNT_FIRST_LOGIN];
}

stock Account_SetFirstLogin(playerid,bool:isFirst)
{
    s_Account[playerid][E_ACCOUNT_FIRST_LOGIN] = isFirst;
}

stock bool:Account_HasSpawned(playerid)
{
    return Util_IsValidPlayer(playerid) && s_Account[playerid][E_ACCOUNT_SPAWNED];
}

stock Account_SetSpawned(playerid,bool:hasSpawned)
{
    s_Account[playerid][E_ACCOUNT_SPAWNED] = hasSpawned;
}

stock Account_GetId(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_ID);
}

stock Account_BumpTries(playerid)
{
    return ++s_Account[playerid][E_ACCOUNT_TRIES];
}

stock Account_SetHash(playerid,const hash[])
{
    strcopy(s_Account[playerid][E_ACCOUNT_HASH],hash,BCRYPT_HASH_LENGTH);
}

stock Account_ClearHash(playerid)
{
    s_Account[playerid][E_ACCOUNT_HASH][0] = EOS;
}

Account_GetAdminLevel(playerid)
{
    if (!Account_IsLoggedIn(playerid))
    {
        return 0;
    }

    return s_Account[playerid][E_ACCOUNT_ADMIN];
}

stock Account_SetAdminLevel(playerid,level)
{
    Account_SetInt(playerid,E_ACCOUNT_ADMIN,"admin_level",level);
}

stock Account_GetLevel(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_LEVEL);
}

stock Account_SetLevel(playerid,level)
{
    Account_SetInt(playerid,E_ACCOUNT_LEVEL,"level",level);
}

stock Account_GetDonateRank(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_DONATE_RANK);
}

stock Account_SetDonateRank(playerid,rank)
{
    Account_SetInt(playerid,E_ACCOUNT_DONATE_RANK,"donate_rank",rank);
}

stock Account_GetReg(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_REG);
}

stock Account_SetReg(playerid,value)
{
    Account_SetInt(playerid,E_ACCOUNT_REG,"reg",value);
}

stock Account_GetSex(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_SEX);
}

stock Account_SetSex(playerid,sex)
{
    Account_SetInt(playerid,E_ACCOUNT_SEX,"sex",sex);
}

stock Account_GetAge(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_AGE);
}

stock Account_SetAge(playerid,age)
{
    Account_SetInt(playerid,E_ACCOUNT_AGE,"age",age);
}

stock Account_GetOrigin(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_ORIGIN);
}

stock Account_SetOrigin(playerid,origin)
{
    Account_SetInt(playerid,E_ACCOUNT_ORIGIN,"origin",origin);
}

stock Account_GetCK(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_CK);
}

stock Account_SetCK(playerid,value)
{
    Account_SetInt(playerid,E_ACCOUNT_CK,"ck",value);
}

stock bool:Account_IsMuted(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_MUTED) == 1;
}

stock Account_SetMuted(playerid,bool:isMuted)
{
    Account_SetInt(playerid,E_ACCOUNT_MUTED,"muted",isMuted ? 1 : 0);
}

stock Account_GetRespect(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_RESPECT);
}

stock Account_SetRespect(playerid,respect)
{
    Account_SetInt(playerid,E_ACCOUNT_RESPECT,"respect",respect);
}

stock Account_GetCash(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_CASH);
}

stock Account_SetCash(playerid,cash)
{
    Account_SetInt(playerid,E_ACCOUNT_CASH,"cash",cash);

    if (Util_IsValidPlayer(playerid))
    {
        ResetPlayerMoney(playerid);
        GivePlayerMoney(playerid,cash);
    }
}

stock Account_GetKills(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_KILLS);
}

stock Account_SetKills(playerid,kills)
{
    Account_SetInt(playerid,E_ACCOUNT_KILLS,"kills",kills);
}

stock Account_GetDeaths(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_DEATHS);
}

stock Account_SetDeaths(playerid,deaths)
{
    Account_SetInt(playerid,E_ACCOUNT_DEATHS,"deaths",deaths);
}

stock Account_GetChar(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_CHAR);
}

stock Account_SetChar(playerid,skin)
{
    Account_SetInt(playerid,E_ACCOUNT_CHAR,"char_skin",skin);
}

stock Account_GetInterior(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_INTERIOR);
}

stock Account_SetInterior(playerid,interior)
{
    Account_SetInt(playerid,E_ACCOUNT_INTERIOR,"interior",interior);
}

stock Account_GetLocal(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_LOCAL);
}

stock Account_SetLocal(playerid,local)
{
    Account_SetInt(playerid,E_ACCOUNT_LOCAL,"local_area",local);
}

stock Account_GetTeam(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_TEAM);
}

stock Account_SetTeam(playerid,team)
{
    Account_SetInt(playerid,E_ACCOUNT_TEAM,"team",team);
}

stock Account_GetModel(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_MODEL);
}

stock Account_SetModel(playerid,model)
{
    Account_SetInt(playerid,E_ACCOUNT_MODEL,"model",model);
}

stock Account_GetTutorial(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_TUTORIAL);
}

stock Account_SetTutorial(playerid,value)
{
    Account_SetInt(playerid,E_ACCOUNT_TUTORIAL,"tutorial",value);
}

stock Account_GetWarnings(playerid)
{
    return Account_GetInt(playerid,E_ACCOUNT_WARNINGS);
}

stock Account_SetWarnings(playerid,warnings)
{
    Account_SetInt(playerid,E_ACCOUNT_WARNINGS,"warnings",warnings);
}

stock Account_SetAdjustable(playerid,value)
{
    Account_SetInt(playerid,E_ACCOUNT_ADJUSTABLE,"adjustable",value);
}

stock Account_GetPosition(playerid,&Float:x,&Float:y,&Float:z)
{
    if (!Util_IsValidPlayer(playerid))
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        return;
    }

    x = s_Account[playerid][E_ACCOUNT_X];
    y = s_Account[playerid][E_ACCOUNT_Y];
    z = s_Account[playerid][E_ACCOUNT_Z];
}

stock Account_SetPosition(playerid,Float:x,Float:y,Float:z,interior,local)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    s_Account[playerid][E_ACCOUNT_X] = x;
    s_Account[playerid][E_ACCOUNT_Y] = y;
    s_Account[playerid][E_ACCOUNT_Z] = z;
    s_Account[playerid][E_ACCOUNT_INTERIOR] = interior;
    s_Account[playerid][E_ACCOUNT_LOCAL] = local;

    if (s_Account[playerid][E_ACCOUNT_ID] > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE players SET pos_x = %f, pos_y = %f, pos_z = %f, interior = %d, local_area = %d WHERE id = %d",x,y,z,interior,local,s_Account[playerid][E_ACCOUNT_ID]));
    }
}

stock Account_SetPositionOverride(playerid,Float:x,Float:y,Float:z,interior,local)
{
    s_Account[playerid][E_ACCOUNT_OVERRIDE] = true;
    s_Account[playerid][E_ACCOUNT_OVERRIDE_X] = x;
    s_Account[playerid][E_ACCOUNT_OVERRIDE_Y] = y;
    s_Account[playerid][E_ACCOUNT_OVERRIDE_Z] = z;
    s_Account[playerid][E_ACCOUNT_OVERRIDE_INTERIOR] = interior;
    s_Account[playerid][E_ACCOUNT_OVERRIDE_LOCAL] = local;
}

stock Account_ClearPositionOverride(playerid)
{
    s_Account[playerid][E_ACCOUNT_OVERRIDE] = false;
}

stock Account_SaveVolatile(playerid)
{
    if (!Account_IsLoggedIn(playerid) || !s_Account[playerid][E_ACCOUNT_SPAWNED])
    {
        return false;
    }

    new Float:x, Float:y, Float:z, Float:health, interior, local;

    if (s_Account[playerid][E_ACCOUNT_OVERRIDE])
    {
        x = s_Account[playerid][E_ACCOUNT_OVERRIDE_X];
        y = s_Account[playerid][E_ACCOUNT_OVERRIDE_Y];
        z = s_Account[playerid][E_ACCOUNT_OVERRIDE_Z];
        interior = s_Account[playerid][E_ACCOUNT_OVERRIDE_INTERIOR];
        local = s_Account[playerid][E_ACCOUNT_OVERRIDE_LOCAL];
    }
    else
    {
        GetPlayerPos(playerid,x,y,z);
        interior = GetPlayerInterior(playerid);
        local = s_Account[playerid][E_ACCOUNT_LOCAL];
    }

    if (x == 0.0 && y == 0.0 && z == 0.0)
    {
        x = ACCOUNT_FALLBACK_X;
        y = ACCOUNT_FALLBACK_Y;
        z = ACCOUNT_FALLBACK_Z;
    }

    GetPlayerHealth(playerid,health);
    s_Account[playerid][E_ACCOUNT_HEALTH] = health;
    Account_SetPosition(playerid,x,y,z,interior,local);
    mysql_tquery_s(g_Mysql,str_format("UPDATE players SET health = %f WHERE id = %d",health,s_Account[playerid][E_ACCOUNT_ID]));
    return true;
}
