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
#define VEHICLE_KEY_MAX (511)
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

static s_VehicleKey[VEHICLE_MAX];
static s_KeyVehicle[VEHICLE_KEY_MAX + 1];
static s_HouseVehicle[VEHICLE_HOUSE_MAX];
static s_VehicleHouse[VEHICLE_MAX];

static s_RowUsed[VEHICLE_KEY_MAX + 1];
static s_RowKind[VEHICLE_KEY_MAX + 1];
static s_RowModel[VEHICLE_KEY_MAX + 1];
static s_RowColor1[VEHICLE_KEY_MAX + 1];
static s_RowColor2[VEHICLE_KEY_MAX + 1];
static s_RowRespawn[VEHICLE_KEY_MAX + 1];
static s_RowInterior[VEHICLE_KEY_MAX + 1];
static s_RowClasses[VEHICLE_KEY_MAX + 1];
static s_RowGates[VEHICLE_KEY_MAX + 1];
static s_RowShop[VEHICLE_KEY_MAX + 1];
static s_RowSlot[VEHICLE_KEY_MAX + 1];
static Float:s_RowPos[VEHICLE_KEY_MAX + 1][4];

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
    if (key < 1 || key > VEHICLE_KEY_MAX || !s_RowUsed[key])
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        angle = 0.0;
        return false;
    }

    x = s_RowPos[key][0];
    y = s_RowPos[key][1];
    z = s_RowPos[key][2];
    angle = s_RowPos[key][3];
    return true;
}

stock Vehicles_GetRowColors(key, &color1, &color2)
{
    if (key < 1 || key > VEHICLE_KEY_MAX || !s_RowUsed[key])
    {
        color1 = -1;
        color2 = -1;
        return false;
    }

    color1 = s_RowColor1[key];
    color2 = s_RowColor2[key];
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
    new key = houseid + 1;

    if (houseid < 0 || houseid >= VEHICLE_HOUSE_MAX || key > VEHICLE_KEY_MAX || !s_RowUsed[key] || s_RowKind[key] != VEHICLE_KIND_HOUSE)
    {
        return false;
    }

    if (model >= 400 && model <= 611)
    {
        s_RowModel[key] = model;
    }

    s_RowColor1[key] = color1;
    s_RowColor2[key] = color2;
    mysql_tquery_s(g_Mysql, str_format("UPDATE vehicles SET model = %d, color1 = %d, color2 = %d WHERE id = %d", s_RowModel[key], color1, color2, key));
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

static Vehicles_StoreRow(row)
{
    new key;
    cache_get_value_name_int(row, "id", key);

    if (key < 1 || key > VEHICLE_KEY_MAX)
    {
        return 0;
    }

    s_RowUsed[key] = true;
    cache_get_value_name_int(row, "kind", s_RowKind[key]);
    cache_get_value_name_int(row, "model", s_RowModel[key]);
    cache_get_value_name_int(row, "color1", s_RowColor1[key]);
    cache_get_value_name_int(row, "color2", s_RowColor2[key]);
    cache_get_value_name_int(row, "respawn", s_RowRespawn[key]);
    cache_get_value_name_int(row, "interior", s_RowInterior[key]);
    cache_get_value_name_int(row, "classes", s_RowClasses[key]);
    cache_get_value_name_int(row, "gates", s_RowGates[key]);
    cache_get_value_name_int(row, "shop", s_RowShop[key]);
    cache_get_value_name_float(row, "x", s_RowPos[key][0]);
    cache_get_value_name_float(row, "y", s_RowPos[key][1]);
    cache_get_value_name_float(row, "z", s_RowPos[key][2]);
    cache_get_value_name_float(row, "angle", s_RowPos[key][3]);
    return key;
}

stock Vehicles_SpawnKey(key)
{
    if (key < 1 || key > VEHICLE_KEY_MAX || !s_RowUsed[key])
    {
        return INVALID_VEHICLE_ID;
    }

    new model = s_RowModel[key], color1 = s_RowColor1[key], color2 = s_RowColor2[key];

    if (s_RowKind[key] == VEHICLE_KIND_STREET)
    {
        model = s_StreetModels[s_RowSlot[key]];
        color1 = random(VEHICLE_STREET_COLOUR_RANGE);
    }

    new vehicleid;

    if (s_RowKind[key] == VEHICLE_KIND_MINIGAME)
    {
        vehicleid = CreateVehicle(model, s_RowPos[key][0], s_RowPos[key][1], s_RowPos[key][2], s_RowPos[key][3], color1, color2, s_RowRespawn[key]);
    }
    else
    {
        vehicleid = AddStaticVehicleEx(model, s_RowPos[key][0], s_RowPos[key][1], s_RowPos[key][2], s_RowPos[key][3], color1, color2, s_RowRespawn[key]);
    }

    if (vehicleid == INVALID_VEHICLE_ID || vehicleid < 1 || vehicleid > MAX_VEHICLES)
    {
        Log_Error("vehicles", "vehicle %d (model %d) was not created", key, model);
        return INVALID_VEHICLE_ID;
    }

    s_VehicleKey[vehicleid] = key;
    s_KeyVehicle[key] = vehicleid;
    s_VehicleKind[vehicleid] = s_RowKind[key];
    s_VehicleClasses[vehicleid] = s_RowClasses[key];
    s_VehicleGates[vehicleid] = s_RowGates[key];
    s_VehicleShop[vehicleid] = s_RowShop[key];

    if (s_RowInterior[key] != 0)
    {
        LinkVehicleToInterior(vehicleid, s_RowInterior[key]);
    }

    if (s_RowKind[key] == VEHICLE_KIND_HOUSE)
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
        new key = Vehicles_StoreRow(row);

        if (key == 0)
        {
            continue;
        }

        if (s_RowKind[key] == VEHICLE_KIND_STREET)
        {
            s_RowSlot[key] = streetIndex % VEHICLE_STREET_SLOTS;
            streetIndex++;
        }
    }

    for (new key = 1; key <= VEHICLE_KEY_MAX; key++)
    {
        if (s_RowUsed[key])
        {
            Vehicles_SpawnKey(key);
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
