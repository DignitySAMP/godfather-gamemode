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
#define VEHICLE_MAX (MAX_VEHICLES + 1)
#define VEHICLE_HOUSE_MAX (64)
#define VEHICLE_NO_HOUSE (255)
#define VEHICLE_STREET_SLOTS (14)
#define VEHICLE_STREET_POOL (20)
#define VEHICLE_STREET_COLOUR_RANGE (126)
#define VEHICLE_SHOP_COUNT (12)
#define VEHICLE_SHOP_GAS (3)
#define VEHICLE_SHOP_UPGRADE (5)
#define VEHICLE_SHOP_TOW (8)
#define VEHICLE_SHOP_DEFAULT_STOCK (100)
#define VEHICLE_SHOP_GAS_PRICE (1)

#define VEHICLE_KIND_HOUSE (0)
#define VEHICLE_KIND_MINIGAME (2)
#define VEHICLE_KIND_STREET (3)

#define VEHICLE_CLASS_COP (1)
#define VEHICLE_CLASS_AMBULANCE (2)
#define VEHICLE_CLASS_TRUCK (4)
#define VEHICLE_CLASS_BOAT (8)
#define VEHICLE_CLASS_PLANE (16)

#define VEHICLE_GATE_COP (1)
#define VEHICLE_GATE_AMBULANCE (2)
#define VEHICLE_GATE_GUARDAIR (4)
#define VEHICLE_GATE_FIRE (8)
#define VEHICLE_GATE_BUS (16)
#define VEHICLE_GATE_SCHOOL (32)
#define VEHICLE_GATE_TAXI (64)
#define VEHICLE_GATE_HITMAN (128)
#define VEHICLE_GATE_NEWS (256)
#define VEHICLE_GATE_KART (512)

forward Vehicles_OnCreated(vehicleid, key);
forward Vehicles_OnSale(playerid, shop, amount, products);
forward Task:Vehicles_LoadWorld();

enum e_VEHICLE_ROW
{
    E_VEHICLE_ROW_KEY,
    E_VEHICLE_ROW_KIND,
    E_VEHICLE_ROW_MODEL,
    E_VEHICLE_ROW_COLOR1,
    E_VEHICLE_ROW_COLOR2,
    E_VEHICLE_ROW_RESPAWN,
    E_VEHICLE_ROW_INTERIOR,
    E_VEHICLE_ROW_CLASSES,
    E_VEHICLE_ROW_GATES,
    E_VEHICLE_ROW_SHOP,
    E_VEHICLE_ROW_SLOT,
    Float:E_VEHICLE_ROW_X,
    Float:E_VEHICLE_ROW_Y,
    Float:E_VEHICLE_ROW_Z,
    Float:E_VEHICLE_ROW_ANGLE,
    E_VEHICLE_ROW_VEHICLE
}

static s_VehicleKey[VEHICLE_MAX];
static Pool:s_VehicleRows;
static Map:s_VehicleRowSlots;
static s_HouseVehicle[VEHICLE_HOUSE_MAX];
static s_VehicleHouse[VEHICLE_MAX];

static s_VehicleKind[VEHICLE_MAX];
static s_VehicleClasses[VEHICLE_MAX];
static s_VehicleGates[VEHICLE_MAX];
static s_VehicleShop[VEHICLE_MAX];

static s_ShopPrice[VEHICLE_SHOP_COUNT];
static s_ShopStock[VEHICLE_SHOP_COUNT];

static s_StreetModels[VEHICLE_STREET_SLOTS];
static s_StreetPoolSize = VEHICLE_STREET_POOL;
static s_WorldCreated;

static const s_StreetPool[VEHICLE_STREET_POOL] =
{
    496, 542, 507, 585, 466, 492, 579, 559, 400, 551,
    516, 475, 561, 550, 566, 558, 562, 562, 603, 560
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
static Vehicles_RowSlot(key)
{
    if (!map_valid(s_VehicleRowSlots) || !map_has_key(s_VehicleRowSlots, key))
    {
        return -1;
    }

    return map_get(s_VehicleRowSlots, key);
}

static bool:Vehicles_FetchRow(key, data[e_VEHICLE_ROW])
{
    new slot = Vehicles_RowSlot(key);

    if (slot == -1)
    {
        return false;
    }

    pool_get_arr(s_VehicleRows, slot, data);
    return true;
}

static Vehicles_StoreRowData(key, const data[e_VEHICLE_ROW])
{
    pool_set_arr(s_VehicleRows, Vehicles_RowSlot(key), data);
}

stock Vehicles_GetKey(vehicleid)
{
    if (vehicleid < 1 || vehicleid > MAX_VEHICLES)
    {
        return 0;
    }

    return s_VehicleKey[vehicleid];
}

stock Vehicles_GetKind(vehicleid)
{
    if (vehicleid < 1 || vehicleid > MAX_VEHICLES || s_VehicleKey[vehicleid] == 0)
    {
        return -1;
    }

    return s_VehicleKind[vehicleid];
}

stock Vehicles_GetClasses(vehicleid)
{
    if (vehicleid < 1 || vehicleid > MAX_VEHICLES)
    {
        return 0;
    }

    return s_VehicleClasses[vehicleid];
}

stock Vehicles_GetGates(vehicleid)
{
    if (vehicleid < 1 || vehicleid > MAX_VEHICLES)
    {
        return 0;
    }

    return s_VehicleGates[vehicleid];
}

stock Vehicles_GetRentalShop(vehicleid)
{
    if (vehicleid < 1 || vehicleid > MAX_VEHICLES || s_VehicleKey[vehicleid] == 0)
    {
        return -1;
    }

    return s_VehicleShop[vehicleid];
}

stock bool:Vehicles_IsCopCar(vehicleid)
{
    return (Vehicles_GetClasses(vehicleid) & VEHICLE_CLASS_COP) != 0;
}

stock bool:Vehicles_IsAmbulance(vehicleid)
{
    return (Vehicles_GetClasses(vehicleid) & VEHICLE_CLASS_AMBULANCE) != 0;
}

stock bool:Vehicles_IsTruck(vehicleid)
{
    return (Vehicles_GetClasses(vehicleid) & VEHICLE_CLASS_TRUCK) != 0;
}

stock bool:Vehicles_IsBoat(vehicleid)
{
    return (Vehicles_GetClasses(vehicleid) & VEHICLE_CLASS_BOAT) != 0;
}

stock bool:Vehicles_IsPlane(vehicleid)
{
    return (Vehicles_GetClasses(vehicleid) & VEHICLE_CLASS_PLANE) != 0;
}

stock bool:Vehicles_GetSpawnPoint(key, &Float:x, &Float:y, &Float:z, &Float:angle)
{
    new data[e_VEHICLE_ROW];

    if (!Vehicles_FetchRow(key, data))
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        angle = 0.0;
        return false;
    }

    x = data[E_VEHICLE_ROW_X];
    y = data[E_VEHICLE_ROW_Y];
    z = data[E_VEHICLE_ROW_Z];
    angle = data[E_VEHICLE_ROW_ANGLE];
    return true;
}

stock Vehicles_GetRowColors(key, &color1, &color2)
{
    new data[e_VEHICLE_ROW];

    if (!Vehicles_FetchRow(key, data))
    {
        color1 = -1;
        color2 = -1;
        return false;
    }

    color1 = data[E_VEHICLE_ROW_COLOR1];
    color2 = data[E_VEHICLE_ROW_COLOR2];
    return true;
}

stock Vehicles_GetHouseCar(houseid)
{
    if (houseid < 0 || houseid >= VEHICLE_HOUSE_MAX)
    {
        return 0;
    }

    return s_HouseVehicle[houseid];
}

stock bool:Vehicles_SetHouseCar(houseid, vehicleid)
{
    if (houseid < 0 || houseid >= VEHICLE_HOUSE_MAX)
    {
        return false;
    }

    new previous = s_HouseVehicle[houseid];

    if (previous > 0 && previous <= MAX_VEHICLES)
    {
        s_VehicleHouse[previous] = 0;
    }

    s_HouseVehicle[houseid] = 0;

    if (vehicleid >= 1 && vehicleid <= MAX_VEHICLES)
    {
        s_HouseVehicle[houseid] = vehicleid;
        s_VehicleHouse[vehicleid] = houseid + 1;
    }

    return true;
}

stock bool:Vehicles_SetHouseCarStyle(houseid, model, color1, color2)
{
    new key = houseid + 1, data[e_VEHICLE_ROW];

    if (houseid < 0 || houseid >= VEHICLE_HOUSE_MAX || !Vehicles_FetchRow(key, data) || data[E_VEHICLE_ROW_KIND] != VEHICLE_KIND_HOUSE)
    {
        return false;
    }

    if (model >= 400 && model <= 611)
    {
        data[E_VEHICLE_ROW_MODEL] = model;
    }

    data[E_VEHICLE_ROW_COLOR1] = color1;
    data[E_VEHICLE_ROW_COLOR2] = color2;
    Vehicles_StoreRowData(key, data);
    mysql_tquery_s(g_Mysql, str_format("UPDATE vehicles SET model = %d, color1 = %d, color2 = %d WHERE id = %d", data[E_VEHICLE_ROW_MODEL], color1, color2, key));
    return true;
}

stock Vehicles_GetShopPrice(shop)
{
    if (shop < 0 || shop >= VEHICLE_SHOP_COUNT)
    {
        return 0;
    }

    return s_ShopPrice[shop];
}

stock Vehicles_SetShopPrice(shop, price)
{
    if (shop >= 0 && shop < VEHICLE_SHOP_COUNT)
    {
        s_ShopPrice[shop] = price;
    }
}

stock Vehicles_GetShopStock(shop)
{
    if (shop < 0 || shop >= VEHICLE_SHOP_COUNT)
    {
        return 0;
    }

    return s_ShopStock[shop];
}

stock Vehicles_SetShopStock(shop, amount)
{
    if (shop >= 0 && shop < VEHICLE_SHOP_COUNT)
    {
        s_ShopStock[shop] = amount;
    }
}

stock Vehicles_SellFromShop(playerid, shop, amount, bool:usesProduct)
{
    if (shop < 0 || shop >= VEHICLE_SHOP_COUNT)
    {
        return;
    }

    if (usesProduct)
    {
        s_ShopStock[shop]--;
    }

    pawn_call_public("Vehicles_OnSale", "dddd", playerid, shop, amount, usesProduct ? 1 : 0);
}

stock Vehicles_ResetShops()
{
    for (new shop = 0; shop < VEHICLE_SHOP_COUNT; shop++)
    {
        s_ShopPrice[shop] = 0;
        s_ShopStock[shop] = VEHICLE_SHOP_DEFAULT_STOCK;
    }

    s_ShopPrice[VEHICLE_SHOP_GAS] = VEHICLE_SHOP_GAS_PRICE;
}

static Vehicles_PickStreetModels()
{
    for (new slot = 0; slot < VEHICLE_STREET_SLOTS; slot++)
    {
        s_StreetModels[slot] = s_StreetPool[random(s_StreetPoolSize)];
    }
}

static Vehicles_StoreRow(row, &streetIndex)
{
    new data[e_VEHICLE_ROW];
    cache_get_value_name_int(row, "id", data[E_VEHICLE_ROW_KEY]);

    new key = data[E_VEHICLE_ROW_KEY];

    if (key < 1)
    {
        return 0;
    }

    cache_get_value_name_int(row, "kind", data[E_VEHICLE_ROW_KIND]);
    cache_get_value_name_int(row, "model", data[E_VEHICLE_ROW_MODEL]);
    cache_get_value_name_int(row, "color1", data[E_VEHICLE_ROW_COLOR1]);
    cache_get_value_name_int(row, "color2", data[E_VEHICLE_ROW_COLOR2]);
    cache_get_value_name_int(row, "respawn", data[E_VEHICLE_ROW_RESPAWN]);
    cache_get_value_name_int(row, "interior", data[E_VEHICLE_ROW_INTERIOR]);
    cache_get_value_name_int(row, "classes", data[E_VEHICLE_ROW_CLASSES]);
    cache_get_value_name_int(row, "gates", data[E_VEHICLE_ROW_GATES]);
    cache_get_value_name_int(row, "shop", data[E_VEHICLE_ROW_SHOP]);
    cache_get_value_name_float(row, "x", data[E_VEHICLE_ROW_X]);
    cache_get_value_name_float(row, "y", data[E_VEHICLE_ROW_Y]);
    cache_get_value_name_float(row, "z", data[E_VEHICLE_ROW_Z]);
    cache_get_value_name_float(row, "angle", data[E_VEHICLE_ROW_ANGLE]);

    if (data[E_VEHICLE_ROW_KIND] == VEHICLE_KIND_STREET)
    {
        data[E_VEHICLE_ROW_SLOT] = streetIndex % VEHICLE_STREET_SLOTS;
        streetIndex++;
    }

    if (!pool_valid(s_VehicleRows))
    {
        s_VehicleRows = pool_new(-1, true);
        s_VehicleRowSlots = map_new();
    }

    new slot = Vehicles_RowSlot(key);

    if (slot == -1)
    {
        map_add(s_VehicleRowSlots, key, pool_add_arr(s_VehicleRows, data));
    }
    else
    {
        pool_set_arr(s_VehicleRows, slot, data);
    }

    return key;
}

stock Vehicles_SpawnKey(key)
{
    new data[e_VEHICLE_ROW];

    if (!Vehicles_FetchRow(key, data))
    {
        return INVALID_VEHICLE_ID;
    }

    new model = data[E_VEHICLE_ROW_MODEL], color1 = data[E_VEHICLE_ROW_COLOR1], color2 = data[E_VEHICLE_ROW_COLOR2];

    if (data[E_VEHICLE_ROW_KIND] == VEHICLE_KIND_STREET)
    {
        model = s_StreetModels[data[E_VEHICLE_ROW_SLOT]];
        color1 = random(VEHICLE_STREET_COLOUR_RANGE);
    }

    new vehicleid;

    if (data[E_VEHICLE_ROW_KIND] == VEHICLE_KIND_MINIGAME)
    {
        vehicleid = CreateVehicle(model, data[E_VEHICLE_ROW_X], data[E_VEHICLE_ROW_Y], data[E_VEHICLE_ROW_Z], data[E_VEHICLE_ROW_ANGLE], color1, color2, data[E_VEHICLE_ROW_RESPAWN]);
    }
    else
    {
        vehicleid = AddStaticVehicleEx(model, data[E_VEHICLE_ROW_X], data[E_VEHICLE_ROW_Y], data[E_VEHICLE_ROW_Z], data[E_VEHICLE_ROW_ANGLE], color1, color2, data[E_VEHICLE_ROW_RESPAWN]);
    }

    if (vehicleid == INVALID_VEHICLE_ID || vehicleid < 1 || vehicleid > MAX_VEHICLES)
    {
        Log_Error("vehicles", "vehicle %d (model %d) was not created", key, model);
        return INVALID_VEHICLE_ID;
    }

    data[E_VEHICLE_ROW_VEHICLE] = vehicleid;
    Vehicles_StoreRowData(key, data);
    s_VehicleKey[vehicleid] = key;
    s_VehicleKind[vehicleid] = data[E_VEHICLE_ROW_KIND];
    s_VehicleClasses[vehicleid] = data[E_VEHICLE_ROW_CLASSES];
    s_VehicleGates[vehicleid] = data[E_VEHICLE_ROW_GATES];
    s_VehicleShop[vehicleid] = data[E_VEHICLE_ROW_SHOP];

    if (data[E_VEHICLE_ROW_INTERIOR] != 0)
    {
        LinkVehicleToInterior(vehicleid, data[E_VEHICLE_ROW_INTERIOR]);
    }

    if (data[E_VEHICLE_ROW_KIND] == VEHICLE_KIND_HOUSE)
    {
        Vehicles_SetHouseCar(key - 1, vehicleid);
    }

    s_WorldCreated++;
    pawn_call_public("Vehicles_OnCreated", "dd", vehicleid, key);
    return vehicleid;
}

async Task:Vehicles_LoadWorld()
{
    await task_ticks(1);

    Vehicles_PickStreetModels();

    await mysql_aquery_s(g_Mysql, str_new("SELECT id, kind, model, color1, color2, x, y, z, angle, respawn, interior, classes, gates, shop FROM vehicles ORDER BY id"), false);

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("vehicles", "world load failed, no vehicles were created");
        return async 0;
    }

    new rows = cache_num_rows(), streetIndex = 0;

    for (new row = 0; row < rows; row++)
    {
        Vehicles_StoreRow(row, streetIndex);
    }

    for (new slot = 0, slots = pool_valid(s_VehicleRows) ? pool_capacity(s_VehicleRows) : 0; slot < slots; slot++)
    {
        if (pool_has(s_VehicleRows, slot))
        {
            Vehicles_SpawnKey(pool_get(s_VehicleRows, slot, _:E_VEHICLE_ROW_KEY));
        }
    }

    Log_Info("vehicles", "%d vehicles created from the table", s_WorldCreated);
    return async s_WorldCreated;
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
public Vehicles_OnCreated(vehicleid, key)
{
    return 1;
}

public Vehicles_OnSale(playerid, shop, amount, products)
{
    return 1;
}
