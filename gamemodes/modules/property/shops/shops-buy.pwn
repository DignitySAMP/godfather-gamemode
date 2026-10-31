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
#define SHOPS_ITEM_PHONE (1)
#define SHOPS_ITEM_SCRATCH (2)
#define SHOPS_ITEM_PHONE_BOOK (3)
#define SHOPS_ITEM_DICE (4)
#define SHOPS_ITEM_KEY (5)
#define SHOPS_ITEM_LOCK (6)
#define SHOPS_ITEM_SPEEDOMETER (7)
#define SHOPS_ITEM_CONDOM (8)
#define SHOPS_ITEM_CD_PLAYER (9)
#define SHOPS_ITEM_CHICKEN (10)
#define SHOPS_ITEM_HAMBURGER (11)
#define SHOPS_ITEM_PIZZA (12)
#define SHOPS_ITEM_COUNT (12)
#define SHOPS_NO_HIRE (0)
#define SHOPS_GROCERY_MAX (3)
#define SHOPS_GROCERY_RANDOM (15)
#define SHOPS_PHONE_MIN (1000)
#define SHOPS_PHONE_RANGE (8999)
#define SHOPS_SCRATCH_SYMBOLS (10)
#define SHOPS_SCRATCH_PRIZE_GREEN (1500)
#define SHOPS_SCRATCH_PRIZE_BLUE (500)

static s_ShopsStoreKey = SHOPS_STORE_KEY;

static const s_ShopsItemCashAbove[SHOPS_ITEM_COUNT + 1] =
{
    0, 500, 7500, 5000, 500, 5000, 10000, 5000, 49, 2500, 10, 10, 10
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
static Shops_Charge(playerid,price,bool:toTill)
{
    new payout = Shops_PerkPrice(playerid,price), line[32];
    Account_SetCash(playerid,Account_GetCash(playerid) - payout);

    if (toTill)
    {
        Business_Earn(s_ShopsStoreKey,payout);
    }

    format(line,sizeof(line),"~r~-$%d",payout);
    Property_GameText(playerid,line,5000,1);
    return payout;
}

static Shops_ScratchClass(roll)
{
    if (roll >= 5)
    {
        return 1;
    }

    if (roll >= 2)
    {
        return 2;
    }

    return 3;
}

static Shops_ScratchSymbol(class,symbol[],size = sizeof(symbol))
{
    switch (class)
    {
        case 1:
        {
            format(symbol,size,"~b~]");
        }
        case 2:
        {
            format(symbol,size,"~g~]");
        }
        default:
        {
            format(symbol,size,"~y~]");
        }
    }
}

static Shops_BuyPhone(playerid)
{
    Shops_Charge(playerid,500,true);
    PlayerPlaySound(playerid,SHOPS_SOUND_PAID,0.0,0.0,0.0);

    new number = SHOPS_PHONE_MIN + random(SHOPS_PHONE_RANGE), line[96];
    format(line,sizeof(line),"   Mobile Phone Purchased your new Number is %d",number);
    SendClientMessage(playerid,COLOR_GRAD4,line);
    SendClientMessage(playerid,COLOR_GRAD5,"You can check this anytime by Typing /stats");
    SendClientMessage(playerid,COLOR_WHITE,"HINT: You can now type /help to see your cell phone commands.");
    pawn_call_public("Shops_OnPhoneBought","dd",playerid,number);
}

static Shops_BuyScratch(playerid)
{
    Shops_Charge(playerid,7500,true);
    PlayerPlaySound(playerid,SHOPS_SOUND_PAID,0.0,0.0,0.0);

    new first = Shops_ScratchClass(random(SHOPS_SCRATCH_SYMBOLS)), second = Shops_ScratchClass(random(SHOPS_SCRATCH_SYMBOLS)), third = Shops_ScratchClass(random(SHOPS_SCRATCH_SYMBOLS));
    new symbolOne[32], symbolTwo[32], symbolThree[32], line[96];
    Shops_ScratchSymbol(first,symbolOne);
    Shops_ScratchSymbol(second,symbolTwo);
    Shops_ScratchSymbol(third,symbolThree);

    if (first == second && first == third)
    {
        new prize = 0;

        if (first == 2)
        {
            prize = SHOPS_SCRATCH_PRIZE_GREEN;
        }
        else if (first == 1)
        {
            prize = SHOPS_SCRATCH_PRIZE_BLUE;
        }

        Account_SetCash(playerid,Account_GetCash(playerid) + prize);
        Business_AddTill(s_ShopsStoreKey,-prize);
        Business_Extort(s_ShopsStoreKey,prize);
        format(line,sizeof(line),"%s %s %s ~n~~n~~w~~g~$%d",symbolOne,symbolTwo,symbolThree,prize);
    }
    else
    {
        format(line,sizeof(line),"%s %s %s ~n~~n~~w~~r~$0",symbolOne,symbolTwo,symbolThree);
    }

    Property_GameText(playerid,line,3000,3);
}

static Shops_BuyPhoneBook(playerid)
{
    Shops_Charge(playerid,5000,true);
    PlayerPlaySound(playerid,SHOPS_SOUND_PAID,0.0,0.0,0.0);
    SendClientMessage(playerid,COLOR_GRAD4,"   Phone Book Purchased you can look up any Players Number !");
    SendClientMessage(playerid,COLOR_WHITE,"HINT: Type /number <id/name>.");
    pawn_call_public("Shops_OnPhoneBookBought","d",playerid);
}

static Shops_BuyDice(playerid)
{
    Shops_Charge(playerid,500,true);
    PlayerPlaySound(playerid,SHOPS_SOUND_PAID,0.0,0.0,0.0);
    Misc_SetHasDice(playerid,true);
    SendClientMessage(playerid,COLOR_GRAD4,"   Dice Purchased you can throw your Dice.");
    SendClientMessage(playerid,COLOR_WHITE,"HINT: Type /dice ");
}

static Shops_BuyKey(playerid)
{
    new lastCar = Vehicles_GetLastCar(playerid);

    if (lastCar == 0)
    {
        SendClientMessage(playerid,COLOR_WHITE,"   You don't have a Vehicle to fit it to !");
        return;
    }

    new hireCar = Vehicles_GetHireCar(playerid);

    if (hireCar != SHOPS_NO_HIRE)
    {
        Vehicles_ReleaseLock(hireCar);
        Vehicles_ClearHireCar(playerid);
    }

    Shops_Charge(playerid,5000,true);
    Business_UseProduct(s_ShopsStoreKey);
    PlayerPlaySound(playerid,SHOPS_SOUND_PAID,0.0,0.0,0.0);
    Vehicles_SetHireCar(playerid,lastCar);
    SendClientMessage(playerid,COLOR_GRAD4,"Key Purchased You Can Lock Your Last Vehicle.");
    SendClientMessage(playerid,COLOR_WHITE,"HINT: Type /lock ");
}

static Shops_BuyLock(playerid)
{
    new house = Houses_GetKey(playerid);

    if (house == HOUSE_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_WHITE,"   You don't have a Vehicle to fit it to !");
        return;
    }

    Vehicles_ClearKeysTo(Vehicles_GetHouseCar(house));
    Shops_Charge(playerid,10000,true);
    Business_UseProduct(s_ShopsStoreKey);
    PlayerPlaySound(playerid,SHOPS_SOUND_PAID,0.0,0.0,0.0);
    SendClientMessage(playerid,COLOR_GRAD4,"New Locks Purchased.");
    SendClientMessage(playerid,COLOR_WHITE,"HINT: Type /lock ");
}

static Shops_BuySpeedometer(playerid)
{
    Fuel_SetSpeedometer(playerid,1);
    Shops_Charge(playerid,5000,true);
    Business_UseProduct(s_ShopsStoreKey);
    PlayerPlaySound(playerid,SHOPS_SOUND_PAID,0.0,0.0,0.0);
    SendClientMessage(playerid,COLOR_GRAD4,"Speedometer Purchased.");
    SendClientMessage(playerid,COLOR_WHITE,"HINT: Type /speedo ");
}

static Shops_BuyCondom(playerid)
{
    Shops_Charge(playerid,50,false);
    PlayerPlaySound(playerid,SHOPS_SOUND_PAID,0.0,0.0,0.0);
    SendClientMessage(playerid,COLOR_GRAD4,"Condom Purchased.");
    pawn_call_public("Shops_OnCondomBought","d",playerid);
}

static Shops_BuyCdPlayer(playerid)
{
    Shops_Charge(playerid,2500,false);
    PlayerPlaySound(playerid,SHOPS_SOUND_PAID,0.0,0.0,0.0);
    SendClientMessage(playerid,COLOR_GRAD4,"CD-Player Purchased.");
    SendClientMessage(playerid,COLOR_WHITE,"HINT: Type /music");
    pawn_call_public("Shops_OnCdPlayerBought","d",playerid);
}

static Shops_BuyGrocery(playerid,kind,provider,const full[],const bought[])
{
    if (Shops_Query(provider,playerid,0) >= SHOPS_GROCERY_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,full);
        return;
    }

    Shops_Charge(playerid,10,false);
    PlayerPlaySound(playerid,SHOPS_SOUND_PAID,0.0,0.0,0.0);
    SendClientMessage(playerid,COLOR_GRAD4,bought);
    pawn_call_public("Shops_OnGroceryBought","ddd",playerid,kind,random(SHOPS_GROCERY_RANDOM));
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
CMD:buy(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new typedStore = Business_GetTypedAt(playerid,BUSINESS_TYPE_247);

    if (typedStore == BUSINESS_NO_KEY && !Property_IsNear(playerid,SHOPS_STORE_RADIUS,SHOPS_STORE_X,SHOPS_STORE_Y,SHOPS_STORE_Z))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You are not in a 24-7 !");
        return 1;
    }

    s_ShopsStoreKey = typedStore != BUSINESS_NO_KEY ? typedStore : SHOPS_STORE_KEY;

    new itemText[16];

    if (sscanf(params,"s[16]",itemText))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /buy [item number]");
        SendClientMessage(playerid,COLOR_GREEN,"|_______ 24-7 _______|");
        SendClientMessage(playerid,COLOR_GRAD1,"| 1: Cell Phone $500			2: Scratch Card $7500");
        SendClientMessage(playerid,COLOR_GRAD2,"| 3: Phone Book $5000			4: Dice $500");
        SendClientMessage(playerid,COLOR_GRAD3,"| 5: Vehicle Key $5000		6: Vehicle Lock $10000");
        SendClientMessage(playerid,COLOR_GRAD4,"| 7: Speedometer $5000		8: Condom $50");
        SendClientMessage(playerid,COLOR_GRAD5,"| 9: CD-Player $2500			10: Chicken $10	");
        SendClientMessage(playerid,COLOR_GRAD5,"| 11: Hamburger $10			12: Frozen Pizza $10");
        return 1;
    }

    new item = strval(itemText);

    if (!Business_IsFreeStock(s_ShopsStoreKey) && Business_GetProducts(s_ShopsStoreKey) == 0)
    {
        Property_GameText(playerid,"~r~Out Of Stock",5000,1);
        return 1;
    }

    if (item < 1 || item > SHOPS_ITEM_COUNT || Account_GetCash(playerid) <= s_ShopsItemCashAbove[item])
    {
        SendClientMessage(playerid,COLOR_WHITE,"   You don't have the cash for that !");
        return 1;
    }

    switch (item)
    {
        case SHOPS_ITEM_PHONE:
        {
            Shops_BuyPhone(playerid);
        }
        case SHOPS_ITEM_SCRATCH:
        {
            Shops_BuyScratch(playerid);
        }
        case SHOPS_ITEM_PHONE_BOOK:
        {
            Shops_BuyPhoneBook(playerid);
        }
        case SHOPS_ITEM_DICE:
        {
            Shops_BuyDice(playerid);
        }
        case SHOPS_ITEM_KEY:
        {
            Shops_BuyKey(playerid);
        }
        case SHOPS_ITEM_LOCK:
        {
            Shops_BuyLock(playerid);
        }
        case SHOPS_ITEM_SPEEDOMETER:
        {
            Shops_BuySpeedometer(playerid);
        }
        case SHOPS_ITEM_CONDOM:
        {
            Shops_BuyCondom(playerid);
        }
        case SHOPS_ITEM_CD_PLAYER:
        {
            Shops_BuyCdPlayer(playerid);
        }
        case SHOPS_ITEM_CHICKEN:
        {
            Shops_BuyGrocery(playerid,SHOPS_GROCERY_CHICKEN,SHOPS_PROVIDER_CHICKENS,"   You have too many Chickens, Cook some first !","Chicken Purchased.");
        }
        case SHOPS_ITEM_HAMBURGER:
        {
            Shops_BuyGrocery(playerid,SHOPS_GROCERY_HAMBURGER,SHOPS_PROVIDER_HAMBURGERS,"   You have too many Hamburgers, Cook some first !","Hamburger Purchased.");
        }
        case SHOPS_ITEM_PIZZA:
        {
            Shops_BuyGrocery(playerid,SHOPS_GROCERY_PIZZA,SHOPS_PROVIDER_PIZZAS,"   You have too many Pizzas, Cook some first !","Frozen Pizza Purchased.");
        }
    }

    return 1;
}
