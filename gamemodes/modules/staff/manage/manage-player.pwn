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
#define MANAGE_LEADER_LEVEL_MAX (11)
#define MANAGE_LEADER_TEAM (11)
#define MANAGE_FAMILY_NUMBER_MAX (10)
#define MANAGE_FAMILY_MEMBERS_MAX (10)
#define MANAGE_STAT_LEVEL (1)
#define MANAGE_STAT_SPAWN_HEALTH (2)
#define MANAGE_STAT_UPGRADES (3)
#define MANAGE_STAT_MODEL (4)
#define MANAGE_STAT_BANK (5)
#define MANAGE_STAT_PHONE (6)
#define MANAGE_STAT_RESPECT (7)
#define MANAGE_STAT_HOUSE_KEY (8)
#define MANAGE_STAT_BUSINESS_KEY (9)
#define MANAGE_STAT_DONATE (10)
#define MANAGE_STAT_FAMILY (11)
#define MANAGE_STAT_DETECTIVE (12)
#define MANAGE_STAT_LAWYER (13)
#define MANAGE_STAT_MECHANIC (14)
#define MANAGE_STAT_NEWS (15)
#define MANAGE_STAT_JACKER (16)
#define MANAGE_STAT_DRUGS (17)
#define MANAGE_STAT_SEX (18)
#define MANAGE_STAT_BOX (19)
#define MANAGE_STAT_JOB (77)
#define MANAGE_STAT_CONTRACT (88)
#define MANAGE_GUN_MAX (46)
#define MANAGE_AMMO_MAX (999)

static const s_ManageLeaderSkins[MANAGE_LEADER_LEVEL_MAX + 1] =
{
    0, 288, 286, 287, 228, 113, 120, 147, 294, 227, 61, 171
};

static const s_ManageForceTeams[9] =
{
    0, 5, 6, 7, 8, 9, 2, 2, 10
};

static const s_ManageForceSkins[9] =
{
    0, 59, 121, 98, 46, 174, 280, 164, 186
};

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
static Manage_SendSetStatUsage(playerid)
{
    SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /setstat [playerid/PartOfName] [statcode] [amount]");
    SendClientMessage(playerid,COLOR_GRAD4,"|1 Level |2 SpawnHealth |3 UpgradePoints |4 Model ");
    SendClientMessage(playerid,COLOR_GRAD3,"|5 BankAccount |6 PhoneNumber |7 RespectPoints ");
    SendClientMessage(playerid,COLOR_GRAD2,"|8 HouseKey |9 BizKey |10 DonateRank |11 FMember");
    SendClientMessage(playerid,COLOR_GRAD2,"|12 Det |13 Lawyer |14 Fixer |15 News |16 Jack |17 Drug |18 Sex |19 Box");
}

static Manage_SendStat(playerid,const text[],amount)
{
    new line[STAFF_LINE_LEN];
    format(line,sizeof(line),text,amount);
    SendClientMessage(playerid,COLOR_GRAD1,line);
}

static Manage_ApplyStat(playerid,targetid,stat,amount)
{
    switch (stat)
    {
        case MANAGE_STAT_LEVEL:
        {
            Account_SetLevel(targetid,amount);
            Manage_SendStat(playerid,"   The Player Was Set To Level %d",amount);
        }
        case MANAGE_STAT_SPAWN_HEALTH:
        {
            Progress_SetSpawnHealth(targetid,float(amount));
            Manage_SendStat(playerid,"   The Player Was Set To %d Spawnhealth ",amount);
        }
        case MANAGE_STAT_UPGRADES:
        {
            Progress_SetUpgradePoints(targetid,amount);
            Manage_SendStat(playerid,"   The Player Was Set To %d Upgrade Points",amount);
        }
        case MANAGE_STAT_MODEL:
        {
            Account_SetModel(targetid,amount);
            Manage_SendStat(playerid,"   The Player Was Set To Model %d",amount);
        }
        case MANAGE_STAT_BANK:
        {
            Bank_SetBalance(targetid,amount);
            Manage_SendStat(playerid,"   The Player Account Was Set To $%d",amount);
        }
        case MANAGE_STAT_RESPECT:
        {
            Account_SetRespect(targetid,amount);
            Manage_SendStat(playerid,"   The Player Respect Points Were Set To %d",amount);
        }
        case MANAGE_STAT_HOUSE_KEY:
        {
            Houses_SetKey(targetid,amount);
            Manage_SendStat(playerid,"   The Player House Key Was Set To %d",amount);
        }
        case MANAGE_STAT_BUSINESS_KEY:
        {
            Business_SetKey(targetid,amount);
            Manage_SendStat(playerid,"   The Player Business Key Was Set To %d",amount);
        }
        case MANAGE_STAT_DONATE:
        {
            Account_SetDonateRank(targetid,amount);
            Manage_SendStat(playerid,"   The Player DonateRank Was Set To %d",amount);
        }
        case MANAGE_STAT_FAMILY:
        {
            Families_SetMember(targetid,amount);
            Manage_SendStat(playerid,"   The Player Family Member Was Set To %d",amount);
        }
        case MANAGE_STAT_DETECTIVE:
        {
            Progress_SetSkill(targetid,PROGRESS_SKILL_DETECTIVE,amount);
            Manage_SendStat(playerid,"   The Player Detective Skill Set To %d",amount);
        }
        case MANAGE_STAT_LAWYER:
        {
            Progress_SetSkill(targetid,PROGRESS_SKILL_LAW,amount);
            Manage_SendStat(playerid,"   The Player Lawyer Skill Set To %d",amount);
        }
        case MANAGE_STAT_MECHANIC:
        {
            Progress_SetSkill(targetid,PROGRESS_SKILL_MECH,amount);
            Manage_SendStat(playerid,"   The Player Car Mechanic Skill Set To %d",amount);
        }
        case MANAGE_STAT_NEWS:
        {
            Progress_SetSkill(targetid,PROGRESS_SKILL_NEWS,amount);
            Manage_SendStat(playerid,"   The Player News Reporter Skill Set To %d",amount);
        }
        case MANAGE_STAT_JACKER:
        {
            Progress_SetSkill(targetid,PROGRESS_SKILL_JACK,amount);
            Manage_SendStat(playerid,"   The Player Car Jacker Skill Set To %d",amount);
        }
        case MANAGE_STAT_DRUGS:
        {
            Progress_SetSkill(targetid,PROGRESS_SKILL_DRUGS,amount);
            Manage_SendStat(playerid,"   The Player Drug Dealer Skill Set To %d",amount);
        }
        case MANAGE_STAT_SEX:
        {
            Progress_SetSkill(targetid,PROGRESS_SKILL_SEX,amount);
            Manage_SendStat(playerid,"   The Player Sex Skill Set To %d",amount);
        }
        case MANAGE_STAT_BOX:
        {
            Progress_SetSkill(targetid,PROGRESS_SKILL_BOX,amount);
            Manage_SendStat(playerid,"   The Player Box Skill Set To %d",amount);
        }
        case MANAGE_STAT_JOB:
        {
            Jobs_SetJob(targetid,amount);
            Manage_SendStat(playerid,"   The Player Job Set To %d",amount);
        }
        case MANAGE_STAT_CONTRACT:
        {
            Jobs_SetContractTime(targetid,amount);
            Manage_SendStat(playerid,"   The Player Job Contract Time Set To %d",amount);
        }
        case MANAGE_STAT_PHONE:
        {
            Phone_SetNumber(targetid,amount);
            Manage_SendStat(playerid,"   The Player Phone Number Was Set To %d",amount);
        }
        default:
        {
            SendClientMessage(playerid,COLOR_GRAD1,"   Invalid Stat Code");
        }
    }
}

static bool:Manage_ValidAdminLevel(level)
{
    return (level >= 0 && level <= ADMIN_LEVEL_MANAGER) || level == ADMIN_LEVEL_DEVELOPER || level == ADMIN_LEVEL_OWNER;
}

static bool:Manage_ValidGun(gun)
{
    if (gun < 1 || gun > MANAGE_GUN_MAX)
    {
        return false;
    }

    switch (gun)
    {
        case 1, 2, 9, 17, 19, 20, 21, 27, 36, 38, 39, 40, 44, 45:
        {
            return false;
        }
    }

    return true;
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
CMD<ADMIN_LEVEL_MANAGER>:setstat(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        Manage_SendSetStatUsage(playerid);
        return 1;
    }

    new targetid = Staff_FindPlayer(token);

    if (!Staff_IsTarget(targetid))
    {
        return 1;
    }

    if (!Util_ReadToken(params,at,token))
    {
        Manage_SendSetStatUsage(playerid);
        return 1;
    }

    new stat = strval(token);

    if (!Util_ReadToken(params,at,token))
    {
        Manage_SendSetStatUsage(playerid);
        return 1;
    }

    Manage_ApplyStat(playerid,targetid,stat,strval(token));
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:setfamily(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /setfamily [Family] [code] [amount]");
        SendClientMessage(playerid,COLOR_GRAD4,"|1 Members");
        return 1;
    }

    new family = strval(token);

    if (family < 1 || family > MANAGE_FAMILY_NUMBER_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   FamilyNr can't be below 1 or above 10 !");
        return 1;
    }

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /setfamily [Family] [code] [amount]");
        SendClientMessage(playerid,COLOR_GRAD4,"|1 Members");
        return 1;
    }

    new stat = strval(token);

    if (stat < 1 || stat > 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Stat Code can't be below 1 or above 1 !");
        return 1;
    }

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /setfamily [Family] [code] [amount]");
        SendClientMessage(playerid,COLOR_GRAD4,"|1 Members");
        return 1;
    }

    new amount = strval(token);

    if (amount < 1 || amount > MANAGE_FAMILY_MEMBERS_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Amount can't be below 1 or above 10 !");
        return 1;
    }

    new name[FAMILY_NAME_LEN], line[STAFF_LINE_LEN];
    family--;
    Families_SetMembers(family,amount);
    Families_GetName(family,name);
    format(line,sizeof(line),"   Family %s set to %d members",name,amount);
    SendClientMessage(playerid,COLOR_GREY,line);
    return 1;
}

CMD<ADMIN_LEVEL_DEVELOPER>:makeadmin(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /makeadmin [playerid/PartOfName] [level(0-4,1337,1338)]");
        return 1;
    }

    new targetid = Staff_FindPlayer(token), level = 0;

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /makeadmin [playerid/PartOfName] [level(0-4,1337,1338)]");
        return 1;
    }

    level = strval(token);

    if (!Manage_ValidAdminLevel(level))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /makeadmin [playerid/PartOfName] [level(0-4,1337,1338)]");
        return 1;
    }

    if (!Staff_IsTarget(targetid))
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    Account_SetAdminLevel(targetid,level);
    Log_Info("staff","AdmCmd: %s has promoted %s to a level %d admin.",name,targetName,level);
    format(line,sizeof(line),"   You have been promoted to a level %d admin by %s",level,name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"   You have promoted %s to a level %d admin.",targetName,level);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    return 1;
}

CMD<ADMIN_LEVEL_DEVELOPER>:makeleader(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /makeleader [playerid/PartOfName] [Number(0-11)]");
        return 1;
    }

    new targetid = Staff_FindPlayer(token), level = 0;

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /makeleader [playerid/PartOfName] [Number(0-11)]");
        return 1;
    }

    level = strval(token);

    if (level > MANAGE_LEADER_LEVEL_MAX || level < 0)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Don't go below number 0, or above number 11!");
        return 1;
    }

    if (!Staff_IsTarget(targetid))
    {
        return 1;
    }

    if (Factions_GetMember(targetid) > 0 || Families_IsIn(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is in a Faction / Family !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    Factions_SetLeader(targetid,level);
    format(line,sizeof(line),"   You have been promoted to Leader to your requested Faction by Admin %s",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"   You have given %s control to run Faction Number %d.",targetName,level);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    Account_SetChar(targetid,s_ManageLeaderSkins[level]);
    Factions_SetAccountTeam(targetid,MANAGE_LEADER_TEAM);
    SetPlayerSkin(targetid,s_ManageLeaderSkins[level]);
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:forceskin(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /forceskin [playerid/PartOfName]");
        return 1;
    }

    new targetid = Staff_FindPlayer(token);

    if (!Staff_IsTarget(targetid))
    {
        return 1;
    }

    new member = Factions_GetMember(targetid);

    if (member < 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not in a Family / Force !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"* You are forced to Change your Skin by Admin %s.",name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* You have forced %s To change his Skin.",targetName);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);

    if (member >= sizeof(s_ManageForceTeams))
    {
        return 1;
    }

    Account_SetTeam(targetid,s_ManageForceTeams[member]);
    Factions_SetChosenSkin(targetid,s_ManageForceSkins[member]);
    Factions_BeginCharSelect(targetid);
    return 1;
}

CMD<ADMIN_LEVEL_MOD>:setteam(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /setteam [playerid/PartOfName] [team(1-11)]");
        return 1;
    }

    new targetid = Staff_FindPlayer(token), team = 0;

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /setteam [playerid/PartOfName] [team(1-11)]");
        return 1;
    }

    team = strval(token);

    if (team < TEAM_CYAN || team > TEAM_ADMIN)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /setteam [playerid/PartOfName] [team(1-11)]");
        return 1;
    }

    if (!Staff_IsTarget(targetid))
    {
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[STAFF_LINE_LEN];
    GetPlayerName(targetid,targetName,sizeof(targetName));
    GetPlayerName(playerid,name,sizeof(name));
    Factions_SetAccountTeam(targetid,team);
    Weapons_Apply(targetid);
    Spawn_Place(targetid);
    Law_ClearCrime(targetid);
    Log_Info("staff","AdmCmd: %s has switched %s to team %d.",name,targetName,team);
    format(line,sizeof(line),"   You have been switched to team %d by %s",team,name);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"   You have switched %s to team %d.",targetName,team);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:givegun(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /givegun [playerid/PartOfName] [weaponid(eg. 46 = Parachute)] [ammo]");
        return 1;
    }

    new targetid = Staff_FindPlayer(token);

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /givegun [playerid/PartOfName] [weaponid] [ammo]");
        SendClientMessage(playerid,COLOR_GRAD4,"3(Club) 4(knife) 5(bat) 6(Shovel) 7(Cue) 8(Katana) 10-13(Dildo) 14(Flowers) 16(Grenades) 18(Molotovs) 22(Pistol) 23(SPistol)");
        SendClientMessage(playerid,COLOR_GRAD3,"24(Eagle) 25(shotgun) 29(MP5) 30(AK47) 31(M4) 33(Rifle) 34(Sniper) 37(Flamethrower) 41(spray) 42(exting) 43(Camera) 46(Parachute)");
        return 1;
    }

    new gun = strval(token);

    if (!Manage_ValidGun(gun))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   wrong WeaponID!");
        return 1;
    }

    new ammo = 0;

    if (Util_ReadToken(params,at,token))
    {
        ammo = strval(token);
    }

    if (ammo < 1 || ammo > MANAGE_AMMO_MAX)
    {
        SendClientMessage(playerid,COLOR_GRAD1,"   Don't go below 1 or above 999 bullets!");
        return 1;
    }

    if (Staff_IsTarget(targetid))
    {
        GivePlayerWeapon(targetid,WEAPON:gun,ammo);
    }

    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:sethp(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /sethp [playerid/PartOfName] [health]");
        return 1;
    }

    new targetid = Staff_FindPlayer(token), health = 0;

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /sethp [playerid/PartOfName] [health]");
        return 1;
    }

    health = strval(token);

    if (Staff_IsTarget(targetid))
    {
        SetPlayerHealth(targetid,float(health));
    }

    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:setarmor(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /setarmor [playerid/PartOfName] [armor]");
        return 1;
    }

    new targetid = Staff_FindPlayer(token), armour = 0;

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /setarmor [playerid/PartOfName] [armor]");
        return 1;
    }

    armour = strval(token);

    if (Staff_IsTarget(targetid))
    {
        SetPlayerArmour(targetid,float(armour));
    }

    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:money(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /money [playerid/PartOfName] [money]");
        return 1;
    }

    new targetid = Staff_FindPlayer(token), amount = 0;

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /money [playerid/PartOfName] [money]");
        return 1;
    }

    amount = strval(token);

    if (Staff_IsTarget(targetid))
    {
        Account_SetCash(targetid,amount);
    }

    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:givemoney(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /givemoney [playerid/PartOfName] [money]");
        return 1;
    }

    new targetid = Staff_FindPlayer(token), amount = 0;

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /givemoney [playerid/PartOfName] [money]");
        return 1;
    }

    amount = strval(token);

    if (Staff_IsTarget(targetid))
    {
        Account_SetCash(targetid,Account_GetCash(targetid) + amount);
    }

    return 1;
}
