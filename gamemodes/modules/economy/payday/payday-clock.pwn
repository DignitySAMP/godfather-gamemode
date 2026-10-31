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
#define PAYDAY_CLOCK_MS (60000)
#define PAYDAY_TIME_SHIFT (-1)
#define PAYDAY_FIXED_WORLD_TIME (15)

static s_PaydayClockHour;
static bool:s_PaydayRealtime = true;

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
stock Payday_FixHour(hour)
{
    hour += PAYDAY_TIME_SHIFT;

    if (hour < 0)
    {
        hour += 24;
    }
    else if (hour > 23)
    {
        hour -= 24;
    }

    return hour;
}

stock Payday_GetServerHour()
{
    new hour, minute, second;
    gettime(hour,minute,second);
    return Payday_FixHour(hour);
}

stock Payday_InitClock()
{
    s_PaydayClockHour = Payday_GetServerHour();
    SetWorldTime(s_PaydayRealtime ? s_PaydayClockHour : PAYDAY_FIXED_WORLD_TIME);
}

stock bool:Payday_SyncClock(hour)
{
    if (hour <= s_PaydayClockHour && !(hour == 0 && s_PaydayClockHour == 23))
    {
        return false;
    }

    new line[64];
    format(line,sizeof(line),"SERVER: The time is now %d:00 hours",hour);
    SendClientMessageToAll(COLOR_WHITE,line);
    s_PaydayClockHour = hour;
    Payday_Run();

    if (s_PaydayRealtime)
    {
        SetWorldTime(hour);
    }

    return true;
}

stock Payday_UpdateScores()
{
    foreach (new playerid : Player)
    {
        if (!IsPlayerNPC(playerid))
        {
            SetPlayerScore(playerid,Account_GetLevel(playerid));
        }
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
Timer_Declare(Payday_ClockTimer)
{
    Payday_SyncClock(Payday_GetServerHour());
    Payday_UpdateScores();
    return true;
}
