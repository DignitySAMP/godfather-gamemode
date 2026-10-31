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
#define SADOORS_MAX (256)
#define SADOORS_NAME_LEN (12)
#define SADOORS_TITLE_LEN (32)
#define SADOORS_TYPE_LEN (12)
#define SADOORS_KIND_LEN (8)
#define SADOORS_ANY_PRICE (-1)
#define INVALID_SADOOR (-1)
#define DOOR_KIND_SA "sa"
#define SADOORS_LOCAL_BASE (3000)

enum
{
    SADOOR_KIND_NONE = 0,
    SADOOR_KIND_HOUSE,
    SADOOR_KIND_BIZ,
    SADOOR_KIND_DOOR
}

enum E_SADOOR_DATA
{
    E_SADOOR_NAME[SADOORS_NAME_LEN],
    E_SADOOR_KIND,
    E_SADOOR_TYPE[SADOORS_TYPE_LEN],
    E_SADOOR_INTERIOR,
    Float:E_SADOOR_OUT_X,
    Float:E_SADOOR_OUT_Y,
    Float:E_SADOOR_OUT_Z,
    Float:E_SADOOR_OUT_ROT,
    Float:E_SADOOR_IN_X,
    Float:E_SADOOR_IN_Y,
    Float:E_SADOOR_IN_Z,
    Float:E_SADOOR_IN_ROT,
    E_SADOOR_TITLE[SADOORS_TITLE_LEN],
    E_SADOOR_PRICE,
    E_SADOOR_LEVEL
}

static s_SaDoors[SADOORS_MAX][E_SADOOR_DATA];
static s_SaDoorCount;

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
static SaDoors_KindOf(const text[])
{
    if (!strcmp(text,"house",true))
    {
        return SADOOR_KIND_HOUSE;
    }

    if (!strcmp(text,"biz",true))
    {
        return SADOOR_KIND_BIZ;
    }

    if (!strcmp(text,"door",true))
    {
        return SADOOR_KIND_DOOR;
    }

    return SADOOR_KIND_NONE;
}

static bool:SaDoors_ReadRow(row,index)
{
    new kindText[SADOORS_KIND_LEN];
    cache_get_value_name(row,"kind",kindText,sizeof(kindText));

    new kind = SaDoors_KindOf(kindText);

    if (kind == SADOOR_KIND_NONE)
    {
        return false;
    }

    cache_get_value_name(row,"name",s_SaDoors[index][E_SADOOR_NAME],SADOORS_NAME_LEN);
    s_SaDoors[index][E_SADOOR_KIND] = kind;
    cache_get_value_name(row,"door_type",s_SaDoors[index][E_SADOOR_TYPE],SADOORS_TYPE_LEN);
    cache_get_value_name_int(row,"interior",s_SaDoors[index][E_SADOOR_INTERIOR]);
    cache_get_value_name_float(row,"out_x",s_SaDoors[index][E_SADOOR_OUT_X]);
    cache_get_value_name_float(row,"out_y",s_SaDoors[index][E_SADOOR_OUT_Y]);
    cache_get_value_name_float(row,"out_z",s_SaDoors[index][E_SADOOR_OUT_Z]);
    cache_get_value_name_float(row,"out_angle",s_SaDoors[index][E_SADOOR_OUT_ROT]);
    cache_get_value_name_float(row,"in_x",s_SaDoors[index][E_SADOOR_IN_X]);
    cache_get_value_name_float(row,"in_y",s_SaDoors[index][E_SADOOR_IN_Y]);
    cache_get_value_name_float(row,"in_z",s_SaDoors[index][E_SADOOR_IN_Z]);
    cache_get_value_name_float(row,"in_angle",s_SaDoors[index][E_SADOOR_IN_ROT]);
    cache_get_value_name(row,"title",s_SaDoors[index][E_SADOOR_TITLE],SADOORS_TITLE_LEN);
    cache_get_value_name_int(row,"price",s_SaDoors[index][E_SADOOR_PRICE]);
    cache_get_value_name_int(row,"level",s_SaDoors[index][E_SADOOR_LEVEL]);
    return true;
}

#pragma warning push
#pragma warning disable 204
async Task:SaDoors_LoadAll()
{
    await mysql_aquery_s(g_Mysql,str_new("SELECT * FROM sa_doors ORDER BY door_id"),false);

    if (mysql_errno(g_Mysql) != 0)
    {
        Log_Error("doors","the sa_doors table could not be read");
        return async 0;
    }

    s_SaDoorCount = 0;

    for (new row = 0, rows = cache_num_rows();row < rows;row++)
    {
        if (s_SaDoorCount >= SADOORS_MAX)
        {
            Log_Error("doors","sa_doors has more doors than SADOORS_MAX");
            break;
        }

        if (SaDoors_ReadRow(row,s_SaDoorCount))
        {
            s_SaDoorCount++;
        }
        else
        {
            Log_Warn("doors","row %d of sa_doors is not a door, skipped",row);
        }
    }

    if (s_SaDoorCount == 0)
    {
        Log_Warn("doors","sa_doors is empty, import godfather.sql into the database");
    }

    Log_Info("doors","%d SA doors loaded",s_SaDoorCount);
    return async s_SaDoorCount;
}
#pragma warning pop

stock SaDoors_GetKind(row)
{
    return row >= 0 && row < s_SaDoorCount ? s_SaDoors[row][E_SADOOR_KIND] : SADOOR_KIND_NONE;
}

stock SaDoors_GetName(row,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (row >= 0 && row < s_SaDoorCount)
    {
        strcopy(dest,s_SaDoors[row][E_SADOOR_NAME],size);
    }
}

stock SaDoors_GetType(row,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (row >= 0 && row < s_SaDoorCount)
    {
        strcopy(dest,s_SaDoors[row][E_SADOOR_TYPE],size);
    }
}

stock SaDoors_GetTitle(row,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (row >= 0 && row < s_SaDoorCount)
    {
        strcopy(dest,s_SaDoors[row][E_SADOOR_TITLE],size);
    }
}

stock SaDoors_GetInterior(row)
{
    return row >= 0 && row < s_SaDoorCount ? s_SaDoors[row][E_SADOOR_INTERIOR] : 0;
}

stock SaDoors_GetPrice(row)
{
    return row >= 0 && row < s_SaDoorCount ? s_SaDoors[row][E_SADOOR_PRICE] : 0;
}

stock SaDoors_GetLevel(row)
{
    return row >= 0 && row < s_SaDoorCount ? s_SaDoors[row][E_SADOOR_LEVEL] : 0;
}

stock SaDoors_GetInside(row,&Float:x,&Float:y,&Float:z,&Float:angle)
{
    x = 0.0;
    y = 0.0;
    z = 0.0;
    angle = 0.0;

    if (row >= 0 && row < s_SaDoorCount)
    {
        x = s_SaDoors[row][E_SADOOR_IN_X];
        y = s_SaDoors[row][E_SADOOR_IN_Y];
        z = s_SaDoors[row][E_SADOOR_IN_Z];
        angle = s_SaDoors[row][E_SADOOR_IN_ROT];
    }
}

static Float:SaDoors_Distance(row,Float:x,Float:y,Float:z)
{
    new Float:deltaX = s_SaDoors[row][E_SADOOR_OUT_X] - x, Float:deltaY = s_SaDoors[row][E_SADOOR_OUT_Y] - y, Float:deltaZ = s_SaDoors[row][E_SADOOR_OUT_Z] - z;
    return floatsqroot(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);
}

stock SaDoors_FindNearest(kind,const type[],price,const name[],Float:x,Float:y,Float:z,&Float:distance)
{
    distance = 0.0;

    new tierPrice = -1;

    if (price != SADOORS_ANY_PRICE && name[0] == EOS)
    {
        new bestGap = cellmax;

        for (new row = 0;row < s_SaDoorCount;row++)
        {
            if (s_SaDoors[row][E_SADOOR_KIND] != kind || (type[0] != EOS && strcmp(s_SaDoors[row][E_SADOOR_TYPE],type,true)))
            {
                continue;
            }

            new gap = s_SaDoors[row][E_SADOOR_PRICE] - price;

            if (gap < 0)
            {
                gap = -gap;
            }

            if (gap < bestGap || (gap == bestGap && s_SaDoors[row][E_SADOOR_PRICE] < tierPrice))
            {
                bestGap = gap;
                tierPrice = s_SaDoors[row][E_SADOOR_PRICE];
            }
        }
    }

    new best = INVALID_SADOOR, Float:bestDistance = 0.0;

    for (new row = 0;row < s_SaDoorCount;row++)
    {
        if (s_SaDoors[row][E_SADOOR_KIND] != kind || (type[0] != EOS && strcmp(s_SaDoors[row][E_SADOOR_TYPE],type,true)))
        {
            continue;
        }

        if (name[0] != EOS && strcmp(s_SaDoors[row][E_SADOOR_NAME],name,true))
        {
            continue;
        }

        if (tierPrice != -1 && s_SaDoors[row][E_SADOOR_PRICE] != tierPrice)
        {
            continue;
        }

        new Float:rowDistance = SaDoors_Distance(row,x,y,z);

        if (best == INVALID_SADOOR || rowDistance < bestDistance)
        {
            best = row;
            bestDistance = rowDistance;
        }
    }

    distance = bestDistance;
    return best;
}

stock SaDoors_RegisterPlain()
{
    new registered = 0;

    for (new row = 0;row < s_SaDoorCount;row++)
    {
        if (s_SaDoors[row][E_SADOOR_KIND] != SADOOR_KIND_DOOR)
        {
            continue;
        }

        Doors_Register(DOOR_KIND_SA,row,s_SaDoors[row][E_SADOOR_OUT_X],s_SaDoors[row][E_SADOOR_OUT_Y],s_SaDoors[row][E_SADOOR_OUT_Z],s_SaDoors[row][E_SADOOR_IN_X],s_SaDoors[row][E_SADOOR_IN_Y],s_SaDoors[row][E_SADOOR_IN_Z],s_SaDoors[row][E_SADOOR_INTERIOR],SADOORS_LOCAL_BASE + row,3.0,3.0,DOOR_FLAG_NONE,DOOR_WORLD_KEEP,"","","","",s_SaDoors[row][E_SADOOR_OUT_ROT],s_SaDoors[row][E_SADOOR_IN_ROT]);
        registered++;
    }

    return registered;
}
