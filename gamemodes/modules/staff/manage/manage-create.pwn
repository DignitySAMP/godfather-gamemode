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
#define CREATE_PRICE_MAX (2000000000)
#define CREATE_LEVEL_MAX (1000)
#define CREATE_DOOR_MESSAGE "   There is already a door here."
#define CREATE_INSIDE_MESSAGE "   Stand outside, in the street, to place a door."

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
static bool:Create_ReadNumber(const text[],&value,minimum,maximum)
{
    if (text[0] == EOS)
    {
        return false;
    }

    for (new i = 0;text[i] != EOS;i++)
    {
        if ((text[i] < '0' || text[i] > '9') && !(i == 0 && text[i] == '-' && text[1] != EOS))
        {
            return false;
        }
    }

    value = strval(text);
    return value >= minimum && value <= maximum;
}

static bool:Create_CheckSpot(playerid)
{
    if (GetPlayerInterior(playerid) != 0)
    {
        SendClientMessage(playerid,COLOR_GRAD2,CREATE_INSIDE_MESSAGE);
        return false;
    }

    if (Doors_FindEntrance(playerid) != INVALID_DOOR_ID)
    {
        SendClientMessage(playerid,COLOR_GRAD2,CREATE_DOOR_MESSAGE);
        return false;
    }

    return true;
}

static Float:Create_FacingAway(playerid)
{
    new Float:angle;
    GetPlayerFacingAngle(playerid,angle);
    return Property_NormalAngle(angle + 180.0);
}

static Create_SendLine(playerid,const text[])
{
    SendClientMessage(playerid,COLOR_WHITE,text);
}

/**
 *                                   __
 *                                  |  |
 *      _______  ______ ____    ____| $$  _______
 *     /       \|      \    \  /      $$ /       |
 *    |  $$$$$$$| $$$$$$\$$$$\|  $$$$$$$|  $$$$$$$
 *    | $$      | $$ | $$ | $$| $$  | $$ \$$    |
 *    | $$_____ | $$ | $$ | $$| $$__| $$ _\$$$$$$|
 *     \$$     \| $$ | $$ | $$ \$$    $$|       $$
 *      \$$$$$$$ \$$  \$$  \$$  \$$$$$$$ \$$$$$$$
 *
 */
CMD<ADMIN_LEVEL_MANAGER>:createhouse(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, priceText[STAFF_TOKEN_LEN], levelText[STAFF_TOKEN_LEN], name[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,priceText) || !Util_ReadToken(params,at,levelText))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /createhouse [price] [level] (interior name)");
        SendClientMessage(playerid,COLOR_GREY,"Stand in front of the door, outside. Use /nearestinterior house [price] to see which interior it picks.");
        return 1;
    }

    new price, level;

    if (!Create_ReadNumber(priceText,price,1,CREATE_PRICE_MAX) || !Create_ReadNumber(levelText,level,0,CREATE_LEVEL_MAX))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   The price has to be at least 1 and the level 0 or more.");
        return 1;
    }

    Util_ReadToken(params,at,name);

    if (!Create_CheckSpot(playerid))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z, Float:distance;
    GetPlayerPos(playerid,x,y,z);

    new row = SaDoors_FindNearest(SADOOR_KIND_HOUSE,"",price,name,x,y,z,distance);

    if (row == INVALID_SADOOR)
    {
        new line[STAFF_LINE_LEN];
        format(line,sizeof(line),"   There is no house interior called %s.",name);
        SendClientMessage(playerid,COLOR_GRAD2,line);
        return 1;
    }

    new Float:inX, Float:inY, Float:inZ, Float:inAngle, title[SADOORS_TITLE_LEN];
    SaDoors_GetInside(row,inX,inY,inZ,inAngle);
    SaDoors_GetTitle(row,title);

    new house = Houses_Create(x,y,z,Create_FacingAway(playerid),inX,inY,inZ,inAngle,SaDoors_GetInterior(row),price,level,title);

    if (house == HOUSE_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   There is no room for another house.");
        return 1;
    }

    new interiorName[SADOORS_NAME_LEN], line[STAFF_LINE_LEN];
    SaDoors_GetName(row,interiorName);
    format(line,sizeof(line),"House %d created: %s (%s, interior %d), $%d, level %d.",house,title,interiorName,SaDoors_GetInterior(row),price,level);
    Create_SendLine(playerid,line);
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:createbiz(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, typeText[STAFF_TOKEN_LEN], priceText[STAFF_TOKEN_LEN], levelText[STAFF_TOKEN_LEN], name[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,typeText) || !Util_ReadToken(params,at,priceText) || !Util_ReadToken(params,at,levelText))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /createbiz [type] [price] [level] (interior name)");
        SendClientMessage(playerid,COLOR_GREY,"Types: 24/7, bar, food, clothes, ammunation, barber, other");
        return 1;
    }

    new type = Business_TypeFromName(typeText);

    if (type == BUSINESS_TYPE_NONE)
    {
        SendClientMessage(playerid,COLOR_GREY,"Types: 24/7, bar, food, clothes, ammunation, barber, other");
        return 1;
    }

    new price, level;

    if (!Create_ReadNumber(priceText,price,1,CREATE_PRICE_MAX) || !Create_ReadNumber(levelText,level,0,CREATE_LEVEL_MAX))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   The price has to be at least 1 and the level 0 or more.");
        return 1;
    }

    Util_ReadToken(params,at,name);

    if (!Create_CheckSpot(playerid))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z, Float:distance;
    GetPlayerPos(playerid,x,y,z);

    new row = SaDoors_FindNearest(SADOOR_KIND_BIZ,typeText,SADOORS_ANY_PRICE,name,x,y,z,distance);

    if (row == INVALID_SADOOR)
    {
        new line[STAFF_LINE_LEN];
        format(line,sizeof(line),"   There is no %s interior%s%s.",typeText,name[0] == EOS ? "" : " called ",name);
        SendClientMessage(playerid,COLOR_GRAD2,line);
        return 1;
    }

    new Float:inX, Float:inY, Float:inZ, Float:inAngle, title[SADOORS_TITLE_LEN];
    SaDoors_GetInside(row,inX,inY,inZ,inAngle);
    SaDoors_GetTitle(row,title);

    new key = Business_CreateTyped(type,title,x,y,z,Create_FacingAway(playerid),inX,inY,inZ,inAngle,SaDoors_GetInterior(row),price,level);

    if (key == BUSINESS_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   There is no room for another business.");
        return 1;
    }

    new interiorName[SADOORS_NAME_LEN], line[STAFF_LINE_LEN];
    SaDoors_GetName(row,interiorName);
    format(line,sizeof(line),"Business %d created: %s, %s (%s, interior %d), $%d, level %d.",key,typeText,title,interiorName,SaDoors_GetInterior(row),price,level);
    Create_SendLine(playerid,line);
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:movehouse(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN], house;

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /movehouse [houseid]");
        SendClientMessage(playerid,COLOR_GREY,"Stand in front of the new door position, outside.");
        return 1;
    }

    if (!Create_ReadNumber(token,house,0,HOUSES_MAX) || !Houses_IsValid(house))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   That house does not exist.");
        return 1;
    }

    if (!Create_CheckSpot(playerid))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    Houses_Move(house,x,y,z,Create_FacingAway(playerid));

    new line[STAFF_LINE_LEN];
    format(line,sizeof(line),"House %d moved to %.1f, %.1f, %.1f.",house,x,y,z);
    Create_SendLine(playerid,line);
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:movebiz(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN], key;

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /movebiz [bizid]");
        SendClientMessage(playerid,COLOR_GREY,"Stand in front of the new door position, outside.");
        return 1;
    }

    if (!Create_ReadNumber(token,key,0,BUSINESS_TYPED_BASE + BUSINESS_TYPED_MAX) || !Business_IsValid(key))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   That business does not exist.");
        return 1;
    }

    if (Business_IsSpecial(key))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   Special businesses cannot be moved.");
        return 1;
    }

    if (!Create_CheckSpot(playerid))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    Business_Move(key,x,y,z,Create_FacingAway(playerid));

    new line[STAFF_LINE_LEN];
    format(line,sizeof(line),"Business %d moved to %.1f, %.1f, %.1f.",key,x,y,z);
    Create_SendLine(playerid,line);
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:deletehouse(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN], house;

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /deletehouse [houseid]");
        return 1;
    }

    if (!Create_ReadNumber(token,house,0,HOUSES_MAX))
    {
        house = HOUSE_NO_KEY;
    }

    switch (Houses_Delete(house))
    {
        case HOUSE_DELETE_OK:
        {
            new line[STAFF_LINE_LEN];
            format(line,sizeof(line),"House %d deleted.",house);
            Create_SendLine(playerid,line);
        }
        case HOUSE_DELETE_OWNED:
        {
            SendClientMessage(playerid,COLOR_GRAD2,"   That house is owned, use /asellhouse first.");
        }
        case HOUSE_DELETE_HAS_CAR:
        {
            SendClientMessage(playerid,COLOR_GRAD2,"   That house has a house car and cannot be deleted.");
        }
        default:
        {
            SendClientMessage(playerid,COLOR_GRAD2,"   That house does not exist.");
        }
    }

    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:deletebiz(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN], key;

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /deletebiz [bizid]");
        return 1;
    }

    if (!Create_ReadNumber(token,key,0,BUSINESS_TYPED_BASE + BUSINESS_TYPED_MAX))
    {
        key = BUSINESS_NO_KEY;
    }

    switch (Business_DeleteTyped(key))
    {
        case BUSINESS_DELETE_OK:
        {
            new line[STAFF_LINE_LEN];
            format(line,sizeof(line),"Business %d deleted.",key);
            Create_SendLine(playerid,line);
        }
        case BUSINESS_DELETE_OWNED:
        {
            SendClientMessage(playerid,COLOR_GRAD2,"   That business is owned, use /asellbiz first.");
        }
        case BUSINESS_DELETE_FIXED:
        {
            SendClientMessage(playerid,COLOR_GRAD2,"   The original businesses cannot be deleted.");
        }
        default:
        {
            SendClientMessage(playerid,COLOR_GRAD2,"   That business does not exist.");
        }
    }

    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:nearestinterior(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, kindText[STAFF_TOKEN_LEN], priceText[STAFF_TOKEN_LEN], Float:x, Float:y, Float:z, Float:distance;
    GetPlayerPos(playerid,x,y,z);
    Util_ReadToken(params,at,kindText);
    Util_ReadToken(params,at,priceText);

    new price = SADOORS_ANY_PRICE, row = INVALID_SADOOR, kind = SADOOR_KIND_NONE, typeText[SADOORS_TYPE_LEN];

    if (priceText[0] != EOS && !Create_ReadNumber(priceText,price,1,CREATE_PRICE_MAX))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /nearestinterior (house/door/bar/food/...) (price)");
        return 1;
    }

    if (kindText[0] == EOS)
    {
        new Float:best = 0.0;

        for (new candidate = SADOOR_KIND_HOUSE;candidate <= SADOOR_KIND_DOOR;candidate++)
        {
            new found = SaDoors_FindNearest(candidate,"",SADOORS_ANY_PRICE,"",x,y,z,distance);

            if (found != INVALID_SADOOR && (row == INVALID_SADOOR || distance < best))
            {
                row = found;
                best = distance;
            }
        }

        distance = best;
    }
    else if (!strcmp(kindText,"house",true))
    {
        row = SaDoors_FindNearest(SADOOR_KIND_HOUSE,"",price,"",x,y,z,distance);
    }
    else if (!strcmp(kindText,"door",true))
    {
        row = SaDoors_FindNearest(SADOOR_KIND_DOOR,"",SADOORS_ANY_PRICE,"",x,y,z,distance);
    }
    else if (Business_TypeFromName(kindText) != BUSINESS_TYPE_NONE)
    {
        row = SaDoors_FindNearest(SADOOR_KIND_BIZ,kindText,SADOORS_ANY_PRICE,"",x,y,z,distance);
    }
    else
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /nearestinterior (house/door/24/7/bar/food/clothes/ammunation/barber/other) (price)");
        return 1;
    }

    if (row == INVALID_SADOOR)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   No interior matches that.");
        return 1;
    }

    kind = SaDoors_GetKind(row);
    SaDoors_GetType(row,typeText);

    new interiorName[SADOORS_NAME_LEN], title[SADOORS_TITLE_LEN], line[STAFF_LINE_LEN];
    SaDoors_GetName(row,interiorName);
    SaDoors_GetTitle(row,title);

    if (kind == SADOOR_KIND_HOUSE)
    {
        format(line,sizeof(line),"Nearest interior: %s, %s, interior %d, house, $%d, level %d, %.0f m to its nearest door.",interiorName,title,SaDoors_GetInterior(row),SaDoors_GetPrice(row),SaDoors_GetLevel(row),distance);
    }
    else if (kind == SADOOR_KIND_BIZ)
    {
        format(line,sizeof(line),"Nearest interior: %s, %s, interior %d, business (%s), %.0f m to its nearest door.",interiorName,title,SaDoors_GetInterior(row),typeText,distance);
    }
    else
    {
        format(line,sizeof(line),"Nearest interior: %s, %s, interior %d, door only, %.0f m to its nearest door.",interiorName,title,SaDoors_GetInterior(row),distance);
    }

    Create_SendLine(playerid,line);
    return 1;
}
