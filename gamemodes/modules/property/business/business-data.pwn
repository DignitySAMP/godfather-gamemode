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
#define BUSINESS_TYPED_BASE (2000)
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

enum e_BUSINESS_DATA
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
    Float:E_BUSINESS_EXIT_ANGLE,
    E_BUSINESS_PICKUP,
    E_BUSINESS_PICKUP_MODEL
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

static Pool:s_Business;
static Map:s_BusinessSlots;
static s_BusinessTypedCount;
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
    return key >= BUSINESS_TYPED_BASE;
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

stock Business_GetTypedLocal(key)
{
    return PROPERTY_LOCAL_BUSINESS_BASE + key;
}

stock Business_FromTypedLocal(local)
{
    if (local >= PROPERTY_LOCAL_BUSINESS_BASE + BUSINESS_TYPED_BASE && local < PROPERTY_LOCAL_SADOOR_BASE)
    {
        return local - PROPERTY_LOCAL_BUSINESS_BASE;
    }

    return BUSINESS_NO_KEY;
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

    if (row >= BUSINESS_FIXED_ROWS)
    {
        return BUSINESS_TYPED_BASE + row - BUSINESS_FIXED_ROWS;
    }

    return BUSINESS_NO_KEY;
}

static Business_Slot(key)
{
    if (!map_valid(s_BusinessSlots) || !map_has_key(s_BusinessSlots,key))
    {
        return -1;
    }

    return map_get(s_BusinessSlots,key);
}

stock bool:Business_IsValid(key)
{
    return Business_Slot(key) != -1;
}

static bool:Business_Fetch(key,data[e_BUSINESS_DATA])
{
    new slot = Business_Slot(key);

    if (slot == -1)
    {
        return false;
    }

    pool_get_arr(s_Business,slot,data);
    return true;
}

static Business_Store(key,const data[e_BUSINESS_DATA])
{
    pool_set_arr(s_Business,Business_Slot(key),data);
}

static Business_Insert(key,const data[e_BUSINESS_DATA])
{
    if (!pool_valid(s_Business))
    {
        s_Business = pool_new(-1,true);
        s_BusinessSlots = map_new();
    }

    map_add(s_BusinessSlots,key,pool_add_arr(s_Business,data));

    if (Business_IsTyped(key) && key - BUSINESS_TYPED_BASE >= s_BusinessTypedCount)
    {
        s_BusinessTypedCount = key - BUSINESS_TYPED_BASE + 1;
    }
}

stock Business_GetRowCount()
{
    return BUSINESS_FIXED_ROWS + s_BusinessTypedCount;
}

stock Business_CountLoaded()
{
    new count = 0;

    for (new row = 0;row < BUSINESS_FIXED_ROWS;row++)
    {
        if (Business_IsValid(Business_GetKeyOfRow(row)))
        {
            count++;
        }
    }

    return count;
}

stock bool:Business_IsOwned(key)
{
    new data[e_BUSINESS_DATA];
    return Business_Fetch(key,data) && data[E_BUSINESS_OWNED] == 1;
}

stock bool:Business_IsLocked(key)
{
    new data[e_BUSINESS_DATA];
    return Business_Fetch(key,data) && data[E_BUSINESS_LOCKED] == 1;
}

stock Business_GetOwner(key,dest[],size = sizeof(dest))
{
    new data[e_BUSINESS_DATA];

    if (!Business_Fetch(key,data))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,data[E_BUSINESS_OWNER],size);
}

stock bool:Business_IsOwnerName(key,const name[])
{
    new data[e_BUSINESS_DATA];

    if (name[0] == EOS || !Business_Fetch(key,data))
    {
        return false;
    }

    return strcmp(name,data[E_BUSINESS_OWNER],true) == 0;
}

stock Business_GetMessage(key,dest[],size = sizeof(dest))
{
    new data[e_BUSINESS_DATA];

    if (!Business_Fetch(key,data))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,data[E_BUSINESS_MESSAGE],size);
}

stock Business_GetExtortion(key,dest[],size = sizeof(dest))
{
    new data[e_BUSINESS_DATA];

    if (!Business_Fetch(key,data))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,data[E_BUSINESS_EXTORTION],size);
}

stock Business_GetEntrance(key,&Float:x,&Float:y,&Float:z)
{
    new data[e_BUSINESS_DATA];

    if (!Business_Fetch(key,data))
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        return;
    }

    x = data[E_BUSINESS_ENTRANCE_X];
    y = data[E_BUSINESS_ENTRANCE_Y];
    z = data[E_BUSINESS_ENTRANCE_Z];
}

stock Business_GetExit(key,&Float:x,&Float:y,&Float:z)
{
    new data[e_BUSINESS_DATA];

    if (!Business_Fetch(key,data))
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        return;
    }

    x = data[E_BUSINESS_EXIT_X];
    y = data[E_BUSINESS_EXIT_Y];
    z = data[E_BUSINESS_EXIT_Z];
}

stock bool:Business_IsNearEntrance(playerid,key,Float:radius)
{
    new data[e_BUSINESS_DATA];

    if (!Business_Fetch(key,data))
    {
        return false;
    }

    return Property_IsNear(playerid,radius,data[E_BUSINESS_ENTRANCE_X],data[E_BUSINESS_ENTRANCE_Y],data[E_BUSINESS_ENTRANCE_Z]);
}

stock bool:Business_IsNearExit(playerid,key,Float:radius)
{
    new data[e_BUSINESS_DATA];

    if (!Business_Fetch(key,data))
    {
        return false;
    }

    return Property_IsNear(playerid,radius,data[E_BUSINESS_EXIT_X],data[E_BUSINESS_EXIT_Y],data[E_BUSINESS_EXIT_Z]);
}

stock Business_GetLevelNeeded(key)
{
    new data[e_BUSINESS_DATA];
    return Business_Fetch(key,data) ? data[E_BUSINESS_LEVEL_NEEDED] : 0;
}

stock Business_GetBuyPrice(key)
{
    new data[e_BUSINESS_DATA];
    return Business_Fetch(key,data) ? data[E_BUSINESS_BUY_PRICE] : 0;
}

stock Business_GetEntranceCost(key)
{
    new data[e_BUSINESS_DATA];
    return Business_Fetch(key,data) ? data[E_BUSINESS_ENTRANCE_COST] : 0;
}

stock Business_GetTill(key)
{
    new data[e_BUSINESS_DATA];
    return Business_Fetch(key,data) ? data[E_BUSINESS_TILL] : 0;
}

stock Business_GetInterior(key)
{
    new data[e_BUSINESS_DATA];
    return Business_Fetch(key,data) ? data[E_BUSINESS_INTERIOR] : 0;
}

stock Business_GetProducts(key)
{
    new data[e_BUSINESS_DATA];
    return Business_Fetch(key,data) ? data[E_BUSINESS_PRODUCTS] : 0;
}

stock Business_GetMaxProducts(key)
{
    new data[e_BUSINESS_DATA];
    return Business_Fetch(key,data) ? data[E_BUSINESS_MAX_PRODUCTS] : 0;
}

stock Business_GetPriceProd(key)
{
    new data[e_BUSINESS_DATA];
    return Business_Fetch(key,data) ? data[E_BUSINESS_PRICE_PROD] : 0;
}

stock Business_GetType(key)
{
    new data[e_BUSINESS_DATA];
    return Business_Fetch(key,data) ? data[E_BUSINESS_TYPE] : BUSINESS_TYPE_NONE;
}

stock Float:Business_GetEntranceAngle(key)
{
    new data[e_BUSINESS_DATA];
    return Business_Fetch(key,data) ? data[E_BUSINESS_ENTRANCE_ANGLE] : DOOR_NO_ANGLE;
}

stock Float:Business_GetExitAngle(key)
{
    new data[e_BUSINESS_DATA];
    return Business_Fetch(key,data) ? data[E_BUSINESS_EXIT_ANGLE] : DOOR_NO_ANGLE;
}

stock bool:Business_IsFreeStock(key)
{
    return Business_IsTyped(key) && Business_IsValid(key) && !Business_IsOwned(key);
}

stock Business_Save(key)
{
    new data[e_BUSINESS_DATA];

    if (!Business_Fetch(key,data))
    {
        return false;
    }

    if (Business_IsSpecial(key))
    {
        mysql_tquery_s(g_Mysql,str_format("UPDATE special_businesses SET owned = %d, owner = '%e', message = '%e', extortion = '%e', level_needed = %d, buy_price = %d, entrance_cost = %d, till = %d, locked = %d, interior = %d, products = %d, max_products = %d, price_prod = %d WHERE special_id = %d",data[E_BUSINESS_OWNED],data[E_BUSINESS_OWNER],data[E_BUSINESS_MESSAGE],data[E_BUSINESS_EXTORTION],data[E_BUSINESS_LEVEL_NEEDED],data[E_BUSINESS_BUY_PRICE],data[E_BUSINESS_ENTRANCE_COST],data[E_BUSINESS_TILL],data[E_BUSINESS_LOCKED],data[E_BUSINESS_INTERIOR],data[E_BUSINESS_PRODUCTS],data[E_BUSINESS_MAX_PRODUCTS],data[E_BUSINESS_PRICE_PROD],key - BUSINESS_SPECIAL_BASE));
        return true;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE businesses SET owned = %d, owner = '%e', message = '%e', extortion = '%e', level_needed = %d, buy_price = %d, entrance_cost = %d, till = %d, locked = %d, interior = %d, products = %d, max_products = %d, price_prod = %d WHERE business_id = %d",data[E_BUSINESS_OWNED],data[E_BUSINESS_OWNER],data[E_BUSINESS_MESSAGE],data[E_BUSINESS_EXTORTION],data[E_BUSINESS_LEVEL_NEEDED],data[E_BUSINESS_BUY_PRICE],data[E_BUSINESS_ENTRANCE_COST],data[E_BUSINESS_TILL],data[E_BUSINESS_LOCKED],data[E_BUSINESS_INTERIOR],data[E_BUSINESS_PRODUCTS],data[E_BUSINESS_MAX_PRODUCTS],data[E_BUSINESS_PRICE_PROD],key));
    return true;
}

stock Business_SyncShop(key)
{
    new data[e_BUSINESS_DATA];

    if (!Business_IsSpecial(key) || !Business_Fetch(key,data))
    {
        return;
    }

    Vehicles_SetShopPrice(key - BUSINESS_SPECIAL_BASE,data[E_BUSINESS_ENTRANCE_COST]);
    Vehicles_SetShopStock(key - BUSINESS_SPECIAL_BASE,data[E_BUSINESS_PRODUCTS]);
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
    new data[e_BUSINESS_DATA];

    if (!Business_Fetch(key,data))
    {
        return false;
    }

    if (data[E_BUSINESS_PICKUP] != -1)
    {
        DestroyDynamicPickup(STREAMER_TAG_PICKUP:data[E_BUSINESS_PICKUP]);
    }

    new model = data[E_BUSINESS_OWNED] == 1 ? BUSINESS_PICKUP_OWNED : BUSINESS_PICKUP_FOR_SALE;
    data[E_BUSINESS_PICKUP_MODEL] = model;
    data[E_BUSINESS_PICKUP] = _:CreateDynamicPickup(model,BUSINESS_PICKUP_TYPE,data[E_BUSINESS_ENTRANCE_X],data[E_BUSINESS_ENTRANCE_Y],data[E_BUSINESS_ENTRANCE_Z],0,0);
    Business_Store(key,data);
    return true;
}

stock Business_RefreshAllPickups()
{
    for (new row = 0, rows = Business_GetRowCount();row < rows;row++)
    {
        Business_RefreshPickup(Business_GetKeyOfRow(row));
    }
}

stock Business_SetMessage(key,const text[])
{
    new data[e_BUSINESS_DATA];

    if (Business_Fetch(key,data))
    {
        strcopy(data[E_BUSINESS_MESSAGE],text,BUSINESS_MESSAGE_LEN);
        Business_Store(key,data);
        Business_Save(key);
    }
}

stock Business_SetExtortion(key,const name[])
{
    new data[e_BUSINESS_DATA];

    if (Business_Fetch(key,data))
    {
        strcopy(data[E_BUSINESS_EXTORTION],name,BUSINESS_NAME_LEN);
        Business_Store(key,data);
        Business_Save(key);
    }
}

stock Business_SetLevelNeeded(key,level)
{
    new data[e_BUSINESS_DATA];

    if (Business_Fetch(key,data))
    {
        data[E_BUSINESS_LEVEL_NEEDED] = level;
        Business_Store(key,data);
        Business_Save(key);
    }
}

stock Business_SetBuyPrice(key,price)
{
    new data[e_BUSINESS_DATA];

    if (Business_Fetch(key,data))
    {
        data[E_BUSINESS_BUY_PRICE] = price;
        Business_Store(key,data);
        Business_Save(key);
    }
}

stock Business_SetEntranceCost(key,cost)
{
    new data[e_BUSINESS_DATA];

    if (Business_Fetch(key,data))
    {
        data[E_BUSINESS_ENTRANCE_COST] = cost;
        Business_Store(key,data);
        Business_Save(key);
        Business_SyncShop(key);
    }
}

stock Business_SetTill(key,amount)
{
    new data[e_BUSINESS_DATA];

    if (Business_Fetch(key,data))
    {
        data[E_BUSINESS_TILL] = amount;
        Business_Store(key,data);
        Business_Save(key);
    }
}

stock Business_AddTill(key,amount)
{
    new data[e_BUSINESS_DATA];

    if (!Business_IsFreeStock(key) && Business_Fetch(key,data))
    {
        data[E_BUSINESS_TILL] += amount;
        Business_Store(key,data);
        Business_Save(key);
    }
}

stock Business_SetLocked(key,bool:isLocked)
{
    new data[e_BUSINESS_DATA];

    if (Business_Fetch(key,data))
    {
        data[E_BUSINESS_LOCKED] = isLocked ? 1 : 0;
        Business_Store(key,data);
        Business_Save(key);
    }
}

stock Business_SetProducts(key,amount)
{
    new data[e_BUSINESS_DATA];

    if (Business_Fetch(key,data))
    {
        data[E_BUSINESS_PRODUCTS] = amount;
        Business_Store(key,data);
        Business_Save(key);
        Business_SyncShop(key);
    }
}

stock Business_AddProducts(key,amount)
{
    new data[e_BUSINESS_DATA];

    if (Business_Fetch(key,data))
    {
        Business_SetProducts(key,data[E_BUSINESS_PRODUCTS] + amount);
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
    new data[e_BUSINESS_DATA];

    if (Business_Fetch(key,data))
    {
        data[E_BUSINESS_PRICE_PROD] = price;
        Business_Store(key,data);
        Business_Save(key);
    }
}

stock Business_Claim(key,const name[])
{
    new data[e_BUSINESS_DATA];

    if (!Business_Fetch(key,data))
    {
        return;
    }

    data[E_BUSINESS_OWNED] = 1;
    strcopy(data[E_BUSINESS_OWNER],name,BUSINESS_OWNER_LEN);
    Business_Store(key,data);
    Business_Save(key);
    Business_RefreshPickup(key);
    pawn_call_public("Business_OnOwnerChanged","d",key);
}

stock Business_Release(key)
{
    new data[e_BUSINESS_DATA];

    if (!Business_Fetch(key,data))
    {
        return;
    }

    data[E_BUSINESS_LOCKED] = Business_IsTyped(key) ? 0 : 1;
    data[E_BUSINESS_OWNED] = 0;
    strcopy(data[E_BUSINESS_OWNER],BUSINESS_OWNER_NONE,BUSINESS_OWNER_LEN);
    strcopy(data[E_BUSINESS_EXTORTION],BUSINESS_EXTORTION_NONE,BUSINESS_NAME_LEN);
    data[E_BUSINESS_TILL] = 0;
    Business_Store(key,data);
    Business_Save(key);
    Business_RefreshPickup(key);
    pawn_call_public("Business_OnOwnerChanged","d",key);
}

stock Business_Extort(key,money)
{
    new data[e_BUSINESS_DATA];

    if (!Business_Fetch(key,data))
    {
        return 0;
    }

    if (strcmp(data[E_BUSINESS_EXTORTION],BUSINESS_EXTORTION_NONE,true) == 0)
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

        if (strcmp(data[E_BUSINESS_EXTORTION],name,true) == 0)
        {
            Account_SetCash(playerid,Account_GetCash(playerid) + payout);
            data[E_BUSINESS_TILL] -= payout;
        }
    }

    Business_Store(key,data);
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
    new key = BUSINESS_TYPED_BASE;

    while (Business_IsValid(key))
    {
        key++;
    }

    return key;
}

stock bool:Business_InitTypedRow(key,type,const message[],Float:entranceX,Float:entranceY,Float:entranceZ,Float:entranceAngle,Float:exitX,Float:exitY,Float:exitZ,Float:exitAngle,interior,price,level)
{
    if (!Business_IsTyped(key) || Business_IsValid(key))
    {
        return false;
    }

    new data[e_BUSINESS_DATA];
    strcopy(data[E_BUSINESS_OWNER],BUSINESS_OWNER_NONE,BUSINESS_OWNER_LEN);
    strcopy(data[E_BUSINESS_MESSAGE],message,BUSINESS_MESSAGE_LEN);
    strcopy(data[E_BUSINESS_EXTORTION],BUSINESS_EXTORTION_NONE,BUSINESS_NAME_LEN);
    data[E_BUSINESS_ENTRANCE_X] = entranceX;
    data[E_BUSINESS_ENTRANCE_Y] = entranceY;
    data[E_BUSINESS_ENTRANCE_Z] = entranceZ;
    data[E_BUSINESS_ENTRANCE_ANGLE] = entranceAngle;
    data[E_BUSINESS_EXIT_X] = exitX;
    data[E_BUSINESS_EXIT_Y] = exitY;
    data[E_BUSINESS_EXIT_Z] = exitZ;
    data[E_BUSINESS_EXIT_ANGLE] = exitAngle;
    data[E_BUSINESS_LEVEL_NEEDED] = level;
    data[E_BUSINESS_BUY_PRICE] = price;
    data[E_BUSINESS_INTERIOR] = interior;
    data[E_BUSINESS_PRODUCTS] = BUSINESS_TYPED_PRODUCTS;
    data[E_BUSINESS_MAX_PRODUCTS] = BUSINESS_TYPED_MAX_PRODUCTS;
    data[E_BUSINESS_PRICE_PROD] = BUSINESS_TYPED_PRICE_PROD;
    data[E_BUSINESS_TYPE] = type;
    data[E_BUSINESS_PICKUP] = -1;
    Business_Insert(key,data);
    return true;
}

stock bool:Business_FreeTypedRow(key)
{
    new data[e_BUSINESS_DATA];

    if (!Business_IsTyped(key) || !Business_Fetch(key,data))
    {
        return false;
    }

    if (data[E_BUSINESS_PICKUP] != -1)
    {
        DestroyDynamicPickup(STREAMER_TAG_PICKUP:data[E_BUSINESS_PICKUP]);
    }

    pool_remove(s_Business,Business_Slot(key));
    map_remove(s_BusinessSlots,key);

    while (s_BusinessTypedCount > 0 && !Business_IsValid(BUSINESS_TYPED_BASE + s_BusinessTypedCount - 1))
    {
        s_BusinessTypedCount--;
    }

    return true;
}

stock bool:Business_SetEntrance(key,Float:x,Float:y,Float:z,Float:angle)
{
    new data[e_BUSINESS_DATA];

    if (Business_IsSpecial(key) || !Business_Fetch(key,data))
    {
        return false;
    }

    data[E_BUSINESS_ENTRANCE_X] = x;
    data[E_BUSINESS_ENTRANCE_Y] = y;
    data[E_BUSINESS_ENTRANCE_Z] = z;
    data[E_BUSINESS_ENTRANCE_ANGLE] = angle;
    Business_Store(key,data);
    return true;
}

static Business_ReadRow(row,data[e_BUSINESS_DATA],bool:isSpecial)
{
    cache_get_value_name_int(row,"owned",data[E_BUSINESS_OWNED]);
    cache_get_value_name(row,"owner",data[E_BUSINESS_OWNER],BUSINESS_OWNER_LEN);
    cache_get_value_name(row,"message",data[E_BUSINESS_MESSAGE],BUSINESS_MESSAGE_LEN);
    cache_get_value_name(row,"extortion",data[E_BUSINESS_EXTORTION],BUSINESS_NAME_LEN);
    cache_get_value_name_float(row,"entrance_x",data[E_BUSINESS_ENTRANCE_X]);
    cache_get_value_name_float(row,"entrance_y",data[E_BUSINESS_ENTRANCE_Y]);
    cache_get_value_name_float(row,"entrance_z",data[E_BUSINESS_ENTRANCE_Z]);

    if (!isSpecial)
    {
        cache_get_value_name_float(row,"exit_x",data[E_BUSINESS_EXIT_X]);
        cache_get_value_name_float(row,"exit_y",data[E_BUSINESS_EXIT_Y]);
        cache_get_value_name_float(row,"exit_z",data[E_BUSINESS_EXIT_Z]);
    }

    cache_get_value_name_int(row,"level_needed",data[E_BUSINESS_LEVEL_NEEDED]);
    cache_get_value_name_int(row,"buy_price",data[E_BUSINESS_BUY_PRICE]);
    cache_get_value_name_int(row,"entrance_cost",data[E_BUSINESS_ENTRANCE_COST]);
    cache_get_value_name_int(row,"till",data[E_BUSINESS_TILL]);
    cache_get_value_name_int(row,"locked",data[E_BUSINESS_LOCKED]);
    cache_get_value_name_int(row,"interior",data[E_BUSINESS_INTERIOR]);
    cache_get_value_name_int(row,"products",data[E_BUSINESS_PRODUCTS]);
    cache_get_value_name_int(row,"max_products",data[E_BUSINESS_MAX_PRODUCTS]);
    cache_get_value_name_int(row,"price_prod",data[E_BUSINESS_PRICE_PROD]);

    if (!isSpecial)
    {
        new typeName[BUSINESS_TYPE_NAME_LEN];
        cache_get_value_name(row,"biz_type",typeName,sizeof(typeName));
        data[E_BUSINESS_TYPE] = Business_TypeFromName(typeName);
        cache_get_value_name_float(row,"entrance_angle",data[E_BUSINESS_ENTRANCE_ANGLE]);
        cache_get_value_name_float(row,"exit_angle",data[E_BUSINESS_EXIT_ANGLE]);
    }
}

static Business_LoadRow(row,key,bool:isSpecial)
{
    new data[e_BUSINESS_DATA], bool:isKnown = Business_Fetch(key,data);

    if (!isKnown)
    {
        data[E_BUSINESS_PICKUP] = -1;
    }

    Business_ReadRow(row,data,isSpecial);

    if (isKnown)
    {
        Business_Store(key,data);
    }
    else
    {
        Business_Insert(key,data);
    }
}

#pragma warning push
#pragma warning disable 204
async Task:Business_LoadAll()
{
    await task_ticks(1);

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
            Log_Error("business","business %d is not a valid business number, it was skipped",id);
            continue;
        }

        Business_LoadRow(row,id,false);
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

        Business_LoadRow(row,BUSINESS_SPECIAL_BASE + id,true);
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
