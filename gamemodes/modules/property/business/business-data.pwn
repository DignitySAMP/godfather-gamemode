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
#define BUSINESS_LOADER "Business"
#define BUSINESS_COUNT (5)
#define BUSINESS_SPECIAL_COUNT (12)
#define BUSINESS_FIXED_ROWS (17)
#define BUSINESS_TYPED_MAX (192)
#define BUSINESS_TYPED_BASE (2000)
#define BUSINESS_ROWS (BUSINESS_FIXED_ROWS + BUSINESS_TYPED_MAX)
#define BUSINESS_TYPE_NAME_LEN (12)
#define BUSINESS_TYPED_PRODUCTS (100)
#define BUSINESS_TYPED_MAX_PRODUCTS (500)
#define BUSINESS_TYPED_PRICE_PROD (100)
#define BUSINESS_SPECIAL_BASE (100)
#define BUSINESS_NO_KEY (255)
#define BUSINESS_OWNER_NONE "The State"
#define BUSINESS_EXTORTION_NONE "No-one"
#define BUSINESS_NAME_LEN (MAX_PLAYER_NAME + 1)
#define BUSINESS_OWNER_LEN (64)
#define BUSINESS_MESSAGE_LEN (128)
#define BUSINESS_PICKUP_FOR_SALE (1272)
#define BUSINESS_PICKUP_OWNED (1239)
#define BUSINESS_PICKUP_TYPE (2)
#define BUSINESS_EXTORTION_PERCENT (10)
#define BUSINESS_PROVIDER_LEN (32)
#define DOOR_KIND_SBIZ "sbiz"
#define BUSINESS_MIGRATION_TYPED_PRICES "UPDATE businesses SET buy_price = CASE biz_type WHEN 'barber' THEN 250000 WHEN 'food' THEN 250000 WHEN 'ammunation' THEN 1500000 ELSE 500000 END, level_needed = CASE biz_type WHEN 'barber' THEN 3 WHEN 'food' THEN 3 WHEN 'ammunation' THEN 7 ELSE 5 END WHERE business_id >= 2000 AND biz_type <> '' AND owned = 0 AND buy_price = 5000000 AND level_needed = 5"
#define DOOR_KIND_TBIZ "tbiz"

#define SBIZ_RENT_A (0)
#define SBIZ_RENT_B (1)
#define SBIZ_PHONE (2)
#define SBIZ_ELECTRICITY (4)
#define SBIZ_HOUSE_UPGRADE (6)
#define SBIZ_STORE (9)
#define SBIZ_PAINTBALL (10)
#define SBIZ_KARTING (11)

#define BIZ_ARMOURY (3)

enum
{
    BUSINESS_TYPE_NONE = 0,
    BUSINESS_TYPE_247,
    BUSINESS_TYPE_BAR,
    BUSINESS_TYPE_FOOD,
    BUSINESS_TYPE_CLOTHES,
    BUSINESS_TYPE_AMMUNATION,
    BUSINESS_TYPE_BARBER,
    BUSINESS_TYPE_OTHER,
    BUSINESS_TYPE_COUNT
}

enum E_BUSINESS_DATA
{
    E_BUSINESS_OWNED,
    E_BUSINESS_OWNER[BUSINESS_OWNER_LEN],
    E_BUSINESS_MESSAGE[BUSINESS_MESSAGE_LEN],
    E_BUSINESS_EXTORTION[BUSINESS_NAME_LEN],
    Float:E_BUSINESS_ENTRANCE_X,
    Float:E_BUSINESS_ENTRANCE_Y,
    Float:E_BUSINESS_ENTRANCE_Z,
    Float:E_BUSINESS_EXIT_X,
    Float:E_BUSINESS_EXIT_Y,
    Float:E_BUSINESS_EXIT_Z,
    E_BUSINESS_LEVEL_NEEDED,
    E_BUSINESS_BUY_PRICE,
    E_BUSINESS_ENTRANCE_COST,
    E_BUSINESS_TILL,
    E_BUSINESS_LOCKED,
    E_BUSINESS_INTERIOR,
    E_BUSINESS_PRODUCTS,
    E_BUSINESS_MAX_PRODUCTS,
    E_BUSINESS_PRICE_PROD,
    E_BUSINESS_TYPE,
    Float:E_BUSINESS_ENTRANCE_ANGLE,
    Float:E_BUSINESS_EXIT_ANGLE
}

enum _:E_BUSINESS_PROVIDER
{
    BUSINESS_PROVIDER_IS_MARRIED = 0
}

static const s_BusinessTypeNames[BUSINESS_TYPE_COUNT][BUSINESS_TYPE_NAME_LEN] =
{
    "",
    "24/7",
    "bar",
    "food",
    "clothes",
    "ammunation",
    "barber",
    "other"
};

static s_Business[BUSINESS_ROWS][E_BUSINESS_DATA];
static bool:s_BusinessUsed[BUSINESS_ROWS];
static s_BusinessPickups[BUSINESS_ROWS] = {-1,...};
static s_BusinessPickupModels[BUSINESS_ROWS];
static s_BusinessProviders[E_BUSINESS_PROVIDER][BUSINESS_PROVIDER_LEN];

forward Task:Business_LoadAll();
forward Business_OnOwnerChanged(key);

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
stock Business_SetProvider(provider,const callback[])
{
    if (provider < 0 || provider >= E_BUSINESS_PROVIDER)
    {
        return false;
    }

    strcopy(s_BusinessProviders[provider],callback,BUSINESS_PROVIDER_LEN);
    return true;
}

stock bool:Business_Ask(provider,playerid,bool:fallback)
{
    if (provider < 0 || provider >= E_BUSINESS_PROVIDER || s_BusinessProviders[provider][0] == EOS)
    {
        return fallback;
    }

    return CallLocalFunction(s_BusinessProviders[provider],"d",playerid) != 0;
}

stock Business_MakeSpecialKey(index)
{
    return BUSINESS_SPECIAL_BASE + index;
}

stock bool:Business_IsTyped(key)
{
    return key >= BUSINESS_TYPED_BASE && key < BUSINESS_TYPED_BASE + BUSINESS_TYPED_MAX;
}

stock Business_GetTypeName(type,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (type > BUSINESS_TYPE_NONE && type < BUSINESS_TYPE_COUNT)
    {
        strcopy(dest,s_BusinessTypeNames[type],size);
    }
}

stock Business_TypeFromName(const name[])
{
    for (new type = BUSINESS_TYPE_247;type < BUSINESS_TYPE_COUNT;type++)
    {
        if (!strcmp(name,s_BusinessTypeNames[type],true))
        {
            return type;
        }
    }

    return BUSINESS_TYPE_NONE;
}

stock bool:Business_IsSpecial(key)
{
    return key >= BUSINESS_SPECIAL_BASE && key < BUSINESS_SPECIAL_BASE + BUSINESS_SPECIAL_COUNT;
}

stock Business_GetRow(key)
{
    if (key >= 0 && key < BUSINESS_COUNT)
    {
        return key;
    }

    if (Business_IsSpecial(key))
    {
        return BUSINESS_COUNT + key - BUSINESS_SPECIAL_BASE;
    }

    if (Business_IsTyped(key))
    {
        return BUSINESS_FIXED_ROWS + key - BUSINESS_TYPED_BASE;
    }

    return -1;
}

stock Business_GetKeyOfRow(row)
{
    if (row >= 0 && row < BUSINESS_COUNT)
    {
        return row;
    }

    if (row >= BUSINESS_COUNT && row < BUSINESS_FIXED_ROWS)
    {
        return BUSINESS_SPECIAL_BASE + row - BUSINESS_COUNT;
    }

    if (row >= BUSINESS_FIXED_ROWS && row < BUSINESS_ROWS)
    {
        return BUSINESS_TYPED_BASE + row - BUSINESS_FIXED_ROWS;
    }

    return BUSINESS_NO_KEY;
}

stock Business_CountLoaded()
{
    new count = 0;

    for (new row = 0;row < BUSINESS_FIXED_ROWS;row++)
    {
        if (s_BusinessUsed[row])
        {
            count++;
        }
    }

    return count;
}

stock bool:Business_IsValid(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row];
}

stock bool:Business_IsOwned(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row] && s_Business[row][E_BUSINESS_OWNED] == 1;
}

stock bool:Business_IsLocked(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row] && s_Business[row][E_BUSINESS_LOCKED] == 1;
}

stock Business_GetOwner(key,dest[],size = sizeof(dest))
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row])
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_Business[row][E_BUSINESS_OWNER],size);
}

stock bool:Business_IsOwnerName(key,const name[])
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row] || name[0] == EOS)
    {
        return false;
    }

    return strcmp(name,s_Business[row][E_BUSINESS_OWNER],true) == 0;
}

stock Business_GetMessage(key,dest[],size = sizeof(dest))
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row])
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_Business[row][E_BUSINESS_MESSAGE],size);
}

stock Business_GetExtortion(key,dest[],size = sizeof(dest))
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row])
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_Business[row][E_BUSINESS_EXTORTION],size);
}

stock Business_GetEntrance(key,&Float:x,&Float:y,&Float:z)
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row])
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        return;
    }

    x = s_Business[row][E_BUSINESS_ENTRANCE_X];
    y = s_Business[row][E_BUSINESS_ENTRANCE_Y];
    z = s_Business[row][E_BUSINESS_ENTRANCE_Z];
}

stock Business_GetExit(key,&Float:x,&Float:y,&Float:z)
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row])
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        return;
    }

    x = s_Business[row][E_BUSINESS_EXIT_X];
    y = s_Business[row][E_BUSINESS_EXIT_Y];
    z = s_Business[row][E_BUSINESS_EXIT_Z];
}

stock bool:Business_IsNearEntrance(playerid,key,Float:radius)
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row])
    {
        return false;
    }

    return Property_IsNear(playerid,radius,s_Business[row][E_BUSINESS_ENTRANCE_X],s_Business[row][E_BUSINESS_ENTRANCE_Y],s_Business[row][E_BUSINESS_ENTRANCE_Z]);
}

stock bool:Business_IsNearExit(playerid,key,Float:radius)
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row])
    {
        return false;
    }

    return Property_IsNear(playerid,radius,s_Business[row][E_BUSINESS_EXIT_X],s_Business[row][E_BUSINESS_EXIT_Y],s_Business[row][E_BUSINESS_EXIT_Z]);
}

stock Business_GetLevelNeeded(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row] ? s_Business[row][E_BUSINESS_LEVEL_NEEDED] : 0;
}

stock Business_GetBuyPrice(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row] ? s_Business[row][E_BUSINESS_BUY_PRICE] : 0;
}

stock Business_GetEntranceCost(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row] ? s_Business[row][E_BUSINESS_ENTRANCE_COST] : 0;
}

stock Business_GetTill(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row] ? s_Business[row][E_BUSINESS_TILL] : 0;
}

stock Business_GetInterior(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row] ? s_Business[row][E_BUSINESS_INTERIOR] : 0;
}

stock Business_GetProducts(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row] ? s_Business[row][E_BUSINESS_PRODUCTS] : 0;
}

stock Business_GetMaxProducts(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row] ? s_Business[row][E_BUSINESS_MAX_PRODUCTS] : 0;
}

stock Business_GetPriceProd(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row] ? s_Business[row][E_BUSINESS_PRICE_PROD] : 0;
}

stock Business_GetType(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row] ? s_Business[row][E_BUSINESS_TYPE] : BUSINESS_TYPE_NONE;
}

stock Float:Business_GetEntranceAngle(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row] ? s_Business[row][E_BUSINESS_ENTRANCE_ANGLE] : DOOR_NO_ANGLE;
}

stock Float:Business_GetExitAngle(key)
{
    new row = Business_GetRow(key);
    return row != -1 && s_BusinessUsed[row] ? s_Business[row][E_BUSINESS_EXIT_ANGLE] : DOOR_NO_ANGLE;
}

stock bool:Business_IsFreeStock(key)
{
    return Business_IsTyped(key) && Business_IsValid(key) && !Business_IsOwned(key);
}

stock Business_Save(key)
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row])
    {
        return false;
    }

    if (Business_IsSpecial(key))
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE special_businesses SET owned = %d, owner = '%e', message = '%e', extortion = '%e', level_needed = %d, buy_price = %d, entrance_cost = %d, till = %d, locked = %d, interior = %d, products = %d, max_products = %d, price_prod = %d WHERE special_id = %d",s_Business[row][E_BUSINESS_OWNED],s_Business[row][E_BUSINESS_OWNER],s_Business[row][E_BUSINESS_MESSAGE],s_Business[row][E_BUSINESS_EXTORTION],s_Business[row][E_BUSINESS_LEVEL_NEEDED],s_Business[row][E_BUSINESS_BUY_PRICE],s_Business[row][E_BUSINESS_ENTRANCE_COST],s_Business[row][E_BUSINESS_TILL],s_Business[row][E_BUSINESS_LOCKED],s_Business[row][E_BUSINESS_INTERIOR],s_Business[row][E_BUSINESS_PRODUCTS],s_Business[row][E_BUSINESS_MAX_PRODUCTS],s_Business[row][E_BUSINESS_PRICE_PROD],key - BUSINESS_SPECIAL_BASE));
        return true;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE businesses SET owned = %d, owner = '%e', message = '%e', extortion = '%e', level_needed = %d, buy_price = %d, entrance_cost = %d, till = %d, locked = %d, interior = %d, products = %d, max_products = %d, price_prod = %d WHERE business_id = %d",s_Business[row][E_BUSINESS_OWNED],s_Business[row][E_BUSINESS_OWNER],s_Business[row][E_BUSINESS_MESSAGE],s_Business[row][E_BUSINESS_EXTORTION],s_Business[row][E_BUSINESS_LEVEL_NEEDED],s_Business[row][E_BUSINESS_BUY_PRICE],s_Business[row][E_BUSINESS_ENTRANCE_COST],s_Business[row][E_BUSINESS_TILL],s_Business[row][E_BUSINESS_LOCKED],s_Business[row][E_BUSINESS_INTERIOR],s_Business[row][E_BUSINESS_PRODUCTS],s_Business[row][E_BUSINESS_MAX_PRODUCTS],s_Business[row][E_BUSINESS_PRICE_PROD],key));
    return true;
}

stock Business_SyncShop(key)
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row] || !Business_IsSpecial(key))
    {
        return;
    }

    Vehicles_SetShopPrice(key - BUSINESS_SPECIAL_BASE,s_Business[row][E_BUSINESS_ENTRANCE_COST]);
    Vehicles_SetShopStock(key - BUSINESS_SPECIAL_BASE,s_Business[row][E_BUSINESS_PRODUCTS]);
}

stock Business_SyncAllShops()
{
    for (new index = 0;index < BUSINESS_SPECIAL_COUNT;index++)
    {
        Business_SyncShop(BUSINESS_SPECIAL_BASE + index);
    }
}

stock Business_RefreshPickup(key)
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row])
    {
        return false;
    }

    if (s_BusinessPickups[row] != -1)
    {
        DestroyDynamicPickup(STREAMER_TAG_PICKUP:s_BusinessPickups[row]);
        s_BusinessPickups[row] = -1;
    }

    new model = s_Business[row][E_BUSINESS_OWNED] == 1 ? BUSINESS_PICKUP_OWNED : BUSINESS_PICKUP_FOR_SALE;
    s_BusinessPickupModels[row] = model;
    s_BusinessPickups[row] = _:CreateDynamicPickup(model,BUSINESS_PICKUP_TYPE,s_Business[row][E_BUSINESS_ENTRANCE_X],s_Business[row][E_BUSINESS_ENTRANCE_Y],s_Business[row][E_BUSINESS_ENTRANCE_Z],0,0);
    return true;
}

stock Business_RefreshAllPickups()
{
    for (new row = 0;row < BUSINESS_ROWS;row++)
    {
        Business_RefreshPickup(Business_GetKeyOfRow(row));
    }
}

stock Business_SetMessage(key,const text[])
{
    new row = Business_GetRow(key);

    if (row != -1 && s_BusinessUsed[row])
    {
        strcopy(s_Business[row][E_BUSINESS_MESSAGE],text,BUSINESS_MESSAGE_LEN);
        Business_Save(key);
    }
}

stock Business_SetExtortion(key,const name[])
{
    new row = Business_GetRow(key);

    if (row != -1 && s_BusinessUsed[row])
    {
        strcopy(s_Business[row][E_BUSINESS_EXTORTION],name,BUSINESS_NAME_LEN);
        Business_Save(key);
    }
}

stock Business_SetLevelNeeded(key,level)
{
    new row = Business_GetRow(key);

    if (row != -1 && s_BusinessUsed[row])
    {
        s_Business[row][E_BUSINESS_LEVEL_NEEDED] = level;
        Business_Save(key);
    }
}

stock Business_SetBuyPrice(key,price)
{
    new row = Business_GetRow(key);

    if (row != -1 && s_BusinessUsed[row])
    {
        s_Business[row][E_BUSINESS_BUY_PRICE] = price;
        Business_Save(key);
    }
}

stock Business_SetEntranceCost(key,cost)
{
    new row = Business_GetRow(key);

    if (row != -1 && s_BusinessUsed[row])
    {
        s_Business[row][E_BUSINESS_ENTRANCE_COST] = cost;
        Business_Save(key);
        Business_SyncShop(key);
    }
}

stock Business_SetTill(key,amount)
{
    new row = Business_GetRow(key);

    if (row != -1 && s_BusinessUsed[row])
    {
        s_Business[row][E_BUSINESS_TILL] = amount;
        Business_Save(key);
    }
}

stock Business_AddTill(key,amount)
{
    new row = Business_GetRow(key);

    if (row != -1 && s_BusinessUsed[row] && !Business_IsFreeStock(key))
    {
        s_Business[row][E_BUSINESS_TILL] += amount;
        Business_Save(key);
    }
}

stock Business_SetLocked(key,bool:isLocked)
{
    new row = Business_GetRow(key);

    if (row != -1 && s_BusinessUsed[row])
    {
        s_Business[row][E_BUSINESS_LOCKED] = isLocked ? 1 : 0;
        Business_Save(key);
    }
}

stock Business_SetProducts(key,amount)
{
    new row = Business_GetRow(key);

    if (row != -1 && s_BusinessUsed[row])
    {
        s_Business[row][E_BUSINESS_PRODUCTS] = amount;
        Business_Save(key);
        Business_SyncShop(key);
    }
}

stock Business_AddProducts(key,amount)
{
    new row = Business_GetRow(key);

    if (row != -1 && s_BusinessUsed[row])
    {
        Business_SetProducts(key,s_Business[row][E_BUSINESS_PRODUCTS] + amount);
    }
}

stock Business_UseProduct(key)
{
    if (Business_IsFreeStock(key))
    {
        return;
    }

    Business_AddProducts(key,-1);
}

stock Business_SetPriceProd(key,price)
{
    new row = Business_GetRow(key);

    if (row != -1 && s_BusinessUsed[row])
    {
        s_Business[row][E_BUSINESS_PRICE_PROD] = price;
        Business_Save(key);
    }
}

stock Business_Claim(key,const name[])
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row])
    {
        return;
    }

    s_Business[row][E_BUSINESS_OWNED] = 1;
    strcopy(s_Business[row][E_BUSINESS_OWNER],name,BUSINESS_OWNER_LEN);
    Business_Save(key);
    Business_RefreshPickup(key);
    pawn_call_public("Business_OnOwnerChanged","d",key);
}

stock Business_Release(key)
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row])
    {
        return;
    }

    s_Business[row][E_BUSINESS_LOCKED] = Business_IsTyped(key) ? 0 : 1;
    s_Business[row][E_BUSINESS_OWNED] = 0;
    strcopy(s_Business[row][E_BUSINESS_OWNER],BUSINESS_OWNER_NONE,BUSINESS_OWNER_LEN);
    strcopy(s_Business[row][E_BUSINESS_EXTORTION],BUSINESS_EXTORTION_NONE,BUSINESS_NAME_LEN);
    s_Business[row][E_BUSINESS_TILL] = 0;
    Business_Save(key);
    Business_RefreshPickup(key);
    pawn_call_public("Business_OnOwnerChanged","d",key);
}

stock Business_Extort(key,money)
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row])
    {
        return 0;
    }

    if (strcmp(s_Business[row][E_BUSINESS_EXTORTION],BUSINESS_EXTORTION_NONE,true) == 0)
    {
        return 0;
    }

    new payout = money / 100;
    payout = payout * BUSINESS_EXTORTION_PERCENT;

    foreach (new playerid : Player)
    {
        if (IsPlayerNPC(playerid) || !Player_IsReady(playerid))
        {
            continue;
        }

        new name[BUSINESS_NAME_LEN];
        GetPlayerName(playerid,name,sizeof(name));

        if (strcmp(s_Business[row][E_BUSINESS_EXTORTION],name,true) == 0)
        {
            Account_SetCash(playerid,Account_GetCash(playerid) + payout);
            s_Business[row][E_BUSINESS_TILL] -= payout;
        }
    }

    Business_Save(key);
    return 1;
}

stock Business_Earn(key,amount)
{
    Business_AddTill(key,amount);
    Business_Extort(key,amount);
}

stock Business_FindFreeTypedKey()
{
    for (new row = BUSINESS_FIXED_ROWS;row < BUSINESS_ROWS;row++)
    {
        if (!s_BusinessUsed[row])
        {
            return BUSINESS_TYPED_BASE + row - BUSINESS_FIXED_ROWS;
        }
    }

    return BUSINESS_NO_KEY;
}

stock bool:Business_InitTypedRow(key,type,const message[],Float:entranceX,Float:entranceY,Float:entranceZ,Float:entranceAngle,Float:exitX,Float:exitY,Float:exitZ,Float:exitAngle,interior,price,level)
{
    new row = Business_GetRow(key);

    if (!Business_IsTyped(key) || row == -1 || s_BusinessUsed[row])
    {
        return false;
    }

    s_Business[row][E_BUSINESS_OWNED] = 0;
    strcopy(s_Business[row][E_BUSINESS_OWNER],BUSINESS_OWNER_NONE,BUSINESS_OWNER_LEN);
    strcopy(s_Business[row][E_BUSINESS_MESSAGE],message,BUSINESS_MESSAGE_LEN);
    strcopy(s_Business[row][E_BUSINESS_EXTORTION],BUSINESS_EXTORTION_NONE,BUSINESS_NAME_LEN);
    s_Business[row][E_BUSINESS_ENTRANCE_X] = entranceX;
    s_Business[row][E_BUSINESS_ENTRANCE_Y] = entranceY;
    s_Business[row][E_BUSINESS_ENTRANCE_Z] = entranceZ;
    s_Business[row][E_BUSINESS_ENTRANCE_ANGLE] = entranceAngle;
    s_Business[row][E_BUSINESS_EXIT_X] = exitX;
    s_Business[row][E_BUSINESS_EXIT_Y] = exitY;
    s_Business[row][E_BUSINESS_EXIT_Z] = exitZ;
    s_Business[row][E_BUSINESS_EXIT_ANGLE] = exitAngle;
    s_Business[row][E_BUSINESS_LEVEL_NEEDED] = level;
    s_Business[row][E_BUSINESS_BUY_PRICE] = price;
    s_Business[row][E_BUSINESS_ENTRANCE_COST] = 0;
    s_Business[row][E_BUSINESS_TILL] = 0;
    s_Business[row][E_BUSINESS_LOCKED] = 0;
    s_Business[row][E_BUSINESS_INTERIOR] = interior;
    s_Business[row][E_BUSINESS_PRODUCTS] = BUSINESS_TYPED_PRODUCTS;
    s_Business[row][E_BUSINESS_MAX_PRODUCTS] = BUSINESS_TYPED_MAX_PRODUCTS;
    s_Business[row][E_BUSINESS_PRICE_PROD] = BUSINESS_TYPED_PRICE_PROD;
    s_Business[row][E_BUSINESS_TYPE] = type;
    s_BusinessUsed[row] = true;
    return true;
}

stock bool:Business_FreeTypedRow(key)
{
    new row = Business_GetRow(key);

    if (!Business_IsTyped(key) || row == -1 || !s_BusinessUsed[row])
    {
        return false;
    }

    if (s_BusinessPickups[row] != -1)
    {
        DestroyDynamicPickup(STREAMER_TAG_PICKUP:s_BusinessPickups[row]);
        s_BusinessPickups[row] = -1;
    }

    s_BusinessUsed[row] = false;
    return true;
}

stock bool:Business_SetEntrance(key,Float:x,Float:y,Float:z,Float:angle)
{
    new row = Business_GetRow(key);

    if (row == -1 || !s_BusinessUsed[row] || Business_IsSpecial(key))
    {
        return false;
    }

    s_Business[row][E_BUSINESS_ENTRANCE_X] = x;
    s_Business[row][E_BUSINESS_ENTRANCE_Y] = y;
    s_Business[row][E_BUSINESS_ENTRANCE_Z] = z;
    s_Business[row][E_BUSINESS_ENTRANCE_ANGLE] = angle;
    return true;
}

static Business_ReadRow(row,key,bool:isSpecial)
{
    new slot = Business_GetRow(key);
    cache_get_value_name_int(row,"owned",s_Business[slot][E_BUSINESS_OWNED]);
    cache_get_value_name(row,"owner",s_Business[slot][E_BUSINESS_OWNER],BUSINESS_OWNER_LEN);
    cache_get_value_name(row,"message",s_Business[slot][E_BUSINESS_MESSAGE],BUSINESS_MESSAGE_LEN);
    cache_get_value_name(row,"extortion",s_Business[slot][E_BUSINESS_EXTORTION],BUSINESS_NAME_LEN);
    cache_get_value_name_float(row,"entrance_x",s_Business[slot][E_BUSINESS_ENTRANCE_X]);
    cache_get_value_name_float(row,"entrance_y",s_Business[slot][E_BUSINESS_ENTRANCE_Y]);
    cache_get_value_name_float(row,"entrance_z",s_Business[slot][E_BUSINESS_ENTRANCE_Z]);

    if (!isSpecial)
    {
        cache_get_value_name_float(row,"exit_x",s_Business[slot][E_BUSINESS_EXIT_X]);
        cache_get_value_name_float(row,"exit_y",s_Business[slot][E_BUSINESS_EXIT_Y]);
        cache_get_value_name_float(row,"exit_z",s_Business[slot][E_BUSINESS_EXIT_Z]);
    }

    cache_get_value_name_int(row,"level_needed",s_Business[slot][E_BUSINESS_LEVEL_NEEDED]);
    cache_get_value_name_int(row,"buy_price",s_Business[slot][E_BUSINESS_BUY_PRICE]);
    cache_get_value_name_int(row,"entrance_cost",s_Business[slot][E_BUSINESS_ENTRANCE_COST]);
    cache_get_value_name_int(row,"till",s_Business[slot][E_BUSINESS_TILL]);
    cache_get_value_name_int(row,"locked",s_Business[slot][E_BUSINESS_LOCKED]);
    cache_get_value_name_int(row,"interior",s_Business[slot][E_BUSINESS_INTERIOR]);
    cache_get_value_name_int(row,"products",s_Business[slot][E_BUSINESS_PRODUCTS]);
    cache_get_value_name_int(row,"max_products",s_Business[slot][E_BUSINESS_MAX_PRODUCTS]);
    cache_get_value_name_int(row,"price_prod",s_Business[slot][E_BUSINESS_PRICE_PROD]);

    if (!isSpecial)
    {
        new typeName[BUSINESS_TYPE_NAME_LEN];
        cache_get_value_name(row,"biz_type",typeName,sizeof(typeName));
        s_Business[slot][E_BUSINESS_TYPE] = Business_TypeFromName(typeName);
        cache_get_value_name_float(row,"entrance_angle",s_Business[slot][E_BUSINESS_ENTRANCE_ANGLE]);
        cache_get_value_name_float(row,"exit_angle",s_Business[slot][E_BUSINESS_EXIT_ANGLE]);
    }

    s_BusinessUsed[slot] = true;
}

#pragma warning push
#pragma warning disable 204
async Task:Business_LoadAll()
{
    await task_ticks(1);

    for (new row = 0;row < BUSINESS_ROWS;row++)
    {
        s_BusinessUsed[row] = false;
    }

    await mysql_aquery_s(g_Mysql,str_new("SELECT * FROM businesses ORDER BY business_id"),false);

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("business","the businesses table could not be read");
        return async 0;
    }

    new loaded = 0;

    for (new row = 0,rows = cache_num_rows();row < rows;row++)
    {
        new id = -1;
        cache_get_value_name_int(row,"business_id",id);

        if (id < 0 || (id >= BUSINESS_COUNT && !Business_IsTyped(id)))
        {
            Log_Error("business","business %d is outside the table, raise BUSINESS_COUNT or BUSINESS_TYPED_MAX",id);
            continue;
        }

        Business_ReadRow(row,id,false);
        loaded++;
    }

    await mysql_aquery_s(g_Mysql,str_new("SELECT * FROM special_businesses ORDER BY special_id"),false);

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("business","the special_businesses table could not be read");
        return async loaded;
    }

    for (new row = 0,rows = cache_num_rows();row < rows;row++)
    {
        new id = -1;
        cache_get_value_name_int(row,"special_id",id);

        if (id < 0 || id >= BUSINESS_SPECIAL_COUNT)
        {
            Log_Error("business","special business %d is outside the table, raise BUSINESS_SPECIAL_COUNT",id);
            continue;
        }

        Business_ReadRow(row,BUSINESS_SPECIAL_BASE + id,true);
        loaded++;
    }

    return async loaded;
}
#pragma warning pop

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
public Business_OnOwnerChanged(key)
{
    return 1;
}
