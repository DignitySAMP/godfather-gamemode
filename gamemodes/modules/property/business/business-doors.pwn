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
#define BUSINESS_DOOR_SOUND (1145)
#define BUSINESS_RADIUS (3.0)

forward Business_DoorCheck(playerid,doorid,index);
forward Business_DoorEntered(playerid,doorid,index);
forward Business_DoorOpened(playerid,doorid,index);
forward Business_SpecialCheck(playerid,doorid,index);
forward Business_SpecialEntered(playerid,doorid,index);
forward Business_SpecialOpened(playerid,doorid,index);
forward Business_TypedCheck(playerid,doorid,index);
forward Business_TypedEntered(playerid,doorid,index);
forward Business_TypedOpened(playerid,doorid,index);
forward Business_OnSpecialEntered(playerid,sbiz);

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
stock Business_GetDoor(key)
{
    if (Business_IsSpecial(key))
    {
        return Doors_Find(DOOR_KIND_SBIZ,key - BUSINESS_SPECIAL_BASE);
    }

    if (Business_IsTyped(key))
    {
        return Doors_Find(DOOR_KIND_TBIZ,key - BUSINESS_TYPED_BASE);
    }

    return Doors_Find(DOOR_KIND_BIZ,key);
}

stock Business_RegisterTypedDoor(key)
{
    if (!Business_IsTyped(key) || !Business_IsValid(key))
    {
        return INVALID_DOOR_ID;
    }

    new Float:entranceX, Float:entranceY, Float:entranceZ, Float:exitX, Float:exitY, Float:exitZ;
    Business_GetEntrance(key,entranceX,entranceY,entranceZ);
    Business_GetExit(key,exitX,exitY,exitZ);
    return Doors_Register(DOOR_KIND_TBIZ,key - BUSINESS_TYPED_BASE,entranceX,entranceY,entranceZ,exitX,exitY,exitZ,Business_GetInterior(key),key,BUSINESS_RADIUS,BUSINESS_RADIUS,DOOR_FLAG_NONE,PROPERTY_WORLD_BUSINESS_BASE + key,"Business_TypedCheck","Business_TypedEntered","","Business_TypedOpened",Business_GetEntranceAngle(key),Business_GetExitAngle(key));
}

stock Business_RegisterDoors()
{
    for (new index = 0;index < BUSINESS_COUNT;index++)
    {
        if (!Business_IsValid(index))
        {
            continue;
        }

        new Float:entranceX, Float:entranceY, Float:entranceZ, Float:exitX, Float:exitY, Float:exitZ;
        Business_GetEntrance(index,entranceX,entranceY,entranceZ);
        Business_GetExit(index,exitX,exitY,exitZ);
        Doors_Register(DOOR_KIND_BIZ,index,entranceX,entranceY,entranceZ,exitX,exitY,exitZ,Business_GetInterior(index),index + DOOR_LOCAL_BIZ_BASE,BUSINESS_RADIUS,BUSINESS_RADIUS,DOOR_FLAG_NONE,PROPERTY_WORLD_BUSINESS_BASE + index,"Business_DoorCheck","Business_DoorEntered","","Business_DoorOpened");
    }

    for (new row = BUSINESS_FIXED_ROWS;row < BUSINESS_ROWS;row++)
    {
        Business_RegisterTypedDoor(Business_GetKeyOfRow(row));
    }

    for (new index = 0;index < BUSINESS_SPECIAL_COUNT;index++)
    {
        new key = BUSINESS_SPECIAL_BASE + index;

        if (!Business_IsValid(key))
        {
            continue;
        }

        new Float:entranceX, Float:entranceY, Float:entranceZ;
        Business_GetEntrance(key,entranceX,entranceY,entranceZ);
        Doors_Register(DOOR_KIND_SBIZ,index,entranceX,entranceY,entranceZ,entranceX,entranceY,entranceZ,0,DOOR_NO_LOCAL,BUSINESS_RADIUS,BUSINESS_RADIUS,DOOR_FLAG_NO_INTERIOR,DOOR_WORLD_KEEP,"Business_SpecialCheck","Business_SpecialEntered","","Business_SpecialOpened");
    }
}

static Business_TakeEntrance(playerid,key)
{
    new cost = Business_GetEntranceCost(key), line[96];
    Account_SetCash(playerid,Account_GetCash(playerid) - cost);
    format(line,sizeof(line),"~r~-$%d~n~~w~type /exit~n~to get out",cost);
    Business_Earn(key,cost);
    Business_UseProduct(key);
    Property_GameText(playerid,line,5000,3);
}

static Business_LogEntry(playerid,const kind[],key,index)
{
    new name[BUSINESS_NAME_LEN], line[96];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"%s payed $%d to enter %s %d",name,Business_GetEntranceCost(key),kind,index);
    Economy_PayLog(line,true);
}

static Business_ToggleLock(playerid,key,const openText[],const closedText[])
{
    if (Business_IsLocked(key))
    {
        Business_SetLocked(key,false);
        Property_GameText(playerid,openText,5000,6);
    }
    else
    {
        Business_SetLocked(key,true);
        Property_GameText(playerid,closedText,5000,6);
    }

    PlayerPlaySound(playerid,BUSINESS_DOOR_SOUND,0.0,0.0,0.0);
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
static Business_CheckEntry(playerid,index)
{
    new isOwner = Business_GetKey(playerid) == index;

    if (!isOwner && Account_GetCash(playerid) < Business_GetEntranceCost(index))
    {
        Property_GameText(playerid,"~r~You don't have the cash",5000,1);
        return 0;
    }

    if (isOwner)
    {
        return 1;
    }

    if (Business_IsLocked(index))
    {
        Property_GameText(playerid,"~r~Closed",5000,1);
        return 0;
    }

    if (Business_GetProducts(index) == 0)
    {
        Property_GameText(playerid,"~r~Out Of Stock",5000,1);
        return 0;
    }

    Business_TakeEntrance(playerid,index);
    return 1;
}

public Business_DoorCheck(playerid,doorid,index)
{
    if (index == BIZ_ARMOURY && !Factions_IsCop(playerid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Cops only !");
        return 0;
    }

    return Business_CheckEntry(playerid,index);
}

public Business_TypedCheck(playerid,doorid,index)
{
    new key = BUSINESS_TYPED_BASE + index;

    if (Business_IsOwned(key))
    {
        return Business_CheckEntry(playerid,key);
    }

    if (Business_IsLocked(key))
    {
        Property_GameText(playerid,"~r~Closed",5000,1);
        return 0;
    }

    return 1;
}

public Business_TypedEntered(playerid,doorid,index)
{
    new key = BUSINESS_TYPED_BASE + index;

    if (Business_IsOwned(key))
    {
        Business_LogEntry(playerid,"tbiz",key,index);
    }

    return 1;
}

public Business_TypedOpened(playerid,doorid,index)
{
    new key = BUSINESS_TYPED_BASE + index;

    if (Business_GetKey(playerid) != key)
    {
        Property_GameText(playerid,"~r~You Don't Have A Key",5000,6);
        return 1;
    }

    Business_ToggleLock(playerid,key,"~w~Business ~g~Open","~w~Business ~r~Closed");
    return 1;
}

public Business_DoorEntered(playerid,doorid,index)
{
    Business_LogEntry(playerid,"biz",index,index);
    return 1;
}

public Business_DoorOpened(playerid,doorid,index)
{
    if (Business_GetKey(playerid) != index)
    {
        Property_GameText(playerid,"~r~You Don't Have A Key",5000,6);
        return 1;
    }

    Business_ToggleLock(playerid,index,"~w~Business ~g~Open","~w~Business ~r~Closed");
    return 1;
}

public Business_SpecialCheck(playerid,doorid,index)
{
    new key = BUSINESS_SPECIAL_BASE + index;

    if (Business_GetKey(playerid) == key)
    {
        return 0;
    }

    if (Account_GetCash(playerid) < Business_GetEntranceCost(key))
    {
        Property_GameText(playerid,"~r~You don't have the cash",5000,1);
        return 0;
    }

    if (Business_IsLocked(key))
    {
        Property_GameText(playerid,"~r~Closed",5000,1);
        return 0;
    }

    if (Business_GetProducts(key) == 0)
    {
        Property_GameText(playerid,"~r~Out Of Stock",5000,1);
        return 0;
    }

    if (index != SBIZ_PAINTBALL && index != SBIZ_KARTING)
    {
        return 0;
    }

    new cost = Business_GetEntranceCost(key);
    Account_SetCash(playerid,Account_GetCash(playerid) - cost);
    Business_UseProduct(key);
    Business_Earn(key,cost);
    return 1;
}

public Business_SpecialEntered(playerid,doorid,index)
{
    if (index == SBIZ_KARTING)
    {
        SendClientMessage(playerid,TEAM_GROVE_COLOR,"You can now participate in a Karting Race, grab a Kart.");
    }

    Business_LogEntry(playerid,"sbiz",BUSINESS_SPECIAL_BASE + index,index);
    pawn_call_public("Business_OnSpecialEntered","dd",playerid,index);
    return 1;
}

public Business_SpecialOpened(playerid,doorid,index)
{
    if (Business_GetKey(playerid) != BUSINESS_SPECIAL_BASE + index)
    {
        Property_GameText(playerid,"~r~You Don't Have A Key",5000,6);
        return 1;
    }

    Business_ToggleLock(playerid,BUSINESS_SPECIAL_BASE + index,"~w~Business ~g~Open","~w~Business ~r~Closed");
    return 1;
}

public Business_OnSpecialEntered(playerid,sbiz)
{
    return 1;
}
