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
#define FAMILY_TOKEN_LEN (64)
#define FAMILY_NEAR_RANGE (8.0)
#define FAMILY_PROX_RANGE (30.0)
#define FAMILY_TIE_RANK (3)
#define FAMILY_TIE_TEXT_MS (2500)
#define FAMILY_TIE_TEXT_STYLE (3)

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
static Families_FindPlayer(const token[])
{
    new targetid = INVALID_PLAYER_ID;

    if (token[0] == EOS || sscanf(token,"u",targetid))
    {
        return INVALID_PLAYER_ID;
    }

    return targetid;
}

static bool:Families_IsTarget(targetid)
{
    return targetid != INVALID_PLAYER_ID && IsPlayerConnected(targetid) && Families_IsLoaded(targetid);
}

static bool:Families_IsOrganisationLeader(playerid)
{
    new leader = Factions_GetLeader(playerid);
    return leader == FACTION_LCN || leader == FACTION_YAKUZA;
}

static bool:Families_CheckOrganisationNumber(playerid,family)
{
    if (family < 1 || family > FAMILIES_COUNT)
    {
        SendClientMessage(playerid,COLOR_GREY,"   FamilyNr can't be below 1 or above 10 !");
        return false;
    }

    new leader = Factions_GetLeader(playerid);

    if (leader == FACTION_LCN && family > 5)
    {
        SendClientMessage(playerid,COLOR_GREY,"   La Cosa Nostra Leader can only take FamilyNr 1 till 5 !");
        return false;
    }

    if (leader == FACTION_YAKUZA && family < 6)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Yakuza Leader can only take FamilyNr 6 till 10 !");
        return false;
    }

    return true;
}

static Families_FormatChat(const title[],const name[],const text[],rank,dest[],size = sizeof(dest))
{
    if (rank >= 1 && rank <= 4)
    {
        format(dest,size,"** %s %s: %s. ))  **",title,name,text);
        return;
    }

    format(dest,size,"** %s %s: %s. )) **",title,name,text);
}

static Families_AdjustText(playerid,family,const params[],at,const usage[],const done[],field)
{
    new text[FAMILY_TEXT_LEN];

    if (Util_ReadRest(params,at,text) == 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,usage);
        return;
    }

    switch (field)
    {
        case 0:
        {
            Families_SetName(family,text);
        }
        case 1:
        {
            Families_SetMotd(family,text);
        }
        case 2:
        {
            Families_SetColourText(family,text);
        }
    }

    SendClientMessage(playerid,COLOR_WHITE,done);
}

static Families_AdjustInvite(playerid,family,const params[],at)
{
    if (Families_GetMembers(family) >= FAMILY_MEMBERS_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Your Family has reached the Maximum of 10 Family Members, can't invite more !");
        return;
    }

    new token[FAMILY_TOKEN_LEN], targetid;

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /adjust invite [playerid/PartOfName]");
        return;
    }

    targetid = Families_FindPlayer(token);

    if (!Families_IsTarget(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return;
    }

    if (Families_GetMember(targetid) != FAMILY_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is already in a Family !");
        return;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], familyName[FAMILY_NAME_LEN], line[FAMILY_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    Families_GetName(family,familyName);
    format(line,sizeof(line),"* You've invited %s to join '%s'.",targetName,familyName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s has invited you to join '%s', you are now a Member of it.",name,familyName);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    Families_SetMember(targetid,family);
    Families_SetRank(targetid,1);
    Families_AddMember(family,1);
}

static Families_AdjustUninvite(playerid,family,const params[],at)
{
    new token[FAMILY_TOKEN_LEN], targetid;

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /adjust uninvite [playerid/PartOfName]");
        return;
    }

    targetid = Families_FindPlayer(token);

    if (!Families_IsTarget(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return;
    }

    if (Families_GetMember(targetid) != family)
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not in your Family !");
        return;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[FAMILY_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You've kicked %s out of your Family.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* Family Leader %s has kicked you out of the Family.",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    Families_SetMember(targetid,FAMILY_NONE);
    Families_SetRank(targetid,0);
    Families_AddMember(family,-1);
}

static Families_AdjustRank(playerid,family,const params[],at)
{
    new token[FAMILY_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /adjust rank [RankNr] [playerid/PartOfName]");
        return;
    }

    new rank = strval(token);

    if (rank < 1 || rank > FAMILY_RANK_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   RankNr can't be below 1 or above 6 !");
        return;
    }

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /adjust rank [RankNr] [playerid/PartOfName]");
        return;
    }

    new targetid = Families_FindPlayer(token);

    if (!Families_IsTarget(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return;
    }

    if (Families_GetMember(targetid) != family)
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not in your Family !");
        return;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[FAMILY_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You've given %s Rank %d.",targetName,rank);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* Family Leader %s has given you Rank %d.",name,rank);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    Families_SetRank(targetid,rank);
}

static Families_ChatFaction(playerid,faction,const name[],const text[],bool:isLeader)
{
    new title[FACTION_TITLE_LEN], line[FAMILY_LINE_LEN], rank = Factions_GetRank(playerid);

    if (isLeader)
    {
        Factions_GetRankTitle(faction,FACTION_RANK_MAX,title);
        rank = 0;
    }
    else if (faction == FACTION_LCN || faction == FACTION_YAKUZA)
    {
        Factions_GetMafiaTitle(rank,title);
    }
    else
    {
        Factions_GetRankTitle(faction,rank,title);
    }

    if (isLeader && (faction == FACTION_LCN || faction == FACTION_YAKUZA))
    {
        Factions_GetMafiaTitle(FACTION_RANK_MAX,title);
    }

    Families_FormatChat(title,name,text,rank,line);
    Families_SendFactionMessage(faction,TEAM_AZTECAS_COLOR,line);
    Log_Info("families","%s",line);
}

static bool:Families_IsChatFaction(faction)
{
    return faction == FACTION_LCN || faction == FACTION_YAKUZA || faction == FACTION_HITMAN || faction == FACTION_NEWS || faction == FACTION_TAXI || faction == FACTION_SCHOOL;
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
CMD:togfam(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Chat_IsFamilyEnabled(playerid))
    {
        Chat_SetFamilyEnabled(playerid,false);
        SendClientMessage(playerid,COLOR_GRAD2,"   Family chat channel Disabled !");
        return 1;
    }

    Chat_SetFamilyEnabled(playerid,true);
    SendClientMessage(playerid,COLOR_GRAD2,"   Family chat channel Enabled !");
    return 1;
}

CMD:families(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[FAMILY_TOKEN_LEN], line[FAMILY_LINE_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        for (new family = 0;family < FAMILIES_COUNT;family++)
        {
            new name[FAMILY_NAME_LEN], leader[FAMILY_LEADER_LEN];
            Families_GetName(family,name);
            Families_GetLeaderName(family,leader);
            format(line,sizeof(line),"Family %d| Name: %s | Leader: %s | Members: %d.",family + 1,name,leader,Families_GetMembers(family));
            SendClientMessage(playerid,COLOR_WHITE,line);
        }

        return 1;
    }

    new family = strval(token);

    if (family < 1 || family > FAMILIES_COUNT)
    {
        SendClientMessage(playerid,COLOR_GREY,"   FamilyNr can't be below 1 or above 10 !");
        return 1;
    }

    family -= 1;

    if (!Families_IsTaken(family))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That FamilyNr hasn't been Taken yet !");
        return 1;
    }

    foreach (new targetid : Player)
    {
        if (Families_GetMember(targetid) == family)
        {
            new name[MAX_PLAYER_NAME + 1];
            GetPlayerName(targetid,name,sizeof(name));
            format(line,sizeof(line),"* Family %d: %s | Rank: %d.",family,name,Families_GetRank(targetid));
            SendClientMessage(playerid,COLOR_GREY,line);
        }
    }

    return 1;
}

CMD:adjust(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new family = Families_GetMember(playerid);

    if (!Families_IsIn(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not in a Family !");
        return 1;
    }

    if (!Families_IsLeaderOf(playerid,family))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not the Leader of your Family !");
        return 1;
    }

    new at = 0, option[FAMILY_TOKEN_LEN];

    if (!Util_ReadToken(params,at,option))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /adjust [name]");
        SendClientMessage(playerid,COLOR_WHITE,"Available Names: Name, MOTD, Color, Spawn, Invite, Uninvite, Rank");
        return 1;
    }

    if (!strcmp(option,"name",true))
    {
        Families_AdjustText(playerid,family,params,at,"USAGE: /adjust Name [Family Name]","You've adjusted your Family's Name.",0);
    }
    else if (!strcmp(option,"motd",true))
    {
        Families_AdjustText(playerid,family,params,at,"USAGE: /adjust MOTD [Family MOTD Text]","You've adjusted your Family's MOTD.",1);
    }
    else if (!strcmp(option,"color",true))
    {
        Families_AdjustText(playerid,family,params,at,"USAGE: /adjust color [Family Color Sample: 0xFFFFFFAA]","You've adjusted your Family's Color.",2);
    }
    else if (!strcmp(option,"spawn",true))
    {
        new Float:x, Float:y, Float:z, Float:angle;
        GetPlayerPos(playerid,x,y,z);
        GetPlayerFacingAngle(playerid,angle);
        Families_SetSpawn(family,x,y,z,angle,GetPlayerInterior(playerid));
        SendClientMessage(playerid,COLOR_WHITE,"You've adjusted your Family's Spawnplace.");
    }
    else if (!strcmp(option,"invite",true))
    {
        Families_AdjustInvite(playerid,family,params,at);
    }
    else if (!strcmp(option,"uninvite",true))
    {
        Families_AdjustUninvite(playerid,family,params,at);
    }
    else if (!strcmp(option,"rank",true))
    {
        Families_AdjustRank(playerid,family,params,at);
    }
    else
    {
        SendClientMessage(playerid,COLOR_GREY,"   Invalid Adjust name !");
    }

    return 1;
}

CMD:giveturf(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Families_IsOrganisationLeader(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not the Leader of one of the Organisations !");
        return 1;
    }

    new at = 0, token[FAMILY_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /giveturf [FamilyNr]");
        return 1;
    }

    new family = strval(token);

    if (!Families_CheckOrganisationNumber(playerid,family))
    {
        return 1;
    }

    family -= 1;

    if (!Families_IsTaken(family))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That FamilyNr hasn't been Taken yet !");
        return 1;
    }

    new bool:found = false, name[FAMILY_NAME_LEN], colour[FAMILY_COLOUR_LEN];
    Families_GetName(family,name);
    Families_GetColourText(family,colour);

    for (new turf = 0,count = Turfs_GetCount();turf < count;turf++)
    {
        if (Turfs_IsPlayerIn(playerid,turf))
        {
            found = true;
            Turfs_SetOwner(turf,name,colour);
        }
    }

    if (found)
    {
        SendClientMessage(playerid,COLOR_LIGHTBLUE,"* Turf adjusted.");
    }
    else
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not in a Turf !");
    }

    return 1;
}

CMD:allowcreation(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Families_IsOrganisationLeader(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not the Leader of one of the Organisations !");
        return 1;
    }

    new at = 0, token[FAMILY_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /allowcreation [FamilyNr] [playerid/PartOfName]");
        return 1;
    }

    new family = strval(token);

    if (!Families_CheckOrganisationNumber(playerid,family))
    {
        return 1;
    }

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /allowcreation [FamilyNr] [playerid/PartOfName]");
        return 1;
    }

    new targetid = Families_FindPlayer(token);

    if (!Families_IsTarget(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    family -= 1;

    if (Families_IsTaken(family))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That FamilyNr is already taken !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[FAMILY_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You've made %s the Leader of FamilyNr %d.",targetName,family);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);

    if (Factions_GetLeader(playerid) == FACTION_LCN)
    {
        format(line,sizeof(line),"* La Cosa Nostra Leader %s has made you a Family Leader of FamilyNr %d.",name,family);
    }
    else
    {
        format(line,sizeof(line),"* Yakuza Leader %s has made you a Family Leader of FamilyNr %d.",name,family);
    }

    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    Families_Take(family,targetName);
    Families_SetMember(targetid,family);
    return 1;
}

CMD:deletecreation(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Families_IsOrganisationLeader(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not the Leader of one of the Organisations !");
        return 1;
    }

    new at = 0, token[FAMILY_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /deletecreation [FamilyNr]");
        return 1;
    }

    new family = strval(token);

    if (!Families_CheckOrganisationNumber(playerid,family))
    {
        return 1;
    }

    family -= 1;

    if (!Families_IsTaken(family))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That FamilyNr isn't taken !");
        return 1;
    }

    Families_Clear(family);
    return 1;
}

CMD:tie(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Factions_IsMember(playerid) && !Families_IsIn(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Family Member / Leader !");
        return 1;
    }

    if (Families_GetActingRank(playerid) < FAMILY_TIE_RANK)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You need Rank 3 or higher to tie people up !");
        return 1;
    }

    new at = 0, token[FAMILY_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /tie [Playerid/PartOfName]");
        return 1;
    }

    new targetid = Families_FindPlayer(token);

    if (targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    if (Families_IsTied(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Player already Tied !");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,FAMILY_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"You cannot Tie up yourself!");
        return 1;
    }

    new vehicleid = GetPlayerVehicleID(playerid);

    if (vehicleid == 0 || GetPlayerState(playerid) != PLAYER_STATE_DRIVER || GetPlayerVehicleID(targetid) != vehicleid)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Player not in your Car, or you're not the Driver !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[FAMILY_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You were tied up by %s, till untie.",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* You tied %s up, till untie.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s ties %s up, so he won't go anywhere.",name,targetName);
    Chat_ProxDetector(FAMILY_PROX_RANGE,playerid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    GameTextForPlayer(targetid,"~r~Tied",FAMILY_TIE_TEXT_MS,FAMILY_TIE_TEXT_STYLE);
    TogglePlayerControllable(targetid,false);
    Families_SetTied(targetid,true);
    return 1;
}

CMD:untie(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Factions_IsMember(playerid) && !Families_IsIn(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Family Member / Leader !");
        return 1;
    }

    if (Families_GetActingRank(playerid) < FAMILY_TIE_RANK)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You need Rank 3 or higher to untie people !");
        return 1;
    }

    new at = 0, token[FAMILY_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /untie [Playerid/PartOfName]");
        return 1;
    }

    new targetid = Families_FindPlayer(token);

    if (targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,FAMILY_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"You cannot Untie yourself!");
        return 1;
    }

    if (!Families_IsTied(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player isn't Tied up !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[FAMILY_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You were Untied by %s.",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* You Untied %s.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    GameTextForPlayer(targetid,"~g~Untied",FAMILY_TIE_TEXT_MS,FAMILY_TIE_TEXT_STYLE);
    TogglePlayerControllable(targetid,true);
    Families_SetTied(targetid,false);
    return 1;
}

CMD:family(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (Account_IsMuted(playerid))
    {
        SendClientMessage(playerid,TEAM_CYAN_COLOR,"You cannot speak, you have been silenced");
        return 1;
    }

    new text[FAMILY_TEXT_LEN];

    if (Util_ReadRest(params,0,text) == 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/f)amily [family chat]");
        return 1;
    }

    if (Factions_GetTeam(playerid) < TEAM_COR && !Families_IsIn(playerid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   you are not part of a Family!");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], member = Factions_GetMember(playerid), leader = Factions_GetLeader(playerid);
    GetPlayerName(playerid,name,sizeof(name));

    if (Families_IsChatFaction(member))
    {
        Families_ChatFaction(playerid,member,name,text,false);
    }
    else if (Families_IsChatFaction(leader))
    {
        Families_ChatFaction(playerid,leader,name,text,true);
    }
    else if (Families_IsIn(playerid))
    {
        new title[FACTION_TITLE_LEN], line[FAMILY_LINE_LEN], rank = Families_GetRank(playerid);
        Factions_GetMafiaTitle(rank,title);
        Families_FormatChat(title,name,text,rank,line);
        Families_SendMessage(Families_GetMember(playerid),TEAM_AZTECAS_COLOR,line);
        Log_Info("families","%s",line);
    }

    return 1;
}

ALT:f=CMD:family;
