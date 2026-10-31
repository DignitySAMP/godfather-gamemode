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
#define STAFF_PRISON_SECONDS (3600)
#define STAFF_KICKRES_LEVEL_MAX (5)
#define STAFF_KICKRES_AMOUNT_MAX (10)

enum E_STAFF_PARSE
{
    STAFF_PARSE_USAGE,
    STAFF_PARSE_NO_TARGET,
    STAFF_PARSE_OK
}

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
static E_STAFF_PARSE:Staff_ParseTarget(playerid,const params[],const usage[],&targetid)
{
    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,usage);
        return STAFF_PARSE_USAGE;
    }

    targetid = Staff_FindPlayer(token);

    if (!Staff_IsTarget(targetid))
    {
        return STAFF_PARSE_NO_TARGET;
    }

    return STAFF_PARSE_OK;
}

static E_STAFF_PARSE:Staff_ParseTargetReason(playerid,const params[],const usage[],&targetid,reason[],size = sizeof(reason))
{
    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,usage);
        return STAFF_PARSE_USAGE;
    }

    targetid = Staff_FindPlayer(token);

    if (!Staff_IsTarget(targetid))
    {
        return STAFF_PARSE_NO_TARGET;
    }

    if (Util_ReadRest(params,at,reason,size) == 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,usage);
        return STAFF_PARSE_USAGE;
    }

    return STAFF_PARSE_OK;
}

static Staff_AnnounceAction(const targetName[],const text[],const adminName[])
{
    new line[STAFF_LINE_LEN];
    format(line,sizeof(line),"AdmCmd: %s was %s by %s",targetName,text,adminName);
    Staff_SendAdmins(COLOR_LIGHTRED,line);
}

static Staff_BanTarget(targetid,const adminName[],const targetName[],const reason[],bool:announce,bool:hadWarnings)
{
    new line[STAFF_LINE_LEN];
    format(line,sizeof(line),"AdmCmd: %s was banned by %s, reason: %s",targetName,adminName,reason);
    Staff_LogDated(STAFF_LOG_BAN,line);

    if (hadWarnings)
    {
        format(line,sizeof(line),"AdmCmd: %s was banned by %s (had 3 Warnings), reason: %s",targetName,adminName,reason);
        Staff_Say(COLOR_LIGHTRED,line);
    }
    else if (announce)
    {
        Staff_Say(COLOR_LIGHTRED,line);
    }

    Staff_MarkBanned(targetid);
    Staff_BanPlayer(targetid);
}

/**
 *                                   __
 *                                  |  |
 *      _______  ______ ____    ____| $$  _______
 *     /       \|      \    \  /      $$ /       |
 *    |  $$$$$$$| $$$$$$\$$$$\|  $$$$$$$|  $$$$$$$
 *    | $$      | $$ | $$ | $$| $$  | $$ \$$    |
 *    | $$_____ | $$ | $$ | $$| $$__| $$ _\$$$$$$|
 *     \$$     \| $$ | $$ | $$ \$$    $$|       $$
 *      \$$$$$$$ \$$  \$$  \$$  \$$$$$$$ \$$$$$$$
 *
 */
CMD<ADMIN_LEVEL_MOD>:prison(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;
    new E_STAFF_PARSE:parsed = Staff_ParseTarget(playerid,params,"USAGE: /prison [playerid/PartOfName]",targetid);

    if (parsed == STAFF_PARSE_USAGE)
    {
        return 1;
    }

    if (parsed == STAFF_PARSE_NO_TARGET)
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"* You placed %s in Fort DeMorgan.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTRED,line);
    format(line,sizeof(line),"* You were placed in Fort DeMorgan by Admin %s.",name);
    SendClientMessage(targetid,COLOR_LIGHTRED,line);
    GameTextForPlayer(targetid,"~w~Welcome to ~n~~r~Fort DeMorgan",5000,3);
    Law_ClearWanted(targetid);
    Law_Jail(targetid,STAFF_PRISON_SECONDS,LAW_JAIL_PRISON);
    return 1;
}

CMD<ADMIN_LEVEL_MOD>:jail(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /jail [playerid/PartOfName] [time(minutes)]");
        return 1;
    }

    new targetid = Staff_FindPlayer(token), minutes = 0;

    if (Util_ReadToken(params,at,token))
    {
        minutes = strval(token);
    }

    if (!Staff_IsTarget(targetid))
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"* You Jailed %s.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTRED,line);
    format(line,sizeof(line),"* You were Jailed by Admin %s.",name);
    SendClientMessage(targetid,COLOR_LIGHTRED,line);
    ResetPlayerWeapons(targetid);
    Law_SetWantedPoints(targetid,0);
    Law_Jail(targetid,minutes * 60,LAW_JAIL_CELL);
    format(line,sizeof(line),"You are jailed for %d minutes.   Bail: Unable",minutes);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:slap(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;
    new E_STAFF_PARSE:parsed = Staff_ParseTarget(playerid,params,"USAGE: /slap [playerid/PartOfName]",targetid);

    if (parsed != STAFF_PARSE_OK)
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], Float:health, Float:x, Float:y, Float:z;
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerHealth(targetid,health);
    SetPlayerHealth(targetid,health - STAFF_SLAP_DAMAGE);
    GetPlayerPos(targetid,x,y,z);
    SetPlayerPos(targetid,x,y,z + STAFF_SLAP_LIFT);
    PlayerPlaySound(targetid,STAFF_SLAP_SOUND,x,y,z + STAFF_SLAP_LIFT);
    Staff_AnnounceAction(targetName,"slapped",name);
    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:mute(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;
    new E_STAFF_PARSE:parsed = Staff_ParseTarget(playerid,params,"USAGE: /mute [playerid/PartOfName]",targetid);

    if (parsed != STAFF_PARSE_OK)
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));

    if (!Account_IsMuted(targetid))
    {
        Account_SetMuted(targetid,true);
        Staff_AnnounceAction(targetName,"silenced",name);
    }
    else
    {
        Account_SetMuted(targetid,false);
        Staff_AnnounceAction(targetName,"unsilenced",name);
    }

    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:kick(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid, reason[STAFF_REASON_LEN];
    new E_STAFF_PARSE:parsed = Staff_ParseTargetReason(playerid,params,"USAGE: /kick [playerid/PartOfName] [reason]",targetid,reason);

    if (parsed != STAFF_PARSE_OK)
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"AdmCmd: %s was kicked by %s, reason: %s",targetName,name,reason);
    Staff_LogDated(STAFF_LOG_KICK,line);
    Staff_KickPlayer(targetid);
    Staff_Say(COLOR_LIGHTRED,line);
    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:skick(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;
    new E_STAFF_PARSE:parsed = Staff_ParseTarget(playerid,params,"USAGE: /skick [playerid/PartOfName]",targetid);

    if (parsed == STAFF_PARSE_OK)
    {
        Staff_KickPlayer(targetid);
    }

    return 1;
}

CMD:kickres(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Staff_HasLevel(playerid,ADMIN_LEVEL_TRIAL))
    {
        return 1;
    }

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /kickres [level] [ammount]");
        return 1;
    }

    new level = strval(token);

    if (level < 0 || level > STAFF_KICKRES_LEVEL_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can only Reserved Slots Kick from level 0 to 5 !");
        return 1;
    }

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /kickres [level] [ammount]");
        return 1;
    }

    new amount = strval(token);

    if (amount < 1 || amount > STAFF_KICKRES_AMOUNT_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can only Reserved Slots Kick of a maximum of 10 players !");
        return 1;
    }

    foreach (new i : Player)
    {
        if (!IsPlayerNPC(i) && Account_GetLevel(i) == level && Account_GetAdminLevel(i) < 1 && Account_GetDonateRank(i) < 1 && amount > 0)
        {
            amount--;
            Staff_KickPlayer(i);
        }
    }

    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:warn(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid, reason[STAFF_REASON_LEN];
    new E_STAFF_PARSE:parsed = Staff_ParseTargetReason(playerid,params,"USAGE: /warn [playerid/PartOfName] [reason]",targetid,reason);

    if (parsed != STAFF_PARSE_OK)
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    Account_SetWarnings(targetid,Account_GetWarnings(targetid) + 1);

    if (Account_GetWarnings(targetid) >= STAFF_WARNINGS_BAN)
    {
        Staff_BanTarget(targetid,name,targetName,reason,false,true);
        return 1;
    }

    format(line,sizeof(line),"You warned %s, reason: %s",targetName,reason);
    SendClientMessage(playerid,COLOR_LIGHTRED,line);
    format(line,sizeof(line),"You were warned by %s, reason: %s",name,reason);
    SendClientMessage(targetid,COLOR_LIGHTRED,line);
    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:sban(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid, reason[STAFF_REASON_LEN];
    new E_STAFF_PARSE:parsed = Staff_ParseTargetReason(playerid,params,"USAGE: /sban [playerid/PartOfName] [reason]",targetid,reason);

    if (parsed != STAFF_PARSE_OK)
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    Staff_BanTarget(targetid,name,targetName,reason,false,false);
    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:ban(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid, reason[STAFF_REASON_LEN];
    new E_STAFF_PARSE:parsed = Staff_ParseTargetReason(playerid,params,"USAGE: /ban [playerid/PartOfName] [reason]",targetid,reason);

    if (parsed != STAFF_PARSE_OK)
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    Staff_BanTarget(targetid,name,targetName,reason,true,false);
    return 1;
}

CMD<ADMIN_LEVEL_MOD>:freeze(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;
    new E_STAFF_PARSE:parsed = Staff_ParseTarget(playerid,params,"USAGE: /freeze [playerid/PartOfName]",targetid);

    if (parsed != STAFF_PARSE_OK)
    {
        return 1;
    }

    if (Account_GetAdminLevel(targetid) > 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"Admins can not be frozen");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    TogglePlayerControllable(targetid,false);
    Staff_AnnounceAction(targetName,"Frozen",name);
    return 1;
}

CMD<ADMIN_LEVEL_TRIAL>:unfreeze(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;
    new E_STAFF_PARSE:parsed = Staff_ParseTarget(playerid,params,"USAGE: /unfreeze [playerid]",targetid);

    if (parsed != STAFF_PARSE_OK)
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    TogglePlayerControllable(targetid,true);
    Staff_AnnounceAction(targetName,"UnFrozen",name);
    return 1;
}
