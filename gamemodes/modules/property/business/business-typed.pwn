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
#define BUSINESS_DELETE_OK (0)
#define BUSINESS_DELETE_MISSING (1)
#define BUSINESS_DELETE_OWNED (2)
#define BUSINESS_DELETE_FIXED (3)
#define BUSINESS_MESSAGE_PREFIX "~w~"

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
stock Business_GetTypedAt(playerid,type)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return BUSINESS_NO_KEY;
    }

    new key = Business_FromTypedLocal(Account_GetLocal(playerid));

    if (Business_IsTyped(key) && Business_IsValid(key) && Business_GetType(key) == type)
    {
        return key;
    }

    return BUSINESS_NO_KEY;
}

stock Business_CreateTyped(type,const title[],Float:entranceX,Float:entranceY,Float:entranceZ,Float:entranceAngle,Float:exitX,Float:exitY,Float:exitZ,Float:exitAngle,interior,price,level)
{
    new key = Business_FindFreeTypedKey(), message[BUSINESS_MESSAGE_LEN], typeName[BUSINESS_TYPE_NAME_LEN];

    format(message,sizeof(message),"%s%s",BUSINESS_MESSAGE_PREFIX,title);
    Business_GetTypeName(type,typeName);

    if (key == BUSINESS_NO_KEY || !Business_InitTypedRow(key,type,message,entranceX,entranceY,entranceZ,entranceAngle,exitX,exitY,exitZ,exitAngle,interior,price,level))
    {
        return BUSINESS_NO_KEY;
    }

    mysql_tquery_s(g_Mysql,str_format("INSERT INTO businesses (business_id, owned, owner, message, extortion, entrance_x, entrance_y, entrance_z, exit_x, exit_y, exit_z, level_needed, buy_price, entrance_cost, till, locked, interior, products, max_products, price_prod, biz_type, entrance_angle, exit_angle) VALUES (%d, 0, '%e', '%e', '%e', %f, %f, %f, %f, %f, %f, %d, %d, 0, 0, 0, %d, %d, %d, %d, '%e', %f, %f) ON DUPLICATE KEY UPDATE owned = 0, owner = VALUES(owner), message = VALUES(message), extortion = VALUES(extortion), entrance_x = VALUES(entrance_x), entrance_y = VALUES(entrance_y), entrance_z = VALUES(entrance_z), exit_x = VALUES(exit_x), exit_y = VALUES(exit_y), exit_z = VALUES(exit_z), level_needed = VALUES(level_needed), buy_price = VALUES(buy_price), entrance_cost = 0, till = 0, locked = 0, interior = VALUES(interior), products = VALUES(products), max_products = VALUES(max_products), price_prod = VALUES(price_prod), biz_type = VALUES(biz_type), entrance_angle = VALUES(entrance_angle), exit_angle = VALUES(exit_angle)",key,BUSINESS_OWNER_NONE,message,BUSINESS_EXTORTION_NONE,entranceX,entranceY,entranceZ,exitX,exitY,exitZ,level,price,interior,BUSINESS_TYPED_PRODUCTS,BUSINESS_TYPED_MAX_PRODUCTS,BUSINESS_TYPED_PRICE_PROD,typeName,entranceAngle,exitAngle));
    Business_RegisterTypedDoor(key);
    Business_RefreshPickup(key);
    return key;
}

stock bool:Business_Move(key,Float:x,Float:y,Float:z,Float:angle)
{
    if (Business_IsSpecial(key) || !Business_SetEntrance(key,x,y,z,angle))
    {
        return false;
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE businesses SET entrance_x = %f, entrance_y = %f, entrance_z = %f, entrance_angle = %f WHERE business_id = %d",x,y,z,angle,key));

    if (Business_IsTyped(key))
    {
        Business_RegisterTypedDoor(key);
    }
    else
    {
        Business_RegisterDoors();
    }

    Business_RefreshPickup(key);
    return true;
}

stock Business_DeleteTyped(key)
{
    if (!Business_IsValid(key))
    {
        return BUSINESS_DELETE_MISSING;
    }

    if (!Business_IsTyped(key))
    {
        return BUSINESS_DELETE_FIXED;
    }

    if (Business_IsOwned(key))
    {
        return BUSINESS_DELETE_OWNED;
    }

    foreach (new playerid : Player)
    {
        if (Business_GetKey(playerid) == key)
        {
            Business_SetKey(playerid,BUSINESS_NO_KEY);
        }
    }

    Doors_Remove(Business_GetDoor(key));
    Business_FreeTypedRow(key);
    mysql_tquery_s(g_Mysql,str_format("DELETE FROM businesses WHERE business_id = %d",key));
    mysql_tquery_s(g_Mysql,str_format("UPDATE business_keys SET business_key = %d WHERE business_key = %d",BUSINESS_NO_KEY,key));
    return BUSINESS_DELETE_OK;
}
