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
#define WHORE_DISEASE_NONE (0)
#define WHORE_DISEASE_CHLAMYDIA (1)
#define WHORE_DISEASE_GONORRHEA (2)
#define WHORE_DISEASE_SYPHILIS (3)
#define WHORE_DISEASE_COUNT (4)
#define WHORE_ROLL_COUNT (21)
#define WHORE_HOSPITAL_RADIUS (3.0)
#define WHORE_HOSPITAL_BILL (1000)

static s_WhoreOffer[MAX_PLAYERS];
static s_WhorePrice[MAX_PLAYERS];
static s_WhoreDisease[MAX_PLAYERS];
static s_WhoreCondoms[MAX_PLAYERS];

static const s_WhoreRolls[4][WHORE_ROLL_COUNT] =
{
    {0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3},
    {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 3}
};

static const s_WhoreHealth[5] = {30, 60, 90, 120, 150};

static const s_WhoreDiseaseNames[WHORE_DISEASE_COUNT][16] =
{
    "None",
    "Chlamydia",
    "Gonorrhea",
    "Syphilis"
};

static const Float:s_WhoreHospitals[2][3] =
{
    {1173.2563, -1323.3102, 15.3943},
    {2029.5945, -1404.6426, 17.2512}
};

static const s_WhoreDamage[WHORE_DISEASE_COUNT] = {0, 5, 12, 20};

forward Whore_Accept(playerid,const params[]);
forward Whore_Cancel(playerid,const params[]);

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
stock Whore_GetDisease(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_WhoreDisease[playerid] : WHORE_DISEASE_NONE;
}

stock Whore_SetDisease(playerid,disease)
{
    if (Util_IsValidPlayer(playerid) && disease >= WHORE_DISEASE_NONE && disease < WHORE_DISEASE_COUNT)
    {
        s_WhoreDisease[playerid] = disease;
    }
}

stock Whore_GetDiseaseName(disease,dest[],size = sizeof(dest))
{
    if (disease < WHORE_DISEASE_NONE || disease >= WHORE_DISEASE_COUNT)
    {
        disease = WHORE_DISEASE_NONE;
    }

    strcopy(dest,s_WhoreDiseaseNames[disease],size);
}

static Whore_Reset(playerid)
{
    s_WhoreOffer[playerid] = OFFER_NONE;
    s_WhorePrice[playerid] = 0;
    s_WhoreDisease[playerid] = WHORE_DISEASE_NONE;
    s_WhoreCondoms[playerid] = 0;
}

static Whore_AnnounceLevel(playerid,skill)
{
    new reached = Jobs_GetSkillLevelReached(skill), line[JOBS_LINE_LEN];

    if (reached == 0)
    {
        return;
    }

    format(line,sizeof(line),"* Your Sex Skill is now Level %d, you offer better Sex (health) and less chance on STD.",reached);
    SendClientMessage(playerid,COLOR_YELLOW,line);
}

static Whore_ApplyHealth(playerid,tier)
{
    new Float:health;
    GetPlayerHealth(playerid,health);

    if (health < 150.0)
    {
        SetPlayerHealth(playerid,health + float(s_WhoreHealth[tier]));
    }
}

static Whore_Infect(playerid,whoreid,tier)
{
    new line[JOBS_LINE_LEN];

    if (tier >= 4)
    {
        Whore_ApplyHealth(playerid,tier);
        SendClientMessage(playerid,COLOR_LIGHTBLUE,"* Your Sex Skill Level is so high you gave high health and No STD.");
        SendClientMessage(whoreid,COLOR_LIGHTBLUE,"* The Whore's Sex Skill Level is so high you got high health and No STD.");
        return;
    }

    Whore_ApplyHealth(playerid,tier);
    new disease = s_WhoreRolls[tier][random(WHORE_ROLL_COUNT)];
    s_WhoreDisease[playerid] = disease;
    s_WhoreDisease[whoreid] = disease;

    if (disease == WHORE_DISEASE_NONE)
    {
        format(line,sizeof(line),"* You got %d Health + no STD while having Sex.",s_WhoreHealth[tier]);
        SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
        SendClientMessage(whoreid,COLOR_LIGHTBLUE,"* You haven't got a STD while having Sex.");
        return;
    }

    format(line,sizeof(line),"* You got %d Health + a %s because of the Sex.",s_WhoreHealth[tier],s_WhoreDiseaseNames[disease]);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* You got a %s because of the Sex.",s_WhoreDiseaseNames[disease]);
    SendClientMessage(whoreid,COLOR_LIGHTBLUE,line);
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
CMD:sex(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Jobs_Is(playerid,JOB_WHORE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not a Whore !");
        return 1;
    }

    if (!IsPlayerInAnyVehicle(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You can only have Sex in a Car !");
        return 1;
    }

    new vehicleid = GetPlayerVehicleID(playerid), targetid, priceText[16], price;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /sex [playerid/PartOfName] [price]");
        return 1;
    }

    sscanf(params,"{u}s[16]",priceText);

    if (!Jobs_ReadPrice(priceText,price))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Price not lower than 1, or above 99999!");
        return 1;
    }

    if (!Util_IsValidPlayer(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is offline !");
        return 1;
    }

    if (!Util_IsNear(playerid,targetid,JOBS_NEAR_RANGE))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is not near you !");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid,COLOR_GREY,"You cannot have Sex with yourself!");
        return 1;
    }

    if (GetPlayerVehicleID(targetid) != vehicleid)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You or the other player must be in a Car together !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    format(line,sizeof(line),"* You offered %s to have Sex with you, for $%d.",targetName,price);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* Whore %s has offered you to have Sex with her, for $%d (type /accept sex) to accept.",name,price);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    s_WhoreOffer[targetid] = playerid;
    s_WhorePrice[targetid] = price;
    return 1;
}

CMD:healme(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new bool:isAtHospital = false;

    for (new i = 0;i < sizeof(s_WhoreHospitals);i++)
    {
        if (Property_IsNear(playerid,WHORE_HOSPITAL_RADIUS,s_WhoreHospitals[i][0],s_WhoreHospitals[i][1],s_WhoreHospitals[i][2]))
        {
            isAtHospital = true;
        }
    }

    if (!isAtHospital)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not at a Hospital !");
        return 1;
    }

    if (s_WhoreDisease[playerid] <= WHORE_DISEASE_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You don't have a STD to heal !");
        return 1;
    }

    s_WhoreDisease[playerid] = WHORE_DISEASE_NONE;
    SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You are no longer infected with a STD anymore because of the Hospital's help !");
    Account_SetCash(playerid,Account_GetCash(playerid) - WHORE_HOSPITAL_BILL);
    SendClientMessage(playerid,TEAM_CYAN_COLOR,"Doc: Your medical bill contained $1000,-. Have a nice day!");
    return 1;
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
public Whore_Accept(playerid,const params[])
{
    new whoreid = s_WhoreOffer[playerid], price = s_WhorePrice[playerid];

    if (whoreid == OFFER_NONE || whoreid == OFFER_STALE)
    {
        s_WhoreOffer[playerid] = OFFER_NONE;
        SendClientMessage(playerid,COLOR_GREY,"   You don't have any Sex offered by a Whore !");
        return 1;
    }

    if (Account_GetCash(playerid) < price)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You can't afford the Sex!");
        return 1;
    }

    new vehicleid = GetPlayerVehicleID(playerid);

    if (!IsPlayerInAnyVehicle(playerid) || GetPlayerVehicleID(whoreid) != vehicleid)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You or the Whore are not both in a Car !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], whoreName[MAX_PLAYER_NAME + 1], line[JOBS_LINE_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(whoreid,whoreName,sizeof(whoreName));
    format(line,sizeof(line),"* You had sex with Whore %s, for $%d.",whoreName,price);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s had sex with you, the $%d was added to your PayCheck.",name,price);
    SendClientMessage(whoreid,COLOR_LIGHTBLUE,line);
    Payday_AddPaycheck(whoreid,price);
    Account_SetCash(playerid,Account_GetCash(playerid) - price);
    new skill = Progress_AddSkill(whoreid,PROGRESS_SKILL_SEX);
    Whore_AnnounceLevel(whoreid,skill);

    if (s_WhoreDisease[playerid] != WHORE_DISEASE_NONE)
    {
        SendClientMessage(whoreid,COLOR_LIGHTBLUE,"* That player was already infected with a STD, can't get another one.");
        return 1;
    }

    if (s_WhoreCondoms[playerid] < 1)
    {
        Whore_Infect(playerid,whoreid,Jobs_GetSkillTier(skill));
    }
    else
    {
        SendClientMessage(whoreid,COLOR_LIGHTBLUE,"* The player used a Condom.");
        SendClientMessage(playerid,COLOR_LIGHTBLUE,"* You used a Condom.");
        s_WhoreCondoms[playerid]--;
    }

    s_WhoreOffer[playerid] = OFFER_NONE;
    return 1;
}

public Whore_Cancel(playerid,const params[])
{
    s_WhoreOffer[playerid] = OFFER_NONE;
    s_WhorePrice[playerid] = 0;
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
    Whore_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Offer_Sweep(s_WhoreOffer,playerid);
    Whore_Reset(playerid);
}

hook OnPlayerSpawn(playerid)
{
    if (!IsPlayerNPC(playerid))
    {
        s_WhoreDisease[playerid] = WHORE_DISEASE_NONE;
    }
}

hook Shops_OnCondomBought(playerid)
{
    s_WhoreCondoms[playerid]++;
}

hook Medics_OnHealed(playerid,targetid)
{
    if (Util_IsValidPlayer(targetid) && s_WhoreDisease[targetid] > WHORE_DISEASE_NONE)
    {
        s_WhoreDisease[targetid] = WHORE_DISEASE_NONE;
        SendClientMessage(targetid,COLOR_LIGHTBLUE,"* You are no longer infected with a STD anymore because of the Medics help !");
    }
}

hook Vehicles_OnTimeCheck(playerid)
{
    new disease = s_WhoreDisease[playerid];

    if (disease <= WHORE_DISEASE_NONE || disease >= WHORE_DISEASE_COUNT)
    {
        return;
    }

    new Float:health, line[JOBS_LINE_LEN];
    GetPlayerHealth(playerid,health);
    SetPlayerHealth(playerid,health - float(s_WhoreDamage[disease]));
    format(line,sizeof(line),"* Lost %d health due to STD.",s_WhoreDamage[disease]);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
}

hook Stats_OnBuild(playerid,targetid)
{
    if (Util_IsValidPlayer(targetid))
    {
        new name[16];
        Whore_GetDiseaseName(s_WhoreDisease[targetid],name);
        Stats_SetText("Disease",name);
    }
}
