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
#define PROGRESS_SKILL_LISTED (10)
#define PROGRESS_SKILL_TIERS (4)
#define PROGRESS_LEVEL_UP_SOUND (1052)
#define PROGRESS_LEVEL_UP_POINTS (2)
#define PROGRESS_HEALTH_STEP (5.0)
#define PROGRESS_HEALTH_COST (1)
#define PROGRESS_PERK_COST (2)

static const s_ProgressSkillOrder[PROGRESS_SKILL_LISTED] =
{
    PROGRESS_SKILL_DETECTIVE,
    PROGRESS_SKILL_LAW,
    PROGRESS_SKILL_SEX,
    PROGRESS_SKILL_DRUGS,
    PROGRESS_SKILL_JACK,
    PROGRESS_SKILL_NEWS,
    PROGRESS_SKILL_MECH,
    PROGRESS_SKILL_CAR,
    PROGRESS_SKILL_BOX,
    PROGRESS_SKILL_FISH
};

static const s_ProgressSkillTitles[PROGRESS_SKILL_LISTED][16] =
{
    "Detective",
    "Lawyer",
    "Whore",
    "Drug Dealer",
    "Car Jacker",
    "News Reporter",
    "Car Mechanic",
    "Car Dealer",
    "Boxing",
    "Fishing"
};

static const s_ProgressSkillFirstText[PROGRESS_SKILL_LISTED][64] =
{
    "You need to find %d more people to Level up.",
    "You need to free %d more people to Level up.",
    "You need to have sex %d times more to Level up.",
    "You need to sell drugs %d times more to Level up.",
    "You need to drop %d cars more to Level up.",
    "You need to use /news %d times more to Level up.",
    "You need to fix/fill a car for %d times more to Level up.",
    "You need to sell %d more cars to people to Level up.",
    "You need to Win %d more Matches to Level up.",
    "You need to Fish %d more Fishes to Level up."
};

static const s_ProgressSkillLaterText[PROGRESS_SKILL_LISTED][64] =
{
    "You need to find %d more people to Level up.",
    "You need to free %d more people to Level up.",
    "You need to have sex %d times more to Level up.",
    "You need to sell drugs %d times more to Level up.",
    "You need to drop %d cars more to Level up.",
    "You need to use /news %d times people to Level up.",
    "You need to fix/fill a car for %d times people to Level up.",
    "You need to sell %d more cars to people to Level up.",
    "You need to Win %d more Matches to Level up.",
    "You need to Fish %d more Fishes to Level up."
};

static const s_ProgressSkillBounds[2][PROGRESS_SKILL_TIERS] =
{
    {50, 100, 200, 400},
    {50, 250, 500, 999}
};

static const s_ProgressSkillTargets[PROGRESS_SKILL_TIERS] = {50, 100, 200, 400};

static const s_ProgressPerkKeywords[PROGRESS_PERK_COUNT][16] =
{
    "alcoholic",
    "drugaddict",
    "miser",
    "trader",
    "painkillers"
};

static const s_ProgressPerkTitles[PROGRESS_PERK_COUNT][16] =
{
    "Alcoholic",
    "Drug Addict",
    "Miser",
    "Trader",
    "Pain Killers"
};

static const s_ProgressPerkLevels[PROGRESS_PERK_COUNT] = {2, 2, 3, 4, 5};

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
static bool:Progress_IsPrefix(const input[],const name[])
{
    return !strcmp(input,name,true,strlen(input));
}

static Progress_ShowSkill(playerid,index)
{
    new level = Progress_GetSkill(playerid,s_ProgressSkillOrder[index]);

    if (level < 0)
    {
        return;
    }

    new row = s_ProgressSkillOrder[index] == PROGRESS_SKILL_FISH ? 1 : 0, tier = PROGRESS_SKILL_TIERS + 1, line[128];

    for (new i = 0;i < PROGRESS_SKILL_TIERS;i++)
    {
        if (level <= s_ProgressSkillBounds[row][i])
        {
            tier = i + 1;
            break;
        }
    }

    format(line,sizeof(line),"Your %s Skill Level = %d.",s_ProgressSkillTitles[index],tier);
    SendClientMessage(playerid,COLOR_YELLOW,line);

    if (tier > PROGRESS_SKILL_TIERS)
    {
        return;
    }

    new remaining = s_ProgressSkillTargets[tier - 1] - level;

    if (tier == 1)
    {
        format(line,sizeof(line),s_ProgressSkillFirstText[index],remaining);
    }
    else
    {
        format(line,sizeof(line),s_ProgressSkillLaterText[index],remaining);
    }

    SendClientMessage(playerid,COLOR_YELLOW,line);
}

static Progress_ShowUpgradeList(playerid)
{
    new line[128], level = Account_GetLevel(playerid);
    format(line,sizeof(line),"USAGE: /upgrade [upgradename] (You have %d Upgrade points)",Progress_GetUpgradePoints(playerid));
    SendClientMessage(playerid,COLOR_GREEN,"_______________________________________");
    SendClientMessage(playerid,COLOR_WHITE,"*** UPGRADES ***");
    SendClientMessage(playerid,COLOR_GRAD2,line);

    if (level == 2)
    {
        SendClientMessage(playerid,COLOR_GRAD3,"Level 2 Perks: Alcoholic, DrugAddict");
    }
    else if (level == 3)
    {
        SendClientMessage(playerid,COLOR_GRAD3,"Level 3 Perks: Alcoholic, DrugAddict, Miser");
    }
    else if (level == 4)
    {
        SendClientMessage(playerid,COLOR_GRAD3,"Level 4 Perks: Alcoholic, DrugAddict, Miser, Trader");
    }
    else if (level >= 5)
    {
        SendClientMessage(playerid,COLOR_GRAD3,"Level 5 Perks: Alcoholic, DrugAddict, Miser, Trader, PainKillers");
    }

    SendClientMessage(playerid,COLOR_GRAD5,"Extra Health: health");
    SendClientMessage(playerid,COLOR_GREEN,"_______________________________________");
}

static Progress_UpgradeHealth(playerid)
{
    new Float:health = Progress_GetSpawnHealth(playerid);

    if (health >= PROGRESS_SPAWN_HEALTH_MAX)
    {
        SendClientMessage(playerid,COLOR_GRAD6,"   You Have Maximum Spawn Health");
        return;
    }

    health += PROGRESS_HEALTH_STEP;
    Progress_SetSpawnHealth(playerid,health);
    Progress_AddUpgradePoints(playerid,-PROGRESS_HEALTH_COST);

    new line[128];
    format(line,sizeof(line),"New Upgrade: You Will Now Spawn With %.2f Health (+5)",health + PROGRESS_SPAWN_HEALTH_BASE);
    SendClientMessage(playerid,COLOR_GRAD6,line);
}

static Progress_UpgradePerk(playerid,perk)
{
    new line[128], current = Progress_GetPerk(playerid,perk);

    if (current >= PROGRESS_PERK_MAX)
    {
        format(line,sizeof(line),"   Your %s Perk is maxed out !",s_ProgressPerkTitles[perk]);
        SendClientMessage(playerid,COLOR_GRAD6,line);
        return;
    }

    Progress_SetPerk(playerid,perk,current + 1);
    Progress_AddUpgradePoints(playerid,-PROGRESS_PERK_COST);
    format(line,sizeof(line),"New Perk Upgrade: Your %s Perk is now Level %d.",s_ProgressPerkTitles[perk],current + 1);
    SendClientMessage(playerid,COLOR_GRAD6,line);
}

static Progress_BuyLevel(playerid)
{
    new level = Account_GetLevel(playerid);

    if (level < 0)
    {
        return;
    }

    new nextLevel = level + 1, cost = nextLevel * STATS_LEVEL_COST, needed = nextLevel * STATS_LEVEL_EXP, line[128];

    if (Account_GetCash(playerid) < cost)
    {
        format(line,sizeof(line),"   You do not have enough Cash ($%d) !",cost);
        SendClientMessage(playerid,COLOR_GRAD1,line);
        return;
    }

    if (Account_GetRespect(playerid) < needed)
    {
        format(line,sizeof(line),"   You need %d Respect Points, you currently have [%d] !",needed,Account_GetRespect(playerid));
        SendClientMessage(playerid,COLOR_GRAD1,line);
        return;
    }

    PlayerPlaySound(playerid,PROGRESS_LEVEL_UP_SOUND,0.0,0.0,0.0);
    Misc_PlayMusic(playerid);
    Account_SetCash(playerid,Account_GetCash(playerid) - cost);
    Account_SetLevel(playerid,nextLevel);

    if (Account_GetDonateRank(playerid) > 0)
    {
        new left = Account_GetRespect(playerid) - needed;
        Account_SetRespect(playerid,left > 0 ? left : 0);
    }
    else
    {
        Account_SetRespect(playerid,0);
    }

    Progress_AddUpgradePoints(playerid,PROGRESS_LEVEL_UP_POINTS);

    format(line,sizeof(line),"~g~LEVEL UP~n~~w~You Are Now Level %d",nextLevel);
    GameTextForPlayer(playerid,line,5000,1);
    format(line,sizeof(line),"   You bought Level %d for ($%d) Type /upgrade",nextLevel,cost);
    SendClientMessage(playerid,COLOR_GRAD1,line);
    format(line,sizeof(line),"   You have %d unspent Upgrade Points",Progress_GetUpgradePoints(playerid));
    SendClientMessage(playerid,COLOR_GRAD2,line);
}

CMD:buylevel(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    Progress_BuyLevel(playerid);
    return 1;
}

CMD:upgrade(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new name[32];

    if (sscanf(params, "s[32]", name))
    {
        Progress_ShowUpgradeList(playerid);
        return 1;
    }

    if (Progress_GetUpgradePoints(playerid) <= 1)
    {
        new line[64];
        format(line,sizeof(line),"   You Have %d Upgrade Points",Progress_GetUpgradePoints(playerid));
        SendClientMessage(playerid, COLOR_GRAD6, line);
        return 1;
    }

    new level = Account_GetLevel(playerid);

    if (level >= 1 && Progress_IsPrefix(name, "health"))
    {
        Progress_UpgradeHealth(playerid);
        return 1;
    }

    for (new perk = 0;perk < PROGRESS_PERK_COUNT;perk++)
    {
        if (level >= s_ProgressPerkLevels[perk] && Progress_IsPrefix(name, s_ProgressPerkKeywords[perk]))
        {
            Progress_UpgradePerk(playerid, perk);
            return 1;
        }
    }

    SendClientMessage(playerid, COLOR_GRAD6, "   Unrecognized Upgrade");
    return 1;
}

CMD:skill(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new text[32];

    if (sscanf(params, "s[32]", text))
    {
        SendClientMessage(playerid, COLOR_WHITE, "|__________________ Skill Info __________________|");
        SendClientMessage(playerid, COLOR_WHITE, "USAGE: /skill [number]");
        SendClientMessage(playerid, COLOR_GREY, "| 1: Detective            7: Car Mechanic");
        SendClientMessage(playerid, COLOR_GREY, "| 2: Lawyer               8: Car Dealer");
        SendClientMessage(playerid, COLOR_GREY, "| 3: Whore                9: Boxer");
        SendClientMessage(playerid, COLOR_GREY, "| 4: Drugs Dealer		  10: Fishing");
        SendClientMessage(playerid, COLOR_GREY, "| 5: Car Jacker");
        SendClientMessage(playerid, COLOR_GREY, "| 6: News Reporter");
        SendClientMessage(playerid, COLOR_WHITE, "|________________________________________________|");
        return 1;
    }

    for (new i = 0;i < PROGRESS_SKILL_LISTED;i++)
    {
        new number[4];
        format(number, sizeof(number), "%d", i + 1);

        if (!strcmp(text, number, true))
        {
            Progress_ShowSkill(playerid, i);
            return 1;
        }
    }

    SendClientMessage(playerid, COLOR_GREY, "   Invalid Skill Number !");
    return 1;
}
