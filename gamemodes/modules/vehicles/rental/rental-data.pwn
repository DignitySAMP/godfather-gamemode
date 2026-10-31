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
#define RENTAL_SOUND_PAID (1052)

new g_PlayerBossShop[MAX_PLAYERS];
new bool:g_PlayerRentalFrozen[MAX_PLAYERS];

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

stock Rental_SetBossShop(playerid, shop)
{
    if (Util_IsValidPlayer(playerid))
    {
        g_PlayerBossShop[playerid] = shop;
    }
}

stock bool:Rental_IsFrozen(playerid)
{
    return Util_IsValidPlayer(playerid) && g_PlayerRentalFrozen[playerid];
}

stock Rental_Unfreeze(playerid)
{
    if (Util_IsValidPlayer(playerid) && g_PlayerRentalFrozen[playerid])
    {
        g_PlayerRentalFrozen[playerid] = false;
        TogglePlayerControllable(playerid, true);
    }
}

stock Rental_OfferCar(playerid, vehicleid)
{
    new shop = Vehicles_GetRentalShop(vehicleid);

    if (shop < 0 || Vehicles_GetHireCar(playerid) == vehicleid)
    {
        return;
    }

    new text[160];
    format(text, sizeof(text), "~w~You can Rent this car~n~Cost:~g~$%d~n~~w~To rent type ~g~/rentcar~w~~n~to get out type ~r~/exit", Vehicles_GetShopPrice(shop));
    g_PlayerRentalFrozen[playerid] = true;
    TogglePlayerControllable(playerid, false);
    GameTextForPlayer(playerid, text, 5000, 3);
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
    g_PlayerBossShop[playerid] = -1;
    g_PlayerRentalFrozen[playerid] = false;
}

hook Stats_OnBuild(playerid,targetid)
{
    if (Vehicles_GetHireCar(targetid) != VEHICLE_NO_HIRE)
    {
        Stats_SetNumber("HireKey",Vehicles_GetHireCar(targetid));
    }
}

hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    if (newstate == PLAYER_STATE_DRIVER)
    {
        Rental_OfferCar(playerid, GetPlayerVehicleID(playerid));
    }
}
