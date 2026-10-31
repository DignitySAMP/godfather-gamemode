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
#define BUSINESS_MAP_ICON (36)
#define BUSINESS_MAP_ICON_BIZ_BASE (1)
#define BUSINESS_MAP_ICON_SPECIAL_BASE (20)

static bool:s_BusinessIconsShown[MAX_PLAYERS];

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

stock Business_ShowMapIcons(playerid)
{
    if (!Util_IsValidPlayer(playerid) || s_BusinessIconsShown[playerid])
    {
        return false;
    }

    s_BusinessIconsShown[playerid] = true;

    for (new index = 0;index < BUSINESS_COUNT;index++)
    {
        new Float:x, Float:y, Float:z;
        Business_GetEntrance(index,x,y,z);
        SetPlayerMapIcon(playerid,index + BUSINESS_MAP_ICON_BIZ_BASE,x,y,z,BUSINESS_MAP_ICON,COLOR_LIGHTRED);
    }

    for (new index = 0;index < BUSINESS_SPECIAL_COUNT;index++)
    {
        new Float:x, Float:y, Float:z;
        Business_GetEntrance(BUSINESS_SPECIAL_BASE + index,x,y,z);
        SetPlayerMapIcon(playerid,index + BUSINESS_MAP_ICON_SPECIAL_BASE,x,y,z,BUSINESS_MAP_ICON,COLOR_LIGHTRED);
    }

    return true;
}

stock Business_ResetMapIcons(playerid)
{
    if (playerid >= 0 && playerid < MAX_PLAYERS)
    {
        s_BusinessIconsShown[playerid] = false;
    }
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

hook OnPlayerConnect(playerid)
{
    Business_ResetMapIcons(playerid);
}

hook OnPlayerSpawn(playerid)
{
    Business_ShowMapIcons(playerid);
}
