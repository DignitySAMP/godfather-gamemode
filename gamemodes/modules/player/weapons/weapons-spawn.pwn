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
#define WEAPONS_BAT_ID (5)
#define WEAPONS_BAT_AMMO (0)
#define WEAPONS_BAT_MIN_TEAM (3)
#define WEAPONS_DONOR_SLOTS (4)
#define WEAPONS_PLAIN_SLOTS (2)
#define WEAPONS_BLOCK_LEN (32)

static s_WeaponsBlockCheck[WEAPONS_BLOCK_LEN];

forward Weapons_OnGive(playerid);

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
stock bool:Weapons_SetBlockCheck(const callback[])
{
    strcopy(s_WeaponsBlockCheck,callback,WEAPONS_BLOCK_LEN);
    return true;
}

stock bool:Weapons_IsBlocked(playerid)
{
    if (s_WeaponsBlockCheck[0] == EOS)
    {
        return false;
    }

    return CallLocalFunction(s_WeaponsBlockCheck,"d",playerid) != 0;
}

stock Weapons_Apply(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    ResetPlayerWeapons(playerid);

    if (Weapons_IsBlocked(playerid))
    {
        return;
    }

    pawn_call_public("Weapons_OnGive","d",playerid);

    if (Account_GetTeam(playerid) >= WEAPONS_BAT_MIN_TEAM)
    {
        GivePlayerWeapon(playerid,WEAPON:WEAPONS_BAT_ID,WEAPONS_BAT_AMMO);
    }

    new slots = Account_GetDonateRank(playerid) > 0 ? WEAPONS_DONOR_SLOTS : WEAPONS_PLAIN_SLOTS;

    for (new slot = 1;slot <= slots;slot++)
    {
        new weaponid = Weapons_GetStoredId(playerid,slot);

        if (weaponid > 0)
        {
            GivePlayerWeapon(playerid,WEAPON:weaponid,Weapons_GetStoredAmmo(playerid,slot));
            Weapons_SetStored(playerid,slot,0,0);
        }
    }
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
public Weapons_OnGive(playerid)
{
    return 1;
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

hook OnPlayerSpawn(playerid)
{
    if (IsPlayerNPC(playerid) || !Player_IsReady(playerid))
    {
        return;
    }

    Weapons_Apply(playerid);
}
