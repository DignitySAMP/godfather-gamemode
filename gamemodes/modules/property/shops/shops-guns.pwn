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
#define SHOPS_GUN_COUNT (19)
#define SHOPS_GUN_NAME_LEN (16)
#define SHOPS_GUN_PRICES (30)
#define SHOPS_GUN_MOD (100)
#define SHOPS_GUN_AMMO_MIN (1)
#define SHOPS_GUN_AMMO_MAX (999)
#define SHOPS_GUN_NO_AMMO_PRICE (-1)
#define SHOPS_GUN_LOCATION_A (99)
#define SHOPS_GUN_LOCATION_B (100)
#define SHOPS_GUN_LOCATION_ARMOURY (102)

enum E_SHOPS_GUN
{
    E_SHOPS_GUN_NAME[SHOPS_GUN_NAME_LEN],
    E_SHOPS_GUN_WEAPON,
    E_SHOPS_GUN_PRICE,
    E_SHOPS_GUN_AMMO_PRICE,
    E_SHOPS_GUN_SLOT
}

static const s_ShopsGunPrices[SHOPS_GUN_PRICES] =
{
    500, 400, 300, 200, 700, 300, 100, 400, 780, 560, 530, 200, 600,
    500, 1000, 3000, 2000, 3000, 2500, 3000, 6000, 4000, 5000, 5000, 1000,
    25, 40, 25, 40, 50
};

static const s_ShopsGuns[SHOPS_GUN_COUNT][E_SHOPS_GUN] =
{
    {"parachute", 46, 0, SHOPS_GUN_NO_AMMO_PRICE, 0},
    {"golfclub", 2, 1, SHOPS_GUN_NO_AMMO_PRICE, 1},
    {"nightstick", 3, 2, SHOPS_GUN_NO_AMMO_PRICE, 1},
    {"baseballbat", 5, 4, SHOPS_GUN_NO_AMMO_PRICE, 1},
    {"shovel", 6, 5, SHOPS_GUN_NO_AMMO_PRICE, 1},
    {"poolcue", 7, 6, SHOPS_GUN_NO_AMMO_PRICE, 1},
    {"purpledildo", 10, 7, SHOPS_GUN_NO_AMMO_PRICE, 1},
    {"whitedildo", 11, 8, SHOPS_GUN_NO_AMMO_PRICE, 1},
    {"longwhitedildo", 12, 9, SHOPS_GUN_NO_AMMO_PRICE, 1},
    {"whitedildo2", 13, 10, SHOPS_GUN_NO_AMMO_PRICE, 1},
    {"flowers", 14, 11, SHOPS_GUN_NO_AMMO_PRICE, 1},
    {"cane", 15, 12, SHOPS_GUN_NO_AMMO_PRICE, 1},
    {"sdpistol", 23, 13, 25, 2},
    {"deagle", 24, 15, 25, 2},
    {"mp5", 29, 18, 27, 3},
    {"shotgun", 25, 19, 26, 3},
    {"ak47", 30, 22, 28, 4},
    {"m4", 31, 23, 28, 4},
    {"rifle", 33, 24, 29, 4}
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
static Shops_ListPrice(const name[])
{
    for (new i = 0;i < SHOPS_GUN_COUNT;i++)
    {
        if (!strcmp(name,s_ShopsGuns[i][E_SHOPS_GUN_NAME],true))
        {
            return s_ShopsGunPrices[s_ShopsGuns[i][E_SHOPS_GUN_PRICE]] / 100 * SHOPS_GUN_MOD;
        }
    }

    return 0;
}

static Shops_ListGuns(playerid)
{
    new line[256];
    SendClientMessage(playerid,COLOR_GREEN,"_______________________________________");
    SendClientMessage(playerid,COLOR_WHITE,"*** Guns & Ammo ***");
    SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /buygun [gunname] [ammoamount]");
    format(line,sizeof(line),"Weapons: parachute ($%d) golfclub ($%d) nightstick ($%d) baseballbat ($%d) shovel ($%d) poolcue ($%d)",Shops_ListPrice("parachute"),Shops_ListPrice("golfclub"),Shops_ListPrice("nightstick"),Shops_ListPrice("baseballbat"),Shops_ListPrice("shovel"),Shops_ListPrice("poolcue"));
    SendClientMessage(playerid,COLOR_GRAD3,line);
    format(line,sizeof(line),"Weapons: purpledildo ($%d) whitedildo ($%d) longwhitedildo ($%d) whitedildo2 ($%d) flowers ($%d) cane",Shops_ListPrice("purpledildo"),Shops_ListPrice("whitedildo"),Shops_ListPrice("longwhitedildo"),Shops_ListPrice("whitedildo2"),Shops_ListPrice("flowers"));
    SendClientMessage(playerid,COLOR_GRAD3,line);
    format(line,sizeof(line),"Weapons: sdpistol ($%d) deagle ($%d) mp5 ($%d)",Shops_ListPrice("sdpistol"),Shops_ListPrice("deagle"),Shops_ListPrice("mp5"));
    SendClientMessage(playerid,COLOR_GRAD3,line);
    format(line,sizeof(line),"Weapons: shotgun ($%d) ak47 ($%d) m4 ($%d) rifle ($%d)",Shops_ListPrice("shotgun"),Shops_ListPrice("ak47"),Shops_ListPrice("m4"),Shops_ListPrice("rifle"));
    SendClientMessage(playerid,COLOR_GRAD3,line);
    format(line,sizeof(line),"Weapons: pistolammo ($%d) shotgunammo ($%d) smgammo ($%d) assaultammo ($%d) rifleammo ($%d)",s_ShopsGunPrices[25],s_ShopsGunPrices[26],s_ShopsGunPrices[27],s_ShopsGunPrices[28],s_ShopsGunPrices[29]);
    SendClientMessage(playerid,COLOR_GRAD3,line);
    SendClientMessage(playerid,COLOR_GREEN,"_______________________________________");
}

static Shops_FindGun(const typed[])
{
    for (new i = 0;i < SHOPS_GUN_COUNT;i++)
    {
        if (strcmp(typed,s_ShopsGuns[i][E_SHOPS_GUN_NAME],true,strlen(typed)) == 0)
        {
            return i;
        }
    }

    return -1;
}

static Shops_StoreGun(playerid,gun,ammo)
{
    new slot = s_ShopsGuns[gun][E_SHOPS_GUN_SLOT];

    if (slot == 0)
    {
        return;
    }

    Weapons_SetStored(playerid,slot,s_ShopsGuns[gun][E_SHOPS_GUN_WEAPON],s_ShopsGuns[gun][E_SHOPS_GUN_AMMO_PRICE] == SHOPS_GUN_NO_AMMO_PRICE ? 1 : ammo);
}

static Shops_GunCharge(gun,ammo)
{
    new price = s_ShopsGunPrices[s_ShopsGuns[gun][E_SHOPS_GUN_PRICE]] / 100 * SHOPS_GUN_MOD, ammoPrice = s_ShopsGuns[gun][E_SHOPS_GUN_AMMO_PRICE];

    if (ammoPrice != SHOPS_GUN_NO_AMMO_PRICE)
    {
        price += s_ShopsGunPrices[ammoPrice] * ammo;
    }

    return price;
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
CMD:buygun(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (Account_GetCash(playerid) < 1)
    {
        SendClientMessage(playerid,COLOR_GREY,"   You don't have enough money with you !");
        return 1;
    }

    new location = Account_GetLocal(playerid), typedShop = Business_GetTypedAt(playerid,BUSINESS_TYPE_AMMUNATION);

    if (typedShop == BUSINESS_NO_KEY && location != SHOPS_GUN_LOCATION_A && location != SHOPS_GUN_LOCATION_B && location != SHOPS_GUN_LOCATION_ARMOURY)
    {
        SendClientMessage(playerid,COLOR_WHITE,"You are not in a store.");
        return 1;
    }

    new biz = typedShop != BUSINESS_NO_KEY ? typedShop : location - DOOR_LOCAL_BIZ_BASE;

    if (!Business_IsFreeStock(biz) && Business_GetProducts(biz) <= 0)
    {
        Property_GameText(playerid,"~r~Out Of Stock",5000,1);
        return 1;
    }

    new typed[32], ammoText[16];

    if (sscanf(params,"s[32]s[16]",typed,ammoText))
    {
        if (typed[0] == EOS)
        {
            Shops_ListGuns(playerid);
        }
        else
        {
            SendClientMessage(playerid,COLOR_GRAD2,"USAGE: /buygun [gunname] [ammoamount]");
        }

        return 1;
    }

    new ammo = strval(ammoText);

    if (ammo < SHOPS_GUN_AMMO_MIN || ammo > SHOPS_GUN_AMMO_MAX)
    {
        SendClientMessage(playerid,COLOR_GREY,"   Ammo amount not lower than 1 or higher than 999 !");
        return 1;
    }

    new gun = Shops_FindGun(typed);

    if (gun == -1)
    {
        SendClientMessage(playerid,COLOR_GRAD6,"ShopKeeper says: I have never heard of that weapon.");
        return 1;
    }

    new payout = Shops_GunCharge(gun,ammo), line[128];

    if (payout > Account_GetCash(playerid))
    {
        format(line,sizeof(line),"   You don't have $%d !",payout);
        SendClientMessage(playerid,COLOR_GRAD3,line);
        return 1;
    }

    Shops_StoreGun(playerid,gun,ammo);

    format(line,sizeof(line),"You have purchased %s with %d ammo for $%d",typed,ammo,payout);
    SendClientMessage(playerid,COLOR_GRAD3,line);

    if (!(location == SHOPS_GUN_LOCATION_ARMOURY && Factions_IsCop(playerid)))
    {
        Account_SetCash(playerid,Account_GetCash(playerid) - payout);
    }

    Business_Earn(biz,payout);
    Business_UseProduct(biz);
    PlayerPlaySound(playerid,SHOPS_SOUND_PAID,0.0,0.0,0.0);
    GivePlayerWeapon(playerid,WEAPON:s_ShopsGuns[gun][E_SHOPS_GUN_WEAPON],ammo);

    new name[BUSINESS_NAME_LEN];
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"%s bought weapons for $%d at biz %d",name,payout,biz);
    Economy_PayLog(line,true);
    return 1;
}
