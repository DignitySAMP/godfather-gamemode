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
#define DOOR_KIND_FIXED "fixed"
#define DOOR_KIND_BIZ "biz"
#define DOOR_FIXED_CITY_HALL (0)
#define DOOR_FIXED_POOL_HALL (1)
#define DOOR_FIXED_DIRT_TRACK (2)
#define DOOR_FIXED_STUNT_TRACK (3)
#define DOOR_BIZ_CITY_BANK (4)

forward Doors_FixedEntered(playerid,doorid,index);

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
stock Doors_RegisterFixed()
{
    Doors_Register(DOOR_KIND_FIXED,DOOR_FIXED_CITY_HALL,-2162.2554,-2385.9541,30.6250,387.7978,173.8582,1008.3828,3,DOOR_LOCAL_CITY_HALL,3.0,3.0,DOOR_FLAG_NONE,DOOR_WORLD_KEEP,"","Doors_FixedEntered");
    Doors_Register(DOOR_KIND_FIXED,DOOR_FIXED_POOL_HALL,2695.6235,-1704.6960,11.8438,-1404.5299,-259.0602,1043.6563,7,DOOR_NO_LOCAL,3.0,6.0,DOOR_FLAG_NONE,DOOR_WORLD_KEEP,"","Doors_FixedEntered");
    Doors_Register(DOOR_KIND_FIXED,DOOR_FIXED_DIRT_TRACK,-2111.5686,-443.9720,38.7344,-1443.0554,-581.1879,1055.0472,4,DOOR_NO_LOCAL,8.0,8.0,DOOR_FLAG_NONE,DOOR_WORLD_KEEP,"","Doors_FixedEntered");
    Doors_Register(DOOR_KIND_FIXED,DOOR_FIXED_STUNT_TRACK,-2080.3079,-406.0309,38.7344,-1464.7732,1557.5533,1052.5313,14,DOOR_NO_LOCAL,8.0,8.0,DOOR_FLAG_NONE,DOOR_WORLD_KEEP,"","Doors_FixedEntered");
    Doors_Register(DOOR_KIND_BIZ,DOOR_BIZ_CITY_BANK,1462.3958,-1012.3912,26.8438,2305.6890,-16.0881,26.7496,0,DOOR_BIZ_CITY_BANK + DOOR_LOCAL_BIZ_BASE,3.0,3.0);
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
public Doors_FixedEntered(playerid,doorid,index)
{
    #pragma unused doorid

    switch (index)
    {
        case DOOR_FIXED_CITY_HALL:
        {
            Property_GameText(playerid,"~w~Welcome to the City Hall",5000,1);
        }
        case DOOR_FIXED_POOL_HALL:
        {
            Property_GameText(playerid,"~w~Welcome to the 8ball Track",5000,1);
        }
        case DOOR_FIXED_DIRT_TRACK:
        {
            Property_GameText(playerid,"~w~Welcome to the Dirt Track",5000,1);
        }
        case DOOR_FIXED_STUNT_TRACK:
        {
            Property_GameText(playerid,"~w~Welcome to the Stunting Track",5000,1);
        }
    }

    return 1;
}
