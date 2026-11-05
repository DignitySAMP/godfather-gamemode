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
#define HOUSES_LOADER "Houses"
#define HOUSE_LOCAL_LIMIT (99)
#define HOUSE_NO_KEY (255)
#define HOUSE_OWNER_NONE "The State"
#define HOUSE_NAME_LEN (MAX_PLAYER_NAME + 1)
#define HOUSE_DESCRIPTION_LEN (32)
#define HOUSE_CAR_DEFAULT_MODEL (418)
#define HOUSE_CAR_DEFAULT_COLOUR (-1)
#define HOUSE_PICKUP_FOR_SALE (1273)
#define HOUSE_PICKUP_OWNED (1239)
#define HOUSE_PICKUP_TYPE (2)
#define HOUSE_PREDICATE_LEN (32)
#define DOOR_KIND_HOUSE "house"

enum e_HOUSE_DATA
{
    Float:E_HOUSE_ENTRANCE_X,
    Float:E_HOUSE_ENTRANCE_Y,
    Float:E_HOUSE_ENTRANCE_Z,
    Float:E_HOUSE_EXIT_X,
    Float:E_HOUSE_EXIT_Y,
    Float:E_HOUSE_EXIT_Z,
    E_HOUSE_HEALTH_X,
    E_HOUSE_HEALTH_Y,
    E_HOUSE_HEALTH_Z,
    E_HOUSE_ARMOUR_X,
    E_HOUSE_ARMOUR_Y,
    E_HOUSE_ARMOUR_Z,
    E_HOUSE_OWNER[HOUSE_NAME_LEN],
    E_HOUSE_DESCRIPTION[HOUSE_DESCRIPTION_LEN],
    E_HOUSE_PRICE,
    E_HOUSE_HEALTH_UPGRADE,
    E_HOUSE_ARMOUR_UPGRADE,
    E_HOUSE_INTERIOR,
    E_HOUSE_LOCKED,
    E_HOUSE_OWNED,
    E_HOUSE_ROOMS,
    E_HOUSE_RENT,
    E_HOUSE_RENTABLE,
    E_HOUSE_TAKINGS,
    E_HOUSE_CAR_MODEL,
    E_HOUSE_CAR_COLOUR1,
    E_HOUSE_CAR_COLOUR2,
    E_HOUSE_SEEN_DAY,
    E_HOUSE_LEVEL,
    Float:E_HOUSE_ENTRANCE_ANGLE,
    Float:E_HOUSE_EXIT_ANGLE,
    E_HOUSE_PICKUP,
    E_HOUSE_PICKUP_MODEL
}

enum _:E_HOUSE_PREDICATE
{
    HOUSE_PREDICATE_IS_COP = 0,
    HOUSE_PREDICATE_IS_MARRIED,
    HOUSE_PREDICATE_ON_MISSION,
    HOUSE_PREDICATE_UPGRADE_STOCK
}

static Pool:s_Houses;
static Map:s_HouseSlots;
static s_HouseCount;

static s_HousePredicates[E_HOUSE_PREDICATE][HOUSE_PREDICATE_LEN];

forward Task:Houses_LoadAll();
forward Houses_OnOwnerChanged(house);
forward Houses_OnCarChanged(house);

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
static Houses_Slot(house)
{
    if (!map_valid(s_HouseSlots) || !map_has_key(s_HouseSlots,house))
    {
        return -1;
    }

    return map_get(s_HouseSlots,house);
}

stock bool:Houses_IsValid(house)
{
    return Houses_Slot(house) != -1;
}

static bool:Houses_Fetch(house,data[e_HOUSE_DATA])
{
    new slot = Houses_Slot(house);

    if (slot == -1)
    {
        return false;
    }

    pool_get_arr(s_Houses,slot,data);
    return true;
}

static Houses_Store(house,const data[e_HOUSE_DATA])
{
    pool_set_arr(s_Houses,Houses_Slot(house),data);
}

static Houses_Insert(house,const data[e_HOUSE_DATA])
{
    if (!pool_valid(s_Houses))
    {
        s_Houses = pool_new(-1,true);
        s_HouseSlots = map_new();
    }

    map_add(s_HouseSlots,house,pool_add_arr(s_Houses,data));

    if (house >= s_HouseCount)
    {
        s_HouseCount = house + 1;
    }
}

stock Houses_GetCount()
{
    return s_HouseCount;
}

stock Houses_GetLocal(house)
{
    if (house < 0 || house == HOUSE_NO_KEY)
    {
        return DOOR_LOCAL_OUTSIDE;
    }

    return house < HOUSE_LOCAL_LIMIT ? house : PROPERTY_LOCAL_HOUSE_BASE + house;
}

stock Houses_FromLocal(local)
{
    if (local >= 0 && local < HOUSE_LOCAL_LIMIT)
    {
        return local;
    }

    if (local >= PROPERTY_LOCAL_HOUSE_BASE + HOUSE_LOCAL_LIMIT && local < PROPERTY_LOCAL_BUSINESS_BASE)
    {
        return local - PROPERTY_LOCAL_HOUSE_BASE;
    }

    return HOUSE_NO_KEY;
}

stock Houses_FindFreeSlot()
{
    new house = 0;

    while (house == HOUSE_NO_KEY || Houses_IsValid(house))
    {
        house++;
    }

    return house;
}

stock Float:Houses_GetEntranceAngle(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) ? data[E_HOUSE_ENTRANCE_ANGLE] : DOOR_NO_ANGLE;
}

stock Float:Houses_GetExitAngle(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) ? data[E_HOUSE_EXIT_ANGLE] : DOOR_NO_ANGLE;
}

stock Houses_SetPredicate(predicate,const callback[])
{
    if (predicate < 0 || predicate >= E_HOUSE_PREDICATE)
    {
        return false;
    }

    strcopy(s_HousePredicates[predicate],callback,HOUSE_PREDICATE_LEN);
    return true;
}

stock bool:Houses_CheckPredicate(predicate,playerid,bool:fallback)
{
    if (predicate < 0 || predicate >= E_HOUSE_PREDICATE || s_HousePredicates[predicate][0] == EOS)
    {
        return fallback;
    }

    return CallLocalFunction(s_HousePredicates[predicate],"d",playerid) != 0;
}

stock Houses_GetEntrance(house,&Float:x,&Float:y,&Float:z)
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        return;
    }

    x = data[E_HOUSE_ENTRANCE_X];
    y = data[E_HOUSE_ENTRANCE_Y];
    z = data[E_HOUSE_ENTRANCE_Z];
}

stock Houses_GetExit(house,&Float:x,&Float:y,&Float:z)
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        return;
    }

    x = data[E_HOUSE_EXIT_X];
    y = data[E_HOUSE_EXIT_Y];
    z = data[E_HOUSE_EXIT_Z];
}

stock bool:Houses_IsNearEntrance(playerid,house,Float:radius)
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        return false;
    }

    return Property_IsNear(playerid,radius,data[E_HOUSE_ENTRANCE_X],data[E_HOUSE_ENTRANCE_Y],data[E_HOUSE_ENTRANCE_Z]);
}

stock bool:Houses_IsNearExit(playerid,house,Float:radius)
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        return false;
    }

    return Property_IsNear(playerid,radius,data[E_HOUSE_EXIT_X],data[E_HOUSE_EXIT_Y],data[E_HOUSE_EXIT_Z]);
}

stock Houses_FindNearEntrance(playerid,Float:radius)
{
    for (new house = 0;house < s_HouseCount;house++)
    {
        if (Houses_IsNearEntrance(playerid,house,radius))
        {
            return house;
        }
    }

    return HOUSE_NO_KEY;
}

stock Houses_GetOwner(house,dest[],size = sizeof(dest))
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,data[E_HOUSE_OWNER],size);
}

stock bool:Houses_IsOwnerName(house,const name[])
{
    new data[e_HOUSE_DATA];

    if (name[0] == EOS || !Houses_Fetch(house,data))
    {
        return false;
    }

    return strcmp(name,data[E_HOUSE_OWNER],true) == 0;
}

stock Houses_GetDescription(house,dest[],size = sizeof(dest))
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,data[E_HOUSE_DESCRIPTION],size);
}

stock Houses_GetPrice(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) ? data[E_HOUSE_PRICE] : 0;
}

stock Houses_GetLevel(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) ? data[E_HOUSE_LEVEL] : 0;
}

stock Houses_GetInterior(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) ? data[E_HOUSE_INTERIOR] : 0;
}

stock Houses_GetRent(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) ? data[E_HOUSE_RENT] : 0;
}

stock Houses_GetRentable(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) ? data[E_HOUSE_RENTABLE] : 0;
}

stock Houses_GetTakings(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) ? data[E_HOUSE_TAKINGS] : 0;
}

stock Houses_GetSeenDay(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) ? data[E_HOUSE_SEEN_DAY] : 0;
}

stock bool:Houses_IsOwned(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) && data[E_HOUSE_OWNED] == 1;
}

stock bool:Houses_IsLocked(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) && data[E_HOUSE_LOCKED] == 1;
}

stock bool:Houses_IsRentable(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) && data[E_HOUSE_RENTABLE] == 1;
}

stock bool:Houses_HasHealthUpgrade(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) && data[E_HOUSE_HEALTH_UPGRADE] == 1;
}

stock bool:Houses_HasArmourUpgrade(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) && data[E_HOUSE_ARMOUR_UPGRADE] == 1;
}

stock bool:Houses_HasTv(house)
{
    new data[e_HOUSE_DATA];
    return Houses_Fetch(house,data) && data[E_HOUSE_HEALTH_X] == 1;
}

stock Houses_GetCar(house,&model,&colour1,&colour2)
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        model = HOUSE_CAR_DEFAULT_MODEL;
        colour1 = HOUSE_CAR_DEFAULT_COLOUR;
        colour2 = HOUSE_CAR_DEFAULT_COLOUR;
        return;
    }

    model = data[E_HOUSE_CAR_MODEL];
    colour1 = data[E_HOUSE_CAR_COLOUR1];
    colour2 = data[E_HOUSE_CAR_COLOUR2];
}

stock Houses_Save(house)
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        return false;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE houses SET owner = '%e', description = '%e', price = %d, health_x = %d, health_y = %d, health_z = %d, armour_x = %d, armour_y = %d, armour_z = %d, health_upgrade = %d, armour_upgrade = %d, interior = %d, locked = %d, owned = %d, rooms = %d, rent = %d, rentable = %d, takings = %d, car_model = %d, car_colour1 = %d, car_colour2 = %d, seen_day = %d, level = %d WHERE house_id = %d",data[E_HOUSE_OWNER],data[E_HOUSE_DESCRIPTION],data[E_HOUSE_PRICE],data[E_HOUSE_HEALTH_X],data[E_HOUSE_HEALTH_Y],data[E_HOUSE_HEALTH_Z],data[E_HOUSE_ARMOUR_X],data[E_HOUSE_ARMOUR_Y],data[E_HOUSE_ARMOUR_Z],data[E_HOUSE_HEALTH_UPGRADE],data[E_HOUSE_ARMOUR_UPGRADE],data[E_HOUSE_INTERIOR],data[E_HOUSE_LOCKED],data[E_HOUSE_OWNED],data[E_HOUSE_ROOMS],data[E_HOUSE_RENT],data[E_HOUSE_RENTABLE],data[E_HOUSE_TAKINGS],data[E_HOUSE_CAR_MODEL],data[E_HOUSE_CAR_COLOUR1],data[E_HOUSE_CAR_COLOUR2],data[E_HOUSE_SEEN_DAY],data[E_HOUSE_LEVEL],house));
    return true;
}

stock Houses_RefreshPickup(house)
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        return false;
    }

    if (data[E_HOUSE_PICKUP] != -1)
    {
        DestroyDynamicPickup(STREAMER_TAG_PICKUP:data[E_HOUSE_PICKUP]);
    }

    new model = data[E_HOUSE_OWNED] == 1 ? HOUSE_PICKUP_OWNED : HOUSE_PICKUP_FOR_SALE;
    data[E_HOUSE_PICKUP_MODEL] = model;
    data[E_HOUSE_PICKUP] = _:CreateDynamicPickup(model,HOUSE_PICKUP_TYPE,data[E_HOUSE_ENTRANCE_X],data[E_HOUSE_ENTRANCE_Y],data[E_HOUSE_ENTRANCE_Z],0,0);
    Houses_Store(house,data);
    return true;
}

stock Houses_SetLocked(house,bool:isLocked)
{
    new data[e_HOUSE_DATA];

    if (Houses_Fetch(house,data))
    {
        data[E_HOUSE_LOCKED] = isLocked ? 1 : 0;
        Houses_Store(house,data);
        Houses_Save(house);
    }
}

stock Houses_SetRent(house,rent)
{
    new data[e_HOUSE_DATA];

    if (Houses_Fetch(house,data))
    {
        data[E_HOUSE_RENT] = rent;
        Houses_Store(house,data);
        Houses_Save(house);
    }
}

stock Houses_SetRentable(house,value)
{
    new data[e_HOUSE_DATA];

    if (Houses_Fetch(house,data))
    {
        data[E_HOUSE_RENTABLE] = value;
        Houses_Store(house,data);
        Houses_Save(house);
    }
}

stock Houses_AddTakings(house,amount)
{
    new data[e_HOUSE_DATA];

    if (Houses_Fetch(house,data))
    {
        data[E_HOUSE_TAKINGS] += amount;
        Houses_Store(house,data);
        Houses_Save(house);
    }
}

stock Houses_SetHealthUpgrade(house,bool:isInstalled)
{
    new data[e_HOUSE_DATA];

    if (Houses_Fetch(house,data))
    {
        data[E_HOUSE_HEALTH_UPGRADE] = isInstalled ? 1 : 0;
        Houses_Store(house,data);
        Houses_Save(house);
    }
}

stock Houses_SetArmourUpgrade(house,bool:isInstalled)
{
    new data[e_HOUSE_DATA];

    if (Houses_Fetch(house,data))
    {
        data[E_HOUSE_ARMOUR_UPGRADE] = isInstalled ? 1 : 0;
        Houses_Store(house,data);
        Houses_Save(house);
    }
}

stock Houses_SetTv(house,bool:isInstalled)
{
    new data[e_HOUSE_DATA];

    if (Houses_Fetch(house,data))
    {
        data[E_HOUSE_HEALTH_X] = isInstalled ? 1 : 0;
        Houses_Store(house,data);
        Houses_Save(house);
    }
}

stock Houses_SetSeenDay(house,day)
{
    new data[e_HOUSE_DATA];

    if (Houses_Fetch(house,data))
    {
        data[E_HOUSE_SEEN_DAY] = day;
        Houses_Store(house,data);
        Houses_Save(house);
    }
}

stock Houses_SetLevel(house,level)
{
    new data[e_HOUSE_DATA];

    if (Houses_Fetch(house,data))
    {
        data[E_HOUSE_LEVEL] = level;
        Houses_Store(house,data);
        Houses_Save(house);
    }
}

stock Houses_SetPrice(house,price)
{
    new data[e_HOUSE_DATA];

    if (Houses_Fetch(house,data))
    {
        data[E_HOUSE_PRICE] = price;
        Houses_Store(house,data);
        Houses_Save(house);
    }
}

stock Houses_SetCar(house,model,colour1,colour2)
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        return;
    }

    data[E_HOUSE_CAR_MODEL] = model;
    data[E_HOUSE_CAR_COLOUR1] = colour1;
    data[E_HOUSE_CAR_COLOUR2] = colour2;
    Houses_Store(house,data);
    Houses_Save(house);
    pawn_call_public("Houses_OnCarChanged","d",house);
}

stock Houses_Claim(house,const name[])
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        return;
    }

    data[E_HOUSE_OWNED] = 1;
    strcopy(data[E_HOUSE_OWNER],name,HOUSE_NAME_LEN);
    Houses_Store(house,data);
    Houses_Save(house);
    Houses_RefreshPickup(house);
    pawn_call_public("Houses_OnOwnerChanged","d",house);
}

stock Houses_Release(house)
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        return;
    }

    data[E_HOUSE_HEALTH_UPGRADE] = 0;
    data[E_HOUSE_ARMOUR_UPGRADE] = 0;
    data[E_HOUSE_HEALTH_X] = 0;
    data[E_HOUSE_HEALTH_Y] = 0;
    data[E_HOUSE_HEALTH_Z] = 0;
    data[E_HOUSE_ARMOUR_X] = 0;
    data[E_HOUSE_ARMOUR_Y] = 0;
    data[E_HOUSE_ARMOUR_Z] = 0;
    data[E_HOUSE_LOCKED] = 1;
    data[E_HOUSE_OWNED] = 0;
    data[E_HOUSE_CAR_MODEL] = HOUSE_CAR_DEFAULT_MODEL;
    data[E_HOUSE_CAR_COLOUR1] = HOUSE_CAR_DEFAULT_COLOUR;
    data[E_HOUSE_CAR_COLOUR2] = HOUSE_CAR_DEFAULT_COLOUR;
    strcopy(data[E_HOUSE_OWNER],HOUSE_OWNER_NONE,HOUSE_NAME_LEN);
    Houses_Store(house,data);
    Houses_Save(house);
    Houses_RefreshPickup(house);
    pawn_call_public("Houses_OnOwnerChanged","d",house);
    pawn_call_public("Houses_OnCarChanged","d",house);
}

stock bool:Houses_InitRow(house,Float:entranceX,Float:entranceY,Float:entranceZ,Float:entranceAngle,Float:exitX,Float:exitY,Float:exitZ,Float:exitAngle,interior,price,level,const description[])
{
    if (house < 0 || house == HOUSE_NO_KEY || Houses_IsValid(house))
    {
        return false;
    }

    new data[e_HOUSE_DATA];
    data[E_HOUSE_ENTRANCE_X] = entranceX;
    data[E_HOUSE_ENTRANCE_Y] = entranceY;
    data[E_HOUSE_ENTRANCE_Z] = entranceZ;
    data[E_HOUSE_ENTRANCE_ANGLE] = entranceAngle;
    data[E_HOUSE_EXIT_X] = exitX;
    data[E_HOUSE_EXIT_Y] = exitY;
    data[E_HOUSE_EXIT_Z] = exitZ;
    data[E_HOUSE_EXIT_ANGLE] = exitAngle;
    strcopy(data[E_HOUSE_OWNER],HOUSE_OWNER_NONE,HOUSE_NAME_LEN);
    strcopy(data[E_HOUSE_DESCRIPTION],description,HOUSE_DESCRIPTION_LEN);
    data[E_HOUSE_PRICE] = price;
    data[E_HOUSE_INTERIOR] = interior;
    data[E_HOUSE_LOCKED] = 1;
    data[E_HOUSE_CAR_MODEL] = HOUSE_CAR_DEFAULT_MODEL;
    data[E_HOUSE_CAR_COLOUR1] = HOUSE_CAR_DEFAULT_COLOUR;
    data[E_HOUSE_CAR_COLOUR2] = HOUSE_CAR_DEFAULT_COLOUR;
    data[E_HOUSE_LEVEL] = level;
    data[E_HOUSE_PICKUP] = -1;
    Houses_Insert(house,data);
    return true;
}

stock bool:Houses_FreeRow(house)
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        return false;
    }

    if (data[E_HOUSE_PICKUP] != -1)
    {
        DestroyDynamicPickup(STREAMER_TAG_PICKUP:data[E_HOUSE_PICKUP]);
    }

    pool_remove(s_Houses,Houses_Slot(house));
    map_remove(s_HouseSlots,house);

    while (s_HouseCount > 0 && !Houses_IsValid(s_HouseCount - 1))
    {
        s_HouseCount--;
    }

    return true;
}

stock bool:Houses_SetEntrance(house,Float:x,Float:y,Float:z,Float:angle)
{
    new data[e_HOUSE_DATA];

    if (!Houses_Fetch(house,data))
    {
        return false;
    }

    data[E_HOUSE_ENTRANCE_X] = x;
    data[E_HOUSE_ENTRANCE_Y] = y;
    data[E_HOUSE_ENTRANCE_Z] = z;
    data[E_HOUSE_ENTRANCE_ANGLE] = angle;
    Houses_Store(house,data);
    return true;
}

static Houses_ReadRow(row,data[e_HOUSE_DATA])
{
    cache_get_value_name_float(row,"entrance_x",data[E_HOUSE_ENTRANCE_X]);
    cache_get_value_name_float(row,"entrance_y",data[E_HOUSE_ENTRANCE_Y]);
    cache_get_value_name_float(row,"entrance_z",data[E_HOUSE_ENTRANCE_Z]);
    cache_get_value_name_float(row,"exit_x",data[E_HOUSE_EXIT_X]);
    cache_get_value_name_float(row,"exit_y",data[E_HOUSE_EXIT_Y]);
    cache_get_value_name_float(row,"exit_z",data[E_HOUSE_EXIT_Z]);
    cache_get_value_name_int(row,"health_x",data[E_HOUSE_HEALTH_X]);
    cache_get_value_name_int(row,"health_y",data[E_HOUSE_HEALTH_Y]);
    cache_get_value_name_int(row,"health_z",data[E_HOUSE_HEALTH_Z]);
    cache_get_value_name_int(row,"armour_x",data[E_HOUSE_ARMOUR_X]);
    cache_get_value_name_int(row,"armour_y",data[E_HOUSE_ARMOUR_Y]);
    cache_get_value_name_int(row,"armour_z",data[E_HOUSE_ARMOUR_Z]);
    cache_get_value_name(row,"owner",data[E_HOUSE_OWNER],HOUSE_NAME_LEN);
    cache_get_value_name(row,"description",data[E_HOUSE_DESCRIPTION],HOUSE_DESCRIPTION_LEN);
    cache_get_value_name_int(row,"price",data[E_HOUSE_PRICE]);
    cache_get_value_name_int(row,"health_upgrade",data[E_HOUSE_HEALTH_UPGRADE]);
    cache_get_value_name_int(row,"armour_upgrade",data[E_HOUSE_ARMOUR_UPGRADE]);
    cache_get_value_name_int(row,"interior",data[E_HOUSE_INTERIOR]);
    cache_get_value_name_int(row,"locked",data[E_HOUSE_LOCKED]);
    cache_get_value_name_int(row,"owned",data[E_HOUSE_OWNED]);
    cache_get_value_name_int(row,"rooms",data[E_HOUSE_ROOMS]);
    cache_get_value_name_int(row,"rent",data[E_HOUSE_RENT]);
    cache_get_value_name_int(row,"rentable",data[E_HOUSE_RENTABLE]);
    cache_get_value_name_int(row,"takings",data[E_HOUSE_TAKINGS]);
    cache_get_value_name_int(row,"car_model",data[E_HOUSE_CAR_MODEL]);
    cache_get_value_name_int(row,"car_colour1",data[E_HOUSE_CAR_COLOUR1]);
    cache_get_value_name_int(row,"car_colour2",data[E_HOUSE_CAR_COLOUR2]);
    cache_get_value_name_int(row,"seen_day",data[E_HOUSE_SEEN_DAY]);
    cache_get_value_name_int(row,"level",data[E_HOUSE_LEVEL]);
    cache_get_value_name_float(row,"entrance_angle",data[E_HOUSE_ENTRANCE_ANGLE]);
    cache_get_value_name_float(row,"exit_angle",data[E_HOUSE_EXIT_ANGLE]);
}

#pragma warning push
#pragma warning disable 204
async Task:Houses_LoadAll()
{
    await mysql_aquery_s(g_Mysql,str_new("SELECT * FROM houses ORDER BY house_id"),false);

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("houses","the houses table could not be read");
        return async 0;
    }

    for (new row = 0, rows = cache_num_rows();row < rows;row++)
    {
        new id = -1;
        cache_get_value_name_int(row,"house_id",id);

        if (id < 0 || id == HOUSE_NO_KEY)
        {
            Log_Error("houses","house %d is not a valid house number, it was skipped",id);
            continue;
        }

        new data[e_HOUSE_DATA], bool:isKnown = Houses_Fetch(id,data);

        if (!isKnown)
        {
            data[E_HOUSE_PICKUP] = -1;
        }

        Houses_ReadRow(row,data);

        if (isKnown)
        {
            Houses_Store(id,data);
        }
        else
        {
            Houses_Insert(id,data);
        }
    }

    return async s_HouseCount;
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
public Houses_OnOwnerChanged(house)
{
    return 1;
}

public Houses_OnCarChanged(house)
{
    return 1;
}
