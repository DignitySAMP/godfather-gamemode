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
#define FAMILIES_LOADER "families"
#define FAMILIES_COUNT (10)
#define FAMILY_NONE (255)
#define FAMILY_RANK_MAX (6)
#define FAMILY_MEMBERS_MAX (10)
#define FAMILY_NAME_LEN (20)
#define FAMILY_MOTD_LEN (128)
#define FAMILY_COLOUR_LEN (20)
#define FAMILY_LEADER_LEN (MAX_PLAYER_NAME + 1)
#define FAMILY_TEXT_LEN (64)
#define FAMILY_LINE_LEN (160)
#define FAMILY_DEFAULT_TEXT "None"
#define FAMILY_DEFAULT_COLOUR "0xFF000069"

enum E_FAMILY_DATA
{
    E_FAMILY_TAKEN,
    E_FAMILY_NAME[FAMILY_NAME_LEN],
    E_FAMILY_MOTD[FAMILY_MOTD_LEN],
    E_FAMILY_COLOUR[FAMILY_COLOUR_LEN],
    E_FAMILY_LEADER[FAMILY_LEADER_LEN],
    E_FAMILY_MEMBERS,
    Float:E_FAMILY_SPAWN_X,
    Float:E_FAMILY_SPAWN_Y,
    Float:E_FAMILY_SPAWN_Z,
    Float:E_FAMILY_SPAWN_ANGLE,
    E_FAMILY_INTERIOR
}

static s_Families[FAMILIES_COUNT][E_FAMILY_DATA];
static s_FamiliesMember[MAX_PLAYERS];
static s_FamiliesRank[MAX_PLAYERS];
static bool:s_FamiliesLoaded[MAX_PLAYERS];
static bool:s_FamiliesTied[MAX_PLAYERS];

forward Task:Families_LoadAll();
forward Families_LoadStart(playerid,accountid,token);

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
static Families_ResetSlot(family)
{
    s_Families[family][E_FAMILY_TAKEN] = 0;
    strcopy(s_Families[family][E_FAMILY_NAME],FAMILY_DEFAULT_TEXT,FAMILY_NAME_LEN);
    strcopy(s_Families[family][E_FAMILY_MOTD],FAMILY_DEFAULT_TEXT,FAMILY_MOTD_LEN);
    strcopy(s_Families[family][E_FAMILY_COLOUR],FAMILY_DEFAULT_COLOUR,FAMILY_COLOUR_LEN);
    strcopy(s_Families[family][E_FAMILY_LEADER],FAMILY_DEFAULT_TEXT,FAMILY_LEADER_LEN);
    s_Families[family][E_FAMILY_MEMBERS] = 0;
    s_Families[family][E_FAMILY_SPAWN_X] = 0.0;
    s_Families[family][E_FAMILY_SPAWN_Y] = 0.0;
    s_Families[family][E_FAMILY_SPAWN_Z] = 0.0;
    s_Families[family][E_FAMILY_SPAWN_ANGLE] = 0.0;
    s_Families[family][E_FAMILY_INTERIOR] = 0;
}

static Families_Save(family)
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE families SET taken = %d, name = '%e', motd = '%e', colour = '%e', leader = '%e', members = %d, spawn_x = %f, spawn_y = %f, spawn_z = %f, spawn_angle = %f, interior = %d WHERE family_id = %d",s_Families[family][E_FAMILY_TAKEN],s_Families[family][E_FAMILY_NAME],s_Families[family][E_FAMILY_MOTD],s_Families[family][E_FAMILY_COLOUR],s_Families[family][E_FAMILY_LEADER],s_Families[family][E_FAMILY_MEMBERS],s_Families[family][E_FAMILY_SPAWN_X],s_Families[family][E_FAMILY_SPAWN_Y],s_Families[family][E_FAMILY_SPAWN_Z],s_Families[family][E_FAMILY_SPAWN_ANGLE],s_Families[family][E_FAMILY_INTERIOR],family));
}

static Families_ReadRow(row,family)
{
    cache_get_value_name_int(row,"taken",s_Families[family][E_FAMILY_TAKEN]);
    cache_get_value_name(row,"name",s_Families[family][E_FAMILY_NAME],FAMILY_NAME_LEN);
    cache_get_value_name(row,"motd",s_Families[family][E_FAMILY_MOTD],FAMILY_MOTD_LEN);
    cache_get_value_name(row,"colour",s_Families[family][E_FAMILY_COLOUR],FAMILY_COLOUR_LEN);
    cache_get_value_name(row,"leader",s_Families[family][E_FAMILY_LEADER],FAMILY_LEADER_LEN);
    cache_get_value_name_int(row,"members",s_Families[family][E_FAMILY_MEMBERS]);
    cache_get_value_name_float(row,"spawn_x",s_Families[family][E_FAMILY_SPAWN_X]);
    cache_get_value_name_float(row,"spawn_y",s_Families[family][E_FAMILY_SPAWN_Y]);
    cache_get_value_name_float(row,"spawn_z",s_Families[family][E_FAMILY_SPAWN_Z]);
    cache_get_value_name_float(row,"spawn_angle",s_Families[family][E_FAMILY_SPAWN_ANGLE]);
    cache_get_value_name_int(row,"interior",s_Families[family][E_FAMILY_INTERIOR]);
}

static Families_Reset(playerid)
{
    s_FamiliesMember[playerid] = FAMILY_NONE;
    s_FamiliesRank[playerid] = 0;
    s_FamiliesLoaded[playerid] = false;
    s_FamiliesTied[playerid] = false;
}

static Families_Write(playerid,const column[],value)
{
    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_families SET %s = %d WHERE account_id = %d",column,value,accountid));
    }
}

stock bool:Families_IsValidSlot(family)
{
    return family >= 0 && family < FAMILIES_COUNT;
}

stock bool:Families_IsTaken(family)
{
    return Families_IsValidSlot(family) && s_Families[family][E_FAMILY_TAKEN] == 1;
}

stock Families_GetName(family,dest[],size = sizeof(dest))
{
    if (!Families_IsValidSlot(family))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_Families[family][E_FAMILY_NAME],size);
}

stock Families_GetColourText(family,dest[],size = sizeof(dest))
{
    if (!Families_IsValidSlot(family))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_Families[family][E_FAMILY_COLOUR],size);
}

stock Families_GetLeaderName(family,dest[],size = sizeof(dest))
{
    if (!Families_IsValidSlot(family))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_Families[family][E_FAMILY_LEADER],size);
}

stock Families_GetMembers(family)
{
    if (!Families_IsValidSlot(family))
    {
        return 0;
    }

    return s_Families[family][E_FAMILY_MEMBERS];
}

stock Families_GetSpawn(family,&Float:x,&Float:y,&Float:z,&Float:angle,&interior)
{
    if (!Families_IsValidSlot(family))
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        angle = 0.0;
        interior = 0;
        return;
    }

    x = s_Families[family][E_FAMILY_SPAWN_X];
    y = s_Families[family][E_FAMILY_SPAWN_Y];
    z = s_Families[family][E_FAMILY_SPAWN_Z];
    angle = s_Families[family][E_FAMILY_SPAWN_ANGLE];
    interior = s_Families[family][E_FAMILY_INTERIOR];
}

stock bool:Families_SetName(family,const name[])
{
    if (!Families_IsValidSlot(family))
    {
        return false;
    }

    strcopy(s_Families[family][E_FAMILY_NAME],name,FAMILY_NAME_LEN);
    Families_Save(family);
    return true;
}

stock bool:Families_SetMotd(family,const motd[])
{
    if (!Families_IsValidSlot(family))
    {
        return false;
    }

    strcopy(s_Families[family][E_FAMILY_MOTD],motd,FAMILY_MOTD_LEN);
    Families_Save(family);
    return true;
}

stock bool:Families_SetColourText(family,const colour[])
{
    if (!Families_IsValidSlot(family))
    {
        return false;
    }

    strcopy(s_Families[family][E_FAMILY_COLOUR],colour,FAMILY_COLOUR_LEN);
    Families_Save(family);
    return true;
}

stock bool:Families_SetMembers(family,amount)
{
    if (!Families_IsValidSlot(family))
    {
        return false;
    }

    s_Families[family][E_FAMILY_MEMBERS] = amount;
    Families_Save(family);
    return true;
}

stock bool:Families_SetSpawn(family,Float:x,Float:y,Float:z,Float:angle,interior)
{
    if (!Families_IsValidSlot(family))
    {
        return false;
    }

    s_Families[family][E_FAMILY_SPAWN_X] = x;
    s_Families[family][E_FAMILY_SPAWN_Y] = y;
    s_Families[family][E_FAMILY_SPAWN_Z] = z;
    s_Families[family][E_FAMILY_SPAWN_ANGLE] = angle;
    s_Families[family][E_FAMILY_INTERIOR] = interior;
    Families_Save(family);
    return true;
}

stock bool:Families_Take(family,const leaderName[])
{
    if (!Families_IsValidSlot(family))
    {
        return false;
    }

    strcopy(s_Families[family][E_FAMILY_LEADER],leaderName,FAMILY_LEADER_LEN);
    s_Families[family][E_FAMILY_MEMBERS]++;
    s_Families[family][E_FAMILY_TAKEN] = 1;
    Families_Save(family);
    return true;
}

stock Families_AddMember(family,amount)
{
    if (Families_IsValidSlot(family))
    {
        s_Families[family][E_FAMILY_MEMBERS] += amount;
        Families_Save(family);
    }
}

stock bool:Families_Clear(family)
{
    if (!Families_IsValidSlot(family))
    {
        return false;
    }

    foreach (new targetid : Player)
    {
        if (s_FamiliesMember[targetid] == family)
        {
            SendClientMessage(targetid,COLOR_LIGHTBLUE,"* The Family you are in got Deleted by the Organisation Leader, you got kicked out automatically.");
            s_FamiliesMember[targetid] = FAMILY_NONE;
            Families_Write(targetid,"family",FAMILY_NONE);
        }
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE player_families SET family = %d WHERE family = %d",FAMILY_NONE,family));
    Families_ResetSlot(family);
    Families_Save(family);
    return true;
}

stock bool:Families_HasSpawn(family)
{
    if (!Families_IsValidSlot(family))
    {
        return false;
    }

    return s_Families[family][E_FAMILY_SPAWN_X] != 0.0 || s_Families[family][E_FAMILY_SPAWN_Y] != 0.0 || s_Families[family][E_FAMILY_SPAWN_Z] != 0.0;
}

stock bool:Families_IsLoaded(playerid)
{
    return Util_IsValidPlayer(playerid) && s_FamiliesLoaded[playerid];
}

stock Families_GetMember(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return FAMILY_NONE;
    }

    return s_FamiliesMember[playerid];
}

stock bool:Families_IsIn(playerid)
{
    return Util_IsValidPlayer(playerid) && Families_IsValidSlot(s_FamiliesMember[playerid]);
}

stock Families_GetRank(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_FamiliesRank[playerid];
}

stock bool:Families_SetMember(playerid,family)
{
    if (!Families_IsLoaded(playerid) || (family != FAMILY_NONE && !Families_IsValidSlot(family)))
    {
        return false;
    }

    s_FamiliesMember[playerid] = family;
    Families_Write(playerid,"family",family);
    return true;
}

stock bool:Families_SetRank(playerid,rank)
{
    if (!Families_IsLoaded(playerid))
    {
        return false;
    }

    s_FamiliesRank[playerid] = rank;
    Families_Write(playerid,"family_rank",rank);
    return true;
}

stock bool:Families_IsLeaderOf(playerid,family)
{
    if (!Util_IsValidPlayer(playerid) || !Families_IsValidSlot(family))
    {
        return false;
    }

    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));
    return !strcmp(s_Families[family][E_FAMILY_LEADER],name,true);
}

stock bool:Families_IsTied(playerid)
{
    return Util_IsValidPlayer(playerid) && s_FamiliesTied[playerid];
}

stock Families_SetTied(playerid,bool:isTied)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_FamiliesTied[playerid] = isTied;
    }
}

stock Families_GetActingRank(playerid)
{
    if (Factions_IsMember(playerid))
    {
        return Factions_GetRank(playerid);
    }

    return Families_GetRank(playerid);
}

stock Families_SendMessage(family,colour,const text[])
{
    if (!Families_IsValidSlot(family))
    {
        return;
    }

    foreach (new targetid : Player)
    {
        if (s_FamiliesMember[targetid] == family && Chat_IsFamilyEnabled(targetid))
        {
            SendClientMessage(targetid,colour,text);
        }
    }
}

stock Families_SendFactionMessage(faction,colour,const text[])
{
    foreach (new targetid : Player)
    {
        if (Factions_IsIn(targetid,faction) && Chat_IsFamilyEnabled(targetid))
        {
            SendClientMessage(targetid,colour,text);
        }
    }
}

async Task:Families_LoadAll()
{
    await task_ticks(1);

    for (new family = 0;family < FAMILIES_COUNT;family++)
    {
        Families_ResetSlot(family);
    }

    await mysql_aquery_s(g_Mysql,str_new("SELECT * FROM families ORDER BY family_id"),false);

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("families","the families table could not be read");
        return async 0;
    }

    new bool:found[FAMILIES_COUNT], loaded = 0;

    for (new row = 0,rows = cache_num_rows();row < rows;row++)
    {
        new family = -1;
        cache_get_value_name_int(row,"family_id",family);

        if (!Families_IsValidSlot(family))
        {
            Log_Error("families","family %d is outside the table, raise FAMILIES_COUNT",family);
            continue;
        }

        Families_ReadRow(row,family);
        found[family] = true;
        loaded++;
    }

    for (new family = 0;family < FAMILIES_COUNT;family++)
    {
        if (!found[family])
        {
            mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO families (family_id) VALUES (%d)",family));
        }
    }

    return async loaded;
}

static Families_Load(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT family, family_rank FROM player_families WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    s_FamiliesMember[playerid] = FAMILY_NONE;
    s_FamiliesRank[playerid] = 0;

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("families","load failed for player %d, starting without a family",playerid);
    }
    else if (cache_num_rows() == 0)
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT IGNORE INTO player_families (account_id) VALUES (%d)",accountid));
    }
    else
    {
        cache_get_value_name_int(0,"family",s_FamiliesMember[playerid]);
        cache_get_value_name_int(0,"family_rank",s_FamiliesRank[playerid]);

        if (!Families_IsValidSlot(s_FamiliesMember[playerid]))
        {
            s_FamiliesMember[playerid] = FAMILY_NONE;
        }
    }

    s_FamiliesLoaded[playerid] = true;

    if (Families_IsIn(playerid))
    {
        new line[FAMILY_LINE_LEN];
        format(line,sizeof(line),"Family MOTD: %s.",s_Families[s_FamiliesMember[playerid]][E_FAMILY_MOTD]);
        SendClientMessage(playerid,COLOR_YELLOW,line);
    }

    Player_LoaderDone(playerid,FAMILIES_LOADER,token);
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
public Families_LoadStart(playerid,accountid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Families_Load(playerid,accountid,token);
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
    Families_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Families_Reset(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    SetTimerEx("Families_LoadStart",0,false,"ddd",playerid,accountid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Families_Reset(playerid);
}
