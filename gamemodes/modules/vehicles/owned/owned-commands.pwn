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
#define VEHICLE_COLOR_PRICE (5000)
#define VEHICLE_UPGRADE_PRICE (100000)
#define VEHICLE_RESET_PRICE (100000)
#define VEHICLE_TOW_PRICE (1000)
#define VEHICLE_COLOR_MAX (126)
#define VEHICLE_GIVEKEY_RANGE (5.0)
#define VEHICLE_GIVEKEY_EMOTE_RANGE (30.0)
#define VEHICLE_UPGRADE_COUNT (22)
#define VEHICLE_UPGRADE_FIRST_FREE (6)
#define VEHICLE_SOUND_LOCK (1145)
#define VEHICLE_SOUND_PAID (1052)
#define VEHICLE_SOUND_PAINT (1134)
#define VEHICLE_UPGRADE_LEVEL (3)

static const s_UpgradeKey[VEHICLE_UPGRADE_COUNT][16] =
{
    "stretch", "hotknife", "bandito", "sultan", "elegy", "phoenix",
    "blistacompact", "clover", "elegant", "emperor", "glendale", "greenwood",
    "huntley", "jester", "landstalker", "merit", "nebula", "sabre",
    "stratum", "sunrise", "tahoma", "uranus"
};

static const s_UpgradeName[VEHICLE_UPGRADE_COUNT][16] =
{
    "Stretch", "Hotknife", "Bandito", "Sultan", "Elegy", "Phoenix",
    "Blista Compact", "Clover", "Elegant", "Emperor", "Glendale", "Greenwood",
    "Huntley", "Jester", "Landstalker", "Merit", "Nebula", "Sabre",
    "Stratum", "Sunrise", "Tahoma", "Uranus"
};

static const s_UpgradeModel[VEHICLE_UPGRADE_COUNT] =
{
    409, 434, 568, 560, 562, 603,
    496, 542, 507, 585, 466, 492,
    579, 559, 400, 551, 516, 475,
    561, 550, 566, 558
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
static bool:Vehicles_IsOwnerOf(playerid)
{
    return Vehicles_IsPlayerHouseOwner(playerid);
}

static Vehicles_Charge(playerid, amount)
{
    Account_SetCash(playerid, Account_GetCash(playerid) - amount);
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
CMD:carcolor(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Vehicles_IsOwnerOf(playerid))
    {
        SendClientMessage(playerid, COLOR_GRAD2, "   You don't own a house");
        return 1;
    }

    new first[32], second[32];

    if (sscanf(params, "s[32]S()[32]", first, second))
    {
        SendClientMessage(playerid, COLOR_GRAD3, "($5000) USAGE: /carcolor [color 1 - 2] [color number]");
        return 1;
    }

    new colornum = strval(first);

    if (colornum > 2 || colornum < 1)
    {
        SendClientMessage(playerid, COLOR_GRAD3, "Choices are 1 or 2");
        return 1;
    }

    if (second[0] == EOS)
    {
        SendClientMessage(playerid, COLOR_GRAD3, "($5000) USAGE: /carcolor [color 1 - 2] [color number]");
        return 1;
    }

    new color = strval(second);

    if (color > VEHICLE_COLOR_MAX)
    {
        SendClientMessage(playerid, COLOR_GRAD3, "Maximum is 126");
        return 1;
    }

    if (Account_GetCash(playerid) < VEHICLE_COLOR_PRICE)
    {
        SendClientMessage(playerid, COLOR_GRAD3, "You can't afford that ($5000)");
        return 1;
    }

    new houseid = Vehicles_GetPlayerHouse(playerid), color1, color2, line[64];
    Vehicles_GetRowColors(houseid + 1, color1, color2);

    if (colornum == 1)
    {
        Vehicles_SetHouseCarStyle(houseid, 0, color, color2);
        format(line, sizeof(line), "Car color 1 set to %d -$5000", color);
    }
    else
    {
        Vehicles_SetHouseCarStyle(houseid, 0, color1, color);
        format(line, sizeof(line), "Car color 2 set to %d -$5000", color);
    }

    SendClientMessage(playerid, COLOR_GRAD3, line);
    SendClientMessage(playerid, COLOR_GRAD6, "Your new paintjob will be complete within 24 hours");
    Vehicles_Charge(playerid, VEHICLE_COLOR_PRICE);
    PlayerPlaySound(playerid, VEHICLE_SOUND_PAINT, 0.0, 0.0, 0.0);
    Vehicles_SellFromShop(playerid, VEHICLE_SHOP_UPGRADE, VEHICLE_COLOR_PRICE, false);
    return 1;
}

CMD:carupgrade(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!Vehicles_IsOwnerOf(playerid))
    {
        SendClientMessage(playerid, COLOR_GRAD2, "   You don't own a house");
        return 1;
    }

    new name[32];

    if (sscanf(params, "s[32]", name))
    {
        SendClientMessage(playerid, COLOR_GREEN, "_______________________________________");
        SendClientMessage(playerid, COLOR_WHITE, "*** CAR UPGRADES Cost $100000 ***");
        SendClientMessage(playerid, COLOR_GRAD2, "USAGE: /carupgrade [carname]");

        if (Account_GetLevel(playerid) >= VEHICLE_UPGRADE_LEVEL)
        {
            SendClientMessage(playerid, COLOR_GRAD3, "Cars: blistacompact clover elegant emperor glendale greenwood");
            SendClientMessage(playerid, COLOR_GRAD3, "Cars: huntley jester landstalker merit nebula sabre stratum");
            SendClientMessage(playerid, COLOR_GRAD3, "Cars: sunrise tahoma uranus");
            SendClientMessage(playerid, COLOR_GRAD3, "Donation cars: stretch elegy phoenix hotknife bandito sultan");
        }

        SendClientMessage(playerid, COLOR_GREEN, "_______________________________________");
        return 1;
    }

    if (Vehicles_GetShopStock(VEHICLE_SHOP_UPGRADE) == 0)
    {
        GameTextForPlayer(playerid, "~r~Out Of Stock", 5000, 1);
        return 1;
    }

    if (Account_GetCash(playerid) < VEHICLE_UPGRADE_PRICE)
    {
        SendClientMessage(playerid, COLOR_GRAD2, "   You can't afford that ($100000)");
        return 1;
    }

    new length = strlen(name), pick = -1;

    for (new i = 0; i < VEHICLE_UPGRADE_COUNT; i++)
    {
        if (strcmp(name, s_UpgradeKey[i], true, length) == 0)
        {
            pick = i;
            break;
        }
    }

    if (pick == -1)
    {
        SendClientMessage(playerid, COLOR_GRAD6, "   Unrecognized Car or Donate Rank not High enough.");
        return 1;
    }

    if (pick < VEHICLE_UPGRADE_FIRST_FREE && Account_GetDonateRank(playerid) < 1)
    {
        SendClientMessage(playerid, COLOR_GREY, "   You don't have a Premium Account !");
        return 1;
    }

    new line[64];
    format(line, sizeof(line), "New Upgrade: Your House Car Is Now A %s", s_UpgradeName[pick]);
    SendClientMessage(playerid, COLOR_GRAD6, line);

    new houseid = Vehicles_GetPlayerHouse(playerid), color1, color2;
    Vehicles_GetRowColors(houseid + 1, color1, color2);
    Vehicles_SetHouseCarStyle(houseid, s_UpgradeModel[pick], color1, color2);

    SendClientMessage(playerid, COLOR_GRAD6, "Your new car will be delivered within 24 hours -$100000");
    Vehicles_Charge(playerid, VEHICLE_UPGRADE_PRICE);
    Vehicles_SellFromShop(playerid, VEHICLE_SHOP_UPGRADE, VEHICLE_UPGRADE_PRICE, true);
    PlayerPlaySound(playerid, VEHICLE_SOUND_PAID, 0.0, 0.0, 0.0);
    return 1;
}

CMD:resetupgrades(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (Account_GetCash(playerid) < VEHICLE_RESET_PRICE)
    {
        SendClientMessage(playerid, COLOR_GRAD1, "   Cost is $100000 !");
        return 1;
    }

    new level = Account_GetLevel(playerid);

    if (level < 2)
    {
        SendClientMessage(playerid, COLOR_GRAD1, "   You need to be at least level 2 !");
        return 1;
    }

    Progress_SetUpgradePoints(playerid, (level - 1) * 2);
    Progress_SetSpawnHealth(playerid, 0.0);

    for (new perk = 0; perk < PROGRESS_PERK_COUNT; perk++)
    {
        Progress_SetPerk(playerid, perk, 0);
    }

    Vehicles_Charge(playerid, VEHICLE_RESET_PRICE);
    PlayerPlaySound(playerid, VEHICLE_SOUND_PAID, 0.0, 0.0, 0.0);

    new line[64];
    format(line, sizeof(line), "   You have %d unspent Upgrade Points !", Progress_GetUpgradePoints(playerid));
    SendClientMessage(playerid, COLOR_GRAD2, line);
    return 1;
}

CMD:lock(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new team = Account_GetTeam(playerid), house = Vehicles_GetPlayerHouse(playerid), housecar = Vehicles_GetPlayerHouseCar(playerid);

    if (team == 2 || team == 1)
    {
        new lastcar = g_PlayerLastCar[playerid];

        if (lastcar == 0 && house == VEHICLE_NO_HOUSE)
        {
            SendClientMessage(playerid, COLOR_GRAD2, "   You don't have a Vehicle.");
            return 1;
        }
        else if (lastcar != 0 && lastcar != housecar)
        {
            if (g_PlayerHireCar[playerid] != lastcar && g_PlayerHireCar[playerid] != VEHICLE_NO_HIRE)
            {
                g_VehicleLastDriver[g_PlayerHireCar[playerid]] = VEHICLE_LAST_DRIVER_ABANDONED;
                Vehicles_ReleaseLock(g_PlayerHireCar[playerid]);
            }

            g_PlayerHireCar[playerid] = lastcar;
        }
    }

    if (house == VEHICLE_NO_HOUSE && g_PlayerHireCar[playerid] == VEHICLE_NO_HIRE)
    {
        SendClientMessage(playerid, COLOR_GRAD2, "   You don't have a Vehicle.");
        return 1;
    }

    new carid = housecar;

    if (g_PlayerHireCar[playerid] != VEHICLE_NO_HIRE && !g_PlayerSwitchKey[playerid])
    {
        carid = g_PlayerHireCar[playerid];
    }

    if (carid == 0)
    {
        SendClientMessage(playerid, COLOR_GRAD2, "   You don't have a Vehicle !");
        return 1;
    }

    new bool:hireKey = g_PlayerHireCar[playerid] == carid && !g_PlayerSwitchKey[playerid];
    new bool:houseKey = housecar != 0 && housecar == carid;

    if (!g_VehicleLocked[carid])
    {
        if (hireKey)
        {
            GameTextForPlayer(playerid, "~w~Hire Vehicle ~r~Locked", 5000, 6);
            PlayerPlaySound(playerid, VEHICLE_SOUND_LOCK, 0.0, 0.0, 0.0);
            g_VehicleLocked[carid] = true;
            Vehicles_LockCar(carid);
        }
        else if (houseKey)
        {
            GameTextForPlayer(playerid, "~w~House Vehicle ~r~Locked", 5000, 6);
            PlayerPlaySound(playerid, VEHICLE_SOUND_LOCK, 0.0, 0.0, 0.0);
            g_VehicleLocked[carid] = true;
            Vehicles_LockCar(carid);
        }
    }
    else
    {
        if (hireKey)
        {
            GameTextForPlayer(playerid, "~w~Hire Vehicle ~g~Unlocked", 5000, 6);
            PlayerPlaySound(playerid, VEHICLE_SOUND_LOCK, 0.0, 0.0, 0.0);
            Vehicles_ReleaseLock(carid);
        }

        if (houseKey)
        {
            GameTextForPlayer(playerid, "~w~House Vehicle ~g~Unlocked", 5000, 6);
            PlayerPlaySound(playerid, VEHICLE_SOUND_LOCK, 0.0, 0.0, 0.0);
            Vehicles_ReleaseLock(carid);
        }
    }

    return 1;
}

CMD:switchkey(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!g_PlayerSwitchKey[playerid])
    {
        if (g_PlayerHireCar[playerid] != VEHICLE_NO_HIRE)
        {
            g_PlayerSwitchKey[playerid] = true;
            GameTextForPlayer(playerid, "~w~You control now your house car", 5000, 6);
        }
        else
        {
            GameTextForPlayer(playerid, "~w~You do not hire a car", 5000, 6);
        }

        return 1;
    }

    g_PlayerSwitchKey[playerid] = false;
    GameTextForPlayer(playerid, "~w~You control now your hire car", 5000, 6);
    return 1;
}

CMD:givekey(cmdid, playerid, params[])
{
    #pragma unused cmdid

    new targetid;

    if (sscanf(params, "u", targetid))
    {
        SendClientMessage(playerid, COLOR_GRAD1, "USAGE: /givekey [playerid/PartOfName]");
        return 1;
    }

    new house = Vehicles_GetPlayerHouse(playerid), car;

    if (g_PlayerHireCar[playerid] == VEHICLE_NO_HIRE && house == VEHICLE_NO_HOUSE)
    {
        SendClientMessage(playerid, COLOR_GRAD1, "  You don't have a key to give");
        return 1;
    }

    new bool:givesHireKey = g_PlayerHireCar[playerid] != VEHICLE_NO_HIRE && !g_PlayerSwitchKey[playerid];

    if (givesHireKey)
    {
        car = g_PlayerHireCar[playerid];
    }
    else
    {
        car = Vehicles_GetPlayerHouseCar(playerid);
    }

    if (car == 0 || targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid) || !Util_IsNear(playerid, targetid, VEHICLE_GIVEKEY_RANGE))
    {
        return 1;
    }

    if (givesHireKey)
    {
        Vehicles_ReleaseLock(car);
        g_PlayerHireCar[playerid] = VEHICLE_NO_HIRE;
    }

    if (g_PlayerHireCar[targetid] != VEHICLE_NO_HIRE)
    {
        Vehicles_ReleaseLock(g_PlayerHireCar[targetid]);
    }

    g_PlayerHireCar[targetid] = car;

    new giver[MAX_PLAYER_NAME + 1], receiver[MAX_PLAYER_NAME + 1], line[128];
    GetPlayerName(playerid, giver, sizeof(giver));
    GetPlayerName(targetid, receiver, sizeof(receiver));
    format(line, sizeof(line), "   You have given %s the key to your vehicle", receiver);
    PlayerPlaySound(playerid, VEHICLE_SOUND_PAID, 0.0, 0.0, 0.0);
    SendClientMessage(playerid, COLOR_GRAD1, line);
    format(line, sizeof(line), "   You have received the key to a vehicle from %s", giver);
    SendClientMessage(targetid, COLOR_GRAD1, line);
    format(line, sizeof(line), "* %s takes out a set of keys, and tosses them to %s.", giver, receiver);
    Chat_ProxDetector(VEHICLE_GIVEKEY_EMOTE_RANGE, playerid, line, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
    return 1;
}

CMD:towcar(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Vehicles_IsOwnerOf(playerid))
    {
        GameTextForPlayer(playerid, "~w~You are not a home owner", 5000, 1);
        return 1;
    }

    if (Vehicles_GetShopStock(VEHICLE_SHOP_TOW) == 0)
    {
        GameTextForPlayer(playerid, "~r~Out Of Stock", 5000, 1);
        return 1;
    }

    if (Vehicles_Tow(Vehicles_GetPlayerHouseCar(playerid)))
    {
        GameTextForPlayer(playerid, "~w~Car~n~~g~Towed Home~n~~r~$-1000", 5000, 1);
        Vehicles_Charge(playerid, VEHICLE_TOW_PRICE);
        PlayerPlaySound(playerid, VEHICLE_SOUND_PAID, 0.0, 0.0, 0.0);
        Vehicles_SellFromShop(playerid, VEHICLE_SHOP_TOW, VEHICLE_TOW_PRICE, true);
    }
    else
    {
        GameTextForPlayer(playerid, "~w~Car is~n~in ~r~use", 5000, 1);
    }

    return 1;
}

CMD:fixcar(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (!Vehicles_IsOwnerOf(playerid))
    {
        GameTextForPlayer(playerid, "~w~You are not a home owner", 5000, 1);
        return 1;
    }

    if (Vehicles_GetShopStock(VEHICLE_SHOP_TOW) == 0)
    {
        GameTextForPlayer(playerid, "~r~Out Of Stock", 5000, 1);
        return 1;
    }

    if (Vehicles_Respawn(Vehicles_GetPlayerHouseCar(playerid)))
    {
        GameTextForPlayer(playerid, "~w~Car~n~~g~Repaired~n~~r~$-1000", 5000, 1);
        Vehicles_Charge(playerid, VEHICLE_TOW_PRICE);
        PlayerPlaySound(playerid, VEHICLE_SOUND_PAID, 0.0, 0.0, 0.0);
        Vehicles_SellFromShop(playerid, VEHICLE_SHOP_TOW, VEHICLE_TOW_PRICE, true);
    }
    else
    {
        GameTextForPlayer(playerid, "~w~Car is~n~in ~r~use", 5000, 1);
    }

    return 1;
}

CMD:oldcar(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new line[48];
    format(line, sizeof(line), "Your old car was: %d", g_PlayerLastCar[playerid]);
    SendClientMessage(playerid, COLOR_GREY, line);
    return 1;
}

CMD:callcar(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    if (g_PlayerBoughtCalls[playerid] <= 0)
    {
        SendClientMessage(playerid, COLOR_GREY, "   Invalid action !");
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    if (Util_IsValidVehicle(g_PlayerBoughtCar[playerid]))
    {
        SetVehiclePos(g_PlayerBoughtCar[playerid], x, y + 4, z);
    }

    SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Bought Car has arrived.");
    g_PlayerBoughtCalls[playerid]--;

    new line[64];
    format(line, sizeof(line), "* You can call your Bought Car for %d times more.", g_PlayerBoughtCalls[playerid]);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, line);
    return 1;
}

CMD:eject(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (!IsPlayerInAnyVehicle(playerid))
    {
        SendClientMessage(playerid, COLOR_GREY, "   You need to be in a Vehicle to use this !");
        return 1;
    }

    if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    {
        SendClientMessage(playerid, COLOR_GREY, "   You can only eject people as the driver !");
        return 1;
    }

    new targetid;

    if (sscanf(params, "u", targetid))
    {
        SendClientMessage(playerid, COLOR_GRAD2, "USAGE: /eject [playerid/PartOfName]");
        return 1;
    }

    if (targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid, COLOR_GREY, " Invalid ID/Name!");
        return 1;
    }

    if (targetid == playerid)
    {
        SendClientMessage(playerid, COLOR_GREY, "You cannot Eject yourself!");
        return 1;
    }

    if (!IsPlayerInVehicle(targetid, GetPlayerVehicleID(playerid)))
    {
        SendClientMessage(playerid, COLOR_GREY, "   That player is not in your Car !");
        return 1;
    }

    new name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], line[96];
    GetPlayerName(playerid, name, sizeof(name));
    GetPlayerName(targetid, targetName, sizeof(targetName));
    format(line, sizeof(line), "* You have thrown %s out of the car!", targetName);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, line);
    format(line, sizeof(line), "* You have been thrown out the car by %s !", name);
    SendClientMessage(targetid, COLOR_LIGHTBLUE, line);
    RemovePlayerFromVehicle(targetid);
    return 1;
}
