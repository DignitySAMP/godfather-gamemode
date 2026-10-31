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
#define COOKING_SLOTS (5)
#define COOKING_NAME_LEN (32)
#define COOKING_LINE_LEN (144)
#define COOKING_CALLBACK_LEN (32)
#define COOKING_EMPTY "Nothing"
#define COOKING_PLACE_RADIUS (3.0)
#define COOKING_PLACE_COUNT (5)
#define COOKING_GROCERY_ID (30)
#define COOKING_ENDANGERED_TURTLE (18)
#define COOKING_ENDANGERED_DOLPHIN (16)
#define COOKING_ENDANGERED_POINTS (2)
#define COOKING_EAT_DIVIDER (3)
#define COOKING_EAT_HEALTH (40.0)
#define COOKING_EAT_RANGE (30.0)

enum
{
    COOKING_PLACE_CLUCKIN = 0,
    COOKING_PLACE_BURGER,
    COOKING_PLACE_PIZZA
}

static s_CookingName[MAX_PLAYERS][COOKING_SLOTS][COOKING_NAME_LEN];
static s_CookingWeight[MAX_PLAYERS][COOKING_SLOTS];
static s_CookingId[MAX_PLAYERS][COOKING_SLOTS];
static s_CookingGroceryCount[MAX_PLAYERS][3];
static s_CookingGroceryWeight[MAX_PLAYERS][3];
static s_CookingFightCheck[COOKING_CALLBACK_LEN];

static const Float:s_CookingPlaces[COOKING_PLACE_COUNT][3] =
{
    {369.9786, -4.0798, 1001.8589},
    {376.4466, -60.9574, 1001.5078},
    {378.1215, -57.4928, 1001.5078},
    {374.1185, -113.6361, 1001.4922},
    {377.7971, -113.7668, 1001.4922}
};

static const s_CookingPlaceKinds[COOKING_PLACE_COUNT] =
{
    COOKING_PLACE_CLUCKIN,
    COOKING_PLACE_BURGER,
    COOKING_PLACE_BURGER,
    COOKING_PLACE_PIZZA,
    COOKING_PLACE_PIZZA
};

forward Cooking_ProvideChickens(playerid);
forward Cooking_ProvideHamburgers(playerid);
forward Cooking_ProvidePizzas(playerid);
forward Cooking_SellCooked(playerid,const params[]);

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
stock Cooking_RegisterProviders()
{
    Shops_SetProvider(SHOPS_PROVIDER_CHICKENS,"Cooking_ProvideChickens");
    Shops_SetProvider(SHOPS_PROVIDER_HAMBURGERS,"Cooking_ProvideHamburgers");
    Shops_SetProvider(SHOPS_PROVIDER_PIZZAS,"Cooking_ProvidePizzas");
}

stock Cooking_ClearAll(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return;
    }

    for (new i = 0;i < COOKING_SLOTS;i++)
    {
        strcopy(s_CookingName[playerid][i],COOKING_EMPTY,COOKING_NAME_LEN);
        s_CookingWeight[playerid][i] = 0;
        s_CookingId[playerid][i] = 0;
    }
}

stock Cooking_ClearGroceries(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return;
    }

    for (new i = 0;i < 3;i++)
    {
        s_CookingGroceryCount[playerid][i] = 0;
        s_CookingGroceryWeight[playerid][i] = 0;
    }
}

stock Cooking_Reset(playerid)
{
    Cooking_ClearAll(playerid);
    Cooking_ClearGroceries(playerid);
}

stock Cooking_GetWeight(playerid,number)
{
    if (!Util_IsValidPlayer(playerid) || number < 1 || number > COOKING_SLOTS)
    {
        return 0;
    }

    return s_CookingWeight[playerid][number - 1];
}

stock Cooking_GetId(playerid,number)
{
    if (!Util_IsValidPlayer(playerid) || number < 1 || number > COOKING_SLOTS)
    {
        return 0;
    }

    return s_CookingId[playerid][number - 1];
}

stock Cooking_GetName(playerid,number,dest[],size = sizeof(dest))
{
    if (!Util_IsValidPlayer(playerid) || number < 1 || number > COOKING_SLOTS)
    {
        strcopy(dest,COOKING_EMPTY,size);
        return;
    }

    strcopy(dest,s_CookingName[playerid][number - 1],size);
}

stock Cooking_SetSlot(playerid,number,const name[],weight,cookId)
{
    if (!Util_IsValidPlayer(playerid) || number < 1 || number > COOKING_SLOTS)
    {
        return;
    }

    strcopy(s_CookingName[playerid][number - 1],name,COOKING_NAME_LEN);
    s_CookingWeight[playerid][number - 1] = weight;
    s_CookingId[playerid][number - 1] = cookId;
}

stock Cooking_ClearSlot(playerid,number)
{
    Cooking_SetSlot(playerid,number,COOKING_EMPTY,0,0);
}

stock Cooking_FindFree(playerid)
{
    for (new number = 1;number <= COOKING_SLOTS;number++)
    {
        if (Cooking_GetWeight(playerid,number) == 0)
        {
            return number;
        }
    }

    return 0;
}

stock Cooking_GetGroceryCount(playerid,kind)
{
    if (!Util_IsValidPlayer(playerid) || kind < 0 || kind >= 3)
    {
        return 0;
    }

    return s_CookingGroceryCount[playerid][kind];
}

stock Cooking_GetGroceryWeight(playerid,kind)
{
    if (!Util_IsValidPlayer(playerid) || kind < 0 || kind >= 3)
    {
        return 0;
    }

    return s_CookingGroceryWeight[playerid][kind];
}

stock Cooking_SetGrocery(playerid,kind,count,weight)
{
    if (!Util_IsValidPlayer(playerid) || kind < 0 || kind >= 3)
    {
        return;
    }

    s_CookingGroceryCount[playerid][kind] = count;
    s_CookingGroceryWeight[playerid][kind] = weight;
}

stock Cooking_FindPlace(playerid)
{
    for (new i = 0;i < COOKING_PLACE_COUNT;i++)
    {
        if (Property_IsNear(playerid,COOKING_PLACE_RADIUS,s_CookingPlaces[i][0],s_CookingPlaces[i][1],s_CookingPlaces[i][2]))
        {
            return s_CookingPlaceKinds[i];
        }
    }

    return -1;
}

stock bool:Cooking_IsAtPlace(playerid)
{
    return Cooking_FindPlace(playerid) != -1;
}

stock bool:Cooking_SetFightCheck(const callback[])
{
    strcopy(s_CookingFightCheck,callback,COOKING_CALLBACK_LEN);
    return true;
}

stock bool:Cooking_IsFighting(playerid)
{
    if (s_CookingFightCheck[0] == EOS)
    {
        return false;
    }

    return CallLocalFunction(s_CookingFightCheck,"d",playerid) != 0;
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
public Cooking_ProvideChickens(playerid)
{
    return Cooking_GetGroceryCount(playerid,SHOPS_GROCERY_CHICKEN);
}

public Cooking_ProvideHamburgers(playerid)
{
    return Cooking_GetGroceryCount(playerid,SHOPS_GROCERY_HAMBURGER);
}

public Cooking_ProvidePizzas(playerid)
{
    return Cooking_GetGroceryCount(playerid,SHOPS_GROCERY_PIZZA);
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
    Cooking_Reset(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Cooking_Reset(playerid);
}

hook Account_OnLogout(playerid,accountid)
{
    Cooking_Reset(playerid);
}

hook Shops_OnGroceryBought(playerid,kind,amount)
{
    Cooking_SetGrocery(playerid,kind,Cooking_GetGroceryCount(playerid,kind) + 1,Cooking_GetGroceryWeight(playerid,kind) + amount);
}
