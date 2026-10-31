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
#define DOORS_MAX (512)
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

enum E_DOOR_DATA
{
    bool:E_DOOR_USED,
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

static s_Doors[DOORS_MAX][E_DOOR_DATA];
static s_DoorCount;

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
    return doorid >= 0 && doorid < s_DoorCount && s_Doors[doorid][E_DOOR_USED];
}

stock Doors_Find(const kind[],index)
{
    for (new id = 0;id < s_DoorCount;id++)
    {
        if (s_Doors[id][E_DOOR_USED] && s_Doors[id][E_DOOR_INDEX] == index && !strcmp(s_Doors[id][E_DOOR_KIND],kind,true))
        {
            return id;
        }
    }

    return INVALID_DOOR_ID;
}

stock Doors_FindByLocal(local)
{
    if (local == DOOR_NO_LOCAL)
    {
        return INVALID_DOOR_ID;
    }

    for (new id = 0;id < s_DoorCount;id++)
    {
        if (s_Doors[id][E_DOOR_USED] && s_Doors[id][E_DOOR_LOCAL] == local)
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
    if (Util_IsValidPlayer(playerid) && Doors_IsValid(doorid) && s_Doors[doorid][E_DOOR_WORLD] != DOOR_WORLD_KEEP)
    {
        SetPlayerVirtualWorld(playerid,s_Doors[doorid][E_DOOR_WORLD]);
    }
}

stock Doors_GetEntrance(doorid,&Float:x,&Float:y,&Float:z)
{
    if (!Doors_IsValid(doorid))
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        return;
    }

    x = s_Doors[doorid][E_DOOR_ENTRANCE_X];
    y = s_Doors[doorid][E_DOOR_ENTRANCE_Y];
    z = s_Doors[doorid][E_DOOR_ENTRANCE_Z];
}

stock Doors_GetExit(doorid,&Float:x,&Float:y,&Float:z)
{
    if (!Doors_IsValid(doorid))
    {
        x = 0.0;
        y = 0.0;
        z = 0.0;
        return;
    }

    x = s_Doors[doorid][E_DOOR_EXIT_X];
    y = s_Doors[doorid][E_DOOR_EXIT_Y];
    z = s_Doors[doorid][E_DOOR_EXIT_Z];
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
    new id = Doors_Find(kind,index);

    if (id == INVALID_DOOR_ID)
    {
        for (new slot = 0;slot < s_DoorCount;slot++)
        {
            if (!s_Doors[slot][E_DOOR_USED])
            {
                id = slot;
                break;
            }
        }
    }

    if (id == INVALID_DOOR_ID)
    {
        if (s_DoorCount >= DOORS_MAX)
        {
            Log_Error("doors","no room for door %s %d: raise DOORS_MAX",kind,index);
            return INVALID_DOOR_ID;
        }

        id = s_DoorCount++;
    }

    s_Doors[id][E_DOOR_USED] = true;
    strcopy(s_Doors[id][E_DOOR_KIND],kind,DOOR_KIND_LEN);
    s_Doors[id][E_DOOR_INDEX] = index;
    s_Doors[id][E_DOOR_ENTRANCE_X] = entranceX;
    s_Doors[id][E_DOOR_ENTRANCE_Y] = entranceY;
    s_Doors[id][E_DOOR_ENTRANCE_Z] = entranceZ;
    s_Doors[id][E_DOOR_ENTRANCE_RADIUS] = entranceRadius;
    s_Doors[id][E_DOOR_EXIT_X] = exitX;
    s_Doors[id][E_DOOR_EXIT_Y] = exitY;
    s_Doors[id][E_DOOR_EXIT_Z] = exitZ;
    s_Doors[id][E_DOOR_EXIT_RADIUS] = exitRadius;
    s_Doors[id][E_DOOR_INTERIOR] = interior;
    s_Doors[id][E_DOOR_WORLD] = world;
    s_Doors[id][E_DOOR_LOCAL] = local;
    s_Doors[id][E_DOOR_FLAGS] = flags;
    strcopy(s_Doors[id][E_DOOR_CHECK],check,DOOR_CALLBACK_LEN);
    strcopy(s_Doors[id][E_DOOR_ENTER],enter,DOOR_CALLBACK_LEN);
    strcopy(s_Doors[id][E_DOOR_LEAVE],leave,DOOR_CALLBACK_LEN);
    strcopy(s_Doors[id][E_DOOR_OPEN],open,DOOR_CALLBACK_LEN);
    s_Doors[id][E_DOOR_ENTRANCE_ANGLE] = entranceAngle;
    s_Doors[id][E_DOOR_EXIT_ANGLE] = exitAngle;

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

    s_Doors[doorid][E_DOOR_USED] = false;
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
    if (!Util_IsValidPlayer(playerid))
    {
        return INVALID_DOOR_ID;
    }

    new Float:playerX, Float:playerY, Float:playerZ;
    GetPlayerPos(playerid,playerX,playerY,playerZ);

    new best = INVALID_DOOR_ID, Float:bestDistance = -1.0;

    for (new id = 0;id < s_DoorCount;id++)
    {
        if (!s_Doors[id][E_DOOR_USED])
        {
            continue;
        }

        new bool:hasInterior = !(s_Doors[id][E_DOOR_FLAGS] & DOOR_FLAG_NO_INTERIOR);
        new Float:entranceDistance = -1.0, Float:exitDistance = -1.0;

        if (searchMode != DOOR_SEARCH_EXIT)
        {
            entranceDistance = Doors_CubeDistance(playerX,playerY,playerZ,s_Doors[id][E_DOOR_ENTRANCE_RADIUS],s_Doors[id][E_DOOR_ENTRANCE_X],s_Doors[id][E_DOOR_ENTRANCE_Y],s_Doors[id][E_DOOR_ENTRANCE_Z]);
        }

        if (searchMode != DOOR_SEARCH_ENTRANCE && hasInterior)
        {
            exitDistance = Doors_CubeDistance(playerX,playerY,playerZ,s_Doors[id][E_DOOR_EXIT_RADIUS],s_Doors[id][E_DOOR_EXIT_X],s_Doors[id][E_DOOR_EXIT_Y],s_Doors[id][E_DOOR_EXIT_Z]);
        }

        if (searchMode == DOOR_SEARCH_OPEN && s_Doors[id][E_DOOR_OPEN][0] == EOS)
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

    new id = Doors_FindByLocal(Account_GetLocal(playerid));

    if (id == INVALID_DOOR_ID || (s_Doors[id][E_DOOR_FLAGS] & DOOR_FLAG_NO_INTERIOR))
    {
        return INVALID_DOOR_ID;
    }

    if (searchMode == DOOR_SEARCH_OPEN && s_Doors[id][E_DOOR_OPEN][0] == EOS)
    {
        return INVALID_DOOR_ID;
    }

    new Float:playerX, Float:playerY, Float:playerZ;
    GetPlayerPos(playerid,playerX,playerY,playerZ);

    if (Doors_CubeDistance(playerX,playerY,playerZ,s_Doors[id][E_DOOR_EXIT_RADIUS],s_Doors[id][E_DOOR_EXIT_X],s_Doors[id][E_DOOR_EXIT_Y],s_Doors[id][E_DOOR_EXIT_Z]) < 0.0)
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
    if (!Util_IsValidPlayer(playerid) || !Doors_IsValid(doorid) || (s_Doors[doorid][E_DOOR_FLAGS] & DOOR_FLAG_NO_INTERIOR))
    {
        return false;
    }

    SetPlayerInterior(playerid,s_Doors[doorid][E_DOOR_INTERIOR]);

    if (s_Doors[doorid][E_DOOR_WORLD] != DOOR_WORLD_KEEP)
    {
        SetPlayerVirtualWorld(playerid,s_Doors[doorid][E_DOOR_WORLD]);
    }

    SetPlayerPos(playerid,s_Doors[doorid][E_DOOR_EXIT_X],s_Doors[doorid][E_DOOR_EXIT_Y],s_Doors[doorid][E_DOOR_EXIT_Z]);

    if (s_Doors[doorid][E_DOOR_EXIT_ANGLE] != DOOR_NO_ANGLE)
    {
        SetPlayerFacingAngle(playerid,s_Doors[doorid][E_DOOR_EXIT_ANGLE]);
    }

    Account_SetInterior(playerid,s_Doors[doorid][E_DOOR_INTERIOR]);

    if (s_Doors[doorid][E_DOOR_LOCAL] != DOOR_NO_LOCAL)
    {
        Account_SetLocal(playerid,s_Doors[doorid][E_DOOR_LOCAL]);
    }

    return true;
}

stock bool:Doors_Enter(playerid,doorid,bool:force = false)
{
    if (!Util_IsValidPlayer(playerid) || !Doors_IsValid(doorid))
    {
        return false;
    }

    if (!force && s_Doors[doorid][E_DOOR_CHECK][0] != EOS && CallLocalFunction(s_Doors[doorid][E_DOOR_CHECK],"ddd",playerid,doorid,s_Doors[doorid][E_DOOR_INDEX]) == 0)
    {
        return false;
    }

    Doors_Place(playerid,doorid);

    if (s_Doors[doorid][E_DOOR_ENTER][0] != EOS)
    {
        CallLocalFunction(s_Doors[doorid][E_DOOR_ENTER],"ddd",playerid,doorid,s_Doors[doorid][E_DOOR_INDEX]);
    }

    return true;
}

stock bool:Doors_Leave(playerid,doorid)
{
    if (!Util_IsValidPlayer(playerid) || !Doors_IsValid(doorid))
    {
        return false;
    }

    SetPlayerInterior(playerid,0);

    if (s_Doors[doorid][E_DOOR_WORLD] != DOOR_WORLD_KEEP)
    {
        SetPlayerVirtualWorld(playerid,0);
    }

    SetPlayerPos(playerid,s_Doors[doorid][E_DOOR_ENTRANCE_X],s_Doors[doorid][E_DOOR_ENTRANCE_Y],s_Doors[doorid][E_DOOR_ENTRANCE_Z]);

    if (s_Doors[doorid][E_DOOR_ENTRANCE_ANGLE] != DOOR_NO_ANGLE)
    {
        SetPlayerFacingAngle(playerid,s_Doors[doorid][E_DOOR_ENTRANCE_ANGLE]);
    }

    Account_SetInterior(playerid,0);

    if (s_Doors[doorid][E_DOOR_LOCAL] != DOOR_NO_LOCAL)
    {
        Account_SetLocal(playerid,DOOR_LOCAL_OUTSIDE);
    }

    if (s_Doors[doorid][E_DOOR_LEAVE][0] != EOS)
    {
        CallLocalFunction(s_Doors[doorid][E_DOOR_LEAVE],"ddd",playerid,doorid,s_Doors[doorid][E_DOOR_INDEX]);
    }

    return true;
}

stock bool:Doors_Open(playerid,doorid)
{
    if (!Util_IsValidPlayer(playerid) || !Doors_IsValid(doorid) || s_Doors[doorid][E_DOOR_OPEN][0] == EOS)
    {
        return false;
    }

    CallLocalFunction(s_Doors[doorid][E_DOOR_OPEN],"ddd",playerid,doorid,s_Doors[doorid][E_DOOR_INDEX]);
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
