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
#define PROPERTY_WORLD_HOUSE_BASE (100000000)
#define PROPERTY_WORLD_BUSINESS_BASE (200000000)
#define PROPERTY_WORLD_LIMIT (300000000)
#define PROPERTY_LOCAL_HOUSE_BASE (100000000)
#define PROPERTY_LOCAL_BUSINESS_BASE (200000000)
#define PROPERTY_LOCAL_SADOOR_BASE (300000000)

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
stock Property_GameText(playerid,const text[],time,style)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    GameTextForPlayer(playerid,text,time,style);
}

stock bool:Property_IsNear(playerid,Float:radius,Float:x,Float:y,Float:z)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return false;
    }

    new Float:playerX, Float:playerY, Float:playerZ;
    GetPlayerPos(playerid,playerX,playerY,playerZ);

    new Float:deltaX = playerX - x, Float:deltaY = playerY - y, Float:deltaZ = playerZ - z;

    return deltaX < radius && deltaX > -radius && deltaY < radius && deltaY > -radius && deltaZ < radius && deltaZ > -radius;
}

stock Float:Property_NormalAngle(Float:angle)
{
    while (angle < 0.0)
    {
        angle += 360.0;
    }

    while (angle >= 360.0)
    {
        angle -= 360.0;
    }

    return angle;
}

stock Property_GetPlayerName(playerid,dest[],size = sizeof(dest))
{
    if (!Util_IsValidPlayer(playerid))
    {
        dest[0] = EOS;
        return;
    }

    GetPlayerName(playerid,dest,size);
}
