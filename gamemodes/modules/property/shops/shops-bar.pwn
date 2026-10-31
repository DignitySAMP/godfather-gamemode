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
#define SHOPS_DRINK_COUNT (5)
#define SHOPS_DRINK_NAME_LEN (12)
#define SHOPS_DRINK_RANGE (30.0)
#define SHOPS_DRINK_SWERVE (25.0)

enum E_SHOPS_DRINK
{
    E_SHOPS_DRINK_NAME[SHOPS_DRINK_NAME_LEN],
    E_SHOPS_DRINK_PRICE,
    E_SHOPS_DRINK_AGE,
    E_SHOPS_DRINK_DRUNK,
    E_SHOPS_DRINK_HEAL,
    bool:E_SHOPS_DRINK_ALCOHOL
}

static const s_ShopsDrinks[SHOPS_DRINK_COUNT][E_SHOPS_DRINK] =
{
    {"beer", 6, 16, 1, 15, true},
    {"vodka", 10, 18, 2, 25, true},
    {"whiskey", 10, 18, 3, 27, true},
    {"water", 2, 0, 0, 5, false},
    {"soda", 2, 0, 0, 5, false}
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
static Shops_FindDrink(const name[])
{
    for (new i = 0;i < SHOPS_DRINK_COUNT;i++)
    {
        if (strcmp(name,s_ShopsDrinks[i][E_SHOPS_DRINK_NAME],true) == 0)
        {
            return i;
        }
    }

    return -1;
}

static Shops_Drink(playerid,drink,const typed[])
{
    new price = s_ShopsDrinks[drink][E_SHOPS_DRINK_PRICE], heal = s_ShopsDrinks[drink][E_SHOPS_DRINK_HEAL];
    new perk = Progress_GetPerk(playerid,PROGRESS_PERK_ALCOHOL), Float:health;
    Account_SetCash(playerid,Account_GetCash(playerid) - price);
    Shops_SetDrunk(playerid,Shops_GetDrunk(playerid) + s_ShopsDrinks[drink][E_SHOPS_DRINK_DRUNK]);

    if (Shops_GetDrunk(playerid) >= SHOPS_DRUNK_EFFECT_LEVEL)
    {
        Property_GameText(playerid,"~w~You are~n~~p~Drunk",3500,1);
    }

    GetPlayerHealth(playerid,health);

    if (health < 100.0)
    {
        if (perk > 0)
        {
            if (s_ShopsDrinks[drink][E_SHOPS_DRINK_ALCOHOL])
            {
                Shops_SetDrunk(playerid,Shops_GetDrunk(playerid) + 1);
            }

            SetPlayerHealth(playerid,health + float(2 * perk + heal));
        }
        else
        {
            SetPlayerHealth(playerid,health + float(heal));
        }
    }

    new name[BUSINESS_NAME_LEN], line[128];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"* %s drinks a %s.",name,typed);
    Chat_ProxDetector(SHOPS_DRINK_RANGE,playerid,line,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
}

static Shops_DrunkSecond(playerid)
{
    if (Shops_GetDrunk(playerid) < SHOPS_DRUNK_EFFECT_LEVEL)
    {
        return;
    }

    Shops_SetDrunkTime(playerid,Shops_GetDrunkTime(playerid) + 1);

    if (Shops_GetDrunkTime(playerid) != SHOPS_DRUNK_EFFECT_SECONDS)
    {
        return;
    }

    Shops_SetDrunkTime(playerid,0);

    new Float:angle;
    GetPlayerFacingAngle(playerid,angle);

    if (IsPlayerInAnyVehicle(playerid))
    {
        if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            SetVehicleZAngle(GetPlayerVehicleID(playerid),angle + SHOPS_DRINK_SWERVE);
        }
    }
    else
    {
        ApplyAnimation(playerid,"PED","WALK_DRUNK",4.0,false,true,false,false,0);
    }
}

static Shops_SoberUp()
{
    foreach (new playerid : Player)
    {
        if (IsPlayerNPC(playerid) || Shops_GetDrunk(playerid) <= 0)
        {
            continue;
        }

        Shops_ResetDrunk(playerid);
        Property_GameText(playerid,"~p~Drunk effect~n~~w~Gone",3500,1);
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
CMD:drink(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!IsAtBar(playerid) && Business_GetTypedAt(playerid,BUSINESS_TYPE_BAR) == BUSINESS_NO_KEY)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You are not at a Bar !");
        return 1;
    }

    if (Shops_GetDrunk(playerid) >= SHOPS_DRUNK_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You can't drink anymore, you will throw up !");
        return 1;
    }

    new typed[32];

    if (sscanf(params,"s[32]",typed))
    {
        SendClientMessage(playerid,COLOR_WHITE,"|__________________ Bar Drinks __________________|");
        SendClientMessage(playerid,COLOR_WHITE,"USAGE: /drink [drinkname]");
        SendClientMessage(playerid,COLOR_GREY,"Available names: Beer ($6), Vodka ($10), Whiskey ($10), Water ($2), Soda($2)");
        SendClientMessage(playerid,COLOR_WHITE,"|________________________________________________|");
        return 1;
    }

    new drink = Shops_FindDrink(typed);

    if (drink == -1)
    {
        SendClientMessage(playerid,COLOR_WHITE,"Bartender: I don't know that Drink Name.");
        return 1;
    }

    if (Account_GetAge(playerid) < s_ShopsDrinks[drink][E_SHOPS_DRINK_AGE])
    {
        new line[96];
        format(line,sizeof(line),"Bartender: Sorry, you need to be %d years to get this drink.",s_ShopsDrinks[drink][E_SHOPS_DRINK_AGE]);
        SendClientMessage(playerid,COLOR_WHITE,line);
        return 1;
    }

    if (Account_GetCash(playerid) < s_ShopsDrinks[drink][E_SHOPS_DRINK_PRICE])
    {
        SendClientMessage(playerid,COLOR_WHITE,"   You don't have the cash for that !");
        return 1;
    }

    Shops_Drink(playerid,drink,typed);
    return 1;
}

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
Timer_Declare(Shops_DrunkTimer)
{
    Shops_SoberUp();
    return true;
}

/**
 *     __                            __
 *    |  \                          |  |
 *    | $$____    ______    ______  | $$   __   _______
 *    | $$    \  /      \  /      \ | $$  /  \ /       |
 *    | $$$$$$$\|  $$$$$$\|  $$$$$$\| $$_/  $$|  $$$$$$$
 *    | $$  | $$| $$  | $$| $$  | $$| $$   $$  \$$    |
 *    | $$  | $$| $$__/ $$| $$__/ $$| $$$$$$\  _\$$$$$$|
 *    | $$  | $$ \$$    $$ \$$    $$| $$  \$$\|       $$
 *     \$$   \$$  \$$$$$$   \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
#include <pp-hooks>

hook OnPlayerConnect(playerid)
{
    Shops_ResetDrunk(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Shops_ResetDrunk(playerid);
}

hook Tick_OnPlayerSecond(playerid)
{
    if (Player_IsReady(playerid))
    {
        Shops_DrunkSecond(playerid);
    }
}
