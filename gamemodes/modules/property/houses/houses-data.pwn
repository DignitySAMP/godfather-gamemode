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
#define HOUSES_MAX (160)
#define HOUSE_LOCAL_LIMIT (99)
#define HOUSE_LOCAL_HIGH_BASE (1000)
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

enum E_HOUSE_DATA
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
    Float:E_HOUSE_EXIT_ANGLE
}

enum _:E_HOUSE_PREDICATE
{
    HOUSE_PREDICATE_IS_COP = 0,
    HOUSE_PREDICATE_IS_MARRIED,
    HOUSE_PREDICATE_ON_MISSION,
    HOUSE_PREDICATE_UPGRADE_STOCK
}

static s_Houses[HOUSES_MAX][E_HOUSE_DATA];
static bool:s_HouseUsed[HOUSES_MAX];
static s_HouseCount;
static s_HousePickups[HOUSES_MAX] = {-1,...};
static s_HousePickupModels[HOUSES_MAX];
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
stock Houses_GetCount()
{
    return s_HouseCount;
}

stock Houses_GetLocal(house)
{
    if (house < 0 || house >= HOUSES_MAX)
    {
        return DOOR_LOCAL_OUTSIDE;
    }

    return house < HOUSE_LOCAL_LIMIT ? house : HOUSE_LOCAL_HIGH_BASE + house - HOUSE_LOCAL_LIMIT;
}

stock Houses_FromLocal(local)
{
    if (local >= 0 && local < HOUSE_LOCAL_LIMIT)
    {
        return local;
    }

    new house = local - HOUSE_LOCAL_HIGH_BASE + HOUSE_LOCAL_LIMIT;

    if (local >= HOUSE_LOCAL_HIGH_BASE && house < HOUSES_MAX)
    {
        return house;
    }

    return HOUSE_NO_KEY;
}

stock Houses_FindFreeSlot()
{
    for (new house = 0;house < HOUSES_MAX;house++)
    {
        if (!s_HouseUsed[house])
        {
            return house;
        }
    }

    return HOUSE_NO_KEY;
}

stock bool:Houses_IsValid(house)
{
    return house >= 0 && house < s_HouseCount && s_HouseUsed[house];
}

stock Float:Houses_GetEntranceAngle(house)
{
    return Houses_IsValid(house) ? s_Houses[house][E_HOUSE_ENTRANCE_ANGLE] : DOOR_NO_ANGLE;
}

stock Float:Houses_GetExitAngle(house)
{
    return Houses_IsValid(house) ? s_Houses[house][E_HOUSE_EXIT_ANGLE] : DOOR_NO_ANGLE;
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
    if (!Houses_IsValid(house))
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        return;
    }

    x = s_Houses[house][E_HOUSE_ENTRANCE_X];
    y = s_Houses[house][E_HOUSE_ENTRANCE_Y];
    z = s_Houses[house][E_HOUSE_ENTRANCE_Z];
}

stock Houses_GetExit(house,&Float:x,&Float:y,&Float:z)
{
    if (!Houses_IsValid(house))
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        return;
    }

    x = s_Houses[house][E_HOUSE_EXIT_X];
    y = s_Houses[house][E_HOUSE_EXIT_Y];
    z = s_Houses[house][E_HOUSE_EXIT_Z];
}

stock bool:Houses_IsNearEntrance(playerid,house,Float:radius)
{
    if (!Houses_IsValid(house))
    {
        return false;
    }

    return Property_IsNear(playerid,radius,s_Houses[house][E_HOUSE_ENTRANCE_X],s_Houses[house][E_HOUSE_ENTRANCE_Y],s_Houses[house][E_HOUSE_ENTRANCE_Z]);
}

stock bool:Houses_IsNearExit(playerid,house,Float:radius)
{
    if (!Houses_IsValid(house))
    {
        return false;
    }

    return Property_IsNear(playerid,radius,s_Houses[house][E_HOUSE_EXIT_X],s_Houses[house][E_HOUSE_EXIT_Y],s_Houses[house][E_HOUSE_EXIT_Z]);
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
    if (!Houses_IsValid(house))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_Houses[house][E_HOUSE_OWNER],size);
}

stock bool:Houses_IsOwnerName(house,const name[])
{
    if (!Houses_IsValid(house) || name[0] == EOS)
    {
        return false;
    }

    return strcmp(name,s_Houses[house][E_HOUSE_OWNER],true) == 0;
}

stock Houses_GetDescription(house,dest[],size = sizeof(dest))
{
    if (!Houses_IsValid(house))
    {
        dest[0] = EOS;
        return;
    }

    strcopy(dest,s_Houses[house][E_HOUSE_DESCRIPTION],size);
}

stock Houses_GetPrice(house)
{
    return Houses_IsValid(house) ? s_Houses[house][E_HOUSE_PRICE] : 0;
}

stock Houses_GetLevel(house)
{
    return Houses_IsValid(house) ? s_Houses[house][E_HOUSE_LEVEL] : 0;
}

stock Houses_GetInterior(house)
{
    return Houses_IsValid(house) ? s_Houses[house][E_HOUSE_INTERIOR] : 0;
}

stock Houses_GetRent(house)
{
    return Houses_IsValid(house) ? s_Houses[house][E_HOUSE_RENT] : 0;
}

stock Houses_GetRentable(house)
{
    return Houses_IsValid(house) ? s_Houses[house][E_HOUSE_RENTABLE] : 0;
}

stock Houses_GetTakings(house)
{
    return Houses_IsValid(house) ? s_Houses[house][E_HOUSE_TAKINGS] : 0;
}

stock Houses_GetSeenDay(house)
{
    return Houses_IsValid(house) ? s_Houses[house][E_HOUSE_SEEN_DAY] : 0;
}

stock bool:Houses_IsOwned(house)
{
    return Houses_IsValid(house) && s_Houses[house][E_HOUSE_OWNED] == 1;
}

stock bool:Houses_IsLocked(house)
{
    return Houses_IsValid(house) && s_Houses[house][E_HOUSE_LOCKED] == 1;
}

stock bool:Houses_IsRentable(house)
{
    return Houses_IsValid(house) && s_Houses[house][E_HOUSE_RENTABLE] == 1;
}

stock bool:Houses_HasHealthUpgrade(house)
{
    return Houses_IsValid(house) && s_Houses[house][E_HOUSE_HEALTH_UPGRADE] == 1;
}

stock bool:Houses_HasArmourUpgrade(house)
{
    return Houses_IsValid(house) && s_Houses[house][E_HOUSE_ARMOUR_UPGRADE] == 1;
}

stock bool:Houses_HasTv(house)
{
    return Houses_IsValid(house) && s_Houses[house][E_HOUSE_HEALTH_X] == 1;
}

stock Houses_GetCar(house,&model,&colour1,&colour2)
{
    if (!Houses_IsValid(house))
    {
        model = HOUSE_CAR_DEFAULT_MODEL;
        colour1 = HOUSE_CAR_DEFAULT_COLOUR;
        colour2 = HOUSE_CAR_DEFAULT_COLOUR;
        return;
    }

    model = s_Houses[house][E_HOUSE_CAR_MODEL];
    colour1 = s_Houses[house][E_HOUSE_CAR_COLOUR1];
    colour2 = s_Houses[house][E_HOUSE_CAR_COLOUR2];
}

stock Houses_Save(house)
{
    if (!Houses_IsValid(house))
    {
        return false;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE houses SET owner = '%e', description = '%e', price = %d, health_x = %d, health_y = %d, health_z = %d, armour_x = %d, armour_y = %d, armour_z = %d, health_upgrade = %d, armour_upgrade = %d, interior = %d, locked = %d, owned = %d, rooms = %d, rent = %d, rentable = %d, takings = %d, car_model = %d, car_colour1 = %d, car_colour2 = %d, seen_day = %d, level = %d WHERE house_id = %d",s_Houses[house][E_HOUSE_OWNER],s_Houses[house][E_HOUSE_DESCRIPTION],s_Houses[house][E_HOUSE_PRICE],s_Houses[house][E_HOUSE_HEALTH_X],s_Houses[house][E_HOUSE_HEALTH_Y],s_Houses[house][E_HOUSE_HEALTH_Z],s_Houses[house][E_HOUSE_ARMOUR_X],s_Houses[house][E_HOUSE_ARMOUR_Y],s_Houses[house][E_HOUSE_ARMOUR_Z],s_Houses[house][E_HOUSE_HEALTH_UPGRADE],s_Houses[house][E_HOUSE_ARMOUR_UPGRADE],s_Houses[house][E_HOUSE_INTERIOR],s_Houses[house][E_HOUSE_LOCKED],s_Houses[house][E_HOUSE_OWNED],s_Houses[house][E_HOUSE_ROOMS],s_Houses[house][E_HOUSE_RENT],s_Houses[house][E_HOUSE_RENTABLE],s_Houses[house][E_HOUSE_TAKINGS],s_Houses[house][E_HOUSE_CAR_MODEL],s_Houses[house][E_HOUSE_CAR_COLOUR1],s_Houses[house][E_HOUSE_CAR_COLOUR2],s_Houses[house][E_HOUSE_SEEN_DAY],s_Houses[house][E_HOUSE_LEVEL],house));
    return true;
}

stock Houses_RefreshPickup(house)
{
    if (!Houses_IsValid(house))
    {
        return false;
    }

    if (s_HousePickups[house] != -1)
    {
        DestroyDynamicPickup(STREAMER_TAG_PICKUP:s_HousePickups[house]);
        s_HousePickups[house] = -1;
    }

    new model = s_Houses[house][E_HOUSE_OWNED] == 1 ? HOUSE_PICKUP_OWNED : HOUSE_PICKUP_FOR_SALE;
    s_HousePickupModels[house] = model;
    s_HousePickups[house] = _:CreateDynamicPickup(model,HOUSE_PICKUP_TYPE,s_Houses[house][E_HOUSE_ENTRANCE_X],s_Houses[house][E_HOUSE_ENTRANCE_Y],s_Houses[house][E_HOUSE_ENTRANCE_Z],0,0);
    return true;
}

stock Houses_SetLocked(house,bool:isLocked)
{
    if (Houses_IsValid(house))
    {
        s_Houses[house][E_HOUSE_LOCKED] = isLocked ? 1 : 0;
        Houses_Save(house);
    }
}

stock Houses_SetRent(house,rent)
{
    if (Houses_IsValid(house))
    {
        s_Houses[house][E_HOUSE_RENT] = rent;
        Houses_Save(house);
    }
}

stock Houses_SetRentable(house,value)
{
    if (Houses_IsValid(house))
    {
        s_Houses[house][E_HOUSE_RENTABLE] = value;
        Houses_Save(house);
    }
}

stock Houses_AddTakings(house,amount)
{
    if (Houses_IsValid(house))
    {
        s_Houses[house][E_HOUSE_TAKINGS] += amount;
        Houses_Save(house);
    }
}

stock Houses_SetHealthUpgrade(house,bool:isInstalled)
{
    if (Houses_IsValid(house))
    {
        s_Houses[house][E_HOUSE_HEALTH_UPGRADE] = isInstalled ? 1 : 0;
        Houses_Save(house);
    }
}

stock Houses_SetArmourUpgrade(house,bool:isInstalled)
{
    if (Houses_IsValid(house))
    {
        s_Houses[house][E_HOUSE_ARMOUR_UPGRADE] = isInstalled ? 1 : 0;
        Houses_Save(house);
    }
}

stock Houses_SetTv(house,bool:isInstalled)
{
    if (Houses_IsValid(house))
    {
        s_Houses[house][E_HOUSE_HEALTH_X] = isInstalled ? 1 : 0;
        Houses_Save(house);
    }
}

stock Houses_SetSeenDay(house,day)
{
    if (Houses_IsValid(house))
    {
        s_Houses[house][E_HOUSE_SEEN_DAY] = day;
        Houses_Save(house);
    }
}

stock Houses_SetLevel(house,level)
{
    if (Houses_IsValid(house))
    {
        s_Houses[house][E_HOUSE_LEVEL] = level;
        Houses_Save(house);
    }
}

stock Houses_SetPrice(house,price)
{
    if (Houses_IsValid(house))
    {
        s_Houses[house][E_HOUSE_PRICE] = price;
        Houses_Save(house);
    }
}

stock Houses_SetCar(house,model,colour1,colour2)
{
    if (!Houses_IsValid(house))
    {
        return;
    }

    s_Houses[house][E_HOUSE_CAR_MODEL] = model;
    s_Houses[house][E_HOUSE_CAR_COLOUR1] = colour1;
    s_Houses[house][E_HOUSE_CAR_COLOUR2] = colour2;
    Houses_Save(house);
    pawn_call_public("Houses_OnCarChanged","d",house);
}

stock Houses_Claim(house,const name[])
{
    if (!Houses_IsValid(house))
    {
        return;
    }

    s_Houses[house][E_HOUSE_OWNED] = 1;
    strcopy(s_Houses[house][E_HOUSE_OWNER],name,HOUSE_NAME_LEN);
    Houses_Save(house);
    Houses_RefreshPickup(house);
    pawn_call_public("Houses_OnOwnerChanged","d",house);
}

stock Houses_Release(house)
{
    if (!Houses_IsValid(house))
    {
        return;
    }

    s_Houses[house][E_HOUSE_HEALTH_UPGRADE] = 0;
    s_Houses[house][E_HOUSE_ARMOUR_UPGRADE] = 0;
    s_Houses[house][E_HOUSE_HEALTH_X] = 0;
    s_Houses[house][E_HOUSE_HEALTH_Y] = 0;
    s_Houses[house][E_HOUSE_HEALTH_Z] = 0;
    s_Houses[house][E_HOUSE_ARMOUR_X] = 0;
    s_Houses[house][E_HOUSE_ARMOUR_Y] = 0;
    s_Houses[house][E_HOUSE_ARMOUR_Z] = 0;
    s_Houses[house][E_HOUSE_LOCKED] = 1;
    s_Houses[house][E_HOUSE_OWNED] = 0;
    s_Houses[house][E_HOUSE_CAR_MODEL] = HOUSE_CAR_DEFAULT_MODEL;
    s_Houses[house][E_HOUSE_CAR_COLOUR1] = HOUSE_CAR_DEFAULT_COLOUR;
    s_Houses[house][E_HOUSE_CAR_COLOUR2] = HOUSE_CAR_DEFAULT_COLOUR;
    strcopy(s_Houses[house][E_HOUSE_OWNER],HOUSE_OWNER_NONE,HOUSE_NAME_LEN);
    Houses_Save(house);
    Houses_RefreshPickup(house);
    pawn_call_public("Houses_OnOwnerChanged","d",house);
    pawn_call_public("Houses_OnCarChanged","d",house);
}

stock bool:Houses_InitRow(house,Float:entranceX,Float:entranceY,Float:entranceZ,Float:entranceAngle,Float:exitX,Float:exitY,Float:exitZ,Float:exitAngle,interior,price,level,const description[])
{
    if (house < 0 || house >= HOUSES_MAX || s_HouseUsed[house])
    {
        return false;
    }

    s_Houses[house][E_HOUSE_ENTRANCE_X] = entranceX;
    s_Houses[house][E_HOUSE_ENTRANCE_Y] = entranceY;
    s_Houses[house][E_HOUSE_ENTRANCE_Z] = entranceZ;
    s_Houses[house][E_HOUSE_ENTRANCE_ANGLE] = entranceAngle;
    s_Houses[house][E_HOUSE_EXIT_X] = exitX;
    s_Houses[house][E_HOUSE_EXIT_Y] = exitY;
    s_Houses[house][E_HOUSE_EXIT_Z] = exitZ;
    s_Houses[house][E_HOUSE_EXIT_ANGLE] = exitAngle;
    s_Houses[house][E_HOUSE_HEALTH_X] = 0;
    s_Houses[house][E_HOUSE_HEALTH_Y] = 0;
    s_Houses[house][E_HOUSE_HEALTH_Z] = 0;
    s_Houses[house][E_HOUSE_ARMOUR_X] = 0;
    s_Houses[house][E_HOUSE_ARMOUR_Y] = 0;
    s_Houses[house][E_HOUSE_ARMOUR_Z] = 0;
    strcopy(s_Houses[house][E_HOUSE_OWNER],HOUSE_OWNER_NONE,HOUSE_NAME_LEN);
    strcopy(s_Houses[house][E_HOUSE_DESCRIPTION],description,HOUSE_DESCRIPTION_LEN);
    s_Houses[house][E_HOUSE_PRICE] = price;
    s_Houses[house][E_HOUSE_HEALTH_UPGRADE] = 0;
    s_Houses[house][E_HOUSE_ARMOUR_UPGRADE] = 0;
    s_Houses[house][E_HOUSE_INTERIOR] = interior;
    s_Houses[house][E_HOUSE_LOCKED] = 1;
    s_Houses[house][E_HOUSE_OWNED] = 0;
    s_Houses[house][E_HOUSE_ROOMS] = 0;
    s_Houses[house][E_HOUSE_RENT] = 0;
    s_Houses[house][E_HOUSE_RENTABLE] = 0;
    s_Houses[house][E_HOUSE_TAKINGS] = 0;
    s_Houses[house][E_HOUSE_CAR_MODEL] = HOUSE_CAR_DEFAULT_MODEL;
    s_Houses[house][E_HOUSE_CAR_COLOUR1] = HOUSE_CAR_DEFAULT_COLOUR;
    s_Houses[house][E_HOUSE_CAR_COLOUR2] = HOUSE_CAR_DEFAULT_COLOUR;
    s_Houses[house][E_HOUSE_SEEN_DAY] = 0;
    s_Houses[house][E_HOUSE_LEVEL] = level;
    s_HouseUsed[house] = true;

    if (house >= s_HouseCount)
    {
        s_HouseCount = house + 1;
    }

    return true;
}

stock bool:Houses_FreeRow(house)
{
    if (!Houses_IsValid(house))
    {
        return false;
    }

    if (s_HousePickups[house] != -1)
    {
        DestroyDynamicPickup(STREAMER_TAG_PICKUP:s_HousePickups[house]);
        s_HousePickups[house] = -1;
    }

    s_HouseUsed[house] = false;

    while (s_HouseCount > 0 && !s_HouseUsed[s_HouseCount - 1])
    {
        s_HouseCount--;
    }

    return true;
}

stock bool:Houses_SetEntrance(house,Float:x,Float:y,Float:z,Float:angle)
{
    if (!Houses_IsValid(house))
    {
        return false;
    }

    s_Houses[house][E_HOUSE_ENTRANCE_X] = x;
    s_Houses[house][E_HOUSE_ENTRANCE_Y] = y;
    s_Houses[house][E_HOUSE_ENTRANCE_Z] = z;
    s_Houses[house][E_HOUSE_ENTRANCE_ANGLE] = angle;
    return true;
}

static Houses_ReadRow(row,id)
{
    cache_get_value_name_float(row,"entrance_x",s_Houses[id][E_HOUSE_ENTRANCE_X]);
    cache_get_value_name_float(row,"entrance_y",s_Houses[id][E_HOUSE_ENTRANCE_Y]);
    cache_get_value_name_float(row,"entrance_z",s_Houses[id][E_HOUSE_ENTRANCE_Z]);
    cache_get_value_name_float(row,"exit_x",s_Houses[id][E_HOUSE_EXIT_X]);
    cache_get_value_name_float(row,"exit_y",s_Houses[id][E_HOUSE_EXIT_Y]);
    cache_get_value_name_float(row,"exit_z",s_Houses[id][E_HOUSE_EXIT_Z]);
    cache_get_value_name_int(row,"health_x",s_Houses[id][E_HOUSE_HEALTH_X]);
    cache_get_value_name_int(row,"health_y",s_Houses[id][E_HOUSE_HEALTH_Y]);
    cache_get_value_name_int(row,"health_z",s_Houses[id][E_HOUSE_HEALTH_Z]);
    cache_get_value_name_int(row,"armour_x",s_Houses[id][E_HOUSE_ARMOUR_X]);
    cache_get_value_name_int(row,"armour_y",s_Houses[id][E_HOUSE_ARMOUR_Y]);
    cache_get_value_name_int(row,"armour_z",s_Houses[id][E_HOUSE_ARMOUR_Z]);
    cache_get_value_name(row,"owner",s_Houses[id][E_HOUSE_OWNER],HOUSE_NAME_LEN);
    cache_get_value_name(row,"description",s_Houses[id][E_HOUSE_DESCRIPTION],HOUSE_DESCRIPTION_LEN);
    cache_get_value_name_int(row,"price",s_Houses[id][E_HOUSE_PRICE]);
    cache_get_value_name_int(row,"health_upgrade",s_Houses[id][E_HOUSE_HEALTH_UPGRADE]);
    cache_get_value_name_int(row,"armour_upgrade",s_Houses[id][E_HOUSE_ARMOUR_UPGRADE]);
    cache_get_value_name_int(row,"interior",s_Houses[id][E_HOUSE_INTERIOR]);
    cache_get_value_name_int(row,"locked",s_Houses[id][E_HOUSE_LOCKED]);
    cache_get_value_name_int(row,"owned",s_Houses[id][E_HOUSE_OWNED]);
    cache_get_value_name_int(row,"rooms",s_Houses[id][E_HOUSE_ROOMS]);
    cache_get_value_name_int(row,"rent",s_Houses[id][E_HOUSE_RENT]);
    cache_get_value_name_int(row,"rentable",s_Houses[id][E_HOUSE_RENTABLE]);
    cache_get_value_name_int(row,"takings",s_Houses[id][E_HOUSE_TAKINGS]);
    cache_get_value_name_int(row,"car_model",s_Houses[id][E_HOUSE_CAR_MODEL]);
    cache_get_value_name_int(row,"car_colour1",s_Houses[id][E_HOUSE_CAR_COLOUR1]);
    cache_get_value_name_int(row,"car_colour2",s_Houses[id][E_HOUSE_CAR_COLOUR2]);
    cache_get_value_name_int(row,"seen_day",s_Houses[id][E_HOUSE_SEEN_DAY]);
    cache_get_value_name_int(row,"level",s_Houses[id][E_HOUSE_LEVEL]);
    cache_get_value_name_float(row,"entrance_angle",s_Houses[id][E_HOUSE_ENTRANCE_ANGLE]);
    cache_get_value_name_float(row,"exit_angle",s_Houses[id][E_HOUSE_EXIT_ANGLE]);
    s_HouseUsed[id] = true;
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

    s_HouseCount = 0;

    for (new row = 0, rows = cache_num_rows();row < rows;row++)
    {
        new id = -1;
        cache_get_value_name_int(row,"house_id",id);

        if (id < 0 || id >= HOUSES_MAX)
        {
            Log_Error("houses","house %d is outside the table, raise HOUSES_MAX",id);
            continue;
        }

        Houses_ReadRow(row,id);

        if (id >= s_HouseCount)
        {
            s_HouseCount = id + 1;
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
