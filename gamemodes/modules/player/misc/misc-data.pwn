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
#define MISC_DICE_RANGE (5.0)
#define MISC_NEAR_RANGE (8.0)
#define MISC_UNCON_X (-1863.15)
#define MISC_UNCON_Y (-21.6598)
#define MISC_UNCON_Z (1060.15)
#define MISC_UNCON_INTERIOR (14)
#define MISC_SOUND_MUSIC_START (1068)
#define MISC_SOUND_MUSIC_STOP (1069)
#define MISC_RADIO_FIX_MS (1000)
#define MISC_MUSIC_MS (5000)

static bool:s_MiscHasDice[MAX_PLAYERS];
static s_MiscCam[MAX_PLAYERS];

forward Misc_FixRadioStop(playerid);
forward Misc_StopMusic();

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
stock Misc_SetHasDice(playerid,bool:hasDice)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    s_MiscHasDice[playerid] = hasDice;
}

stock bool:Misc_HasDice(playerid)
{
    return Util_IsValidPlayer(playerid) && s_MiscHasDice[playerid];
}

stock Misc_SetCam(playerid,cam)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    s_MiscCam[playerid] = cam;
}

stock Misc_GetCam(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return 0;
    }

    return s_MiscCam[playerid];
}

stock Misc_FixRadio(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    PlayerPlaySound(playerid,MISC_SOUND_MUSIC_START,0.0,0.0,0.0);
    SetTimerEx("Misc_FixRadioStop",MISC_RADIO_FIX_MS,false,"d",playerid);
}

stock Misc_PlayMusic(playerid)
{
    if (!Util_IsValidPlayer(playerid))
    {
        return;
    }

    SetTimer("Misc_StopMusic",MISC_MUSIC_MS,false);
    PlayerPlaySound(playerid,MISC_SOUND_MUSIC_START,0.0,0.0,0.0);
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
public Misc_FixRadioStop(playerid)
{
    if (IsPlayerConnected(playerid))
    {
        PlayerPlaySound(playerid,MISC_SOUND_MUSIC_STOP,0.0,0.0,0.0);
    }

    return 1;
}

public Misc_StopMusic()
{
    foreach (new i : Player)
    {
        PlayerPlaySound(i,MISC_SOUND_MUSIC_STOP,0.0,0.0,0.0);
    }

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

hook OnPlayerConnect(playerid)
{
    s_MiscHasDice[playerid] = false;
    s_MiscCam[playerid] = 0;
}

hook OnPlayerSpawn(playerid)
{
    if (IsPlayerNPC(playerid) || !Player_IsReady(playerid))
    {
        return;
    }

    Misc_FixRadio(playerid);
}
