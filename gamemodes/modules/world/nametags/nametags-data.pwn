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
#define NAMETAGS_RANGE (10.0)

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
stock bool:Nametags_IsInRange(playerid,targetid)
{
    new Float:viewerX, Float:viewerY, Float:viewerZ, Float:targetX, Float:targetY, Float:targetZ;
    GetPlayerPos(playerid,viewerX,viewerY,viewerZ);
    GetPlayerPos(targetid,targetX,targetY,targetZ);

    new Float:deltaX = viewerX - targetX, Float:deltaY = viewerY - targetY, Float:deltaZ = viewerZ - targetZ;
    return floatsqroot(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ) < NAMETAGS_RANGE;
}

stock Nametags_Refresh(playerid)
{
    foreach (new targetid : Player)
    {
        if (targetid != playerid && !IsPlayerNPC(targetid))
        {
            ShowPlayerNameTagForPlayer(playerid,targetid,Nametags_IsInRange(playerid,targetid));
        }
    }
}
