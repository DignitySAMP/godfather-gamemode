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
static Trucker_Deliver(playerid,vehicleid,key,bool:withSound)
{
    new load = Trucker_GetLoad(vehicleid), products = Business_GetProducts(key), maxProducts = Business_GetMaxProducts(key), price = Business_GetPriceProd(key), till = Business_GetTill(key);
    new sold = 0, earned = 0, stop = 0;

    while (load > 0)
    {
        if (products == maxProducts)
        {
            stop = 1;
            break;
        }

        if (price > till)
        {
            stop = 2;
            break;
        }

        load--;
        products++;
        earned += price;
        till -= price;
        sold++;

        if (load == 0)
        {
            stop = 3;
        }
    }

    if (sold > 0)
    {
        Trucker_SetLoad(vehicleid,load);
        Business_AddProducts(key,sold);
        Business_SetTill(key,till);
        Account_SetCash(playerid,Account_GetCash(playerid) + earned);
    }

    if (stop == 0)
    {
        return;
    }

    new line[TRUCKER_LINE_LEN];

    switch (stop)
    {
        case 1:
        {
            Property_GameText(playerid,"~r~Our stores are full",5000,1);
        }
        case 2:
        {
            Property_GameText(playerid,"~r~We Cant Afford The Deal",5000,1);
        }
        case 3:
        {
            Property_GameText(playerid,"~r~Truck is empty, return to the stock house",5000,1);
        }
    }

    format(line,sizeof(line),"Cash Earned $%d.",earned);
    SendClientMessage(playerid,TEAM_GROVE_COLOR,line);
    Trucker_ShowLoad(playerid,vehicleid,true);

    if (withSound)
    {
        PlayerPlaySound(playerid,TRUCKER_SOUND_PAID,0.0,0.0,0.0);
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
CMD:load(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new vehicleid = GetPlayerVehicleID(playerid);

    if (Trucker_GetKey(vehicleid) == 0)
    {
        Property_GameText(playerid,"~r~You are not in a delivery truck",5000,1);
        return 1;
    }

    Trucker_ShowLoad(playerid,vehicleid,true);
    return 1;
}

CMD:buyprods(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Property_IsNear(playerid,TRUCKER_STOCK_RADIUS,TRUCKER_STOCK_X,TRUCKER_STOCK_Y,TRUCKER_STOCK_Z))
    {
        return 1;
    }

    new vehicleid = GetPlayerVehicleID(playerid);

    if (Trucker_GetKey(vehicleid) == 0)
    {
        SendClientMessage(playerid,TEAM_GROVE_COLOR,"This Vehicle does not deliver Products.");
        return 1;
    }

    new load = Trucker_GetLoad(vehicleid), capacity = Trucker_GetCapacity(vehicleid), line[TRUCKER_LINE_LEN];

    if (load >= capacity)
    {
        Trucker_ShowLoad(playerid,vehicleid,true);
        return 1;
    }

    new amountText[16];

    if (sscanf(params,"s[16]",amountText))
    {
        SendClientMessage(playerid,COLOR_GRAD1,"USAGE: /buyprods [amount]");
        return 1;
    }

    new amount = strval(amountText);

    if (amount < TRUCKER_BUY_MIN || amount > TRUCKER_BUY_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Can't buy less than 1 Product or more than 500 !");
        return 1;
    }

    if (load + amount > capacity)
    {
        format(line,sizeof(line),"   You went over the Truck Products Carry Limit of %d, you currently carry %d.",capacity,load);
        SendClientMessage(playerid,COLOR_GREY,line);
        return 1;
    }

    new cost = amount * TRUCKER_PRODUCT_COST;

    if (Account_GetCash(playerid) < cost)
    {
        format(line,sizeof(line),"You can't afford %d Products at $%d !",amount,cost);
        SendClientMessage(playerid,TEAM_GROVE_COLOR,line);
        return 1;
    }

    Trucker_SetLoad(vehicleid,load + amount);
    Trucker_ShowLoad(playerid,vehicleid,true);
    format(line,sizeof(line),"You bought %d Products for $%d.",amount,cost);
    SendClientMessage(playerid,TEAM_GROVE_COLOR,line);
    Account_SetCash(playerid,Account_GetCash(playerid) - cost);
    PlayerPlaySound(playerid,TRUCKER_SOUND_PAID,0.0,0.0,0.0);
    return 1;
}

CMD:sellprods(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new vehicleid = GetPlayerVehicleID(playerid);

    if (Trucker_GetKey(vehicleid) == 0)
    {
        Property_GameText(playerid,"~r~You are not in a delivery truck",5000,1);
        return 1;
    }

    if (Trucker_GetLoad(vehicleid) == 0)
    {
        Property_GameText(playerid,"~r~Truck is empty, return to the stock house",5000,1);
        Trucker_ShowLoad(playerid,vehicleid,true);
        return 1;
    }

    for (new row = 0, rows = Business_GetRowCount();row < rows;row++)
    {
        new key = Business_GetKeyOfRow(row);

        if (!Business_IsValid(key) || !Business_IsNearEntrance(playerid,key,TRUCKER_DELIVER_RADIUS))
        {
            continue;
        }

        Trucker_Deliver(playerid,vehicleid,key,!Business_IsSpecial(key));
        return 1;
    }

    Property_GameText(playerid,"~r~To Far From A Business",5000,1);
    return 1;
}
