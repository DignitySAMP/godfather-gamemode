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
#define DEATH_SAFE_SECONDS (60)
#define DEATH_SLICE (100)
#define DEATH_SLICE_BROKE_BONUS (500)
#define DEATH_SUE_COST (2000)
#define DEATH_SUE_HOSPITAL (100)
#define DEATH_SOUND_KILL (1083)
#define DEATH_SOUND_SUE (1084)
#define DEATH_MINIGUN (38)
#define DEATH_TEAM_MAFIA_MIN (5)
#define DEATH_LINE_LEN (160)

static s_DeathSafeTime[MAX_PLAYERS];

forward Death_OnPaintballKill(playerid,killerid);
forward Death_OnKilled(playerid,killerid,reason);
forward Death_IsSafe(playerid);

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
stock Death_GetSafeTime(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_DeathSafeTime[playerid];
}

stock Death_SetSafeTime(playerid,seconds)
{
    if (Util_IsValidPlayer(playerid))
    {
        s_DeathSafeTime[playerid] = seconds;
    }
}

stock Death_Reset(playerid)
{
    s_DeathSafeTime[playerid] = DEATH_SAFE_SECONDS;
}

stock Death_Tick(playerid)
{
    if (s_DeathSafeTime[playerid] > 0)
    {
        s_DeathSafeTime[playerid]--;
    }
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
public Death_OnPaintballKill(playerid,killerid)
{
    return 1;
}

public Death_OnKilled(playerid,killerid,reason)
{
    return 1;
}

public Death_IsSafe(playerid)
{
    return Death_GetSafeTime(playerid) > 0 ? 1 : 0;
}
