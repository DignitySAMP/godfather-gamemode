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
#define HOUSE_BUY_RADIUS (2.0)
#define HOUSE_WITHDRAW_RADIUS (100.0)
#define HOUSE_RENT_MAX (99999)
#define HOUSE_SOLD_SOUND (1052)
#define HOUSE_UPGRADE_HEALTH (1)
#define HOUSE_UPGRADE_ARMOUR (2)
#define HOUSE_UPGRADE_TV (3)
#define HOUSE_UPGRADE_HEALTH_PRICE (50000)
#define HOUSE_UPGRADE_ARMOUR_PRICE (100000)
#define HOUSE_UPGRADE_TV_PRICE (500)
#define HOUSE_UPGRADE_HEALTH_LEVEL (5)
#define HOUSE_UPGRADE_ARMOUR_LEVEL (7)
#define HOUSE_UPGRADE_TV_LEVEL (3)

forward Houses_OnUpgradeBought(playerid,house,item,price);

static Houses_Welcome(playerid,house)
{
    Houses_Place(playerid,house);
    Property_GameText(playerid,"~w~Welcome Home~n~You can exit at any time by moving to this door and typing /exit",5000,3);
}

static Houses_PayForUpgrade(playerid,house,item,price)
{
    Account_SetCash(playerid,Account_GetCash(playerid) - price);
    PlayerPlaySound(playerid,HOUSE_SOLD_SOUND,0.0,0.0,0.0);
    pawn_call_public("Houses_OnUpgradeBought","dddd",playerid,house,item,price);
}

CMD:buyhouse(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    for (new house = 0,count = Houses_GetCount();house < count;house++)
    {
        if (!Houses_IsValid(house) || Houses_IsOwned(house) || !Houses_IsNearEntrance(playerid,house,HOUSE_BUY_RADIUS))
        {
            continue;
        }

        new line[96];

        if (Account_GetLevel(playerid) < Houses_GetLevel(house))
        {
            format(line,sizeof(line),"   You must be Level %d to purchase this !",Houses_GetLevel(house));
            SendClientMessage(playerid,COLOR_GRAD5,line);
            return 1;
        }

        new key = Houses_GetKey(playerid);

        if (key != HOUSE_NO_KEY && Houses_IsOwner(playerid,key))
        {
            SendClientMessage(playerid,COLOR_WHITE,"   You already own a house, type /sellhouse if you want to buy this one !");
            return 1;
        }

        if (Account_GetCash(playerid) < Houses_GetPrice(house))
        {
            SendClientMessage(playerid,COLOR_WHITE,"   You don't have the cash for that !");
            return 1;
        }

        new name[HOUSE_NAME_LEN];
        Property_GetPlayerName(playerid,name);
        Houses_SetKey(playerid,house);
        Houses_Claim(house,name);
        Account_SetCash(playerid,Account_GetCash(playerid) - Houses_GetPrice(house));
        Misc_PlayMusic(playerid);
        Houses_Welcome(playerid,house);
        SendClientMessage(playerid,COLOR_WHITE,"Congratulations, on your new Purchase !");
        SendClientMessage(playerid,COLOR_WHITE,"Type /help to review the new property help section !");
        Houses_TouchOwned(playerid);
        return 1;
    }

    return 1;
}

CMD:rentroom(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    for (new house = 0,count = Houses_GetCount();house < count;house++)
    {
        if (!Houses_IsOwned(house) || !Houses_IsRentable(house) || !Houses_IsNearEntrance(playerid,house,HOUSE_BUY_RADIUS))
        {
            continue;
        }

        new key = Houses_GetKey(playerid);

        if (key != HOUSE_NO_KEY && Houses_IsOwner(playerid,key))
        {
            SendClientMessage(playerid,COLOR_WHITE,"   You already own a house, type /sellhouse if you want to rent this one.");
            return 1;
        }

        if (Account_GetCash(playerid) < Houses_GetRent(house))
        {
            SendClientMessage(playerid,COLOR_WHITE,"You don't have the cash for that");
            return 1;
        }

        Houses_SetKey(playerid,house);
        Account_SetCash(playerid,Account_GetCash(playerid) - Houses_GetRent(house));
        Houses_AddTakings(house,Houses_GetRent(house));
        Misc_PlayMusic(playerid);
        Houses_Welcome(playerid,house);
        SendClientMessage(playerid,COLOR_WHITE,"Congratulations, You can enter and exit here anytime.");
        SendClientMessage(playerid,COLOR_WHITE,"Type /help to review the new property help section.");
        return 1;
    }

    return 1;
}

CMD:unrent(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new key = Houses_GetKey(playerid);

    if (key != HOUSE_NO_KEY && Houses_IsOwner(playerid,key))
    {
        SendClientMessage(playerid,COLOR_WHITE,"   You own this house !");
        return 1;
    }

    Houses_SetKey(playerid,HOUSE_NO_KEY);
    SendClientMessage(playerid,COLOR_WHITE,"You are now homeless.");
    return 1;
}

CMD:housewithdraw(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new house = Houses_GetOwnedHouse(playerid);

    if (house == HOUSE_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_WHITE,"You don't own a house.");
        return 1;
    }

    new line[96], amountText[16];

    if (sscanf(params,"s[16]",amountText))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /housewithdraw [amount]");
        format(line,sizeof(line),"  You Have $%d in your cashbox.",Houses_GetTakings(house));
        SendClientMessage(playerid,COLOR_GRAD3,line);
        return 1;
    }

    new amount = strval(amountText);

    if (amount > Houses_GetTakings(house) || amount < 1)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't have that much !");
        return 1;
    }

    if (!Houses_IsNearExit(playerid,house,HOUSE_WITHDRAW_RADIUS))
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You are too far from your house !");
        return 1;
    }

    Account_SetCash(playerid,Account_GetCash(playerid) + amount);
    Houses_AddTakings(house,-amount);
    format(line,sizeof(line),"  You Have Withdrawn $%d from your cashbox Total: $%d ",amount,Houses_GetTakings(house));
    SendClientMessage(playerid,COLOR_YELLOW,line);
    return 1;
}

CMD:sellhouse(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new house = Houses_GetKey(playerid);

    if (house == HOUSE_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_WHITE,"You don't own a house.");
        return 1;
    }

    if (Houses_CheckPredicate(HOUSE_PREDICATE_IS_MARRIED,playerid,false))
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are Married, can't sell the House !");
        return 1;
    }

    if (!Houses_IsOwner(playerid,house))
    {
        SendClientMessage(playerid,COLOR_WHITE,"You don't own a house.");
        return 1;
    }

    new line[96];
    Houses_Release(house);
    Account_SetCash(playerid,Account_GetCash(playerid) + Houses_GetPrice(house));
    PlayerPlaySound(playerid,HOUSE_SOLD_SOUND,0.0,0.0,0.0);
    format(line,sizeof(line),"~w~Congratulations~n~ You have sold your property for ~n~~g~$%d",Houses_GetPrice(house));
    Property_GameText(playerid,line,10000,3);
    Houses_SetKey(playerid,HOUSE_NO_KEY);

    if (Account_GetLocal(playerid) == Houses_GetLocal(house))
    {
        new Float:x, Float:y, Float:z;
        Houses_GetEntrance(house,x,y,z);
        SetPlayerInterior(playerid,0);
        Doors_ResetWorld(playerid);
        SetPlayerPos(playerid,x,y,z);
        Account_SetInterior(playerid,0);
    }

    return 1;
}

CMD:houseupgrade(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new house = Houses_GetOwnedHouse(playerid);

    if (house == HOUSE_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't own a house");
        return 1;
    }

    new itemText[16];

    if (sscanf(params,"s[16]",itemText))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /houseupgrade [item number]");
        SendClientMessage(playerid,COLOR_GRAD1,"|_______ Home Supplies _______|");
        SendClientMessage(playerid,COLOR_GRAD2,"| 1: Health Upgrade $50000");
        SendClientMessage(playerid,COLOR_GRAD3,"| 2: Armour Upgrade $100000");
        SendClientMessage(playerid,COLOR_GRAD5,"| 3: TV $500");
        return 1;
    }

    switch (strval(itemText))
    {
        case HOUSE_UPGRADE_HEALTH:
        {
            if (!Houses_CheckPredicate(HOUSE_PREDICATE_UPGRADE_STOCK,playerid,true))
            {
                Property_GameText(playerid,"~r~Out Of Stock",5000,1);
                return 1;
            }

            if (Account_GetLevel(playerid) < HOUSE_UPGRADE_HEALTH_LEVEL)
            {
                SendClientMessage(playerid,COLOR_GRAD5,"You Must Be Level 5 To Purchase This");
                return 1;
            }

            if (Account_GetCash(playerid) < HOUSE_UPGRADE_HEALTH_PRICE)
            {
                SendClientMessage(playerid,COLOR_GRAD5,"You Don't Have The Cash To Purchase This");
                return 1;
            }

            Houses_SetHealthUpgrade(house,true);
            Houses_PayForUpgrade(playerid,house,HOUSE_UPGRADE_HEALTH,HOUSE_UPGRADE_HEALTH_PRICE);
            SendClientMessage(playerid,COLOR_GRAD5,"You Can Now Heal Yourself At Home, Type /heal.");
        }
        case HOUSE_UPGRADE_ARMOUR:
        {
            if (!Houses_CheckPredicate(HOUSE_PREDICATE_IS_COP,playerid,false))
            {
                SendClientMessage(playerid,COLOR_GREY,"   You can't buy this, you are not a Cop !");
                return 1;
            }

            if (!Houses_CheckPredicate(HOUSE_PREDICATE_UPGRADE_STOCK,playerid,true))
            {
                Property_GameText(playerid,"~r~Out Of Stock",5000,1);
                return 1;
            }

            if (Account_GetLevel(playerid) < HOUSE_UPGRADE_ARMOUR_LEVEL)
            {
                SendClientMessage(playerid,COLOR_GRAD5,"You Must Be Level 7 To Purchase This");
                return 1;
            }

            if (Account_GetCash(playerid) < HOUSE_UPGRADE_ARMOUR_PRICE)
            {
                SendClientMessage(playerid,COLOR_GRAD5,"You Don't Have The Cash To Purchase This");
                return 1;
            }

            Houses_SetArmourUpgrade(house,true);
            Houses_PayForUpgrade(playerid,house,HOUSE_UPGRADE_ARMOUR,HOUSE_UPGRADE_ARMOUR_PRICE);
            SendClientMessage(playerid,COLOR_GRAD5,"You Can Now Get Armour At Home, Type /heal.");
        }
        case HOUSE_UPGRADE_TV:
        {
            if (!Houses_CheckPredicate(HOUSE_PREDICATE_UPGRADE_STOCK,playerid,true))
            {
                Property_GameText(playerid,"~r~Out Of Stock",5000,1);
                return 1;
            }

            if (Account_GetLevel(playerid) < HOUSE_UPGRADE_TV_LEVEL)
            {
                SendClientMessage(playerid,COLOR_GRAD5,"You Must Be Level 3 To Purchase This");
                return 1;
            }

            if (Account_GetCash(playerid) < HOUSE_UPGRADE_TV_PRICE)
            {
                SendClientMessage(playerid,COLOR_GRAD5,"You Don't Have The Cash To Purchase This");
                return 1;
            }

            Houses_SetTv(house,true);
            Houses_PayForUpgrade(playerid,house,HOUSE_UPGRADE_TV,HOUSE_UPGRADE_TV_PRICE);
            SendClientMessage(playerid,COLOR_GRAD5,"You can now use your TV set, type /tv.");
        }
    }

    return 1;
}

ALT:hu=CMD:houseupgrade;

CMD:setrent(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new house = Houses_GetOwnedHouse(playerid);

    if (house == HOUSE_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't own a house");
        return 1;
    }

    new rentText[16];

    if (sscanf(params,"s[16]",rentText))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /setrent [RentFee]");
        return 1;
    }

    new rent = strval(rentText);

    if (rent < 1 || rent > HOUSE_RENT_MAX)
    {
        SendClientMessage(playerid,COLOR_WHITE,"Minimum rent is $1, Maximum rent is $99999.");
        return 1;
    }

    Houses_SetRent(house,rent);

    new line[64];
    format(line,sizeof(line),"House rent set to $%d",rent);
    SendClientMessage(playerid,COLOR_WHITE,line);
    return 1;
}

CMD:evictall(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new house = Houses_GetOwnedHouse(playerid);

    if (house == HOUSE_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't own a house !");
        return 1;
    }

    new evicted = 0;

    foreach (new tenant : Player)
    {
        if (tenant != playerid && Houses_GetKey(tenant) == house)
        {
            SendClientMessage(tenant,COLOR_WHITE,"You have been evicted from your house.");
            Houses_SetKey(tenant,HOUSE_NO_KEY);
            evicted++;
        }
    }

    mysql_tquery_s(g_Mysql,str_format("UPDATE house_keys SET house_key = %d WHERE house_key = %d AND account_id <> %d",HOUSE_NO_KEY,house,Account_GetId(playerid)));

    if (evicted > 0)
    {
        SendClientMessage(playerid,COLOR_WHITE,"Everyone have been evicted.");
    }

    return 1;
}

CMD:evict(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new house = Houses_GetOwnedHouse(playerid);

    if (house == HOUSE_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't own a house !");
        return 1;
    }

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /evict [playerid/PartOfName]");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(targetid,COLOR_WHITE,"You can't evict yourself.");
        return 1;
    }

    if (targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid))
    {
        return 1;
    }

    if (Houses_GetKey(targetid) == house)
    {
        SendClientMessage(targetid,COLOR_WHITE,"You have been evicted");
        SendClientMessage(playerid,COLOR_WHITE,"Player has been evicted");
        Houses_SetKey(targetid,HOUSE_NO_KEY);
    }
    else
    {
        SendClientMessage(playerid,COLOR_WHITE,"Player doesn't rent at your House !");
    }

    return 1;
}

CMD:setrentable(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new house = Houses_GetOwnedHouse(playerid);

    if (house == HOUSE_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GRAD2,"   You don't own a house !");
        return 1;
    }

    new valueText[16];

    if (sscanf(params,"s[16]",valueText))
    {
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /setrentable [0/1]");
        return 1;
    }

    new value = strval(valueText);
    Houses_SetRentable(house,value);

    new line[64];
    format(line,sizeof(line),"House rentable set to %d.",value);
    SendClientMessage(playerid,COLOR_WHITE,line);
    return 1;
}

CMD:home(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new house = Houses_GetKey(playerid);

    if (house == HOUSE_NO_KEY)
    {
        Property_GameText(playerid,"~w~You are homeless",5000,1);
        return 1;
    }

    if (Houses_CheckPredicate(HOUSE_PREDICATE_ON_MISSION,playerid,false))
    {
        SendClientMessage(playerid,COLOR_GREY,"   On a mission right now, can't use this command !");
        return 1;
    }

    new Float:x, Float:y, Float:z;
    Houses_GetEntrance(house,x,y,z);
    SetPlayerCheckpoint(playerid,x,y,z,HOUSE_HOME_RADIUS);
    Property_GameText(playerid,"~w~Waypoint set ~r~Home",5000,1);
    Houses_SetHomeWaypoint(playerid,true);
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
public Houses_OnUpgradeBought(playerid,house,item,price)
{
    return 1;
}
