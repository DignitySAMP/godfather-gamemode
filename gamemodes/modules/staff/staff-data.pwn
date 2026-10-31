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
#define STAFF_LOG_KICK "kick"
#define STAFF_LOG_BAN "ban"
#define STAFF_LOG_CK "ck"
#define STAFF_LOG_PAY "pay"
#define STAFF_LOG_TEXT_LEN (256)
#define STAFF_TOKEN_LEN (32)
#define STAFF_REASON_LEN (64)
#define STAFF_LINE_LEN (192)
#define STAFF_ACTION_LEN (32)
#define STAFF_IDLE_MS (600000)
#define STAFF_SPECTATE_MS (2000)
#define STAFF_CREATED_CARS_MAX (100)
#define STAFF_WARNINGS_BAN (3)
#define STAFF_SLAP_DAMAGE (5.0)
#define STAFF_SLAP_LIFT (5.0)
#define STAFF_SLAP_SOUND (1130)
#define STAFF_UNSPEC_SOUND (1145)
#define STAFF_NO_LOCAL (255)

enum E_STAFF_SPECTATE
{
    STAFF_SPECTATE_NONE,
    STAFF_SPECTATE_WATCHING,
    STAFF_SPECTATE_UNSPEC,
    STAFF_SPECTATE_RESTORE,
    STAFF_SPECTATE_RELEASE,
    STAFF_SPECTATE_PENDING
}

enum E_STAFF_KICK_FLAG
{
    STAFF_KICK_NONE,
    STAFF_KICK_KICK,
    STAFF_KICK_BAN
}

static E_STAFF_SPECTATE:s_StaffSpectateMode[MAX_PLAYERS];
static s_StaffSpectateTarget[MAX_PLAYERS];
static bool:s_StaffWatchingTv[MAX_PLAYERS];
static Float:s_StaffUnspecPosition[MAX_PLAYERS][3];
static s_StaffUnspecInterior[MAX_PLAYERS];
static s_StaffUnspecLocal[MAX_PLAYERS];
static s_StaffUnspecWorld[MAX_PLAYERS];
static Float:s_StaffDonorPosition[MAX_PLAYERS][3];
static E_STAFF_KICK_FLAG:s_StaffKickFlag[MAX_PLAYERS];
static Float:s_StaffIdlePosition[MAX_PLAYERS][6];
static bool:s_StaffIdleHasSample[MAX_PLAYERS];
static Float:s_StaffMark[MAX_PLAYERS][3];
static s_StaffBanAction[STAFF_ACTION_LEN];
static s_StaffCreatedCars[STAFF_CREATED_CARS_MAX];
static s_StaffCreatedCount;

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
stock Staff_ResetPlayer(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return;
    }

    s_StaffSpectateMode[playerid] = STAFF_SPECTATE_NONE;
    s_StaffSpectateTarget[playerid] = INVALID_PLAYER_ID;
    s_StaffWatchingTv[playerid] = false;
    s_StaffUnspecLocal[playerid] = STAFF_NO_LOCAL;
    s_StaffUnspecInterior[playerid] = 0;
    s_StaffUnspecWorld[playerid] = 0;
    s_StaffKickFlag[playerid] = STAFF_KICK_NONE;
    s_StaffIdleHasSample[playerid] = false;

    for (new i = 0;i < 3;i++)
    {
        s_StaffUnspecPosition[playerid][i] = 0.0;
        s_StaffDonorPosition[playerid][i] = 0.0;
        s_StaffMark[playerid][i] = 0.0;
    }

    for (new i = 0;i < 6;i++)
    {
        s_StaffIdlePosition[playerid][i] = 0.0;
    }
}

stock bool:Staff_HasLevel(playerid,level)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return false;
    }

    return IsPlayerAdmin(playerid) || Account_GetAdminLevel(playerid) >= level;
}

stock Staff_FindPlayer(const token[])
{
    new targetid = INVALID_PLAYER_ID;

    if (sscanf(token,"u",targetid))
    {
        return INVALID_PLAYER_ID;
    }

    return targetid;
}

stock bool:Staff_IsTarget(targetid)
{
    return targetid != INVALID_PLAYER_ID && Util_IsValidPlayer(targetid) && !IsPlayerNPC(targetid);
}

stock Staff_SendAdmins(colour,const text[],level = 1)
{
    foreach (new i : Player)
    {
        if (!IsPlayerNPC(i) && Account_GetAdminLevel(i) >= level)
        {
            SendClientMessage(i,colour,text);
        }
    }

    Log_Info("staff","%s",text);
}

stock Staff_Say(colour,const text[])
{
    SendClientMessageToAll(colour,text);
}

stock Staff_Log(const kind[],const text[])
{
    mysql_pquery_s(g_Mysql,str_format("INSERT INTO staff_log (kind, line) VALUES ('%e', '%e')",kind,text));
}

stock Staff_CKLog(const text[])
{
    Staff_Log(STAFF_LOG_CK,text);
}

stock Staff_PayLog(const text[])
{
    Staff_Log(STAFF_LOG_PAY,text);
}

stock Staff_LogDated(const kind[],const text[])
{
    new year, month, day, line[STAFF_LOG_TEXT_LEN];
    getdate(year,month,day);
    format(line,sizeof(line),"%s (%d-%d-%d)",text,month,day,year);
    Staff_Log(kind,line);
}

stock Staff_BanPlayer(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    if (s_StaffBanAction[0] != EOS)
    {
        CallLocalFunction(s_StaffBanAction,"d",playerid);
        return;
    }

    Ban(playerid);
}

stock Staff_KickPlayer(playerid)
{
    if (Util_IsValidPlayer(playerid))
    {
        Kick(playerid);
    }
}

stock Staff_MarkBanned(playerid)
{
    Account_SetAdminLevel(playerid,Account_GetLevel(playerid));
    Account_SetLevel(playerid,ACCOUNT_AUTOBAN_LEVEL);
}

stock Staff_FlagKick(playerid,bool:isBan = false)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_StaffKickFlag[playerid] = isBan ? STAFF_KICK_BAN : STAFF_KICK_KICK;
    }
}

stock E_STAFF_KICK_FLAG:Staff_TakeKickFlag(playerid)
{
    new E_STAFF_KICK_FLAG:flag = s_StaffKickFlag[playerid];
    s_StaffKickFlag[playerid] = STAFF_KICK_NONE;
    return flag;
}

stock E_STAFF_SPECTATE:Staff_GetSpectateMode(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return STAFF_SPECTATE_NONE;
    }

    return s_StaffSpectateMode[playerid];
}

stock Staff_SetSpectateMode(playerid,E_STAFF_SPECTATE:mode)
{
    if (playerid >= 0 && playerid < MAX_PLAYERS)
    {
        s_StaffSpectateMode[playerid] = mode;
    }
}

stock bool:Staff_IsSpectating(playerid)
{
    return Staff_GetSpectateMode(playerid) != STAFF_SPECTATE_NONE;
}

stock Staff_GetSpectateTarget(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return INVALID_PLAYER_ID;
    }

    return s_StaffSpectateTarget[playerid];
}

stock Staff_SetSpectateTarget(playerid,targetid)
{
    if (playerid >= 0 && playerid < MAX_PLAYERS)
    {
        s_StaffSpectateTarget[playerid] = targetid;
    }
}

stock bool:Staff_IsWatchingTv(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_StaffWatchingTv[playerid];
}

stock Staff_SetWatchingTv(playerid,bool:isWatching)
{
    if (playerid >= 0 && playerid < MAX_PLAYERS)
    {
        s_StaffWatchingTv[playerid] = isWatching;
    }
}

stock Staff_SaveUnspec(playerid)
{
    GetPlayerPos(playerid,s_StaffUnspecPosition[playerid][0],s_StaffUnspecPosition[playerid][1],s_StaffUnspecPosition[playerid][2]);
    s_StaffUnspecInterior[playerid] = Account_GetInterior(playerid);
    s_StaffUnspecLocal[playerid] = Account_GetLocal(playerid);
    s_StaffUnspecWorld[playerid] = GetPlayerVirtualWorld(playerid);
}

stock Staff_GetUnspecWorld(playerid)
{
    return s_StaffUnspecWorld[playerid];
}

stock Staff_GetUnspec(playerid,&Float:x,&Float:y,&Float:z,&interior,&local)
{
    x = s_StaffUnspecPosition[playerid][0];
    y = s_StaffUnspecPosition[playerid][1];
    z = s_StaffUnspecPosition[playerid][2];
    interior = s_StaffUnspecInterior[playerid];
    local = s_StaffUnspecLocal[playerid];
}

stock Staff_ClearUnspecLocal(playerid)
{
    s_StaffUnspecLocal[playerid] = STAFF_NO_LOCAL;
}

stock Staff_SaveDonorPosition(playerid)
{
    GetPlayerPos(playerid,s_StaffDonorPosition[playerid][0],s_StaffDonorPosition[playerid][1],s_StaffDonorPosition[playerid][2]);
}

stock Staff_GetDonorPosition(playerid,&Float:x,&Float:y,&Float:z)
{
    x = s_StaffDonorPosition[playerid][0];
    y = s_StaffDonorPosition[playerid][1];
    z = s_StaffDonorPosition[playerid][2];
}

stock Staff_SetMark(playerid,Float:x,Float:y,Float:z)
{
    s_StaffMark[playerid][0] = x;
    s_StaffMark[playerid][1] = y;
    s_StaffMark[playerid][2] = z;
}

stock Staff_GetMark(playerid,&Float:x,&Float:y,&Float:z)
{
    x = s_StaffMark[playerid][0];
    y = s_StaffMark[playerid][1];
    z = s_StaffMark[playerid][2];
}

stock bool:Staff_IdleSample(playerid)
{
    GetPlayerPos(playerid,s_StaffIdlePosition[playerid][0],s_StaffIdlePosition[playerid][1],s_StaffIdlePosition[playerid][2]);

    new bool:isIdle = s_StaffIdleHasSample[playerid] && s_StaffIdlePosition[playerid][0] == s_StaffIdlePosition[playerid][3] && s_StaffIdlePosition[playerid][1] == s_StaffIdlePosition[playerid][4] && s_StaffIdlePosition[playerid][2] == s_StaffIdlePosition[playerid][5];

    s_StaffIdlePosition[playerid][3] = s_StaffIdlePosition[playerid][0];
    s_StaffIdlePosition[playerid][4] = s_StaffIdlePosition[playerid][1];
    s_StaffIdlePosition[playerid][5] = s_StaffIdlePosition[playerid][2];
    s_StaffIdleHasSample[playerid] = true;
    return isIdle;
}

stock bool:Staff_TrackCreatedCar(vehicleid)
{
    if (s_StaffCreatedCount >= STAFF_CREATED_CARS_MAX)
    {
        return false;
    }

    s_StaffCreatedCars[s_StaffCreatedCount++] = vehicleid;
    return true;
}

stock bool:Staff_CreatedCarsFull()
{
    return s_StaffCreatedCount >= STAFF_CREATED_CARS_MAX;
}

stock Staff_DestroyCreatedCars()
{
    for (new i = 0;i < s_StaffCreatedCount;i++)
    {
        if (s_StaffCreatedCars[i] != 0)
        {
            DestroyVehicle(s_StaffCreatedCars[i]);
        }

        s_StaffCreatedCars[i] = 0;
    }

    s_StaffCreatedCount = 0;
}

