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
#define MANAGE_SELL_SOUND (1052)
#define MANAGE_SELL_TEXT_MS (10000)
#define MANAGE_EDIT_RANGE (3.0)
#define MANAGE_RESET_CAR_MODEL (499)

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
static Manage_SellBusiness(playerid,const params[],const usage[],bool:isSpecial)
{
    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD1,usage);
        return;
    }

    new index = strval(token), key = index;

    if (isSpecial)
    {
        if (index < 0 || index >= BUSINESS_SPECIAL_COUNT)
        {
            return;
        }

        key = Business_MakeSpecialKey(index);
    }
    else if (index < 0 || (index >= BUSINESS_COUNT && !Business_IsTyped(index)))
    {
        return;
    }

    if (!Business_IsValid(key))
    {
        return;
    }

    new till = Business_GetTill(key);
    Business_Release(key);
    Business_SetTill(key,till);
    PlayerPlaySound(playerid,MANAGE_SELL_SOUND,0.0,0.0,0.0);
    GameTextForPlayer(playerid,"~w~You have sold the Business",MANAGE_SELL_TEXT_MS,3);
}

static Manage_EditHouses(playerid,const field[],value)
{
    for (new house = 0,count = Houses_GetCount();house < count;house++)
    {
        if (!Houses_IsValid(house) || !Houses_IsNearEntrance(playerid,house,MANAGE_EDIT_RANGE))
        {
            continue;
        }

        new line[STAFF_LINE_LEN];
        format(line,sizeof(line),"House: %d",house);
        SendClientMessage(playerid,COLOR_GRAD2,line);

        if (value > 0)
        {
            if (!strcmp(field,"level",true))
            {
                Houses_SetLevel(house,value);
            }
            else if (!strcmp(field,"price",true))
            {
                Houses_SetPrice(house,value);
            }
        }
    }
}

static Manage_EditBusiness(playerid,key,const label[],const field[],value)
{
    if (!Business_IsValid(key) || !Business_IsNearEntrance(playerid,key,MANAGE_EDIT_RANGE))
    {
        return;
    }

    new index = Business_IsSpecial(key) ? key - BUSINESS_SPECIAL_BASE : key, line[STAFF_LINE_LEN];
    format(line,sizeof(line),"%s: %d",label,index);
    SendClientMessage(playerid,COLOR_GRAD2,line);

    if (value <= 0)
    {
        return;
    }

    if (!strcmp(field,"level",true))
    {
        Business_SetLevelNeeded(key,value);
    }
    else if (!strcmp(field,"price",true))
    {
        Business_SetBuyPrice(key,value);
    }
    else if (!strcmp(field,"funds",true))
    {
        Business_SetTill(key,value);
    }
    else if (!strcmp(field,"products",true))
    {
        Business_SetProducts(key,value);
    }
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
CMD<ADMIN_LEVEL_MANAGER>:asellbiz(cmdid, playerid, params[])
{
    #pragma unused cmdid

    Manage_SellBusiness(playerid,params,"USAGE: /asellbiz [bizid]",false);
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:asellsbiz(cmdid, playerid, params[])
{
    #pragma unused cmdid

    Manage_SellBusiness(playerid,params,"USAGE: /asellsbiz [sbizid]",true);
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:asellhouse(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /asellhouse [houseid]");
        return 1;
    }

    new house = strval(token);

    if (!Houses_IsValid(house))
    {
        return 1;
    }

    Houses_Release(house);
    PlayerPlaySound(playerid,MANAGE_SELL_SOUND,0.0,0.0,0.0);
    GameTextForPlayer(playerid,"~w~You have sold this property",MANAGE_SELL_TEXT_MS,3);
    return 1;
}

CMD<ADMIN_LEVEL_DEVELOPER>:resethousecars(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    for (new house = 0,count = Houses_GetCount();house < count;house++)
    {
        if (!Houses_IsValid(house))
        {
            continue;
        }

        new model, colour1, colour2;
        Houses_GetCar(house,model,colour1,colour2);
        Houses_SetCar(house,MANAGE_RESET_CAR_MODEL,colour1,colour2);
    }

    SendClientMessage(playerid,COLOR_GREY,"   All House Cars resetted !");
    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:edithousecar(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, token[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,token))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /edithousecar [vecid]");
        return 1;
    }

    new model = strval(token);

    for (new house = 0,count = Houses_GetCount();house < count;house++)
    {
        if (!Houses_IsValid(house) || !Houses_IsNearEntrance(playerid,house,MANAGE_EDIT_RANGE))
        {
            continue;
        }

        new oldModel, colour1, colour2, line[STAFF_LINE_LEN];
        Houses_GetCar(house,oldModel,colour1,colour2);
        Houses_SetCar(house,model,colour1,colour2);
        format(line,sizeof(line),"House Car: %d is now %d",house,model);
        SendClientMessage(playerid,COLOR_GRAD2,line);
    }

    return 1;
}

CMD<ADMIN_LEVEL_MANAGER>:edit(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new at = 0, field[STAFF_TOKEN_LEN], amount[STAFF_TOKEN_LEN];

    if (!Util_ReadToken(params,at,field))
    {
        SendClientMessage(playerid,COLOR_WHITE,"|__________________ Edit __________________|");
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /edit [name] [ammount] (Used for Houses and Businesses)");
        SendClientMessage(playerid,COLOR_GREY,"Available names: Level, Price, Funds, Products");
        SendClientMessage(playerid,COLOR_WHITE,"|____________________________________________|");
        return 1;
    }

    if (!Util_ReadToken(params,at,amount))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /edit [name] [ammount]");
        return 1;
    }

    new value = strval(amount), line[STAFF_LINE_LEN];
    Manage_EditHouses(playerid,field,value);

    for (new key = 0;key < BUSINESS_COUNT;key++)
    {
        Manage_EditBusiness(playerid,key,"Biz",field,value);
    }

    for (new index = 0;index < BUSINESS_SPECIAL_COUNT;index++)
    {
        Manage_EditBusiness(playerid,Business_MakeSpecialKey(index),"SBiz",field,value);
    }

    for (new row = BUSINESS_FIXED_ROWS;row < BUSINESS_ROWS;row++)
    {
        Manage_EditBusiness(playerid,Business_GetKeyOfRow(row),"Biz",field,value);
    }

    format(line,sizeof(line),"You've adjusted the: %s.",field);
    SendClientMessage(playerid,COLOR_WHITE,line);
    return 1;
}
