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
#define PHONE_LOADER "phone"
#define PHONE_LINE_NONE (255)
#define PHONE_LINE_EMERGENCY (911)
#define PHONE_LINE_POLICE_CRIME (912)
#define PHONE_LINE_POLICE_NAME (913)
#define PHONE_LINE_PARAMEDIC (914)
#define PHONE_NUMBER_MIN (1000)
#define PHONE_NUMBER_RANGE (8999)
#define PHONE_CALL_COST (10)
#define PHONE_CHARGE_TIME (60)
#define PHONE_TEXT_COST (25)
#define PHONE_RING_CALL (10)
#define PHONE_RING_SMS (20)
#define PHONE_RING_ANSWER_TIME (5)
#define PHONE_PROX_RANGE (30.0)
#define PHONE_SPEECH_RANGE (20.0)
#define PHONE_LINE_LEN (192)

static s_PhoneNumber[MAX_PLAYERS];
static bool:s_PhoneBook[MAX_PLAYERS];
static bool:s_PhoneLoaded[MAX_PLAYERS];
static bool:s_PhoneOffline[MAX_PLAYERS];
static s_PhoneLine[MAX_PLAYERS];
static s_PhoneCellTime[MAX_PLAYERS];
static s_PhoneCallCost[MAX_PLAYERS];
static s_PhoneRingTone[MAX_PLAYERS];
static bool:s_PhoneRingReverse[MAX_PLAYERS];
static bool:s_PhoneTickEnabled = true;

forward Phone_LoadStart(playerid,accountid,token);

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
stock bool:Phone_IsLoaded(playerid)
{
    return Util_IsValidPlayer(playerid) && s_PhoneLoaded[playerid];
}

stock bool:Phone_IsPlayerLine(line)
{
    return line >= 0 && line < MAX_PLAYERS;
}

stock Phone_GetNumber(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_PhoneNumber[playerid];
}

stock bool:Phone_SetNumber(playerid,number)
{
    if (!Phone_IsLoaded(playerid))
    {
        return false;
    }

    s_PhoneNumber[playerid] = number;

    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_phone SET number = %d WHERE account_id = %d",number,accountid));
    }

    return true;
}

stock bool:Phone_HasPhoneBook(playerid)
{
    return Util_IsValidPlayer(playerid) && s_PhoneBook[playerid];
}

stock bool:Phone_SetPhoneBook(playerid,bool:hasBook)
{
    if (!Phone_IsLoaded(playerid))
    {
        return false;
    }

    s_PhoneBook[playerid] = hasBook;

    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_phone SET phonebook = %d WHERE account_id = %d",hasBook ? 1 : 0,accountid));
    }

    return true;
}

stock bool:Phone_IsOffline(playerid)
{
    return Util_IsValidPlayer(playerid) && s_PhoneOffline[playerid];
}

stock Phone_SetOffline(playerid,bool:isOffline)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_PhoneOffline[playerid] = isOffline;
    }
}

stock Phone_GetLine(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return PHONE_LINE_NONE;
    }

    return s_PhoneLine[playerid];
}

stock Phone_SetLine(playerid,line)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_PhoneLine[playerid] = line;
    }
}

stock Phone_GetPartnerLine(playerid)
{
    new line = Phone_GetLine(playerid);

    if (!Phone_IsPlayerLine(line))
    {
        return -1;
    }

    return s_PhoneLine[line];
}

stock Phone_GetCellTime(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_PhoneCellTime[playerid];
}

stock Phone_SetCellTime(playerid,seconds)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_PhoneCellTime[playerid] = seconds;
    }
}

stock Phone_GetCallCost(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_PhoneCallCost[playerid];
}

stock Phone_SetCallCost(playerid,amount)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_PhoneCallCost[playerid] = amount;
    }
}

stock Phone_GetRingTone(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_PhoneRingTone[playerid];
}

stock Phone_SetRingTone(playerid,value)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_PhoneRingTone[playerid] = value;
    }
}

stock Phone_Beep(playerid)
{
    Phone_SetRingTone(playerid,PHONE_RING_SMS);
}

stock bool:Phone_IsRingReverse(playerid)
{
    return Util_IsValidPlayer(playerid) && s_PhoneRingReverse[playerid];
}

stock Phone_SetRingReverse(playerid,bool:isReverse)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_PhoneRingReverse[playerid] = isReverse;
    }
}

stock bool:Phone_IsTickEnabled()
{
    return s_PhoneTickEnabled;
}

stock Phone_BeepTeam(team,colour,const text[])
{
    foreach (new playerid : Player)
    {
        if (!IsPlayerNPC(playerid) && Factions_GetTeam(playerid) == team)
        {
            SendClientMessage(playerid,colour,text);
            Phone_Beep(playerid);
        }
    }
}

static Phone_Clear(playerid)
{
    s_PhoneNumber[playerid] = 0;
    s_PhoneBook[playerid] = false;
    s_PhoneLoaded[playerid] = false;
}

static Phone_ClearSession(playerid)
{
    s_PhoneOffline[playerid] = false;
    s_PhoneLine[playerid] = PHONE_LINE_NONE;
    s_PhoneCellTime[playerid] = 0;
    s_PhoneCallCost[playerid] = 0;
    s_PhoneRingTone[playerid] = 0;
    s_PhoneRingReverse[playerid] = false;
}

static Phone_Load(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT number, phonebook FROM player_phone WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    Phone_Clear(playerid);

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("phone","load failed for player %d, starting without a phone",playerid);
    }
    else if (cache_num_rows() == 0)
    {
        s_PhoneNumber[playerid] = PHONE_NUMBER_MIN + random(PHONE_NUMBER_RANGE);
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO player_phone (account_id, number, phonebook) VALUES (%d, %d, 0)",accountid,s_PhoneNumber[playerid]));
    }
    else
    {
        new phonebook = 0;
        cache_get_value_name_int(0,"number",s_PhoneNumber[playerid]);
        cache_get_value_name_int(0,"phonebook",phonebook);
        s_PhoneBook[playerid] = phonebook != 0;
    }

    s_PhoneLoaded[playerid] = true;
    Player_LoaderDone(playerid,PHONE_LOADER,token);
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
public Phone_LoadStart(playerid,accountid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Phone_Load(playerid,accountid,token);
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
    Phone_Clear(playerid);
    Phone_ClearSession(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    SetTimerEx("Phone_LoadStart",0,false,"ddd",playerid,accountid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Phone_Clear(playerid);
}

hook Stats_OnBuild(playerid,targetid)
{
    Stats_SetNumber("Phone",Phone_GetNumber(targetid));
}

hook Frisk_OnBuild(playerid,targetid)
{
    if (Phone_HasPhoneBook(targetid))
    {
        Misc_SetFriskItem(MISC_FRISK_ITEM_PHONEBOOK,true);
    }
}

hook Shops_OnPhoneBought(playerid,number)
{
    Phone_SetNumber(playerid,number);
}

hook Shops_OnPhoneBookBought(playerid)
{
    Phone_SetPhoneBook(playerid,true);
}
