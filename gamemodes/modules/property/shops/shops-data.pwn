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
#define SHOPS_PROVIDER_LEN (32)
#define SHOPS_STORE_KEY (BUSINESS_SPECIAL_BASE + SBIZ_STORE)
#define SHOPS_STORE_X (-30.875)
#define SHOPS_STORE_Y (-88.9609)
#define SHOPS_STORE_Z (1004.53)
#define SHOPS_STORE_RADIUS (100.0)
#define SHOPS_SOUND_PAID (1052)
#define SHOPS_DRUNK_MAX (10)
#define SHOPS_DRUNK_EFFECT_LEVEL (5)
#define SHOPS_DRUNK_EFFECT_SECONDS (8)
#define SHOPS_DRUNK_RESET_MS (300000)

enum _:E_SHOPS_PROVIDER
{
    SHOPS_PROVIDER_CHICKENS = 0,
    SHOPS_PROVIDER_HAMBURGERS,
    SHOPS_PROVIDER_PIZZAS
}

enum
{
    SHOPS_GROCERY_CHICKEN = 0,
    SHOPS_GROCERY_HAMBURGER,
    SHOPS_GROCERY_PIZZA
}

static s_ShopsProviders[E_SHOPS_PROVIDER][SHOPS_PROVIDER_LEN];
static s_ShopsDrunk[MAX_PLAYERS];
static s_ShopsDrunkTime[MAX_PLAYERS];

forward Shops_OnPhoneBought(playerid,number);
forward Shops_OnPhoneBookBought(playerid);
forward Shops_OnCdPlayerBought(playerid);
forward Shops_OnCondomBought(playerid);
forward Shops_OnGroceryBought(playerid,kind,amount);

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
stock Shops_SetProvider(provider,const callback[])
{
    if (provider < 0 || provider >= E_SHOPS_PROVIDER)
    {
        return false;
    }

    strcopy(s_ShopsProviders[provider],callback,SHOPS_PROVIDER_LEN);
    return true;
}

stock Shops_Query(provider,playerid,fallback)
{
    if (provider < 0 || provider >= E_SHOPS_PROVIDER || s_ShopsProviders[provider][0] == EOS)
    {
        return fallback;
    }

    return CallLocalFunction(s_ShopsProviders[provider],"d",playerid);
}

stock Shops_GetDrunk(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_ShopsDrunk[playerid] : 0;
}

stock Shops_SetDrunk(playerid,level)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_ShopsDrunk[playerid] = level;
    }
}

stock Shops_GetDrunkTime(playerid)
{
    return Util_IsValidPlayer(playerid) ? s_ShopsDrunkTime[playerid] : 0;
}

stock Shops_SetDrunkTime(playerid,seconds)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_ShopsDrunkTime[playerid] = seconds;
    }
}

stock Shops_ResetDrunk(playerid)
{
    if (playerid >= 0 && playerid < MAX_PLAYERS)
    {
        s_ShopsDrunk[playerid] = 0;
        s_ShopsDrunkTime[playerid] = 0;
    }
}

stock bool:IsAtClothShop(playerid)
{
    if (!IsPlayerConnected(playerid))
    {
        return false;
    }

    return Property_IsNear(playerid,25.0,207.5627,-103.7291,1005.2578) || Property_IsNear(playerid,25.0,203.9068,-41.0728,1001.8047) || Property_IsNear(playerid,30.0,214.4470,-7.6471,1001.2109) || Property_IsNear(playerid,50.0,161.3765,-83.8416,1001.8047);
}

stock bool:IsAtBar(playerid)
{
    if (!IsPlayerConnected(playerid))
    {
        return false;
    }

    return Property_IsNear(playerid,4.0,495.7801,-76.0305,998.7578) || Property_IsNear(playerid,4.0,499.9654,-20.2515,1000.6797) || Property_IsNear(playerid,4.0,1215.9480,-13.3519,1000.9219) || Property_IsNear(playerid,10.0,-2658.9749,1407.4136,906.2734);
}

stock Shops_PerkPrice(playerid,price)
{
    new perk = Progress_GetPerk(playerid,PROGRESS_PERK_TRADER);

    if (perk > 0)
    {
        return price - (price / 100) * perk;
    }

    return price;
}
