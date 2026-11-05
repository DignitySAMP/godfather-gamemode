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
#define SELL_NAME_LEN (16)
#define SELL_CALLBACK_LEN (32)
#define SELL_REST_LEN (128)

static Map:s_SellOptions;

forward Fishing_SellFish(playerid,const params[]);

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
static bool:Sell_Key(const name[],dest[SELL_NAME_LEN])
{
    if (name[0] == EOS || strlen(name) >= SELL_NAME_LEN)
    {
        dest[0] = EOS;
        return false;
    }

    strcopy(dest,name,SELL_NAME_LEN);

    for (new i = 0;dest[i] != EOS;i++)
    {
        dest[i] = tolower(dest[i]);
    }

    return true;
}

static bool:Sell_Find(const name[],dest[],size = sizeof(dest))
{
    new key[SELL_NAME_LEN];
    dest[0] = EOS;

    if (!map_valid(s_SellOptions) || !Sell_Key(name,key) || !map_has_str_key(s_SellOptions,key))
    {
        return false;
    }

    map_str_get_str(s_SellOptions,key,dest,size);
    return true;
}

stock bool:Sell_Register(const name[],const callback[])
{
    if (name[0] == EOS || strlen(name) >= SELL_NAME_LEN)
    {
        return false;
    }

    if (!pawn_public_exists(callback))
    {
        Log_Error("fishing","sell callback %s is not a public, %s is not registered",callback,name);
        return false;
    }

    new key[SELL_NAME_LEN], stored[SELL_CALLBACK_LEN];
    Sell_Key(name,key);
    strcopy(stored,callback,SELL_CALLBACK_LEN);

    if (!map_valid(s_SellOptions))
    {
        s_SellOptions = map_new();
    }

    map_str_remove(s_SellOptions,key);
    map_str_add_str(s_SellOptions,key,stored);
    return true;
}

static bool:Sell_Run(playerid,const name[],const rest[])
{
    new callback[SELL_CALLBACK_LEN];

    if (!Sell_Find(name,callback))
    {
        return false;
    }

    pawn_call_public(callback,"ds",playerid,rest);
    return true;
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
CMD:sell(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new name[32], rest[SELL_REST_LEN];

    if (sscanf(params,"s[32]S()[128]",name,rest))
    {
        SendClientMessage(playerid,COLOR_WHITE,"|__________________ Selling __________________|");
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /sell [name]");
        SendClientMessage(playerid,COLOR_GREY,"Available names: Fish, Cooked");
        SendClientMessage(playerid,COLOR_WHITE,"|_____________________________________________|");
        return 1;
    }

    if (!Sell_Run(playerid,name,rest))
    {
        SendClientMessage(playerid,COLOR_GREY,"   Unknown Selling Name !");
    }

    return 1;
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
public Fishing_SellFish(playerid,const params[])
{
    if (!Property_IsNear(playerid,SHOPS_STORE_RADIUS,SHOPS_STORE_X,SHOPS_STORE_Y,SHOPS_STORE_Z))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You are not in a 24-7 !");
        return 1;
    }

    new numberText[16];

    if (sscanf(params,"s[16]",numberText))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /sell fish [fish]");
        return 1;
    }

    new number = strval(numberText), line[FISHING_LINE_LEN];

    if (number < 1 || number > FISHING_SLOTS)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Fish number can't be below 1 or above 5 !");
        return 1;
    }

    new weight = Fishing_GetWeight(playerid,number);

    if (weight < 1)
    {
        format(line,sizeof(line),"   You didn't even catch a Fish at that number(%d) !",number);
        SendClientMessage(playerid,COLOR_GREY,line);
        return 1;
    }

    if (weight < FISHING_MIN_SELL_WEIGHT)
    {
        SendClientMessage(playerid,COLOR_WHITE,"We are only interested in Fishes weighing 20 LBS or more.");
        return 1;
    }

    new price = Fishing_GetPrice(Fishing_GetFishId(playerid,number)) * weight, name[FISHING_NAME_LEN];

    if (Progress_GetPerk(playerid,PROGRESS_PERK_TRADER) > 0)
    {
        price += (price / 100) * FISHING_TRADER_PERCENT;
    }

    Fishing_GetName(playerid,number,name);
    Property_GameText(playerid,"~g~Fish~n~~r~Sold",3000,1);
    format(line,sizeof(line),"* You have sold your %s that weighs %d, for $%d.",name,weight,price);
    SendClientMessage(playerid,COLOR_LIGHTBLUE,line);
    Account_SetCash(playerid,Account_GetCash(playerid) + price);
    Fishing_ClearSlot(playerid,number);
    Fishing_ClearLast(playerid);
    return 1;
}
