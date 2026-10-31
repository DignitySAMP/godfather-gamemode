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
CMD:rentcar(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new vehicleid = GetPlayerVehicleID(playerid), shop = Vehicles_GetRentalShop(vehicleid);

    if (shop < 0)
    {
        return 1;
    }

    if (Vehicles_GetShopStock(shop) == 0)
    {
        GameTextForPlayer(playerid, "~r~Out Of Stock", 5000, 1);
        return 1;
    }

    if (g_PlayerBossShop[playerid] == shop)
    {
        GameTextForPlayer(playerid, "~w~No charge for the boss", 5000, 3);
        g_PlayerRentalFrozen[playerid] = false;
        TogglePlayerControllable(playerid, true);
        return 1;
    }

    new price = Vehicles_GetShopPrice(shop);

    if (Account_GetCash(playerid) < price)
    {
        SendClientMessage(playerid, COLOR_GRAD2, "   You don't have that much cash !");
        return 1;
    }

    Account_SetCash(playerid, Account_GetCash(playerid) - price);
    Vehicles_SellFromShop(playerid, shop, price, true);

    new key = Vehicles_GetHireCar(playerid);

    if (key != VEHICLE_NO_HIRE)
    {
        Vehicles_ReleaseLock(key);
    }

    Vehicles_SetHireCar(playerid, vehicleid);
    PlayerPlaySound(playerid, RENTAL_SOUND_PAID, 0.0, 0.0, 0.0);
    g_PlayerRentalFrozen[playerid] = false;
    TogglePlayerControllable(playerid, true);
    GameTextForPlayer(playerid, "~w~We hope you enjoy ~n~the use of this car~n~To lock or unlock your car~n~type ~g~/lock~n~~w~please drive safely", 5000, 3);
    return 1;
}

CMD:hirecar(cmdid, playerid, params[])
{
    #pragma unused cmdid

    if (Account_GetAdminLevel(playerid) < ADMIN_LEVEL_DEVELOPER)
    {
        return 1;
    }

    new car;

    if (sscanf(params, "i", car))
    {
        SendClientMessage(playerid, COLOR_GRAD1, "USAGE: /hirecar [key id]");
        return 1;
    }

    if (car < 0 || car > MAX_VEHICLES)
    {
        return 1;
    }

    Vehicles_SetHireCar(playerid, car);

    new line[64];
    format(line, sizeof(line), "Key Fashioned You Can Lock Car %d.", car);
    SendClientMessage(playerid, COLOR_GRAD4, line);
    SendClientMessage(playerid, COLOR_WHITE, "HINT: Type /lock ");
    return 1;
}

CMD:unrentcar(cmdid, playerid, params[])
{
    #pragma unused cmdid, params

    new key = Vehicles_GetHireCar(playerid);

    if (key != VEHICLE_NO_HIRE)
    {
        Vehicles_ReleaseLock(key);
        Vehicles_ClearHireCar(playerid);
        GameTextForPlayer(playerid, "~w~You no longer rent a car", 5000, 3);
    }

    return 1;
}
