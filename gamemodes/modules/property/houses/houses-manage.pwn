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
#define HOUSE_DELETE_OK (0)
#define HOUSE_DELETE_MISSING (1)
#define HOUSE_DELETE_OWNED (2)
#define HOUSE_DELETE_HAS_CAR (3)

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
stock Houses_Create(Float:entranceX,Float:entranceY,Float:entranceZ,Float:entranceAngle,Float:exitX,Float:exitY,Float:exitZ,Float:exitAngle,interior,price,level,const description[])
{
    new house = Houses_FindFreeSlot();

    if (house == HOUSE_NO_KEY || !Houses_InitRow(house,entranceX,entranceY,entranceZ,entranceAngle,exitX,exitY,exitZ,exitAngle,interior,price,level,description))
    {
        return HOUSE_NO_KEY;
    }

    mysql_tquery_s(g_Mysql,str_format("INSERT INTO houses (house_id, entrance_x, entrance_y, entrance_z, exit_x, exit_y, exit_z, owner, description, price, interior, locked, owned, level, entrance_angle, exit_angle) VALUES (%d, %f, %f, %f, %f, %f, %f, '%e', '%e', %d, %d, 1, 0, %d, %f, %f) ON DUPLICATE KEY UPDATE entrance_x = VALUES(entrance_x), entrance_y = VALUES(entrance_y), entrance_z = VALUES(entrance_z), exit_x = VALUES(exit_x), exit_y = VALUES(exit_y), exit_z = VALUES(exit_z), owner = VALUES(owner), description = VALUES(description), price = VALUES(price), interior = VALUES(interior), locked = 1, owned = 0, level = VALUES(level), entrance_angle = VALUES(entrance_angle), exit_angle = VALUES(exit_angle), health_upgrade = 0, armour_upgrade = 0, takings = 0, rent = 0, rentable = 0",house,entranceX,entranceY,entranceZ,exitX,exitY,exitZ,HOUSE_OWNER_NONE,description,price,interior,level,entranceAngle,exitAngle));
    Houses_RegisterDoor(house);
    Houses_RefreshPickup(house);
    return house;
}

stock bool:Houses_Move(house,Float:x,Float:y,Float:z,Float:angle)
{
    if (!Houses_SetEntrance(house,x,y,z,angle))
    {
        return false;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE houses SET entrance_x = %f, entrance_y = %f, entrance_z = %f, entrance_angle = %f WHERE house_id = %d",x,y,z,angle,house));
    Houses_RegisterDoor(house);
    Houses_RefreshPickup(house);
    return true;
}

stock Houses_Delete(house)
{
    if (!Houses_IsValid(house))
    {
        return HOUSE_DELETE_MISSING;
    }

    if (Houses_IsOwned(house))
    {
        return HOUSE_DELETE_OWNED;
    }

    if (Vehicles_GetHouseCar(house) != 0)
    {
        return HOUSE_DELETE_HAS_CAR;
    }

    foreach (new playerid : Player)
    {
        if (Houses_GetKey(playerid) == house)
        {
            Houses_SetKey(playerid,HOUSE_NO_KEY);
        }
    }

    Doors_Remove(Houses_GetDoor(house));
    Houses_FreeRow(house);
    mysql_tquery_s(g_Mysql,str_format("DELETE FROM houses WHERE house_id = %d",house));
    mysql_tquery_s(g_Mysql,str_format("UPDATE house_keys SET house_key = %d WHERE house_key = %d",HOUSE_NO_KEY,house));
    return HOUSE_DELETE_OK;
}
