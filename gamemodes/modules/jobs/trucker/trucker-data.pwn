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
#define TRUCKER_TABLE (100)
#define TRUCKER_LINE_LEN (144)
#define TRUCKER_PRODUCT_COST (50)
#define TRUCKER_BUY_MIN (1)
#define TRUCKER_BUY_MAX (500)
#define TRUCKER_STOCK_X (2787.8)
#define TRUCKER_STOCK_Y (-2436.3)
#define TRUCKER_STOCK_Z (13.7)
#define TRUCKER_STOCK_RADIUS (60.0)
#define TRUCKER_DELIVER_RADIUS (10.0)
#define TRUCKER_SOUND_PAID (1052)

static s_TruckerLoad[TRUCKER_TABLE];

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
stock Trucker_GetKey(vehicleid)
{
    if (!Util_IsValidVehicle(vehicleid) || !Vehicles_IsTruck(vehicleid))
    {
        return 0;
    }

    new key = Vehicles_GetKey(vehicleid);

    if (key < 1 || key >= TRUCKER_TABLE)
    {
        return 0;
    }

    return key;
}

stock Trucker_GetCapacity(vehicleid)
{
    switch (Trucker_GetKey(vehicleid))
    {
        case 78, 79:
        {
            return 100;
        }
        case 80, 81:
        {
            return 50;
        }
    }

    return 0;
}

stock Trucker_GetLoad(vehicleid)
{
    new key = Trucker_GetKey(vehicleid);

    if (key == 0)
    {
        return 0;
    }

    return s_TruckerLoad[key];
}

stock Trucker_SetLoad(vehicleid,load)
{
    new key = Trucker_GetKey(vehicleid);

    if (key != 0)
    {
        s_TruckerLoad[key] = load;
    }
}

stock Trucker_ShowLoad(playerid,vehicleid,bool:withPeriod)
{
    new line[TRUCKER_LINE_LEN];
    format(line,sizeof(line),withPeriod ? ("Products: %d/%d.") : ("Products: %d/%d"),Trucker_GetLoad(vehicleid),Trucker_GetCapacity(vehicleid));
    SendClientMessage(playerid,TEAM_GROVE_COLOR,line);
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

hook Vehicles_OnDriverEnter(playerid,vehicleid)
{
    if (Trucker_GetKey(vehicleid) == 0)
    {
        return;
    }

    Trucker_ShowLoad(playerid,vehicleid,false);
    SendClientMessage(playerid,COLOR_WHITE,"INFO: You can deliver Products to Businesses.");
    SendClientMessage(playerid,COLOR_WHITE,"INFO: Commands are /load /buyprods /sellprods");
}
