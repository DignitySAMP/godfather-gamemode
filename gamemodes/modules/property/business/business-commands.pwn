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
#define BUSINESS_BUY_RADIUS (2.0)
#define BUSINESS_TILL_RADIUS (100.0)
#define BUSINESS_PRICE_MIN (1)
#define BUSINESS_PRICE_MAX (99999)
#define BUSINESS_FEE_MIN (0)
#define BUSINESS_FEE_MAX (99999)
#define BUSINESS_NAME_INPUT_LEN (64)
#define BUSINESS_SOLD_SOUND (1052)
#define BUSINESS_NO_ONE_ID (555)

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
stock Business_PrintInfo(playerid,key)
{
    if (!IsPlayerConnected(playerid) || !Business_IsValid(key))
    {
        return;
    }

    new line[256], message[BUSINESS_MESSAGE_LEN], extortion[BUSINESS_NAME_LEN];
    Business_GetMessage(key,message);
    Business_GetExtortion(key,extortion);
    SendClientMessage(playerid,COLOR_GREEN,"_______________________________________");
    format(line,sizeof(line),"*** %s ***",message);
    SendClientMessage(playerid,COLOR_WHITE,line);
    format(line,sizeof(line),"Locked: %d EntryFee: $%d Till: $%d",Business_IsLocked(key) ? 1 : 0,Business_GetEntranceCost(key),Business_GetTill(key));
    SendClientMessage(playerid,COLOR_GRAD1,line);
    format(line,sizeof(line),"Products: %d/%d Extortion By: %s",Business_GetProducts(key),Business_GetMaxProducts(key),extortion);
    SendClientMessage(playerid,COLOR_GRAD2,line);
    SendClientMessage(playerid,COLOR_GREEN,"_______________________________________");
}

static bool:Business_Purchase(playerid,key)
{
    new line[96];

    if (Account_GetLevel(playerid) < Business_GetLevelNeeded(key))
    {
        format(line,sizeof(line),"You Must Be Level %d To Purchase This",Business_GetLevelNeeded(key));
        SendClientMessage(playerid,COLOR_GRAD5,line);
        return true;
    }

    if (Account_GetCash(playerid) < Business_GetBuyPrice(key))
    {
        SendClientMessage(playerid,COLOR_WHITE,"You don't have the cash for that");
        return true;
    }

    new name[BUSINESS_NAME_LEN];
    Property_GetPlayerName(playerid,name);
    Business_SetKey(playerid,key);
    Business_Claim(key,name);
    Account_SetCash(playerid,Account_GetCash(playerid) - Business_GetBuyPrice(key));
    Misc_PlayMusic(playerid);

    if (!Business_IsSpecial(key))
    {
        Doors_Place(playerid,Business_GetDoor(key));
        Property_GameText(playerid,"~w~Welcome~n~You can exit at any time by moving to this door and typing /exit",5000,3);
    }

    SendClientMessage(playerid,COLOR_WHITE,"Congratulations, On Your New Purchase.");
    SendClientMessage(playerid,COLOR_WHITE,"Type /help to review the new business help section.");
    Houses_TouchOwned(playerid);
    return true;
}

static bool:Business_ReadAmount(const params[],&amount)
{
    new amountText[16];
    amount = 0;

    if (sscanf(params,"s[16]",amountText))
    {
        return false;
    }

    amount = strval(amountText);
    return true;
}

static Business_PrintTill(playerid,key)
{
    new line[64];
    format(line,sizeof(line),"  You Have $%d in your till.",Business_GetTill(key));
    SendClientMessage(playerid,COLOR_GRAD3,line);
}

static bool:Business_IsNearTill(playerid,key)
{
    if (Business_IsSpecial(key))
    {
        return Business_IsNearEntrance(playerid,key,BUSINESS_TILL_RADIUS);
    }

    return Business_IsNearExit(playerid,key,BUSINESS_TILL_RADIUS);
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
CMD:buybiz(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Business_GetKey(playerid) != BUSINESS_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_WHITE,"   You already own a business, type /sellbiz if you want to buy this one.");
        return 1;
    }

    for (new index = 0;index < BUSINESS_SPECIAL_COUNT;index++)
    {
        new key = BUSINESS_SPECIAL_BASE + index;

        if (!Business_IsValid(key) || Business_IsOwned(key) || !Business_IsNearEntrance(playerid,key,BUSINESS_BUY_RADIUS))
        {
            continue;
        }

        Business_Purchase(playerid,key);
        return 1;
    }

    for (new key = 0;key < BUSINESS_COUNT;key++)
    {
        if (!Business_IsValid(key) || Business_IsOwned(key) || !Business_IsNearEntrance(playerid,key,BUSINESS_BUY_RADIUS))
        {
            continue;
        }

        Business_Purchase(playerid,key);
        return 1;
    }

    for (new row = BUSINESS_FIXED_ROWS;row < BUSINESS_ROWS;row++)
    {
        new key = Business_GetKeyOfRow(row);

        if (!Business_IsValid(key) || Business_IsOwned(key) || !Business_IsNearEntrance(playerid,key,BUSINESS_BUY_RADIUS))
        {
            continue;
        }

        Business_Purchase(playerid,key);
        return 1;
    }

    return 1;
}

CMD:sellbiz(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new key = Business_GetKey(playerid);

    if (key == BUSINESS_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_WHITE,"You don't own a bizz.");
        return 1;
    }

    if (Business_Ask(BUSINESS_PROVIDER_IS_MARRIED,playerid,false))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are Married, can't sell the House !");
        return 1;
    }

    if (!Business_IsOwner(playerid,key))
    {
        SendClientMessage(playerid,COLOR_WHITE,"You don't own a business.");
        return 1;
    }

    new payout = Business_GetTill(key) + Business_GetBuyPrice(key) / 2, line[96];
    Business_Release(key);
    Account_SetCash(playerid,Account_GetCash(playerid) + payout);
    PlayerPlaySound(playerid,BUSINESS_SOLD_SOUND,0.0,0.0,0.0);
    format(line,sizeof(line),"~w~Congratulations~n~ You have sold your property for ~n~~g~$%d",payout);
    Property_GameText(playerid,line,10000,3);
    Business_SetKey(playerid,BUSINESS_NO_KEY);
    return 1;
}

CMD:bizinfo(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new key = Business_GetKey(playerid);

    if (key == BUSINESS_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_WHITE,"You don't own a business.");
        return 1;
    }

    Business_PrintInfo(playerid,key);
    return 1;
}

CMD:prodprice(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new key = Business_GetKey(playerid);

    if (key == BUSINESS_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't own a business");
        return 1;
    }

    new amount;

    if (!Business_ReadAmount(params,amount))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /prodprice [amount to pay per Product]");
        return 1;
    }

    if (amount < BUSINESS_PRICE_MIN || amount > BUSINESS_PRICE_MAX)
    {
        SendClientMessage(playerid,COLOR_WHITE,"Minimum amount is $1, Maximum amount is $99999.");
        return 1;
    }

    if (amount > Business_GetTill(key))
    {
        SendClientMessage(playerid,COLOR_WHITE,"You don't have that much in your Till.");
        return 1;
    }

    new line[64];
    Business_SetPriceProd(key,amount);
    format(line,sizeof(line),"Buying Products for $%d.",amount);
    SendClientMessage(playerid,COLOR_WHITE,line);
    return 1;
}

CMD:bizfee(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new key = Business_GetKey(playerid);

    if (key == BUSINESS_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't own a business !");
        return 1;
    }

    new amount;

    if (!Business_ReadAmount(params,amount))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /bizfee [EntranceFee]");
        return 1;
    }

    if (amount < BUSINESS_FEE_MIN || amount > BUSINESS_FEE_MAX)
    {
        SendClientMessage(playerid,COLOR_WHITE,"Minimum entrance is $0, Maximum entrance is $99999.");
        return 1;
    }

    new line[64];
    Business_SetEntranceCost(key,amount);
    format(line,sizeof(line),"Entrance fee set to $%d.",amount);
    SendClientMessage(playerid,COLOR_WHITE,line);
    return 1;
}

CMD:extortion(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new key = Business_GetKey(playerid);

    if (key == BUSINESS_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't own a business");
        return 1;
    }

    new nameText[32];

    if (sscanf(params,"s[32]",nameText))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /extortion [playerid/PartOfName] (or 555 for No-one)");
        return 1;
    }

    new targetid = INVALID_PLAYER_ID, line[128];

    if (strval(nameText) == BUSINESS_NO_ONE_ID && strlen(nameText) == 3)
    {
        Business_SetExtortion(key,BUSINESS_EXTORTION_NONE);
        format(line,sizeof(line),"Business Extortion Name set to %s",BUSINESS_EXTORTION_NONE);
        SendClientMessage(playerid,COLOR_WHITE,line);
        return 1;
    }

    sscanf(nameText,"u",targetid);

    if (targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid,COLOR_GREY,"   That player is Offline !");
        return 1;
    }

    new sender[BUSINESS_NAME_LEN], extorter[BUSINESS_NAME_LEN];
    GetPlayerName(playerid,sender,sizeof(sender));
    GetPlayerName(targetid,extorter,sizeof(extorter));
    format(line,sizeof(line),"* %s is now Extortioning your Business.",extorter);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    format(line,sizeof(line),"* %s has adjusted his Business, you are now Extortioning his Business.",sender);
    SendClientMessage(targetid,COLOR_LIGHTBLUE,line);
    Business_SetExtortion(key,extorter);
    format(line,sizeof(line),"Business Extortion Name set to %s",extorter);
    SendClientMessage(playerid,COLOR_WHITE,line);
    return 1;
}

CMD:bizname(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new key = Business_GetKey(playerid);

    if (key == BUSINESS_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't own a business");
        return 1;
    }

    new start = 0, length = strlen(params), result[BUSINESS_NAME_INPUT_LEN];

    while (start < length && params[start] <= ' ')
    {
        start++;
    }

    strmid(result,params,start,length,sizeof(result));

    if (strlen(result) == 0)
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /bizname [Name]");
        return 1;
    }

    new line[96];
    Business_SetMessage(key,result);
    format(line,sizeof(line),"Business name set to %s",result);
    SendClientMessage(playerid,COLOR_WHITE,line);
    return 1;
}

CMD:bizwithdraw(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new key = Business_GetKey(playerid);

    if (key == BUSINESS_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't own a business");
        return 1;
    }

    new amount;

    if (!Business_ReadAmount(params,amount))
    {
        Business_PrintTill(playerid,key);
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /bizwithdraw [amount]");
        return 1;
    }

    if (amount > Business_GetTill(key) || amount < 1)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't have that much");
        return 1;
    }

    if (!Business_IsNearTill(playerid,key))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You are too far from your business");
        return 1;
    }

    new line[96];
    Account_SetCash(playerid,Account_GetCash(playerid) + amount);
    Business_AddTill(key,-amount);
    format(line,sizeof(line),"  You Have Withdrawn $%d from your till Total: $%d ",amount,Business_GetTill(key));
    SendClientMessage(playerid,COLOR_YELLOW,line);
    return 1;
}

CMD:bizbank(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new key = Business_GetKey(playerid);

    if (key == BUSINESS_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't own a business");
        return 1;
    }

    new amount;

    if (!Business_ReadAmount(params,amount))
    {
        Business_PrintTill(playerid,key);
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /bizbank [amount]");
        return 1;
    }

    if (amount > Account_GetCash(playerid) || amount < 1)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't have that much");
        return 1;
    }

    if (!Business_IsNearTill(playerid,key))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You are too far from your business");
        return 1;
    }

    new line[96];
    Account_SetCash(playerid,Account_GetCash(playerid) - amount);
    Business_Earn(key,amount);
    format(line,sizeof(line),"  You Have Banked $%d to your till Total: $%d ",amount,Business_GetTill(key));
    SendClientMessage(playerid,COLOR_YELLOW,line);
    return 1;
}
