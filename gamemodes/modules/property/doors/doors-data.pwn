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
#define DOOR_KIND_LEN (12)
#define DOOR_CALLBACK_LEN (32)
#define INVALID_DOOR_ID (-1)
#define DOOR_NO_LOCAL (-1)
#define DOOR_LOCAL_OUTSIDE (255)
#define DOOR_LOCAL_BIZ_BASE (99)
#define DOOR_LOCAL_CITY_HALL (241)
#define DOOR_WORLD_KEEP (-1)
#define DOOR_NO_ANGLE (1000.0)

enum
{
    DOOR_FLAG_NONE = 0,
    DOOR_FLAG_NO_INTERIOR = 1
}

enum
{
    DOOR_SEARCH_ENTRANCE = 0,
    DOOR_SEARCH_EXIT,
    DOOR_SEARCH_OPEN
}

enum e_DOOR_DATA
{
    E_DOOR_KIND[DOOR_KIND_LEN],
    E_DOOR_INDEX,
    Float:E_DOOR_ENTRANCE_X,
    Float:E_DOOR_ENTRANCE_Y,
    Float:E_DOOR_ENTRANCE_Z,
    Float:E_DOOR_ENTRANCE_RADIUS,
    Float:E_DOOR_EXIT_X,
    Float:E_DOOR_EXIT_Y,
    Float:E_DOOR_EXIT_Z,
    Float:E_DOOR_EXIT_RADIUS,
    E_DOOR_INTERIOR,
    E_DOOR_WORLD,
    E_DOOR_LOCAL,
    E_DOOR_FLAGS,
    E_DOOR_CHECK[DOOR_CALLBACK_LEN],
    E_DOOR_ENTER[DOOR_CALLBACK_LEN],
    E_DOOR_LEAVE[DOOR_CALLBACK_LEN],
    E_DOOR_OPEN[DOOR_CALLBACK_LEN],
    Float:E_DOOR_ENTRANCE_ANGLE,
    Float:E_DOOR_EXIT_ANGLE
}

static Pool:s_Doors;

forward Doors_OnExitUnhandled(playerid);

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
stock bool:Doors_IsValid(doorid)
{
    return doorid >= 0 && pool_valid(s_Doors) && pool_has(s_Doors,doorid);
}

static bool:Doors_Fetch(doorid,data[e_DOOR_DATA])
{
    if (!Doors_IsValid(doorid))
    {
        return false;
    }

    pool_get_arr(s_Doors,doorid,data);
    return true;
}

stock Doors_Find(const kind[],index)
{
    if (!pool_valid(s_Doors))
    {
        return INVALID_DOOR_ID;
    }

    new data[e_DOOR_DATA];

    for_pool(it : s_Doors)
    {
        new id = iter_get_key(it);
        pool_get_arr(s_Doors,id,data);

        if (data[E_DOOR_INDEX] == index && !strcmp(data[E_DOOR_KIND],kind,true))
        {
            return id;
        }
    }

    return INVALID_DOOR_ID;
}

stock Doors_FindByLocal(local)
{
    if (local == DOOR_NO_LOCAL || !pool_valid(s_Doors))
    {
        return INVALID_DOOR_ID;
    }

    new data[e_DOOR_DATA];

    for_pool(it : s_Doors)
    {
        new id = iter_get_key(it);
        pool_get_arr(s_Doors,id,data);

        if (data[E_DOOR_LOCAL] == local)
        {
            return id;
        }
    }

    return INVALID_DOOR_ID;
}

stock bool:Doors_IsPrivateWorld(world)
{
    return world >= PROPERTY_WORLD_HOUSE_BASE && world < PROPERTY_WORLD_LIMIT;
}

stock Doors_ResetWorld(playerid)
{
    if (Util_IsValidPlayer(playerid) && Doors_IsPrivateWorld(GetPlayerVirtualWorld(playerid)))
    {
        SetPlayerVirtualWorld(playerid,0);
    }
}

stock Doors_ApplyWorld(playerid,doorid)
{
    new data[e_DOOR_DATA];

    if (Util_IsValidPlayer(playerid) && Doors_Fetch(doorid,data) && data[E_DOOR_WORLD] != DOOR_WORLD_KEEP)
    {
        SetPlayerVirtualWorld(playerid,data[E_DOOR_WORLD]);
    }
}

stock Doors_GetEntrance(doorid,&Float:x,&Float:y,&Float:z)
{
    new data[e_DOOR_DATA];

    if (!Doors_Fetch(doorid,data))
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        return;
    }

    x = data[E_DOOR_ENTRANCE_X];
    y = data[E_DOOR_ENTRANCE_Y];
    z = data[E_DOOR_ENTRANCE_Z];
}

stock Doors_GetExit(doorid,&Float:x,&Float:y,&Float:z)
{
    new data[e_DOOR_DATA];

    if (!Doors_Fetch(doorid,data))
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        return;
    }

    x = data[E_DOOR_EXIT_X];
    y = data[E_DOOR_EXIT_Y];
    z = data[E_DOOR_EXIT_Z];
}

static Doors_ValidateCallback(const kind[],index,const callback[])
{
    if (callback[0] != EOS && funcidx(callback) == -1)
    {
        Log_Error("doors","door %s %d names the callback %s, which does not exist",kind,index,callback);
    }
}

stock Doors_Register(const kind[],index,Float:entranceX,Float:entranceY,Float:entranceZ,Float:exitX,Float:exitY,Float:exitZ,interior,local,Float:entranceRadius = 3.0,Float:exitRadius = 3.0,flags = DOOR_FLAG_NONE,world = DOOR_WORLD_KEEP,const check[] = "",const enter[] = "",const leave[] = "",const open[] = "",Float:entranceAngle = DOOR_NO_ANGLE,Float:exitAngle = DOOR_NO_ANGLE)
{
    if (!pool_valid(s_Doors))
    {
        s_Doors = pool_new(-1,true);
    }

    new data[e_DOOR_DATA];
    strcopy(data[E_DOOR_KIND],kind,DOOR_KIND_LEN);
    data[E_DOOR_INDEX] = index;
    data[E_DOOR_ENTRANCE_X] = entranceX;
    data[E_DOOR_ENTRANCE_Y] = entranceY;
    data[E_DOOR_ENTRANCE_Z] = entranceZ;
    data[E_DOOR_ENTRANCE_RADIUS] = entranceRadius;
    data[E_DOOR_EXIT_X] = exitX;
    data[E_DOOR_EXIT_Y] = exitY;
    data[E_DOOR_EXIT_Z] = exitZ;
    data[E_DOOR_EXIT_RADIUS] = exitRadius;
    data[E_DOOR_INTERIOR] = interior;
    data[E_DOOR_WORLD] = world;
    data[E_DOOR_LOCAL] = local;
    data[E_DOOR_FLAGS] = flags;
    strcopy(data[E_DOOR_CHECK],check,DOOR_CALLBACK_LEN);
    strcopy(data[E_DOOR_ENTER],enter,DOOR_CALLBACK_LEN);
    strcopy(data[E_DOOR_LEAVE],leave,DOOR_CALLBACK_LEN);
    strcopy(data[E_DOOR_OPEN],open,DOOR_CALLBACK_LEN);
    data[E_DOOR_ENTRANCE_ANGLE] = entranceAngle;
    data[E_DOOR_EXIT_ANGLE] = exitAngle;

    new id = Doors_Find(kind,index);

    if (id == INVALID_DOOR_ID)
    {
        id = pool_add_arr(s_Doors,data);
    }
    else
    {
        pool_set_arr(s_Doors,id,data);
    }

    Doors_ValidateCallback(kind,index,check);
    Doors_ValidateCallback(kind,index,enter);
    Doors_ValidateCallback(kind,index,leave);
    Doors_ValidateCallback(kind,index,open);
    return id;
}

stock bool:Doors_Remove(doorid)
{
    if (!Doors_IsValid(doorid))
    {
        return false;
    }

    pool_remove(s_Doors,doorid);
    return true;
}

static Float:Doors_CubeDistance(Float:playerX,Float:playerY,Float:playerZ,Float:radius,Float:x,Float:y,Float:z)
{
    new Float:deltaX = playerX - x, Float:deltaY = playerY - y, Float:deltaZ = playerZ - z;

    if (deltaX < radius && deltaX > -radius && deltaY < radius && deltaY > -radius && deltaZ < radius && deltaZ > -radius)
    {
        return deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ;
    }

    return -1.0;
}

stock Doors_FindNearest(playerid,searchMode)
{
    if (!Util_IsValidPlayer(playerid) || !pool_valid(s_Doors))
    {
        return INVALID_DOOR_ID;
    }

    new Float:playerX, Float:playerY, Float:playerZ;
    GetPlayerPos(playerid,playerX,playerY,playerZ);

    new best = INVALID_DOOR_ID, Float:bestDistance = -1.0, data[e_DOOR_DATA];

    for_pool(it : s_Doors)
    {
        new id = iter_get_key(it);
        pool_get_arr(s_Doors,id,data);

        new bool:hasInterior = !(data[E_DOOR_FLAGS] & DOOR_FLAG_NO_INTERIOR);
        new Float:entranceDistance = -1.0, Float:exitDistance = -1.0;

        if (searchMode != DOOR_SEARCH_EXIT)
        {
            entranceDistance = Doors_CubeDistance(playerX,playerY,playerZ,data[E_DOOR_ENTRANCE_RADIUS],data[E_DOOR_ENTRANCE_X],data[E_DOOR_ENTRANCE_Y],data[E_DOOR_ENTRANCE_Z]);
        }

        if (searchMode != DOOR_SEARCH_ENTRANCE && hasInterior)
        {
            exitDistance = Doors_CubeDistance(playerX,playerY,playerZ,data[E_DOOR_EXIT_RADIUS],data[E_DOOR_EXIT_X],data[E_DOOR_EXIT_Y],data[E_DOOR_EXIT_Z]);
        }

        if (searchMode == DOOR_SEARCH_OPEN && data[E_DOOR_OPEN][0] == EOS)
        {
            continue;
        }

        new Float:distance = entranceDistance;

        if (distance < 0.0 || (exitDistance >= 0.0 && exitDistance < distance))
        {
            distance = exitDistance;
        }

        if (distance < 0.0)
        {
            continue;
        }

        if (best == INVALID_DOOR_ID || distance < bestDistance)
        {
            best = id;
            bestDistance = distance;
        }
    }

    return best;
}

static Doors_FindOwn(playerid,searchMode)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return INVALID_DOOR_ID;
    }

    new id = Doors_FindByLocal(Account_GetLocal(playerid)), data[e_DOOR_DATA];

    if (!Doors_Fetch(id,data) || (data[E_DOOR_FLAGS] & DOOR_FLAG_NO_INTERIOR))
    {
        return INVALID_DOOR_ID;
    }

    if (searchMode == DOOR_SEARCH_OPEN && data[E_DOOR_OPEN][0] == EOS)
    {
        return INVALID_DOOR_ID;
    }

    new Float:playerX, Float:playerY, Float:playerZ;
    GetPlayerPos(playerid,playerX,playerY,playerZ);

    if (Doors_CubeDistance(playerX,playerY,playerZ,data[E_DOOR_EXIT_RADIUS],data[E_DOOR_EXIT_X],data[E_DOOR_EXIT_Y],data[E_DOOR_EXIT_Z]) < 0.0)
    {
        return INVALID_DOOR_ID;
    }

    return id;
}

stock Doors_FindEntrance(playerid)
{
    return Doors_FindNearest(playerid,DOOR_SEARCH_ENTRANCE);
}

stock Doors_FindExit(playerid)
{
    new own = Doors_FindOwn(playerid,DOOR_SEARCH_EXIT);
    return own != INVALID_DOOR_ID ? own : Doors_FindNearest(playerid,DOOR_SEARCH_EXIT);
}

stock Doors_FindOpenable(playerid)
{
    new own = Doors_FindOwn(playerid,DOOR_SEARCH_OPEN);
    return own != INVALID_DOOR_ID ? own : Doors_FindNearest(playerid,DOOR_SEARCH_OPEN);
}

stock bool:Doors_Place(playerid,doorid)
{
    new data[e_DOOR_DATA];

    if (!Util_IsValidPlayer(playerid) || !Doors_Fetch(doorid,data) || (data[E_DOOR_FLAGS] & DOOR_FLAG_NO_INTERIOR))
    {
        return false;
    }

    SetPlayerInterior(playerid,data[E_DOOR_INTERIOR]);

    if (data[E_DOOR_WORLD] != DOOR_WORLD_KEEP)
    {
        SetPlayerVirtualWorld(playerid,data[E_DOOR_WORLD]);
    }

    SetPlayerPos(playerid,data[E_DOOR_EXIT_X],data[E_DOOR_EXIT_Y],data[E_DOOR_EXIT_Z]);

    if (data[E_DOOR_EXIT_ANGLE] != DOOR_NO_ANGLE)
    {
        SetPlayerFacingAngle(playerid,data[E_DOOR_EXIT_ANGLE]);
    }

    Account_SetInterior(playerid,data[E_DOOR_INTERIOR]);

    if (data[E_DOOR_LOCAL] != DOOR_NO_LOCAL)
    {
        Account_SetLocal(playerid,data[E_DOOR_LOCAL]);
    }

    return true;
}

stock bool:Doors_Enter(playerid,doorid,bool:force = false)
{
    new data[e_DOOR_DATA];

    if (!Util_IsValidPlayer(playerid) || !Doors_Fetch(doorid,data))
    {
        return false;
    }

    if (!force && data[E_DOOR_CHECK][0] != EOS && CallLocalFunction(data[E_DOOR_CHECK],"ddd",playerid,doorid,data[E_DOOR_INDEX]) == 0)
    {
        return false;
    }

    Doors_Place(playerid,doorid);

    if (data[E_DOOR_ENTER][0] != EOS)
    {
        CallLocalFunction(data[E_DOOR_ENTER],"ddd",playerid,doorid,data[E_DOOR_INDEX]);
    }

    return true;
}

stock bool:Doors_Leave(playerid,doorid)
{
    new data[e_DOOR_DATA];

    if (!Util_IsValidPlayer(playerid) || !Doors_Fetch(doorid,data))
    {
        return false;
    }

    SetPlayerInterior(playerid,0);

    if (data[E_DOOR_WORLD] != DOOR_WORLD_KEEP)
    {
        SetPlayerVirtualWorld(playerid,0);
    }

    SetPlayerPos(playerid,data[E_DOOR_ENTRANCE_X],data[E_DOOR_ENTRANCE_Y],data[E_DOOR_ENTRANCE_Z]);

    if (data[E_DOOR_ENTRANCE_ANGLE] != DOOR_NO_ANGLE)
    {
        SetPlayerFacingAngle(playerid,data[E_DOOR_ENTRANCE_ANGLE]);
    }

    Account_SetInterior(playerid,0);

    if (data[E_DOOR_LOCAL] != DOOR_NO_LOCAL)
    {
        Account_SetLocal(playerid,DOOR_LOCAL_OUTSIDE);
    }

    if (data[E_DOOR_LEAVE][0] != EOS)
    {
        CallLocalFunction(data[E_DOOR_LEAVE],"ddd",playerid,doorid,data[E_DOOR_INDEX]);
    }

    return true;
}

stock bool:Doors_Open(playerid,doorid)
{
    new data[e_DOOR_DATA];

    if (!Util_IsValidPlayer(playerid) || !Doors_Fetch(doorid,data) || data[E_DOOR_OPEN][0] == EOS)
    {
        return false;
    }

    CallLocalFunction(data[E_DOOR_OPEN],"ddd",playerid,doorid,data[E_DOOR_INDEX]);
    return true;
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
public Doors_OnExitUnhandled(playerid)
{
    return 1;
}
