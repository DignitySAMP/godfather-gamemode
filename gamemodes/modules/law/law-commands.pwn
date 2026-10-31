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
#define LAW_MDC_RADIUS (5.0)
#define LAW_MDC_X (253.9280)
#define LAW_MDC_Y (69.6094)
#define LAW_MDC_Z (1003.6406)
#define LAW_CLEAR_RADIUS (3.0)
#define LAW_ARREST_RADIUS (6.0)
#define LAW_ARREST_X (268.3327)
#define LAW_ARREST_Y (77.8972)
#define LAW_ARREST_Z (1001.0391)
#define LAW_RAM_RADIUS (3.0)
#define LAW_CAMERA_RADIUS (8.0)
#define LAW_CAMERA_X (211.6222)
#define LAW_CAMERA_Y (1811.9565)
#define LAW_CAMERA_Z (21.8594)
#define LAW_CAMERA_COUNT (5)
#define LAW_CAMERA_OFF (6)
#define LAW_GATE_RADIUS (8.0)
#define LAW_GATE_X (96.9123)
#define LAW_GATE_Y (1920.5088)
#define LAW_GATE_Z (18.1473)
#define LAW_TAKE_RANK (2)
#define LAW_CLEAR_FAMILY_RANK (4)
#define LAW_CLEAR_FAMILY_PRICE (5000)
#define LAW_PRISON_SECONDS (3600)
#define LAW_ARREST_MAX_MINUTES (20)
#define LAW_ARREST_MAX_PRICE (99999)
#define LAW_ARREST_MAX_BAIL (3000000)
#define LAW_TICKET_MAX (99999)
#define LAW_TICKET_RANGE (5.0)
#define LAW_WANTED_PER_LINE (3)
#define LAW_SPAWN_ANGLE (10.0)

static const Float:s_LawCameras[LAW_CAMERA_COUNT][6] =
{
    {118.1011, 1931.3221, 22.5527, 98.9656, 1920.9819, 18.2180},
    {213.5340, 1875.3075, 17.6406, 213.8679, 1884.1714, 13.8945},
    {266.0640, 1894.8856, 38.6459, 224.0039, 1887.1532, 17.6406},
    {260.8112, 1808.0175, 38.6303, 227.5645, 1818.4778, 17.6406},
    {114.5196, 1814.3483, 38.6029, 123.6176, 1846.4792, 17.6549}
};

static Float:s_LawCameraReturn[MAX_PLAYERS][3];
static Float:s_LawCameraAngle[MAX_PLAYERS];
static s_LawCameraInterior[MAX_PLAYERS];
static bool:s_LawCameraBack[MAX_PLAYERS];

forward Law_OnTakeDrugs(playerid,targetid);
forward Law_OnTakeMaterials(playerid,targetid);
forward Law_OnDeliverPaper(playerid,const params[]);

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
static Law_TakeTarget(playerid,const params[],at,const usage[])
{
    new token[LAW_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,usage);
        return INVALID_PLAYER_ID;
    }

    new targetid = Law_FindPlayer(token);

    if (!Law_IsTarget(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return INVALID_PLAYER_ID;
    }

    if (!Util_IsNear(playerid,targetid,LAW_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return INVALID_PLAYER_ID;
    }

    return targetid;
}

static Law_TakeMessages(playerid,targetid,const what[])
{
    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[LAW_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You have taken away %s's %s.",targetName,what);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* Officer %s has taken away your %s.",name,what);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
}

static Law_TakeLicense(playerid,const params[],at,const usage[],license,const what[])
{
    new targetid = Law_TakeTarget(playerid,params,at,usage);

    if (targetid == INVALID_PLAYER_ID)
    {
        return;
    }

    Law_TakeMessages(playerid,targetid,what);
    License_Set(targetid,license,0);
}

static bool:Law_IsLeaderEscort(playerid)
{
    return Factions_GetLeader(playerid) == FACTION_YAKUZA || Factions_GetLeader(playerid) == FACTION_TAXI;
}

stock bool:Law_AcceptTicket(playerid)
{
    new officerid = Law_GetTicketOfficer(playerid);

    if (officerid == INVALID_PLAYER_ID)
    {
        SendClientMessage(playerid,COLOR_GREY,"   No-one offered you a Ticket !");
        return false;
    }

    if (!IsPlayerConnected(officerid))
    {
        return false;
    }

    if (!Util_IsNear(playerid,officerid,LAW_TICKET_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   The Officer is not near you !");
        return false;
    }

    new name[MAX_PLAYER_NAME + 1], officerName[MAX_PLAYER_NAME + 1], line[LAW_LINE_LEN], amount = Law_GetTicketAmount(playerid);
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(officerid,officerName,sizeof(officerName));
    format(line,sizeof(line),"* You have paid the Ticket of $%d to Officer %s.",amount,officerName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s has paid your Ticket of $%d.",name,amount);
    SendClientMessage(officerid,COLOR_LIGHTBLUE,line);
    Law_AdjustCash(playerid,-amount);
    Law_AdjustCash(officerid,amount);
    Law_ClearTicket(playerid);
    return true;
}

stock Law_CancelTicket(playerid)
{
    Law_ClearTicket(playerid);
}

static Law_ClearTargetRecord(targetid)
{
    Law_ClearWanted(targetid);
    Law_ClearCrime(targetid);
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
CMD:mdc(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Factions_IsCop(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Cop !");
        return 1;
    }

    new at = 0, token[LAW_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /mdc [playerid/PartOfName]");
        return 1;
    }

    new targetid = Law_FindPlayer(token);

    if (!Vehicles_IsCopCar(GetPlayerVehicleID(playerid)) && !Property_IsNear(playerid,LAW_MDC_RADIUS,LAW_MDC_X,LAW_MDC_Y,LAW_MDC_Z))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You are not in a Police Vehicle or in the Police Department.");
        return 1;
    }

    if (!Law_IsTarget(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], line[LAW_LINE_LEN], text[LAW_CRIME_LEN];
    GetPlayerName(targetid,name,sizeof(name));
    SendClientMessage(playerid,TEAM_BLUE_COLOR,"______-=MOBILE DATA COMPUTER=-_______");
    format(line,sizeof(line),"Name : %s",name);
    SendClientMessage(playerid,COLOR_WHITE,line);
    Law_GetCrimeText(targetid,LAW_CRIME_OFFENCE,text);
    format(line,sizeof(line),"Crime : %s",text);
    SendClientMessage(playerid,COLOR_GRAD2,line);
    Law_GetCrimeText(targetid,LAW_CRIME_CLAIMANT,text);
    format(line,sizeof(line),"Claimant : %s",text);
    SendClientMessage(playerid,COLOR_GRAD3,line);
    Law_GetCrimeText(targetid,LAW_CRIME_REPORT,text);
    format(line,sizeof(line),"Reported : %s",text);
    SendClientMessage(playerid,COLOR_GRAD4,line);
    Law_GetCrimeText(targetid,LAW_CRIME_ACCUSED,text);
    format(line,sizeof(line),"Accused : %s",text);
    SendClientMessage(playerid,COLOR_GRAD5,line);
    SendClientMessage(playerid,TEAM_BLUE_COLOR,"_______________________________________");
    return 1;
}

CMD:suspect(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (Law_NeedsDuty(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not on Duty!");
        return 1;
    }

    new at = 0, token[LAW_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/su)spect [playerid/PartOfName] [crime description]");
        return 1;
    }

    new targetid = Law_FindPlayer(token);

    if (!Law_IsOfficer(playerid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You are not a Cop / FBI / National Guard !");
        return 1;
    }

    if (!Law_IsTarget(targetid))
    {
        new line[LAW_LINE_LEN];
        format(line,sizeof(line),"   %s is not an active player.",token);
        SendClientMessage(playerid,COLOR_GRAD1,line);
        return 1;
    }

    if (Law_IsPolice(targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You can't suspect a Cop !");
        return 1;
    }

    new reason[LAW_REASON_LEN];

    if (Util_ReadRest(params,at,reason) == 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: (/su)spect [playerid/PartOfName] [crime text]");
        return 1;
    }

    if (Law_GetWantedPoints(targetid) == 0)
    {
        Law_SetWantedPoints(targetid,3);
    }
    else
    {
        Law_AddWantedPoints(targetid,2);
    }

    Law_SetCriminal(targetid,playerid,reason);
    return 1;
}

ALT:su=CMD:suspect;

CMD:wanted(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Law_IsOfficer(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You're not a Cop / FBI / National Guard !");
        return 1;
    }

    new line[LAW_LINE_LEN], entry[MAX_PLAYER_NAME + 12], count = 0;
    SendClientMessage(playerid,COLOR_GREEN,"Current Wanted Suspects:");

    foreach (new i : Player)
    {
        if (IsPlayerNPC(i) || Law_GetWantedLevel(i) <= 1)
        {
            continue;
        }

        new name[MAX_PLAYER_NAME + 1];
        GetPlayerName(i,name,sizeof(name));
        format(entry,sizeof(entry),"%s: %d",name,Law_GetWantedLevel(i));
        strcat(line,entry,sizeof(line));
        count++;

        if (count > LAW_WANTED_PER_LINE)
        {
            SendClientMessage(playerid,COLOR_YELLOW,line);
            count = 0;
            line[0] = EOS;
        }
        else
        {
            strcat(line,", ",sizeof(line));
        }
    }

    if (count <= LAW_WANTED_PER_LINE && count > 0)
    {
        line[strlen(line) - 2] = '.';
        SendClientMessage(playerid,COLOR_YELLOW,line);
    }

    return 1;
}

CMD:bail(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Law_GetJailed(playerid) != LAW_JAIL_CELL)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   You are not in Jail !");
        return 1;
    }

    new price = Law_GetBail(playerid);

    if (price <= 0)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   You don't have a Bail Price !");
        return 1;
    }

    if (Account_GetCash(playerid) < price)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   You can't afford the Bail Price !");
        return 1;
    }

    new line[LAW_LINE_LEN];
    format(line,sizeof(line),"You bailed yourself out for: $%d",price);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    Law_AdjustCash(playerid,-price);
    Law_SetBail(playerid,0);
    Law_CancelLawyer(playerid);
    Law_SetJailTime(playerid,1);
    return 1;
}

CMD:clear(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new member = Factions_GetMember(playerid), leader = Factions_GetLeader(playerid), rank = Factions_GetRank(playerid);
    new at = 0, token[LAW_TOKEN_LEN];

    if (Law_IsPoliceOrLeader(playerid))
    {
        if (!Property_IsNear(playerid,LAW_CLEAR_RADIUS,LAW_MDC_X,LAW_MDC_Y,LAW_MDC_Z))
        {
            SendClientMessage(playerid,COLOR_GRAD2,"   You are not inside the Police Station!");
            return 1;
        }

        if (!Util_ReadToken(params,at,token))
        {
            SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /clear [playerid/PartOfName]");
            return 1;
        }

        new targetid = Law_FindPlayer(token);

        if (!Law_IsTarget(targetid))
        {
            SendClientMessage(playerid,COLOR_GREY,"   Invalid ID/Name!");
            return 1;
        }

        if (targetid == playerid)
        {
            SendClientMessage(playerid,COLOR_GREY,"You cannot Clear yourself!");
            return 1;
        }

        new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[LAW_LINE_LEN];
        GetPlayerName(targetid,targetName,sizeof(targetName));
        GetPlayerName(playerid,name,sizeof(name));
        format(line,sizeof(line),"* You cleared the Records and Wanted Points of %s.",targetName);
        SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
        format(line,sizeof(line),"* Officer %s has cleared your Records and Wanted Points.",name);
        SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
        Law_ClearRecord(targetid);
        return 1;
    }

    if (member == FACTION_LCN || member == FACTION_YAKUZA || leader == FACTION_LCN || leader == FACTION_YAKUZA)
    {
        if (!Util_ReadToken(params,at,token))
        {
            SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /clear [playerid/PartOfName]");
            return 1;
        }

        new targetid = Law_FindPlayer(token);

        if (!Law_IsTarget(targetid))
        {
            SendClientMessage(playerid,COLOR_GREY,"   Invalid ID/Name!");
            return 1;
        }

        if (targetid == playerid)
        {
            SendClientMessage(playerid,COLOR_GREY,"You cannot Clear yourself!");
            return 1;
        }

        if (rank < LAW_CLEAR_FAMILY_RANK)
        {
            SendClientMessage(playerid,COLOR_GREY,"   You need Rank 4 to clear someone's Wanted Points + Records !");
            return 1;
        }

        if (Account_GetCash(playerid) < LAW_CLEAR_FAMILY_PRICE)
        {
            SendClientMessage(playerid,COLOR_GREY,"   You need $5000 to Clear your Family Member !");
            return 1;
        }

        new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[LAW_LINE_LEN];
        GetPlayerName(targetid,targetName,sizeof(targetName));
        GetPlayerName(playerid,name,sizeof(name));

        if (member > 0)
        {
            if (Factions_GetMember(targetid) != member)
            {
                SendClientMessage(playerid,COLOR_GREY,"   That player is not in your Family !");
                return 1;
            }

            format(line,sizeof(line),"* You cleared the Records and Wanted Points of %s for $5000.",targetName);
            SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
            format(line,sizeof(line),"* Family Member %s with Rank %d, has cleared your Records and Wanted Points.",name,rank);
            SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
        }
        else
        {
            if (Factions_GetMember(targetid) != leader)
            {
                SendClientMessage(playerid,COLOR_GREY,"   That player is not in your Family !");
                return 1;
            }

            format(line,sizeof(line),"* You cleared the Records and Wanted Points of %s for $5000.",targetName);
            SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
            format(line,sizeof(line),"* Family Leader %s, has cleared your Records and Wanted Points.",name);
            SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
        }

        Law_ClearTargetRecord(targetid);
        Law_AdjustCash(playerid,-LAW_CLEAR_FAMILY_PRICE);
        return 1;
    }

    SendClientMessage(playerid,COLOR_GREY,"   You are not a Cop / FBI / National Guard / Family Member !");
    return 1;
}

CMD:ticket(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Law_IsPoliceOrLeader(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Cop!");
        return 1;
    }

    if (Law_NeedsDuty(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not on Duty!");
        return 1;
    }

    new at = 0, token[LAW_TOKEN_LEN], priceText[LAW_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token) || !Util_ReadToken(params,at,priceText))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /ticket [playerid/PartOfName] [price] [reason]");
        return 1;
    }

    new targetid = Law_FindPlayer(token), price = strval(priceText);

    if (price < 1 || price > LAW_TICKET_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Ticket Money can't be below 1 or higher than 99999 !");
        return 1;
    }

    if (!Law_IsTarget(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,LAW_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    new reason[LAW_REASON_LEN];

    if (Util_ReadRest(params,at,reason) == 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /ticket [playerid/PartOfName] [price] [reason]");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[LAW_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"* You gave %s a Ticket costing $%d, reason: %s",targetName,price,reason);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* Officer %s has given you a Ticket costing $%d, reason: %s",name,price,reason);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,"* Type /accept ticket, to accept it.");
    Law_SetTicket(targetid,playerid,price);
    return 1;
}

CMD:arrest(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Law_IsOfficer(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Cop / FBI / National Guard !");
        return 1;
    }

    if (Law_NeedsDuty(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not on Duty!");
        return 1;
    }

    if (!Property_IsNear(playerid,LAW_ARREST_RADIUS,LAW_ARREST_X,LAW_ARREST_Y,LAW_ARREST_Z))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not near the Jail, can't Arrest !");
        return 1;
    }

    new at = 0, token[LAW_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /arrest [price] [time (minutes)] [bail (0=no 1=yes)] [bailprice]");
        return 1;
    }

    new price = strval(token);

    if (price < 1 || price > LAW_ARREST_MAX_PRICE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Jail Price can't be below $1 or above $99999 !");
        return 1;
    }

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /arrest [price] [time (minutes)] [bail (0=no 1=yes)] [bailprice]");
        return 1;
    }

    new minutes = strval(token);

    if (minutes < 1 || minutes > LAW_ARREST_MAX_MINUTES)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Jail Time Minutes can't be below 1 or above 20 (Take the person to prison then) !");
        return 1;
    }

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /arrest [price] [time (minutes)] [bail (0=no 1=yes)] [bailprice]");
        return 1;
    }

    new bail = strval(token);

    if (bail < 0 || bail > 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Jail Bailing can't be below 0 or above 1 !");
        return 1;
    }

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /arrest [price] [time (minutes)] [bail (0=no 1=yes)] [bailprice]");
        return 1;
    }

    new bailPrice = strval(token);

    if (bailPrice < 0 || bailPrice > LAW_ARREST_MAX_BAIL)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Jail Bailing can't be below $0 or above $3000000 !");
        return 1;
    }

    new suspect = Law_GetClosestPlayer(playerid);

    if (!Law_IsTarget(suspect))
    {
        SendClientMessage(playerid,COLOR_GREY,"   No-one close enough to arrest.");
        return 1;
    }

    if (Law_GetDistance(playerid,suspect) >= LAW_CLOSE_RANGE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   No-one close enough to arrest.");
        return 1;
    }

    if (Law_GetWantedLevel(suspect) < 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Player must be at least Wanted Level 1 !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[LAW_LINE_LEN];
    GetPlayerName(suspect,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"* You arrested %s !",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    new charged = Account_GetCash(suspect) < price ? Account_GetCash(suspect) : price;

    if (charged < 0)
    {
        charged = 0;
    }

    Law_AdjustCash(suspect,-charged);
    format(line,sizeof(line),"arrested by %s ~n~    for $%d",name,charged);
    GameTextForPlayer(suspect,line,5000,5);
    ResetPlayerWeapons(suspect);

    if (Factions_IsIn(playerid,FACTION_POLICE))
    {
        format(line,sizeof(line),"<< Officer %s arrested suspect %s >>",name,targetName);
        Law_SendNews(COLOR_LIGHTRED,line);
    }
    else if (Factions_IsIn(playerid,FACTION_FBI))
    {
        format(line,sizeof(line),"<< FBI Agent %s arrested suspect %s >>",name,targetName);
        Law_SendNews(COLOR_LIGHTRED,line);
    }
    else if (Factions_IsIn(playerid,FACTION_NATIONAL_GUARD))
    {
        format(line,sizeof(line),"<< Soldier %s arrested suspect %s >>",name,targetName);
        Law_SendNews(COLOR_LIGHTRED,line);
    }

    Law_Jail(suspect,minutes * 60,LAW_JAIL_CELL);

    if (bail == 1)
    {
        Law_SetBail(suspect,bailPrice);
        format(line,sizeof(line),"You are jailed for %d seconds.   Bail: $%d",Law_GetJailTime(suspect),bailPrice);
    }
    else
    {
        Law_SetBail(suspect,0);
        format(line,sizeof(line),"You are jailed for %d seconds.   Bail: Unable",Law_GetJailTime(suspect));
    }

    SendClientMessage(suspect,COLOR_LIGHTBLUE,line);
    Law_SetArrested(suspect,Law_GetArrested(suspect) + 1);
    Law_SetFree(suspect,playerid,"Got Arrested");
    Law_ClearWanted(suspect);
    Law_SetLawyerWait(suspect,1);
    return 1;
}

CMD:take(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Law_IsOfficer(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Cop !");
        return 1;
    }

    if (Factions_GetRank(playerid) < LAW_TAKE_RANK)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You need to be Rank 2 or Higher for this action !");
        return 1;
    }

    new at = 0, name[LAW_TOKEN_LEN];

    if (!Util_ReadToken(params,at,name))
    {
        SendClientMessage(playerid,COLOR_WHITE,"|__________________ Take Licenses __________________|");
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /take [licensename] [playerid/PartOfName]");
        SendClientMessage(playerid,COLOR_GREY,"Available names: Driverslicense, Flyinglicense, Boatlicense, Gunlicense, Weapons, Drugs, Materials");
        SendClientMessage(playerid,COLOR_WHITE,"|___________________________________________________|");
        return 1;
    }

    if (!strcmp(name,"driverslicense",true))
    {
        Law_TakeLicense(playerid,params,at,"USAGE: /take driverslicense [playerid/PartOfName]",LICENSE_CAR,"Drivers License");
    }
    else if (!strcmp(name,"flyinglicense",true))
    {
        Law_TakeLicense(playerid,params,at,"USAGE: /take flyinglicense [playerid/PartOfName]",LICENSE_FLY,"Flying License");
    }
    else if (!strcmp(name,"gunlicense",true))
    {
        Law_TakeLicense(playerid,params,at,"USAGE: /take gunlicense [playerid/PartOfName]",LICENSE_GUN,"Weapon License");
    }
    else if (!strcmp(name,"boatlicense",true))
    {
        Law_TakeLicense(playerid,params,at,"USAGE: /take boatlicense [playerid/PartOfName]",LICENSE_BOAT,"Boat License");
    }
    else if (!strcmp(name,"weapons",true))
    {
        new targetid = Law_TakeTarget(playerid,params,at,"USAGE: /take weapons [playerid/PartOfName]");

        if (targetid != INVALID_PLAYER_ID)
        {
            Law_TakeMessages(playerid,targetid,"Weapons");
            ResetPlayerWeapons(targetid);
            Weapons_ClearStored(targetid);
        }
    }
    else if (!strcmp(name,"drugs",true))
    {
        new targetid = Law_TakeTarget(playerid,params,at,"USAGE: /take drugs [playerid/PartOfName]");

        if (targetid != INVALID_PLAYER_ID)
        {
            Law_TakeMessages(playerid,targetid,"Drugs");
            pawn_call_public("Law_OnTakeDrugs","dd",playerid,targetid);
        }
    }
    else if (!strcmp(name,"materials",true))
    {
        new targetid = Law_TakeTarget(playerid,params,at,"USAGE: /take materials [playerid/PartOfName]");

        if (targetid != INVALID_PLAYER_ID)
        {
            Law_TakeMessages(playerid,targetid,"Materials");
            pawn_call_public("Law_OnTakeMaterials","dd",playerid,targetid);
        }
    }
    else
    {
        SendClientMessage(playerid,COLOR_GREY,"   Unknown Take name !");
    }

    return 1;
}

CMD:ram(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Law_IsPoliceOrLeader(playerid) && !Law_IsLeaderEscort(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Cop / Soldier !");
        return 1;
    }

    new house = Houses_FindNearEntrance(playerid,LAW_RAM_RADIUS);

    if (Houses_IsValid(house) && Houses_Enter(playerid,house,true))
    {
        Property_GameText(playerid,"~r~Breached the door",5000,1);
    }

    return 1;
}

CMD:camera(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Factions_IsCop(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Cop / Soldier !");
        return 1;
    }

    if (!Property_IsNear(playerid,LAW_CAMERA_RADIUS,LAW_CAMERA_X,LAW_CAMERA_Y,LAW_CAMERA_Z))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not at the Area51 Security Panel !");
        return 1;
    }

    new at = 0, token[LAW_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /camera [number 1 - 6]  (6 = OFF)");
        return 1;
    }

    new number = strval(token);

    if (number < 1 || number > LAW_CAMERA_OFF)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Camera Number can't be below 1 or above 6 !");
        return 1;
    }

    TogglePlayerControllable(playerid,false);
    GetPlayerPos(playerid,s_LawCameraReturn[playerid][0],s_LawCameraReturn[playerid][1],s_LawCameraReturn[playerid][2]);

    if (number == LAW_CAMERA_OFF)
    {
        Medics_ClearBill(playerid);
        TogglePlayerControllable(playerid,true);
        GetPlayerFacingAngle(playerid,s_LawCameraAngle[playerid]);
        s_LawCameraInterior[playerid] = GetPlayerInterior(playerid);
        s_LawCameraBack[playerid] = true;
        SetSpawnInfo(playerid,Account_GetTeam(playerid),Account_GetModel(playerid),s_LawCameraReturn[playerid][0],s_LawCameraReturn[playerid][1],s_LawCameraReturn[playerid][2],LAW_SPAWN_ANGLE,WEAPON:0,0,WEAPON:0,0,WEAPON:0,0);
        SpawnPlayer(playerid);
        return 1;
    }

    SetPlayerCameraPos(playerid,s_LawCameras[number - 1][0],s_LawCameras[number - 1][1],s_LawCameras[number - 1][2]);
    SetPlayerCameraLookAt(playerid,s_LawCameras[number - 1][3],s_LawCameras[number - 1][4],s_LawCameras[number - 1][5]);
    return 1;
}

CMD:deliver(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new bool:isPaper = Law_CheckPaper(playerid);

    if (!isPaper && !Law_IsPoliceOrLeader(playerid) && !Law_IsLeaderEscort(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Paper Boy !");
        return 1;
    }

    if (!Law_IsOfficer(playerid))
    {
        if (isPaper)
        {
            pawn_call_public("Law_OnDeliverPaper","ds",playerid,params);
        }

        return 1;
    }

    if (!Property_IsNear(playerid,LAW_GATE_RADIUS,LAW_GATE_X,LAW_GATE_Y,LAW_GATE_Z))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not at the Area51 Delivery Gate !");
        return 1;
    }

    new at = 0, token[LAW_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /deliver [playerid/PartOfName]");
        return 1;
    }

    new targetid = Law_FindPlayer(token);

    if (!Law_IsTarget(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can't throw yourself into Fort DeMorgan !");
        return 1;
    }

    if (Law_GetWantedLevel(targetid) < 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   The player needs at least Wanted Level 1 to be thrown into Fort DeMorgan !");
        return 1;
    }

    if (Law_IsPolice(targetid) || Law_IsLeaderEscort(targetid))
    {
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,LAW_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[LAW_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"* You've brought %s to Fort DeMorgan.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s brought you to Fort DeMorgan.",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    GameTextForPlayer(targetid,"~w~Welcome to ~n~~r~Fort DeMorgan",5000,3);
    Law_ClearWanted(targetid);
    Law_Jail(targetid,LAW_PRISON_SECONDS,LAW_JAIL_PRISON);
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
    s_LawCameraBack[playerid] = false;
}

hook OnPlayerDeath(playerid,killerid,WEAPON:reason)
{
    s_LawCameraBack[playerid] = false;
}

hook Spawn_OnChoose(playerid)
{
    if (s_LawCameraBack[playerid])
    {
        Spawn_SetPoint(playerid,s_LawCameraReturn[playerid][0],s_LawCameraReturn[playerid][1],s_LawCameraReturn[playerid][2],s_LawCameraAngle[playerid],s_LawCameraInterior[playerid],SPAWN_PRIORITY_CAMERA);
        s_LawCameraBack[playerid] = false;
    }
}
