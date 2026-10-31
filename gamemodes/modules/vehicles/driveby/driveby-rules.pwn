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
#define DRIVEBY_WEAPON_DEAGLE (24)
#define DRIVEBY_WEAPON_SAWNOFF (26)

static bool:s_DriveByTold[MAX_PLAYERS];
static s_DriveByBlocked[MAX_PLAYERS];

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

bool:DriveBy_AllowShot(playerid, weaponid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || IsPlayerNPC(playerid))
    {
        return true;
    }

    new PLAYER_STATE:seat = GetPlayerState(playerid);

    if (seat == PLAYER_STATE_DRIVER)
    {
        DriveBy_Refuse(playerid, "   You can't do a drive-by while driving !");
        return false;
    }

    if (seat == PLAYER_STATE_PASSENGER && (weaponid == DRIVEBY_WEAPON_DEAGLE || weaponid == DRIVEBY_WEAPON_SAWNOFF))
    {
        DriveBy_Refuse(playerid, "   You can't do a drive-by with that weapon !");
        return false;
    }

    return true;
}

static DriveBy_Refuse(playerid, const text[])
{
    s_DriveByBlocked[playerid]++;
    SetPlayerArmedWeapon(playerid, WEAPON:0);

    if (s_DriveByTold[playerid])
    {
        return;
    }

    s_DriveByTold[playerid] = true;
    SendClientMessage(playerid, COLOR_GREY, text);
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
    s_DriveByTold[playerid] = false;
    s_DriveByBlocked[playerid] = 0;
}

hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    if (newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
    {
        s_DriveByTold[playerid] = false;
    }
}
