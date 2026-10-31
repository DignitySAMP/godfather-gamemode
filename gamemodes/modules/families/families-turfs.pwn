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
#define TURF_MAX (16)
#define TURF_OWNER_LEN (64)
#define TURF_COLOUR_LEN (20)
#define TURF_DEFAULT_COLOUR (0xFF000069)

enum E_TURF_DATA
{
    E_TURF_OWNER[TURF_OWNER_LEN],
    E_TURF_COLOUR[TURF_COLOUR_LEN],
    Float:E_TURF_MIN_X,
    Float:E_TURF_MIN_Y,
    Float:E_TURF_MAX_X,
    Float:E_TURF_MAX_Y,
    E_TURF_ZONE
}

static s_Turfs[TURF_MAX][E_TURF_DATA];
static s_TurfCount;

forward Task:Turfs_LoadAll();

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
static Turfs_Save(turf)
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE turfs SET owner = '%e', colour = '%e' WHERE turf_id = %d",s_Turfs[turf][E_TURF_OWNER],s_Turfs[turf][E_TURF_COLOUR],turf));
}

static Turfs_HexDigit(character)
{
    if (character >= '0' && character <= '9')
    {
        return character - '0';
    }

    if (character >= 'a' && character <= 'f')
    {
        return character - 'a' + 10;
    }

    if (character >= 'A' && character <= 'F')
    {
        return character - 'A' + 10;
    }

    return -1;
}

stock Turfs_ParseColour(const text[])
{
    new at = 0;

    while (text[at] != EOS && text[at] <= ' ')
    {
        at++;
    }

    if (text[at] == '0' && (text[at + 1] == 'x' || text[at + 1] == 'X'))
    {
        at += 2;
    }

    new value = 0, digits = 0;

    while (text[at] != EOS)
    {
        new digit = Turfs_HexDigit(text[at]);

        if (digit == -1 || digits >= 8)
        {
            return TURF_DEFAULT_COLOUR;
        }

        value = (value << 4) | digit;
        digits++;
        at++;
    }

    if (digits == 0)
    {
        return TURF_DEFAULT_COLOUR;
    }

    return value;
}

stock Turfs_GetCount()
{
    return s_TurfCount;
}

stock bool:Turfs_IsValid(turf)
{
    return turf >= 0 && turf < s_TurfCount;
}

stock bool:Turfs_SetOwner(turf,const owner[],const colour[])
{
    if (!Turfs_IsValid(turf))
    {
        return false;
    }

    strcopy(s_Turfs[turf][E_TURF_OWNER],owner,TURF_OWNER_LEN);
    strcopy(s_Turfs[turf][E_TURF_COLOUR],colour,TURF_COLOUR_LEN);
    Turfs_Save(turf);

    foreach (new playerid : Player)
    {
        if (!IsPlayerNPC(playerid) && Player_IsReady(playerid))
        {
            GangZoneShowForPlayer(playerid,s_Turfs[turf][E_TURF_ZONE],Turfs_ParseColour(s_Turfs[turf][E_TURF_COLOUR]));
        }
    }

    return true;
}

stock bool:Turfs_IsPlayerIn(playerid,turf)
{
    if (!Util_IsValidPlayer(playerid) || !Turfs_IsValid(turf))
    {
        return false;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    return x >= s_Turfs[turf][E_TURF_MIN_X] && x < s_Turfs[turf][E_TURF_MAX_X] && y >= s_Turfs[turf][E_TURF_MIN_Y] && y < s_Turfs[turf][E_TURF_MAX_Y];
}

stock Turfs_ShowFor(playerid)
{
    for (new turf = 0;turf < s_TurfCount;turf++)
    {
        GangZoneShowForPlayer(playerid,s_Turfs[turf][E_TURF_ZONE],Turfs_ParseColour(s_Turfs[turf][E_TURF_COLOUR]));
    }
}

async Task:Turfs_LoadAll()
{
    await task_ticks(1);

    for (new turf = 0;turf < s_TurfCount;turf++)
    {
        GangZoneDestroy(s_Turfs[turf][E_TURF_ZONE]);
    }

    s_TurfCount = 0;

    await mysql_aquery_s(g_Mysql,str_new("SELECT * FROM turfs ORDER BY turf_id"),false);

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("families","the turfs table could not be read");
        return async 0;
    }

    for (new row = 0,rows = cache_num_rows();row < rows;row++)
    {
        if (s_TurfCount >= TURF_MAX)
        {
            Log_Error("families","the turfs table has more rows than TURF_MAX holds");
            break;
        }

        new turf = s_TurfCount;
        cache_get_value_name(row,"owner",s_Turfs[turf][E_TURF_OWNER],TURF_OWNER_LEN);
        cache_get_value_name(row,"colour",s_Turfs[turf][E_TURF_COLOUR],TURF_COLOUR_LEN);
        cache_get_value_name_float(row,"min_x",s_Turfs[turf][E_TURF_MIN_X]);
        cache_get_value_name_float(row,"min_y",s_Turfs[turf][E_TURF_MIN_Y]);
        cache_get_value_name_float(row,"max_x",s_Turfs[turf][E_TURF_MAX_X]);
        cache_get_value_name_float(row,"max_y",s_Turfs[turf][E_TURF_MAX_Y]);
        s_Turfs[turf][E_TURF_ZONE] = GangZoneCreate(s_Turfs[turf][E_TURF_MIN_X],s_Turfs[turf][E_TURF_MIN_Y],s_Turfs[turf][E_TURF_MAX_X],s_Turfs[turf][E_TURF_MAX_Y]);
        s_TurfCount++;
    }

    return async s_TurfCount;
}
