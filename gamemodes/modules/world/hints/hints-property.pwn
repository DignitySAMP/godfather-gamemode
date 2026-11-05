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
static bool:Hints_ShowBusiness(playerid,key,bool:isTruck)
{
    new line[HINTS_TEXT_LEN], message[BUSINESS_MESSAGE_LEN];

    if (isTruck && Business_IsNearEntrance(playerid,key,HINTS_TRUCK_RADIUS))
    {
        Business_GetMessage(key,message);
        format(line,sizeof(line),"~w~%s~n~~r~Products Required~w~: %d~n~~y~Price per Product: ~w~: $%d~n~~g~Funds: ~w~: $%d",message,Business_GetMaxProducts(key) - Business_GetProducts(key),Business_GetPriceProd(key),Business_GetTill(key));
        Hints_Show(playerid,line,HINTS_STYLE_DEFAULT);
        return true;
    }

    if (!Business_IsNearEntrance(playerid,key,HINTS_RADIUS))
    {
        return false;
    }

    Business_GetMessage(key,message);

    if (Business_IsOwned(key))
    {
        new owner[BUSINESS_OWNER_LEN], extortion[BUSINESS_OWNER_LEN];
        Business_GetOwner(key,owner);
        Business_GetExtortion(key,extortion);
        format(line,sizeof(line),"~w~%s~w~~n~Owner : %s~n~Extortion by : %s~n~Entrance Fee : ~g~$%d ~w~Level : %d ~n~to enter type /enter",message,owner,extortion,Business_GetEntranceCost(key),Business_GetLevelNeeded(key));
    }
    else
    {
        format(line,sizeof(line),"~w~%s~w~~n~This Business is for sale~n~Cost: ~g~$%d ~w~Level : %d ~n~to buy this Business type /buybiz",message,Business_GetBuyPrice(key),Business_GetLevelNeeded(key));
    }

    Hints_Show(playerid,line,HINTS_STYLE_DEFAULT);
    return true;
}

static bool:Hints_ShowHouse(playerid)
{
    new house = Houses_FindNearEntrance(playerid,HINTS_RADIUS);

    if (house == HOUSE_NO_KEY)
    {
        return false;
    }

    new line[HINTS_TEXT_LEN];

    if (Houses_IsOwned(house))
    {
        new owner[HOUSE_NAME_LEN];
        Houses_GetOwner(house,owner);

        if (Houses_GetRentable(house) == 0)
        {
            format(line,sizeof(line),"~w~This House is owned by~n~%s~n~Level : %d",owner,Houses_GetLevel(house));
        }
        else
        {
            format(line,sizeof(line),"~w~This House is owned by~n~%s~n~Rent: $%d Level : %d~n~Type /rentroom to rent a room",owner,Houses_GetRent(house),Houses_GetLevel(house));
        }
    }
    else
    {
        new description[HOUSE_DESCRIPTION_LEN];
        Houses_GetDescription(house,description);
        format(line,sizeof(line),"~w~This House is for sale~n~Description: %s ~n~Cost: ~g~$%d~n~~w~ Level : %d~n~to buy this house type /buyhouse",description,Houses_GetPrice(house),Houses_GetLevel(house));
    }

    Hints_Show(playerid,line,HINTS_STYLE_DEFAULT);
    return true;
}

stock bool:Hints_ShowProperty(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);

    if (x == 0.0 || y == 0.0 || z == 0.0)
    {
        return false;
    }

    new bool:isTruck = Vehicles_IsTruck(GetPlayerVehicleID(playerid));

    for (new row = BUSINESS_COUNT;row < BUSINESS_FIXED_ROWS;row++)
    {
        if (Hints_ShowBusiness(playerid,Business_GetKeyOfRow(row),isTruck))
        {
            return true;
        }
    }

    if (Hints_ShowHouse(playerid))
    {
        return true;
    }

    for (new row = 0;row < BUSINESS_COUNT;row++)
    {
        if (Hints_ShowBusiness(playerid,Business_GetKeyOfRow(row),isTruck))
        {
            return true;
        }
    }

    for (new row = BUSINESS_FIXED_ROWS, rows = Business_GetRowCount();row < rows;row++)
    {
        if (Hints_ShowBusiness(playerid,Business_GetKeyOfRow(row),isTruck))
        {
            return true;
        }
    }

    return false;
}
