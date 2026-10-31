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
#define CK_SLOTS (10)
#define CK_NONE (INVALID_PLAYER_ID)
#define CK_NAME_LEN (MAX_PLAYER_NAME + 1)
#define CK_EMPTY_NAME "No-one"
#define CK_MIN_LEVEL (5)
#define CK_LINE_LEN (192)

enum E_CK_REQUEST
{
    E_CK_USED,
    E_CK_SENDER[CK_NAME_LEN],
    E_CK_TARGET[CK_NAME_LEN]
}

static s_Ck[CK_SLOTS][E_CK_REQUEST];
static s_CkOn[MAX_PLAYERS];
static s_CkGetting[MAX_PLAYERS];

forward Task:Ck_LoadRequests();
forward Ck_LoadOnBoot();

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
stock bool:Ck_IsValidSlot(slot)
{
    return slot >= 0 && slot < CK_SLOTS;
}

stock bool:Ck_IsUsed(slot)
{
    return Ck_IsValidSlot(slot) && s_Ck[slot][E_CK_USED] != 0;
}

stock Ck_GetSender(slot,dest[],size = sizeof(dest))
{
    if (!Ck_IsValidSlot(slot))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_Ck[slot][E_CK_SENDER],size);
}

stock Ck_GetTarget(slot,dest[],size = sizeof(dest))
{
    if (!Ck_IsValidSlot(slot))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_Ck[slot][E_CK_TARGET],size);
}

stock Ck_Save(slot)
{
    if (!Ck_IsValidSlot(slot))
    {
        return;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE ck_requests SET sender = '%e', target = '%e', used = %d WHERE slot_id = %d",s_Ck[slot][E_CK_SENDER],s_Ck[slot][E_CK_TARGET],s_Ck[slot][E_CK_USED],slot));
}

stock Ck_Clear(slot)
{
    if (!Ck_IsValidSlot(slot))
    {
        return;
    }

    strcopy(s_Ck[slot][E_CK_SENDER],CK_EMPTY_NAME,CK_NAME_LEN);
    strcopy(s_Ck[slot][E_CK_TARGET],CK_EMPTY_NAME,CK_NAME_LEN);
    s_Ck[slot][E_CK_USED] = 0;
    Ck_Save(slot);
}

stock Ck_Request(playerid,targetid)
{
    for (new slot = 0;slot < CK_SLOTS;slot++)
    {
        if (s_Ck[slot][E_CK_USED] != 1)
        {
            GetPlayerName(playerid,s_Ck[slot][E_CK_SENDER],CK_NAME_LEN);
            GetPlayerName(targetid,s_Ck[slot][E_CK_TARGET],CK_NAME_LEN);
            s_Ck[slot][E_CK_USED] = 1;
            Ck_Save(slot);
            return slot;
        }
    }

    return -1;
}

stock Ck_Reset(playerid)
{
    s_CkOn[playerid] = CK_NONE;
    s_CkGetting[playerid] = CK_NONE;
}

stock Ck_Accept(slot,&killerid,&victimid)
{
    killerid = CK_NONE;
    victimid = CK_NONE;

    for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
    {
        if (!IsPlayerConnected(playerid) || IsPlayerNPC(playerid))
        {
            continue;
        }

        new name[MAX_PLAYER_NAME + 1];
        GetPlayerName(playerid,name,sizeof(name));

        if (!strcmp(s_Ck[slot][E_CK_SENDER],name,true))
        {
            killerid = playerid;
        }
        else if (!strcmp(s_Ck[slot][E_CK_TARGET],name,true))
        {
            victimid = playerid;
        }
    }

    if (killerid == CK_NONE || victimid == CK_NONE)
    {
        return false;
    }

    s_CkOn[killerid] = victimid;
    s_CkGetting[victimid] = killerid;
    return true;
}

stock Ck_HandleDeath(playerid,killerid)
{
    if (s_CkGetting[playerid] == CK_NONE && s_CkOn[playerid] == CK_NONE)
    {
        return;
    }

    if (killerid == CK_NONE || !Util_IsValidPlayer(killerid) || IsPlayerNPC(killerid))
    {
        return;
    }

    if (s_CkGetting[killerid] == CK_NONE && s_CkOn[killerid] == CK_NONE)
    {
        return;
    }

    new killer[MAX_PLAYER_NAME + 1], dier[MAX_PLAYER_NAME + 1], line[CK_LINE_LEN];
    GetPlayerName(playerid,dier,sizeof(dier));
    GetPlayerName(killerid,killer,sizeof(killer));
    format(line,sizeof(line),"* %s has performed a Character Kill on you, you aren't able to play with this Character anymore.",killer);
    SendClientMessage(playerid,COLOR_LIGHTRED,line);
    format(line,sizeof(line),"** %s has Character Killed %s **",killer,dier);
    Staff_CKLog(line);
    Account_SetCK(playerid,1);

    if (s_CkGetting[playerid] != CK_NONE)
    {
        s_CkGetting[playerid] = CK_NONE;
    }
    else if (s_CkOn[playerid] != CK_NONE)
    {
        s_CkOn[playerid] = CK_NONE;
    }

    if (s_CkGetting[killerid] != CK_NONE)
    {
        s_CkGetting[killerid] = CK_NONE;
    }
    else if (s_CkOn[killerid] != CK_NONE)
    {
        s_CkOn[killerid] = CK_NONE;
    }

    Staff_FlagKick(playerid);
}

stock Ck_HandleDisconnect(playerid)
{
    new requester = s_CkGetting[playerid], target = s_CkOn[playerid];

    if (requester != CK_NONE && Util_IsValidPlayer(requester))
    {
        SendClientMessage(requester,COLOR_YELLOW,"Your Character Kill has left the server, try again later.");
        s_CkOn[requester] = CK_NONE;
    }

    if (target != CK_NONE && Util_IsValidPlayer(target))
    {
        s_CkGetting[target] = CK_NONE;
    }
}

#pragma warning push
#pragma warning disable 204
async Task:Ck_LoadRequests()
{
    await mysql_aquery_s(g_Mysql,str_new("SELECT slot_id, sender, target, used FROM ck_requests ORDER BY slot_id"),false);

    new rows = cache_num_rows();

    for (new i = 0;i < rows;i++)
    {
        new slot = 0;
        cache_get_value_name_int(i,"slot_id",slot);

        if (!Ck_IsValidSlot(slot))
        {
            continue;
        }

        cache_get_value_name(i,"sender",s_Ck[slot][E_CK_SENDER],CK_NAME_LEN);
        cache_get_value_name(i,"target",s_Ck[slot][E_CK_TARGET],CK_NAME_LEN);
        cache_get_value_name_int(i,"used",s_Ck[slot][E_CK_USED]);
    }

    return async 1;
}
#pragma warning pop

static Ck_BootTask()
{
    yield 1;

    await Ck_LoadRequests();
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
public Ck_LoadOnBoot()
{
    Ck_BootTask();
    return 1;
}
