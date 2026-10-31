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
#define HOUSE_DOOR_SOUND (1145)

forward Houses_LoadOnBoot();
forward Houses_DoorCheck(playerid,doorid,index);
forward Houses_DoorEntered(playerid,doorid,index);
forward Houses_DoorLeft(playerid,doorid,index);
forward Houses_DoorOpened(playerid,doorid,index);

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
stock Houses_GetDoor(house)
{
    return Doors_Find(DOOR_KIND_HOUSE,house);
}

stock bool:Houses_Place(playerid,house)
{
    return Doors_Place(playerid,Houses_GetDoor(house));
}

stock bool:Houses_Enter(playerid,house,bool:force = false)
{
    return Doors_Enter(playerid,Houses_GetDoor(house),force);
}

stock Houses_ApplyCar(house)
{
    new model, colour1, colour2;
    Houses_GetCar(house,model,colour1,colour2);
    Vehicles_SetHouseCarStyle(house,model,colour1,colour2);
}

stock Houses_RegisterDoor(house)
{
    if (!Houses_IsValid(house))
    {
        return INVALID_DOOR_ID;
    }

    new Float:entranceX, Float:entranceY, Float:entranceZ, Float:exitX, Float:exitY, Float:exitZ;
    Houses_GetEntrance(house,entranceX,entranceY,entranceZ);
    Houses_GetExit(house,exitX,exitY,exitZ);
    return Doors_Register(DOOR_KIND_HOUSE,house,entranceX,entranceY,entranceZ,exitX,exitY,exitZ,Houses_GetInterior(house),Houses_GetLocal(house),3.0,3.0,DOOR_FLAG_NONE,PROPERTY_WORLD_HOUSE_BASE + house,"Houses_DoorCheck","Houses_DoorEntered","Houses_DoorLeft","Houses_DoorOpened",Houses_GetEntranceAngle(house),Houses_GetExitAngle(house));
}

stock Houses_RegisterDoors()
{
    for (new house = 0,count = Houses_GetCount();house < count;house++)
    {
        Houses_RegisterDoor(house);
    }
}

stock Houses_RefreshAllPickups()
{
    for (new house = 0,count = Houses_GetCount();house < count;house++)
    {
        Houses_RefreshPickup(house);
    }
}

static Houses_BootTask()
{
    yield 1;

    await Houses_LoadAll();
    Houses_RegisterDoors();
    Houses_RefreshAllPickups();
    Log_Info("houses","%d houses loaded",Houses_GetCount());
    Boot_LoaderDone();
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
public Houses_LoadOnBoot()
{
    Houses_BootTask();
    return 1;
}

public Houses_DoorCheck(playerid,doorid,index)
{
    if (Houses_GetKey(playerid) == index || !Houses_IsLocked(index))
    {
        return 1;
    }

    Property_GameText(playerid,"~r~Locked",5000,1);
    return 0;
}

public Houses_DoorEntered(playerid,doorid,index)
{
    Property_GameText(playerid,"~w~Welcome Home",5000,1);
    return 1;
}

public Houses_DoorLeft(playerid,doorid,index)
{
    if (Houses_HasHealthUpgrade(index))
    {
        new Float:health;
        GetPlayerHealth(playerid,health);

        if (health < 100.0)
        {
            SetPlayerHealth(playerid,100.0);
        }
    }

    return 1;
}

public Houses_DoorOpened(playerid,doorid,index)
{
    if (Houses_GetKey(playerid) != index)
    {
        Property_GameText(playerid,"~r~You Don't Have A Key",5000,6);
        return 1;
    }

    if (Houses_IsLocked(index))
    {
        Houses_SetLocked(index,false);
        Property_GameText(playerid,"~w~Door ~g~Unlocked",5000,6);
    }
    else
    {
        Houses_SetLocked(index,true);
        Property_GameText(playerid,"~w~Door ~r~Locked",5000,6);
    }

    PlayerPlaySound(playerid,HOUSE_DOOR_SOUND,0.0,0.0,0.0);
    return 1;
}

/**
 *     __                            __
 *    |  \                          |  |
 *    | $$____    ______    ______  | $$   __   _______
 *    | $$    \  /      \  /      \ | $$  /  \ /       |
 *    | $$$$$$$\|  $$$$$$\|  $$$$$$\| $$_/  $$|  $$$$$$$
 *    | $$  | $$| $$  | $$| $$  | $$| $$   $$  \$$    |
 *    | $$  | $$| $$__/ $$| $$__/ $$| $$$$$$\  _\$$$$$$|
 *    | $$  | $$ \$$    $$ \$$    $$| $$  \$$\|       $$
 *     \$$   \$$  \$$$$$$   \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
#include <pp-hooks>

hook Houses_OnCarChanged(house)
{
    Houses_ApplyCar(house);
}

