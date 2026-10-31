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
#define FISHING_LOADER "Fishing"
#define FISHING_SLOTS (5)
#define FISHING_NAME_LEN (20)
#define FISHING_NAME_COUNT (22)
#define FISHING_LINE_LEN (144)
#define FISHING_EMPTY "None"
#define FISHING_PLACE_RADIUS (1.0)
#define FISHING_PLACE_COUNT (10)
#define FISHING_COOLDOWN_MS (300000)
#define FISHING_CAUGHT_LIMIT (5)
#define FISHING_COOLDOWN_TICKS (3)
#define FISHING_MIN_SELL_WEIGHT (20)
#define FISHING_TRADER_PERCENT (5)
#define FISHING_MONEY_BAG (20)
#define FISHING_MONEY_BAG_MAX (500)
#define FISHING_SKILL_LEVEL_2 (50)
#define FISHING_SKILL_LEVEL_3 (250)
#define FISHING_SKILL_LEVEL_4 (500)
#define FISHING_SKILL_LEVEL_5 (1000)

static s_FishingCaught[MAX_PLAYERS];
static s_FishingBiggest[MAX_PLAYERS];
static s_FishingCooldown[MAX_PLAYERS];
static bool:s_FishingLoaded[MAX_PLAYERS];
static s_FishingName[MAX_PLAYERS][FISHING_SLOTS][FISHING_NAME_LEN];
static s_FishingWeight[MAX_PLAYERS][FISHING_SLOTS];
static s_FishingId[MAX_PLAYERS][FISHING_SLOTS];
static s_FishingLastSlot[MAX_PLAYERS];
static s_FishingLastId[MAX_PLAYERS];
static s_FishingLastWeight[MAX_PLAYERS];

static const s_FishingNames[FISHING_NAME_COUNT][FISHING_NAME_LEN] =
{
    "Jacket",
    "Amberjack",
    "Grouper",
    "Red Snapper",
    "Pants",
    "Trout",
    "Blue Marlin",
    "Can",
    "Mackerel",
    "Sea Bass",
    "Shoes",
    "Pike",
    "Sail Fish",
    "Garbage",
    "Tuna",
    "Eel",
    "Dolphin",
    "Shark",
    "Turtle",
    "Catfish",
    "Money Bag",
    "Swordfish"
};

static const Float:s_FishingPlaces[FISHING_PLACE_COUNT][3] =
{
    {403.8266, -2088.7598, 7.8359},
    {398.7553, -2088.7490, 7.8359},
    {396.2197, -2088.6692, 7.8359},
    {391.1094, -2088.7976, 7.8359},
    {383.4157, -2088.7849, 7.8359},
    {374.9598, -2088.7979, 7.8359},
    {369.8107, -2088.7927, 7.8359},
    {367.3637, -2088.7925, 7.8359},
    {362.2244, -2088.7981, 7.8359},
    {354.5382, -2088.7979, 7.8359}
};

forward Fishing_BeginLoad(playerid,token);

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
stock bool:Fishing_IsLoaded(playerid)
{
    return Util_IsValidPlayer(playerid) && s_FishingLoaded[playerid];
}

static Fishing_Write(playerid)
{
    new accountid = Account_GetId(playerid);

    if (accountid > 0)
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE player_fishing SET fishes = %d, biggest_fish = %d WHERE account_id = %d",s_FishingCaught[playerid],s_FishingBiggest[playerid],accountid));
    }
}

stock Fishing_ClearAll(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return;
    }

    for (new i = 0;i < FISHING_SLOTS;i++)
    {
        strcopy(s_FishingName[playerid][i],FISHING_EMPTY,FISHING_NAME_LEN);
        s_FishingWeight[playerid][i] = 0;
        s_FishingId[playerid][i] = 0;
    }
}

stock Fishing_ClearLast(playerid)
{
    if (playerid >= 0 && playerid < MAX_PLAYERS)
    {
        s_FishingLastSlot[playerid] = 0;
        s_FishingLastId[playerid] = 0;
    }
}

stock Fishing_Reset(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return;
    }

    s_FishingCaught[playerid] = 0;
    s_FishingBiggest[playerid] = 0;
    s_FishingCooldown[playerid] = 0;
    s_FishingLoaded[playerid] = false;
    s_FishingLastWeight[playerid] = 0;
    Fishing_ClearAll(playerid);
    Fishing_ClearLast(playerid);
}

stock Fishing_GetCaught(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_FishingCaught[playerid] : 0;
}

stock bool:Fishing_SetCaught(playerid,value)
{
    if (!Fishing_IsLoaded(playerid))
    {
        return false;
    }

    s_FishingCaught[playerid] = value;
    Fishing_Write(playerid);
    return true;
}

stock Fishing_GetBiggest(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_FishingBiggest[playerid] : 0;
}

stock bool:Fishing_SetBiggest(playerid,value)
{
    if (!Fishing_IsLoaded(playerid))
    {
        return false;
    }

    s_FishingBiggest[playerid] = value;
    Fishing_Write(playerid);
    return true;
}

stock Fishing_GetFishName(fishId,dest[],size = sizeof(dest))
{
    if (fishId < 0 || fishId >= FISHING_NAME_COUNT)
    {
        strcopy(dest,FISHING_EMPTY,size);
        return;
    }

    strcopy(dest,s_FishingNames[fishId],size);
}

stock Fishing_GetPrice(fishId)
{
    switch (fishId)
    {
        case 1:
        {
            return 1;
        }
        case 2, 3:
        {
            return 3;
        }
        case 5:
        {
            return 5;
        }
        case 6:
        {
            return 2;
        }
        case 8:
        {
            return 8;
        }
        case 9, 14:
        {
            return 12;
        }
        case 11, 15:
        {
            return 9;
        }
        case 12, 16, 17:
        {
            return 7;
        }
        case 18:
        {
            return 10;
        }
        case 19:
        {
            return 4;
        }
        case 21:
        {
            return 3;
        }
    }

    return 0;
}

stock Fishing_GetWeight(playerid,number)
{
    if (!Util_IsValidPlayer(playerid) || number < 1 || number > FISHING_SLOTS)
    {
        return 0;
    }

    return s_FishingWeight[playerid][number - 1];
}

stock Fishing_GetFishId(playerid,number)
{
    if (!Util_IsValidPlayer(playerid) || number < 1 || number > FISHING_SLOTS)
    {
        return 0;
    }

    return s_FishingId[playerid][number - 1];
}

stock Fishing_GetName(playerid,number,dest[],size = sizeof(dest))
{
    if (!Util_IsValidPlayer(playerid) || number < 1 || number > FISHING_SLOTS)
    {
        strcopy(dest,FISHING_EMPTY,size);
        return;
    }

    strcopy(dest,s_FishingName[playerid][number - 1],size);
}

stock Fishing_SetSlot(playerid,number,fishId,weight)
{
    if (!Util_IsValidPlayer(playerid) || number < 1 || number > FISHING_SLOTS)
    {
        return;
    }

    Fishing_GetFishName(fishId,s_FishingName[playerid][number - 1],FISHING_NAME_LEN);
    s_FishingWeight[playerid][number - 1] = weight;
    s_FishingId[playerid][number - 1] = fishId;
}

stock Fishing_ClearSlot(playerid,number)
{
    if (!Util_IsValidPlayer(playerid) || number < 1 || number > FISHING_SLOTS)
    {
        return;
    }

    strcopy(s_FishingName[playerid][number - 1],FISHING_EMPTY,FISHING_NAME_LEN);
    s_FishingWeight[playerid][number - 1] = 0;
    s_FishingId[playerid][number - 1] = 0;
}

stock Fishing_FindFree(playerid)
{
    for (new number = 1;number <= FISHING_SLOTS;number++)
    {
        if (Fishing_GetWeight(playerid,number) == 0)
        {
            return number;
        }
    }

    return 0;
}

stock bool:Fishing_HasAny(playerid)
{
    for (new number = 1;number <= FISHING_SLOTS;number++)
    {
        if (Fishing_GetWeight(playerid,number) > 0)
        {
            return true;
        }
    }

    return false;
}

stock bool:Fishing_IsFull(playerid)
{
    for (new number = 1;number <= FISHING_SLOTS;number++)
    {
        if (Fishing_GetWeight(playerid,number) <= 0)
        {
            return false;
        }
    }

    return true;
}

stock Fishing_GetLastSlot(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_FishingLastSlot[playerid] : 0;
}

stock Fishing_GetLastFish(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_FishingLastId[playerid] : 0;
}

stock Fishing_GetLastWeight(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_FishingLastWeight[playerid] : 0;
}

stock Fishing_SetLast(playerid,slot,fishId,weight)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_FishingLastSlot[playerid] = slot;
        s_FishingLastId[playerid] = fishId;
        s_FishingLastWeight[playerid] = weight;
    }
}

stock bool:Fishing_IsAtPlace(playerid)
{
    for (new i = 0;i < FISHING_PLACE_COUNT;i++)
    {
        if (Property_IsNear(playerid,FISHING_PLACE_RADIUS,s_FishingPlaces[i][0],s_FishingPlaces[i][1],s_FishingPlaces[i][2]))
        {
            return true;
        }
    }

    return false;
}

stock Fishing_TickCooldown(playerid)
{
    if (!Fishing_IsLoaded(playerid) || s_FishingCaught[playerid] < FISHING_CAUGHT_LIMIT)
    {
        return;
    }

    if (s_FishingCooldown[playerid] >= FISHING_COOLDOWN_TICKS)
    {
        Fishing_SetCaught(playerid,0);
        s_FishingCooldown[playerid] = 0;
    }
    else
    {
        s_FishingCooldown[playerid]++;
    }
}

static Fishing_LoadPlayer(playerid,accountid,token)
{
    yield 1;

    await mysql_aquery_s(g_Mysql,str_format("SELECT fishes, biggest_fish FROM player_fishing WHERE account_id = %d LIMIT 1",accountid),false);

    if (!IsPlayerConnected(playerid) || token != Player_GetLoadToken(playerid))
    {
        return;
    }

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("fishing","row load failed for player %d",playerid);
        return;
    }

    new caught = 0, biggest = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"fishes",caught);
        cache_get_value_name_int(0,"biggest_fish",biggest);
    }
    else
    {
        mysql_tquery_s(g_Mysql,str_format("INSERT INTO player_fishing (account_id) VALUES (%d) ON DUPLICATE KEY UPDATE account_id = account_id",accountid));
    }

    s_FishingCaught[playerid] = caught;
    s_FishingBiggest[playerid] = biggest;
    s_FishingLoaded[playerid] = true;
    Player_LoaderDone(playerid,FISHING_LOADER,token);
}

Timer_Declare(Fishing_CooldownTimer)
{
    foreach (new playerid : Player)
    {
        if (!IsPlayerNPC(playerid))
        {
            Fishing_TickCooldown(playerid);
        }
    }

    return true;
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
public Fishing_BeginLoad(playerid,token)
{
    if (IsPlayerConnected(playerid) && token == Player_GetLoadToken(playerid))
    {
        Fishing_LoadPlayer(playerid,Player_GetLoadAccount(playerid),token);
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
    Fishing_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Fishing_Reset(playerid);
}

hook Account_OnLogin(playerid,accountid)
{
    Fishing_Reset(playerid);
    SetTimerEx("Fishing_BeginLoad",0,false,"dd",playerid,Player_GetLoadToken(playerid));
}

hook Account_OnLogout(playerid,accountid)
{
    Fishing_Reset(playerid);
}

hook Stats_OnBuild(playerid,targetid)
{
    if (Fishing_IsLoaded(targetid))
    {
        Stats_SetNumber("FishesCaught",Fishing_GetCaught(targetid));
        Stats_SetNumber("BiggestFish",Fishing_GetBiggest(targetid));
    }
}

hook Frisk_OnBuild(playerid,targetid)
{
    if (Fishing_HasAny(targetid))
    {
        Misc_SetFriskItem(MISC_FRISK_ITEM_FISHES,true);
    }
}
