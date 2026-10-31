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
#define FACTION_MEGAPHONE_RANGE (60.0)
#define FACTION_DUTY_RANGE (30.0)
#define FACTION_LOCKER_RADIUS (3.0)
#define FACTION_LOCKER_X (255.3)
#define FACTION_LOCKER_Y (77.4)
#define FACTION_LOCKER_Z (1003.6)
#define FACTION_LOCKER2_X (-1616.1294)
#define FACTION_LOCKER2_Y (681.1594)
#define FACTION_LOCKER2_Z (7.1875)

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
static Factions_RadioFaction(playerid)
{
    for (new faction = FACTION_POLICE;faction <= FACTION_NATIONAL_GUARD;faction++)
    {
        if (Factions_IsIn(playerid,faction))
        {
            return faction;
        }
    }

    if (Factions_GetTeam(playerid) == TEAM_CYAN || Factions_IsIn(playerid,FACTION_MEDICS))
    {
        return FACTION_MEDICS;
    }

    return FACTION_NONE;
}

static Factions_BuildRadioLine(playerid,faction,bool:departments,const text[],dest[],size = sizeof(dest))
{
    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));

    if (faction == FACTION_MEDICS)
    {
        format(dest,size,"** Paramedic %s: %s, over. **",name,text);
        return;
    }

    new title[FACTION_TITLE_LEN], rank = Factions_GetRank(playerid);
    Factions_GetRankTitle(faction,rank,title);

    if (departments && faction == FACTION_POLICE && (rank < 1 || rank > FACTION_RANK_MAX))
    {
        strcopy(title,"Officer");
    }

    format(dest,size,"** %s %s: %s, over. **",title,name,text);
}

static bool:Factions_IsTarget(targetid)
{
    return targetid != INVALID_PLAYER_ID && IsPlayerConnected(targetid);
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
CMD:radio(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new text[FACTION_TEXT_LEN];
    Util_ReadRest(params,0,text);

    if (text[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/r)adio [radio chat]");
        return 1;
    }

    new faction = Factions_RadioFaction(playerid);

    if (faction == FACTION_NONE)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You are not part of a Team !");
        return 1;
    }

    new line[FACTION_LINE_LEN];
    Factions_BuildRadioLine(playerid,faction,false,text,line);
    Factions_SendRadio(faction,faction == FACTION_MEDICS ? TEAM_CYAN_COLOR : TEAM_BLUE_COLOR,line);
    Log_Info("factions","%s",line);
    return 1;
}

ALT:r=CMD:radio;

CMD:departments(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new text[FACTION_TEXT_LEN];
    Util_ReadRest(params,0,text);

    if (text[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/d)epartments [department chat]");
        return 1;
    }

    new faction = Factions_RadioFaction(playerid);

    if (faction == FACTION_NONE)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You are not part of a Team !");
        return 1;
    }

    new line[FACTION_LINE_LEN];
    Factions_BuildRadioLine(playerid,faction,true,text,line);
    Factions_SendTeam(TEAM_BLUE,COLOR_ALLDEPT,line);
    Factions_SendTeam(TEAM_CYAN,COLOR_ALLDEPT,line);
    Log_Info("factions","%s",line);
    return 1;
}

ALT:d=CMD:departments;

CMD:megaphone(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new text[FACTION_TEXT_LEN];
    Util_ReadRest(params,0,text);

    if (text[0] == EOS)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/m)egaphone [megaphone chat]");
        return 1;
    }

    if (Factions_GetTeam(playerid) != TEAM_BLUE && !Factions_IsCop(playerid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You are not part of a Team !");
        return 1;
    }

    if (!Vehicles_IsCopCar(GetPlayerVehicleID(playerid)))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You are not in a Police Vehicle !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], line[FACTION_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));

    if (Factions_IsIn(playerid,FACTION_POLICE))
    {
        format(line,sizeof(line),"[Officer %s:o< %s]",name,text);
    }
    else if (Factions_IsIn(playerid,FACTION_FBI))
    {
        format(line,sizeof(line),"[Agent %s:o< %s]",name,text);
    }
    else if (Factions_IsIn(playerid,FACTION_NATIONAL_GUARD))
    {
        format(line,sizeof(line),"[Soldier %s:o< %s]",name,text);
    }
    else
    {
        return 1;
    }

    Chat_ProxDetector(FACTION_MEGAPHONE_RANGE,playerid,line,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
    Log_Info("factions","%s",line);
    return 1;
}

ALT:m=CMD:megaphone;

CMD:duty(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Factions_IsIn(playerid,FACTION_POLICE))
    {
        new bool:inLocker = Property_IsNear(playerid,FACTION_LOCKER_RADIUS,FACTION_LOCKER_X,FACTION_LOCKER_Y,FACTION_LOCKER_Z) || Property_IsNear(playerid,FACTION_LOCKER_RADIUS,FACTION_LOCKER2_X,FACTION_LOCKER2_Y,FACTION_LOCKER2_Z) || Account_GetLocal(playerid) != DOOR_LOCAL_OUTSIDE;

        if (!inLocker)
        {
            SendClientMessage(playerid,COLOR_GRAD2,"   You are not in a locker room !");
            return 1;
        }

        new name[MAX_PLAYER_NAME + 1], line[FACTION_LINE_LEN];
        GetPlayerName(playerid,name,sizeof(name));

        if (!Factions_IsOnDuty(playerid))
        {
            format(line,sizeof(line),"* Officer %s took a Badge and a Gun from his locker.",name);
            Chat_ProxDetector(FACTION_DUTY_RANGE,playerid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
            GivePlayerWeapon(playerid,WEAPON:24,70);
            GivePlayerWeapon(playerid,WEAPON:3,0);
            Factions_SetOnDuty(playerid,true);
        }
        else
        {
            format(line,sizeof(line),"* Officer %s places his Badge and Gun in his locker.",name);
            Chat_ProxDetector(FACTION_DUTY_RANGE,playerid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
            GivePlayerWeapon(playerid,WEAPON:23,150);
            GivePlayerWeapon(playerid,WEAPON:5,0);
            Factions_SetOnDuty(playerid,false);
        }

        return 1;
    }

    if (!Factions_RunDutyEvent(playerid))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   You are not a Cop !");
    }

    return 1;
}

CMD:invite(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /invite [playerid/PartOfName]");
        return 1;
    }

    new faction = Factions_GetLeader(playerid);

    if (faction < 1)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   you are not authorized to use that command(leaders only)!");
        return 1;
    }

    if (!Factions_IsTarget(targetid))
    {
        return 1;
    }

    if (!Player_IsReady(targetid) || Factions_GetTeam(targetid) != TEAM_GREEN || Factions_GetMember(targetid) != 0 || Factions_CheckPredicate(FACTION_PREDICATE_IN_FAMILY,targetid,false))
    {
        SendClientMessage(playerid,COLOR_GREY,"  That player is currently Wanted / a Different Team / or already a Family Member.");
        return 1;
    }

    if (Factions_CheckPredicate(FACTION_PREDICATE_HAS_JOB,targetid,false))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can't invite him, player has a Job !");
        return 1;
    }

    if (faction == FACTION_MAYOR || faction > FACTION_SCHOOL)
    {
        return 1;
    }

    Account_SetTeam(targetid,Factions_GetInviteTeam(faction));
    Factions_SetTeam(targetid,Factions_GetInviteRuntimeTeam(faction));
    Factions_SetChosenSkin(targetid,Factions_GetChosenSkinFor(faction));
    SetPlayerSkin(targetid,Factions_GetPreviewSkinFor(faction));

    new factionName[20], name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[FACTION_LINE_LEN];
    Factions_GetInviteName(faction,factionName);
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    Factions_SetMember(targetid,faction);
    Factions_SetRank(targetid,1);
    Log_Info("factions","AdmCmd: %s has invited %s to join %s.",name,targetName,factionName);
    format(line,sizeof(line),"   You have Joined the %s, you were invited by Leader %s",factionName,name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"   You have Invited %s to join the %s.",targetName,factionName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    Factions_BeginCharSelect(targetid);
    return 1;
}

CMD:uninvite(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /uninvite [playerid/PartOfName]");
        return 1;
    }

    if (Factions_GetLeader(playerid) < 1)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   you are not authorized to use that command(Leaders only)!");
        return 1;
    }

    if (!Factions_IsTarget(targetid) || !Factions_IsLoaded(targetid) || Factions_GetMember(targetid) <= 0)
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[FACTION_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    Log_Info("factions","AdmCmd: %s has uninvited %s.",name,targetName);
    format(line,sizeof(line),"* You have been kicked from a Family / Police Force, by Leader %s.",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,"* You are now a Civilian again.");
    Factions_SetAccountTeam(targetid,TEAM_GREEN);
    Factions_SetMember(targetid,0);
    Factions_SetRank(targetid,0);
    Account_SetChar(targetid,0);
    Account_SetModel(targetid,Factions_RandomCivilianSkin());
    Factions_OnTeamChangedNotify(targetid);
    Spawn_Begin(targetid);
    format(line,sizeof(line),"   You have kicked %s from his Family / Police Force.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    return 1;
}

CMD:giverank(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /giverank [playerid/PartOfName] [Number(0-6)]");
        return 1;
    }

    new numberText[16];

    if (sscanf(params,"{u}s[16]",numberText))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /giverank [playerid/PartOfName] [Number(0-6)]");
        return 1;
    }

    new rank = strval(numberText);

    if (rank > FACTION_RANK_MAX || rank < 0)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Don't go below number 0, or above number 6!");
        return 1;
    }

    if (Factions_GetLeader(playerid) < 1)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   you are not authorized to use that command(Leaders Only)!");
        return 1;
    }

    if (!Factions_IsTarget(targetid) || !Factions_IsLoaded(targetid))
    {
        return 1;
    }

    if (!Factions_IsIn(targetid,Factions_GetLeader(playerid)))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not in your Family !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[FACTION_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    Factions_SetRank(targetid,rank);
    format(line,sizeof(line),"   You have been promoted to a higher Rank by Leader %s",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"   You have given %s Rank %d.",targetName,rank);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    return 1;
}

CMD:portable(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Factions_IsIn(playerid,FACTION_HITMAN))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Member of the Hitman Agency !");
        return 1;
    }

    if (Factions_IsOnLaptop(playerid))
    {
        SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You have shutdowned your Laptop, and Disconnected from your Agency.");
        Factions_SetOnLaptop(playerid,false);
        return 1;
    }

    SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You have booted up your Laptop, and Connected to your Agency.");
    SendClientMessage(playerid,COLOR_WHITE,"|___ Hitman Agency ___|");
    SendClientMessage(playerid,COLOR_YELLOW2,"|");
    SendClientMessage(playerid,COLOR_YELLOW2,"| - News");
    SendClientMessage(playerid,COLOR_YELLOW2,"| - Contracts");
    SendClientMessage(playerid,COLOR_YELLOW2,"| - Givehit");
    SendClientMessage(playerid,COLOR_YELLOW2,"| - Order");
    SendClientMessage(playerid,COLOR_YELLOW2,"| - Ranks");
    SendClientMessage(playerid,COLOR_YELLOW2,"| - Logout");
    SendClientMessage(playerid,COLOR_WHITE,"|______________|00:00|");
    Factions_SetOnLaptop(playerid,true);
    return 1;
}
