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
#define CASINOS_SPOTS (5)
#define CASINOS_EXIT_X (1022.599975)
#define CASINOS_EXIT_Y (-1123.699951)
#define CASINOS_EXIT_Z (23.799999)
#define CASINOS_TEXT_MS (5000)
#define CASINOS_TEXT_STYLE (1)

static const Float:s_CasinosSpots[CASINOS_SPOTS][4] =
{
    {20.0, 2015.4500, 1017.0900, 996.8750},
    {20.0, 2233.9099, 1710.7300, 1011.2987},
    {10.0, 2265.7900, 1619.5800, 1090.4453},
    {10.0, 2265.7800, 1675.9301, 1090.4453},
    {20.0, 1133.0699, -9.5731, 1000.6797}
};

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
stock Casinos_FindSpot(playerid)
{
    for (new i = 0;i < CASINOS_SPOTS;i++)
    {
        if (Property_IsNear(playerid,s_CasinosSpots[i][0],s_CasinosSpots[i][1],s_CasinosSpots[i][2],s_CasinosSpots[i][3]))
        {
            return i;
        }
    }

    return -1;
}

stock Casinos_Check(playerid)
{
    if (Casinos_FindSpot(playerid) == -1)
    {
        return;
    }

    GameTextForPlayer(playerid,"~r~Closed",CASINOS_TEXT_MS,CASINOS_TEXT_STYLE);
    SetPlayerInterior(playerid,0);
    SetPlayerVirtualWorld(playerid,0);
    SetPlayerPos(playerid,CASINOS_EXIT_X,CASINOS_EXIT_Y,CASINOS_EXIT_Z);
}
