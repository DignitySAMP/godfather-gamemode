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
#define MISC_TIME_SHIFT (-1)
#define MISC_TIME_SHOW_MS (5000)
#define MISC_TIME_JAIL_OFFSET (10)
#define MISC_TIME_PROVIDER_LEN (32)

static s_MiscJailProvider[MISC_TIME_PROVIDER_LEN];

static const s_MiscMonthNames[12][10] =
{
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
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
stock Misc_ShiftHour(hour)
{
    hour += MISC_TIME_SHIFT;

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

stock Misc_BuildTimeText(dest[],size,day,month,hour,minute,jailTime)
{
    new monthName[10], padding[2];

    if (month >= 1 && month <= 12)
    {
        strcopy(monthName,s_MiscMonthNames[month - 1],sizeof(monthName));
    }

    if (minute < 10)
    {
        padding = "0";
    }

    format(dest,size,"~y~%d %s~n~~g~|~w~%d:%s%d~g~|",day,monthName,hour,padding,minute);

    if (jailTime > 0)
    {
        format(dest,size,"%s~n~~w~Jail Time Left: %d sec",dest,jailTime - MISC_TIME_JAIL_OFFSET);
    }
}

stock bool:Misc_SetJailProvider(const callback[])
{
    strcopy(s_MiscJailProvider,callback,MISC_TIME_PROVIDER_LEN);
    return true;
}

stock Misc_GetJailTime(playerid)
{
    if (s_MiscJailProvider[0] == EOS)
    {
        return 0;
    }

    return CallLocalFunction(s_MiscJailProvider,"d",playerid);
}

stock Misc_ShowTime(playerid)
{
    new year, month, day, hour, minute, second, text[128];
    getdate(year,month,day);
    gettime(hour,minute,second);
    hour = Misc_ShiftHour(hour);
    Misc_BuildTimeText(text,sizeof(text),day,month,hour,minute,Misc_GetJailTime(playerid));
    GameTextForPlayer(playerid,text,MISC_TIME_SHOW_MS,1);
}
